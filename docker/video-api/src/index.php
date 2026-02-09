<?php
/**
 * Video API - UniPlus
 * 
 * Endpoints:
 * GET  /api/videos         - Lista vídeos (do S3 processed bucket)
 * GET  /api/videos/{id}    - Detalhes do vídeo
 * POST /api/videos/upload  - Gera presigned URL para upload direto no S3
 * GET  /api/videos/{id}/status - Status do processamento
 * GET  /health             - Health check
 */

require_once __DIR__ . '/../vendor/autoload.php';

use Aws\S3\S3Client;
use Aws\Exception\AwsException;

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Environment variables (set via Terraform ECS task definition)
$rawBucket       = getenv('RAW_BUCKET') ?: '';
$processedBucket = getenv('PROCESSED_BUCKET') ?: '';
$awsRegion       = getenv('AWS_REGION') ?: getenv('AWS_DEFAULT_REGION') ?: 'sa-east-1';
$environment     = getenv('ENVIRONMENT') ?: 'dev';

// Initialize S3 client (uses ECS Task Role credentials automatically)
function getS3Client(): S3Client {
    global $awsRegion;
    static $client = null;
    if ($client === null) {
        $client = new S3Client([
            'region'  => $awsRegion,
            'version' => 'latest',
        ]);
    }
    return $client;
}

// Simple router
$requestUri    = $_SERVER['REQUEST_URI'];
$requestMethod = $_SERVER['REQUEST_METHOD'];
$path          = parse_url($requestUri, PHP_URL_PATH);
$path          = str_replace('/api/videos', '', $path);

// Routes
switch (true) {
    // Health check
    case $path === '/health' || $requestUri === '/health':
        http_response_code(200);
        echo json_encode([
            'status'    => 'healthy',
            'service'   => 'video-api',
            'timestamp' => date('c'),
            'version'   => '2.0.0',
            'aws'       => [
                'raw_bucket'       => $rawBucket ? '✅ configured' : '❌ missing',
                'processed_bucket' => $processedBucket ? '✅ configured' : '❌ missing',
            ],
        ]);
        break;

    // List videos from S3 processed bucket
    case $path === '' || $path === '/':
        if ($requestMethod === 'GET') {
            try {
                $videos = listProcessedVideos();
                echo json_encode([
                    'success' => true,
                    'data'    => $videos,
                    'pagination' => [
                        'total' => count($videos),
                    ],
                ]);
            } catch (Exception $e) {
                http_response_code(500);
                echo json_encode([
                    'success' => false,
                    'error'   => 'Failed to list videos: ' . $e->getMessage(),
                ]);
            }
        }
        break;

    // Generate presigned URL for upload
    case $path === '/upload':
        if ($requestMethod === 'POST') {
            handleUpload();
        } else {
            http_response_code(405);
            echo json_encode(['error' => 'Method not allowed']);
        }
        break;

    // Get video details by ID
    case preg_match('/^\/(vid_[a-zA-Z0-9_-]+)$/', $path, $matches):
        $videoId = $matches[1];
        handleVideoDetails($videoId);
        break;

    // Processing status
    case preg_match('/^\/(vid_[a-zA-Z0-9_-]+)\/status$/', $path, $matches):
        $videoId = $matches[1];
        handleVideoStatus($videoId);
        break;

    // 404
    default:
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'error'   => 'Endpoint not found',
            'available_endpoints' => [
                'GET /api/videos'            => 'List processed videos',
                'POST /api/videos/upload'    => 'Get presigned upload URL',
                'GET /api/videos/{id}'       => 'Get video details',
                'GET /api/videos/{id}/status' => 'Get processing status',
                'GET /health'                => 'Health check',
            ],
        ]);
}

// ===== Handler Functions =====

/**
 * Generate S3 presigned URL for direct browser upload
 */
