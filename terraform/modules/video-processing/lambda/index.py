"""
Lambda Function: Video Processor
Triggers MediaConvert jobs to transcode videos to HLS + MP4 formats

Called by: Step Functions
Flow: SQS → EventBridge Pipes → Step Functions → This Lambda → MediaConvert
"""

import boto3
import json
import os
from urllib.parse import unquote_plus


def get_mediaconvert_endpoint():
    """Get the MediaConvert endpoint for the region."""
    client = boto3.client('mediaconvert', region_name=os.environ.get('AWS_REGION_NAME', 'sa-east-1'))
    response = client.describe_endpoints()
    return response['Endpoints'][0]['Url']


def create_hls_output(width, height, bitrate):
    """Create HLS output configuration for a specific resolution."""
    return {
        "VideoDescription": {
            "Width": width,
            "Height": height,
            "CodecSettings": {
                "Codec": "H_264",
                "H264Settings": {
                    "Bitrate": bitrate,
                    "RateControlMode": "CBR",
                    "QualityTuningLevel": "SINGLE_PASS_HQ",
                    "CodecProfile": "HIGH",
                    "CodecLevel": "AUTO"
                }
            }
        },
        "AudioDescriptions": [{
            "CodecSettings": {
                "Codec": "AAC",
                "AacSettings": {
                    "Bitrate": 128000,
                    "CodingMode": "CODING_MODE_2_0",
                    "SampleRate": 48000
                }
            }
        }],
        "ContainerSettings": {
            "Container": "M3U8",
            "M3u8Settings": {}
        },
        "NameModifier": f"_{height}p"
    }


def handler(event, context):
    """
    Process video and create MediaConvert job.
    
    Called by Step Functions with payload:
    - bucket: S3 bucket name
    - key: S3 object key (video file path)
    """
    print(f"Received event: {json.dumps(event)}")
    
    # Get MediaConvert client with custom endpoint
    endpoint_url = get_mediaconvert_endpoint()
    mediaconvert = boto3.client('mediaconvert', endpoint_url=endpoint_url)
    
    output_bucket = os.environ['OUTPUT_BUCKET']
    mediaconvert_role = os.environ['MEDIACONVERT_ROLE']
    environment = os.environ.get('ENVIRONMENT', 'dev')
    
    # Get bucket and key from event (called by Step Functions)
    bucket = event.get('bucket')
    key = event.get('key')
    
    if not bucket or not key:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing bucket or key in event'})
        }
    
    key = unquote_plus(key)
    print(f"Processing video: s3://{bucket}/{key}")
    
    # Generate output path based on input
    # Input: videos/course-1/lesson-1.mp4
    # Output: videos/course-1/lesson-1/hls/, /mp4/, /thumb/
    output_key = key.rsplit('.', 1)[0]  # Remove extension
    
    job_settings = {
        "Inputs": [{
            "FileInput": f"s3://{bucket}/{key}",
            "AudioSelectors": {
                "Audio Selector 1": {
                    "DefaultSelection": "DEFAULT"
                }
            },
            "VideoSelector": {},
            "TimecodeSource": "ZEROBASED"
        }],
        "OutputGroups": [
            # HLS Output Group (Adaptive Streaming)
            {
                "Name": "HLS Group",
                "OutputGroupSettings": {
                    "Type": "HLS_GROUP_SETTINGS",
                    "HlsGroupSettings": {
                        "Destination": f"s3://{output_bucket}/{output_key}/hls/",
                        "SegmentLength": 10,
                        "MinSegmentLength": 0,
                        "SegmentControl": "SEGMENTED_FILES",
                        "ManifestDurationFormat": "INTEGER",
                        "OutputSelection": "MANIFESTS_AND_SEGMENTS"
                    }
                },
                "Outputs": [
                    create_hls_output(1920, 1080, 5000000),  # 1080p - 5 Mbps
                    create_hls_output(1280, 720, 2500000),   # 720p  - 2.5 Mbps
                    create_hls_output(854, 480, 1000000),    # 480p  - 1 Mbps
                    create_hls_output(640, 360, 600000),     # 360p  - 600 Kbps
                ]
            },
            # MP4 Output (Download)
            {
                "Name": "MP4 Download",
                "OutputGroupSettings": {
                    "Type": "FILE_GROUP_SETTINGS",
                    "FileGroupSettings": {
                        "Destination": f"s3://{output_bucket}/{output_key}/mp4/"
                    }
                },
                "Outputs": [{
                    "VideoDescription": {
                        "Width": 1280,
                        "Height": 720,
                        "CodecSettings": {
                            "Codec": "H_264",
                            "H264Settings": {
                                "Bitrate": 2500000,
                                "RateControlMode": "CBR",
                                "QualityTuningLevel": "SINGLE_PASS_HQ"
                            }
                        }
                    },
                    "AudioDescriptions": [{
                        "CodecSettings": {
                            "Codec": "AAC",
                            "AacSettings": {
                                "Bitrate": 128000,
                                "CodingMode": "CODING_MODE_2_0",
                                "SampleRate": 48000
                            }
                        }
                    }],
                    "ContainerSettings": {
                        "Container": "MP4",
                        "Mp4Settings": {}
                    },
                    "NameModifier": "_720p"
                }]
            },
            # Thumbnail Output
            {
                "Name": "Thumbnails",
                "OutputGroupSettings": {
                    "Type": "FILE_GROUP_SETTINGS",
                    "FileGroupSettings": {
                        "Destination": f"s3://{output_bucket}/{output_key}/thumb/"
                    }
                },
                "Outputs": [{
                    "VideoDescription": {
                        "Width": 1280,
                        "Height": 720,
                        "CodecSettings": {
                            "Codec": "FRAME_CAPTURE",
                            "FrameCaptureSettings": {
                                "FramerateNumerator": 1,
                                "FramerateDenominator": 30,
                                "MaxCaptures": 5,
                                "Quality": 80
                            }
                        }
                    },
                    "ContainerSettings": {
                        "Container": "RAW"
                    },
                    "NameModifier": "_thumb"
                }]
            }
        ]
    }
    
    # Create MediaConvert job
    response = mediaconvert.create_job(
        Role=mediaconvert_role,
        Settings=job_settings,
        UserMetadata={
            'originalBucket': bucket,
            'originalKey': key,
            'environment': environment,
            'outputBucket': output_bucket,
            'outputPath': output_key
        },
        Tags={
            'Project': 'uniplus-platform',
            'Environment': environment,
            'Type': 'video-processing'
        }
    )
    
    job_id = response['Job']['Id']
    print(f"Created MediaConvert job: {job_id}")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'MediaConvert job created',
            'jobId': job_id,
            'inputKey': key,
            'outputPath': output_key
        })
    }
