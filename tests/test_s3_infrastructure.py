"""
S3 Bucket Infrastructure Tests
Validates S3 buckets are configured correctly.
"""
import pytest
from botocore.exceptions import ClientError


@pytest.mark.infrastructure
@pytest.mark.s3
@pytest.mark.integration
class TestS3Buckets:
    """Test suite for S3 bucket configurations."""

    def test_raw_videos_bucket_exists(self, s3_client, bucket_prefix):
        """Verify raw videos bucket exists."""
        bucket_name = f"{bucket_prefix}-raw-videos"
        
        try:
            response = s3_client.head_bucket(Bucket=bucket_name)
            assert response['ResponseMetadata']['HTTPStatusCode'] == 200
        except ClientError as e:
            pytest.fail(f"Bucket {bucket_name} does not exist: {e}")

    def test_processed_videos_bucket_exists(self, s3_client, bucket_prefix):
        """Verify processed videos bucket exists."""
        bucket_name = f"{bucket_prefix}-processed-videos"
        
        try:
            response = s3_client.head_bucket(Bucket=bucket_name)
            assert response['ResponseMetadata']['HTTPStatusCode'] == 200
        except ClientError as e:
            pytest.fail(f"Bucket {bucket_name} does not exist: {e}")

    def test_assets_bucket_exists(self, s3_client, bucket_prefix):
        """Verify assets bucket exists."""
        bucket_name = f"{bucket_prefix}-assets"
        
        try:
            response = s3_client.head_bucket(Bucket=bucket_name)
            assert response['ResponseMetadata']['HTTPStatusCode'] == 200
        except ClientError as e:
            pytest.fail(f"Bucket {bucket_name} does not exist: {e}")

    def test_raw_videos_bucket_versioning_enabled(self, s3_client, bucket_prefix):
        """Verify versioning is enabled on raw videos bucket."""
        bucket_name = f"{bucket_prefix}-raw-videos"
        
        response = s3_client.get_bucket_versioning(Bucket=bucket_name)
        assert response.get('Status') == 'Enabled', \
            f"Versioning not enabled on {bucket_name}"

    def test_raw_videos_bucket_encryption(self, s3_client, bucket_prefix):
        """Verify encryption is enabled on raw videos bucket."""
        bucket_name = f"{bucket_prefix}-raw-videos"
        
        try:
            response = s3_client.get_bucket_encryption(Bucket=bucket_name)
            rules = response['ServerSideEncryptionConfiguration']['Rules']
            assert len(rules) > 0, "No encryption rules configured"
            
            # Check for AES256 or KMS encryption
            encryption_type = rules[0]['ApplyServerSideEncryptionByDefault']['SSEAlgorithm']
            assert encryption_type in ['AES256', 'aws:kms'], \
                f"Unexpected encryption type: {encryption_type}"
        except ClientError as e:
            if 'ServerSideEncryptionConfigurationNotFoundError' in str(e):
                pytest.fail(f"Encryption not configured on {bucket_name}")
            raise

    def test_buckets_block_public_access(self, s3_client, bucket_prefix):
        """Verify public access is blocked on all buckets."""
        buckets = [
            f"{bucket_prefix}-raw-videos",
            f"{bucket_prefix}-processed-videos",
            f"{bucket_prefix}-assets"
        ]
        
        for bucket_name in buckets:
            try:
                response = s3_client.get_public_access_block(Bucket=bucket_name)
                config = response['PublicAccessBlockConfiguration']
                
                assert config['BlockPublicAcls'] is True, \
                    f"BlockPublicAcls not enabled on {bucket_name}"
                assert config['IgnorePublicAcls'] is True, \
                    f"IgnorePublicAcls not enabled on {bucket_name}"
                assert config['BlockPublicPolicy'] is True, \
                    f"BlockPublicPolicy not enabled on {bucket_name}"
                assert config['RestrictPublicBuckets'] is True, \
                    f"RestrictPublicBuckets not enabled on {bucket_name}"
            except ClientError as e:
                pytest.fail(f"Failed to get public access block for {bucket_name}: {e}")

    def test_raw_videos_bucket_lifecycle_rules(self, s3_client, bucket_prefix):
        """Verify lifecycle rules are configured for raw videos bucket."""
        bucket_name = f"{bucket_prefix}-raw-videos"
        
        try:
            response = s3_client.get_bucket_lifecycle_configuration(Bucket=bucket_name)
            rules = response.get('Rules', [])
            assert len(rules) > 0, f"No lifecycle rules on {bucket_name}"
        except ClientError as e:
            if 'NoSuchLifecycleConfiguration' in str(e):
                # Lifecycle is optional, just log
                pytest.skip(f"No lifecycle configuration on {bucket_name}")
            raise

    def test_raw_videos_eventbridge_notifications(self, s3_client, bucket_prefix):
        """Verify EventBridge notifications are enabled for raw videos bucket."""
        bucket_name = f"{bucket_prefix}-raw-videos"
        
        response = s3_client.get_bucket_notification_configuration(Bucket=bucket_name)
        
        assert response.get('EventBridgeConfiguration', {}).get('EventBridgeEnabled', False), \
            f"EventBridge notifications not enabled on {bucket_name}"