function handleUpload(): void {
    global $rawBucket, $awsRegion;

    $input = json_decode(file_get_contents('php://input'), true);

    $filename    = $input['filename'] ?? 'video.mp4';
    $contentType = $input['content_type'] ?? 'video/mp4';
    $title       = $input['title'] ?? pathinfo($filename, PATHINFO_FILENAME);
    $discipline  = $input['discipline'] ?? '';
    $turma       = $input['turma'] ?? '';

    // Validate file extension
    $allowedExtensions = ['mp4', 'mov', 'avi', 'mkv'];
    $extension = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
    if (!in_array($extension, $allowedExtensions)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'error'   => "Formato não suportado: .$extension. Use: " . implode(', ', $allowedExtensions),
        ]);
        return;
    }

    // Check if bucket is configured
    if (empty($rawBucket)) {
        http_response_code(503);
        echo json_encode([
            'success' => false,
            'error'   => 'Storage not configured. RAW_BUCKET env var missing.',
        ]);
        return;
    }

    // Generate unique video ID and S3 key
    $videoId = 'vid_' . bin2hex(random_bytes(6));
    $timestamp = date('Y/m/d');
    $safeFilename = preg_replace('/[^a-zA-Z0-9._-]/', '_', $filename);
    $s3Key = "videos/{$timestamp}/{$videoId}/{$safeFilename}";

    try {
        $s3 = getS3Client();

        // Create presigned PUT URL (valid for 60 minutes)
        $cmd = $s3->getCommand('PutObject', [
            'Bucket'      => $rawBucket,
            'Key'         => $s3Key,
            'ContentType' => $contentType,
            'Metadata'    => [
                'video-id'   => $videoId,
                'title'      => substr($title, 0, 256),
                'discipline' => substr($discipline, 0, 128),
                'turma'      => substr($turma, 0, 64),
                'uploaded-by' => 'portal-professor',
            ],
        ]);

        $presignedRequest = $s3->createPresignedRequest($cmd, '+60 minutes');
        $presignedUrl = (string) $presignedRequest->getUri();

        echo json_encode([
            'success' => true,
            'data'    => [
                'video_id'      => $videoId,
                'upload_url'    => $presignedUrl,
                'upload_method' => 'PUT',
                'content_type'  => $contentType,
                's3_key'        => $s3Key,
                'bucket'        => $rawBucket,
                'expires_in'    => 3600,
                'max_size'      => '5GB',
                'headers'       => [
                    'Content-Type'              => $contentType,
                    'x-amz-meta-video-id'       => $videoId,
                    'x-amz-meta-title'          => $title,
                    'x-amz-meta-discipline'     => $discipline,
                    'x-amz-meta-uploaded-by'    => 'portal-professor',
                ],
            ],
        ]);
    } catch (AwsException $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'error'   => 'Failed to generate upload URL: ' . $e->getAwsErrorMessage(),
        ]);
    }
}

/**
 * List processed videos from S3
 */
function listProcessedVideos(): array {
    global $processedBucket;

    if (empty($processedBucket)) {
        return [];
    }

    $s3 = getS3Client();
    $videos = [];

    try {
        // List "directories" under videos/ prefix (each video has its own folder)
        $result = $s3->listObjectsV2([
            'Bucket'    => $processedBucket,
            'Prefix'    => 'videos/',
            'Delimiter' => '/',
            'MaxKeys'   => 100,
        ]);

        // Also check for HLS manifests to find processed videos
        $hlsResult = $s3->listObjectsV2([
            'Bucket'  => $processedBucket,
            'Prefix'  => 'videos/',
            'MaxKeys' => 500,
        ]);

        $videoFolders = [];
        foreach ($hlsResult->get('Contents') ?? [] as $object) {
            $key = $object['Key'];
            // Look for HLS manifests as indicator of completed processing
            if (str_ends_with($key, '.m3u8') || str_ends_with($key, '_720p.mp4')) {
                // Extract video folder path: videos/2026/02/09/vid_xxx/hls/xxx.m3u8
                $parts = explode('/', $key);
                // Find vid_ part
                foreach ($parts as $i => $part) {
                    if (str_starts_with($part, 'vid_')) {
                        $videoId = $part;
                        $basePath = implode('/', array_slice($parts, 0, $i + 1));
                        if (!isset($videoFolders[$videoId])) {
                            $videoFolders[$videoId] = [
                                'id'        => $videoId,
                                'base_path' => $basePath,
                                'hls_url'   => null,
                                'mp4_url'   => null,
                                'thumbnail' => null,
                                'created_at' => $object['LastModified']->format('c'),
                            ];
                        }
                        // Categorize files
                        if (str_ends_with($key, '.m3u8') && !str_contains($key, '_')) {
                            $videoFolders[$videoId]['hls_url'] = $key;
                        }
                        if (str_ends_with($key, '_720p.mp4')) {
                            $videoFolders[$videoId]['mp4_url'] = $key;
                        }
                        if (str_contains($key, 'thumb')) {
                            $videoFolders[$videoId]['thumbnail'] = $key;
                        }
                        break;
                    }
                }
            }
        }

        foreach ($videoFolders as $video) {
            $videos[] = [
                'id'         => $video['id'],
                'title'      => $video['id'], // Could be enhanced with metadata DB
                'status'     => 'published',
                'hls_url'    => $video['hls_url'],
                'mp4_url'    => $video['mp4_url'],
                'thumbnail'  => $video['thumbnail'],
                'created_at' => $video['created_at'],
            ];
        }
    } catch (AwsException $e) {
        error_log('Failed to list videos: ' . $e->getMessage());
    }

    return $videos;
}

