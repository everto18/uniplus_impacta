<?php
header('Content-Type: application/json');
http_response_code(200);
echo json_encode([
    'status' => 'healthy',
    'service' => 'video-api',
    'timestamp' => date('c'),
    'version' => '1.0.0'
]);
