<?php
// Health check endpoint
header('Content-Type: application/json');
http_response_code(200);
echo json_encode([
    'status' => 'healthy',
    'service' => 'portal-aluno',
    'timestamp' => date('c'),
    'version' => '1.0.0'
]);
