<?php
/**
 * Video API - UniPlus
 * 
 * Endpoints:
 * GET  /api/videos         - Lista vídeos
 * GET  /api/videos/{id}    - Detalhes do vídeo
 * POST /api/videos/upload  - Inicia upload (retorna URL pré-assinada)
 * GET  /health             - Health check
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Simple router
$requestUri = $_SERVER['REQUEST_URI'];
$requestMethod = $_SERVER['REQUEST_METHOD'];

// Remove query string
$path = parse_url($requestUri, PHP_URL_PATH);
$path = str_replace('/api/videos', '', $path);

// Mock data
$videos = [
    [
        'id' => 'vid_001',
        'title' => 'Introdução a Algoritmos',
        'description' => 'Conceitos fundamentais de algoritmos e sua importância.',
        'duration' => '45:30',
        'views' => 1234,
        'thumbnail' => '/assets/thumbs/algorithms.jpg',
        'url' => 'https://d2zihajmogu5jn.cloudfront.net/elephantsdream/hls/ed_hd.m3u8',
        'status' => 'published',
        'created_at' => '2026-02-01T10:00:00Z',
        'discipline' => 'Algoritmos e Estrutura de Dados',
        'professor' => 'Prof. João Santos'
    ],
    [
        'id' => 'vid_002',
        'title' => 'Complexidade de Algoritmos',
        'description' => 'Análise de complexidade temporal e espacial.',
        'duration' => '52:15',
        'views' => 987,
        'thumbnail' => '/assets/thumbs/complexity.jpg',
        'url' => 'https://d2zihajmogu5jn.cloudfront.net/elephantsdream/hls/ed_hd.m3u8',
        'status' => 'published',
        'created_at' => '2026-02-02T14:30:00Z',
        'discipline' => 'Algoritmos e Estrutura de Dados',
        'professor' => 'Prof. João Santos'
    ],
    [
        'id' => 'vid_003',
        'title' => 'Árvores Binárias',
        'description' => 'Estrutura, inserção, busca e remoção em árvores binárias.',
        'duration' => '55:00',
        'views' => 432,
        'thumbnail' => '/assets/thumbs/trees.jpg',
        'url' => 'https://d2zihajmogu5jn.cloudfront.net/elephantsdream/hls/ed_hd.m3u8',
        'status' => 'processing',
        'created_at' => '2026-02-05T09:15:00Z',
        'discipline' => 'Algoritmos e Estrutura de Dados',
        'professor' => 'Prof. João Santos'
    ]
];

// Routes
switch (true) {
    // Health check
    case $path === '/health' || $requestUri === '/health':
        http_response_code(200);
        echo json_encode([
            'status' => 'healthy',
            'service' => 'video-api',
            'timestamp' => date('c'),
            'version' => '1.0.0'
        ]);
        break;

    // List videos
    case $path === '' || $path === '/':
        if ($requestMethod === 'GET') {
            // Pagination
            $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
            $limit = isset($_GET['limit']) ? min((int)$_GET['limit'], 50) : 10;
            
            // Filter by status
            $status = isset($_GET['status']) ? $_GET['status'] : null;
            $filtered = $status 
                ? array_filter($videos, fn($v) => $v['status'] === $status)
                : $videos;
            
            echo json_encode([
                'success' => true,
                'data' => array_values($filtered),
                'pagination' => [
                    'page' => $page,
                    'limit' => $limit,
                    'total' => count($filtered),
                    'pages' => ceil(count($filtered) / $limit)
                ]
            ]);
        }
        break;

    // Get video by ID
    case preg_match('/^\/vid_\d+$/', $path):
        $videoId = ltrim($path, '/');
        $video = array_filter($videos, fn($v) => $v['id'] === $videoId);
        
        if (empty($video)) {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'error' => 'Video not found'
            ]);
        } else {
            echo json_encode([
                'success' => true,
                'data' => array_values($video)[0]
            ]);
        }
        break;

    // Upload presigned URL
    case $path === '/upload':
        if ($requestMethod === 'POST') {
            // Get request body
            $input = json_decode(file_get_contents('php://input'), true);
            
            $filename = $input['filename'] ?? 'video.mp4';
            $contentType = $input['content_type'] ?? 'video/mp4';
            
            // Generate mock presigned URL (in production, this would call AWS S3)
            $videoId = 'vid_' . str_pad(rand(100, 999), 3, '0', STR_PAD_LEFT);
            $uploadUrl = "https://uniplus-raw-videos.s3.sa-east-1.amazonaws.com/{$videoId}/{$filename}?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Expires=3600";
            
            echo json_encode([
                'success' => true,
                'data' => [
                    'video_id' => $videoId,
                    'upload_url' => $uploadUrl,
                    'expires_in' => 3600,
                    'max_size' => '5GB',
                    'allowed_types' => ['video/mp4', 'video/quicktime', 'video/x-msvideo']
                ]
            ]);
        } else {
            http_response_code(405);
            echo json_encode(['error' => 'Method not allowed']);
        }
        break;

    // Processing status
    case preg_match('/^\/vid_\d+\/status$/', $path):
        $videoId = explode('/', ltrim($path, '/'))[0];
        
        echo json_encode([
            'success' => true,
            'data' => [
                'video_id' => $videoId,
                'status' => 'processing',
                'progress' => 45,
                'steps' => [
                    ['name' => 'upload', 'status' => 'completed'],
                    ['name' => 'validation', 'status' => 'completed'],
                    ['name' => 'transcoding', 'status' => 'in_progress', 'progress' => 45],
                    ['name' => 'thumbnail', 'status' => 'pending'],
                    ['name' => 'publishing', 'status' => 'pending']
                ],
                'estimated_completion' => '2026-02-07T15:30:00Z'
            ]
        ]);
        break;

    // 404
    default:
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'error' => 'Endpoint not found',
            'available_endpoints' => [
                'GET /api/videos' => 'List videos',
                'GET /api/videos/{id}' => 'Get video details',
                'POST /api/videos/upload' => 'Get presigned upload URL',
                'GET /api/videos/{id}/status' => 'Get processing status',
                'GET /health' => 'Health check'
            ]
        ]);
}