/**
 * Get video details
 */
function handleVideoDetails(string $videoId): void {
    global $processedBucket, $rawBucket;

    $s3 = getS3Client();
    $details = ['id' => $videoId, 'status' => 'unknown'];

    try {
        // Check processed bucket for outputs
        $processed = $s3->listObjectsV2([
            'Bucket'  => $processedBucket ?: 'dummy',
            'Prefix'  => "videos/",
            'MaxKeys' => 100,
        ]);

        $outputs = [];
        foreach ($processed->get('Contents') ?? [] as $obj) {
            if (str_contains($obj['Key'], $videoId)) {
                $outputs[] = [
                    'key'  => $obj['Key'],
                    'size' => $obj['Size'],
                    'last_modified' => $obj['LastModified']->format('c'),
                ];
            }
        }

        if (!empty($outputs)) {
            $details['status']  = 'published';
            $details['outputs'] = $outputs;
        } else {
            // Check raw bucket
            $raw = $s3->listObjectsV2([
                'Bucket'  => $rawBucket ?: 'dummy',
                'Prefix'  => "videos/",
                'MaxKeys' => 50,
            ]);
            foreach ($raw->get('Contents') ?? [] as $obj) {
                if (str_contains($obj['Key'], $videoId)) {
                    $details['status'] = 'processing';
                    $details['raw_file'] = $obj['Key'];
                    break;
                }
            }
        }

        echo json_encode(['success' => true, 'data' => $details]);
    } catch (AwsException $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'error'   => 'Failed to get video details: ' . $e->getAwsErrorMessage(),
        ]);
    }
}

/**
 * Get video processing status
 */
function handleVideoStatus(string $videoId): void {
    global $processedBucket, $rawBucket;

    $s3 = getS3Client();

    $steps = [
        ['name' => 'upload',      'status' => 'pending'],
        ['name' => 'validation',  'status' => 'pending'],
        ['name' => 'transcoding', 'status' => 'pending'],
        ['name' => 'thumbnail',   'status' => 'pending'],
        ['name' => 'publishing',  'status' => 'pending'],
    ];

    $overallStatus = 'unknown';

    try {
        // Check raw bucket (upload completed?)
        $hasRaw = false;
        if ($rawBucket) {
            $raw = $s3->listObjectsV2([
                'Bucket'  => $rawBucket,
                'Prefix'  => "videos/",
                'MaxKeys' => 50,
            ]);
            foreach ($raw->get('Contents') ?? [] as $obj) {
                if (str_contains($obj['Key'], $videoId)) {
                    $hasRaw = true;
                    $steps[0]['status'] = 'completed'; // upload
                    $steps[1]['status'] = 'completed'; // validation
                    break;
                }
            }
        }

        // Check processed bucket
        $hasHls = false;
        $hasThumb = false;
        if ($processedBucket) {
            $processed = $s3->listObjectsV2([
                'Bucket'  => $processedBucket,
                'Prefix'  => "videos/",
                'MaxKeys' => 100,
            ]);
            foreach ($processed->get('Contents') ?? [] as $obj) {
                if (str_contains($obj['Key'], $videoId)) {
                    if (str_ends_with($obj['Key'], '.m3u8') || str_ends_with($obj['Key'], '.mp4')) {
                        $hasHls = true;
                    }
                    if (str_contains($obj['Key'], 'thumb')) {
                        $hasThumb = true;
                    }
                }
            }
        }

        if ($hasHls) {
            $steps[2]['status'] = 'completed'; // transcoding
            $overallStatus = 'processing';
        } elseif ($hasRaw) {
            $steps[2]['status'] = 'in_progress';
            $overallStatus = 'processing';
        }

        if ($hasThumb) {
            $steps[3]['status'] = 'completed'; // thumbnail
        }

        if ($hasHls && $hasThumb) {
            $steps[4]['status'] = 'completed'; // publishing
            $overallStatus = 'published';
        }

        if (!$hasRaw && !$hasHls) {
            $overallStatus = 'not_found';
        }

        echo json_encode([
            'success' => true,
            'data'    => [
                'video_id' => $videoId,
                'status'   => $overallStatus,
                'steps'    => $steps,
            ],
        ]);
    } catch (AwsException $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'error'   => 'Failed to get status: ' . $e->getAwsErrorMessage(),
        ]);
    }
}
