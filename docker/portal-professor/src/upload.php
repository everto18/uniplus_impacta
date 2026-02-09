<?php
// Portal do Professor - Upload
$basePath = '/professor';
$currentPage = 'upload';
$professorName = 'Prof. João Santos';
$professorInitials = 'JS';

$disciplinas = [
    ['id' => 1, 'name' => 'Algoritmos e Estrutura de Dados'],
    ['id' => 2, 'name' => 'Estrutura de Dados Avançada'],
    ['id' => 3, 'name' => 'Programação Orientada a Objetos'],
];
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload de Conteúdo - UniPlus</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="<?= $basePath ?>/assets/css/style.css">
    <style>
        .upload-area {
            border: 3px dashed var(--glass-border);
            border-radius: 20px;
            padding: 4rem;
            text-align: center;
            transition: all 0.3s;
            cursor: pointer;
            background: rgba(99, 102, 241, 0.05);
        }
        .upload-area:hover, .upload-area.dragover {
            border-color: var(--primary);
            background: rgba(99, 102, 241, 0.15);
            transform: scale(1.01);
        }
        .upload-area i {
            font-size: 4rem;
            color: var(--primary);
            margin-bottom: 1.5rem;
            display: block;
        }
        .file-item {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem;
            background: rgba(255,255,255,0.05);
            border-radius: 12px;
            margin-bottom: 0.75rem;
        }
        .file-icon {
            width: 50px;
            height: 50px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            color: white;
        }
        .file-icon.video { background: var(--primary); }
        .file-icon.pdf { background: var(--danger); }
        .file-icon.doc { background: var(--secondary); }
        .file-progress {
            height: 6px;
            background: rgba(255,255,255,0.1);
            border-radius: 3px;
            overflow: hidden;
            margin-top: 0.5rem;
        }
        .file-progress-bar {
            height: 100%;
            background: var(--gradient);
            border-radius: 3px;
            transition: width 0.3s;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header glass">
        <a href="<?= $basePath ?>" class="logo">
            <i class="fas fa-graduation-cap"></i>
            <span>UniPlus</span>
        </a>
        
        <nav class="nav">
            <a href="<?= $basePath ?>"><i class="fas fa-home"></i> Início</a>
            <a href="<?= $basePath ?>/turmas.php"><i class="fas fa-users"></i> Turmas</a>
            <a href="<?= $basePath ?>/upload.php" class="active"><i class="fas fa-cloud-upload-alt"></i> Upload</a>
            <a href="<?= $basePath ?>/conteudos.php"><i class="fas fa-folder"></i> Conteúdos</a>
        </nav>

        <div class="user-menu">
            <span><?= $professorName ?></span>
            <div class="user-avatar"><?= $professorInitials ?></div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="container">
        <div class="page-header fade-in">
            <h1 class="page-title"><i class="fas fa-cloud-upload-alt" style="color: var(--primary);"></i> Upload de Conteúdo</h1>
            <p class="page-subtitle">Envie vídeos de aulas e materiais complementares</p>
        </div>

        <div style="display: grid; grid-template-columns: 1.5fr 1fr; gap: 2rem;">
            <!-- Upload Area -->
            <div class="fade-in">
                <div class="glass" style="padding: 2rem;">
                    <h3 style="margin-bottom: 1.5rem;"><i class="fas fa-video" style="color: var(--primary);"></i> Upload de Vídeo</h3>
                    
                    <div class="upload-area" id="uploadArea">
                        <i class="fas fa-cloud-upload-alt"></i>
                        <h3 style="font-size: 1.3rem; margin-bottom: 0.5rem;">Arraste e solte seu vídeo aqui</h3>
                        <p style="color: rgba(255,255,255,0.6); margin-bottom: 1.5rem;">ou clique para selecionar</p>
                        <p style="font-size: 0.85rem; color: rgba(255,255,255,0.4);">
                            Formatos: MP4, MOV, AVI, MKV • Máximo: 5GB
                        </p>
                        <input type="file" id="fileInput" accept="video/*" style="display: none;">
                    </div>

                    <!-- Upload Queue -->
                    <div id="uploadQueue" style="margin-top: 1.5rem; display: none;">
                        <h4 style="margin-bottom: 1rem;">Fila de Upload</h4>
                        <div class="file-item">
                            <div class="file-icon video"><i class="fas fa-video"></i></div>
                            <div style="flex: 1;">
                                <p style="font-weight: 500;">Aula_Grafos_Parte1.mp4</p>
                                <p style="font-size: 0.85rem; color: rgba(255,255,255,0.5);">1.2 GB • 45% enviado</p>
                                <div class="file-progress">
                                    <div class="file-progress-bar" style="width: 45%;"></div>
                                </div>
                            </div>
                            <button class="btn btn-secondary" style="padding: 8px;"><i class="fas fa-times"></i></button>
                        </div>
                    </div>
                </div>

                <!-- Materials Upload -->
                <div class="glass" style="padding: 2rem; margin-top: 1.5rem;">
                    <h3 style="margin-bottom: 1.5rem;"><i class="fas fa-file-alt" style="color: var(--accent);"></i> Materiais Complementares</h3>
                    
                    <div class="upload-area" style="padding: 2rem;">
                        <i class="fas fa-file-pdf" style="font-size: 2.5rem;"></i>
                        <p style="font-weight: 500; margin-top: 1rem;">Slides, PDFs, Documentos</p>
                        <p style="font-size: 0.85rem; color: rgba(255,255,255,0.5);">PDF, DOCX, PPTX, ZIP</p>
                    </div>
                </div>
            </div>

            <!-- Form -->
            <div class="fade-in stagger-2">
                <div class="glass" style="padding: 2rem;">
                    <h3 style="margin-bottom: 1.5rem;"><i class="fas fa-info-circle" style="color: var(--secondary);"></i> Informações do Conteúdo</h3>
                    
                    <form id="uploadForm">
                        <div class="form-group">
                            <label class="form-label">Título da Aula *</label>
                            <input type="text" class="form-input" placeholder="Ex: Introdução a Grafos" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Disciplina *</label>
                            <select class="form-input" required>
                                <option value="">Selecione...</option>
                                <?php foreach ($disciplinas as $d): ?>
                                <option value="<?= $d['id'] ?>"><?= $d['name'] ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Turma *</label>
                            <select class="form-input" required>
                                <option value="">Selecione...</option>
                                <option value="1">Turma A - 2026.1</option>
                                <option value="2">Turma B - 2026.1</option>
                                <option value="3">Todas as turmas</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Descrição</label>
                            <textarea class="form-input" rows="4" placeholder="Descreva o conteúdo da aula..."></textarea>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Tags</label>
                            <input type="text" class="form-input" placeholder="grafos, algoritmos, busca">
                        </div>

                        <div class="form-group">
                            <label style="display: flex; align-items: center; gap: 10px; cursor: pointer;">
                                <input type="checkbox" style="width: 18px; height: 18px;">
                                <span>Disponibilizar imediatamente</span>
                            </label>
                        </div>

                        <button type="submit" class="btn btn-primary" style="width: 100%; justify-content: center; padding: 14px;">
                            <i class="fas fa-upload"></i> Iniciar Upload
                        </button>
                    </form>
                </div>

                <!-- Tips -->
                <div class="glass" style="padding: 1.5rem; margin-top: 1.5rem;">
                    <h4 style="margin-bottom: 1rem;"><i class="fas fa-lightbulb" style="color: var(--accent);"></i> Dicas</h4>
                    <ul style="list-style: none; font-size: 0.9rem; color: rgba(255,255,255,0.7);">
                        <li style="margin-bottom: 0.5rem;">✅ Use boa iluminação e áudio claro</li>
                        <li style="margin-bottom: 0.5rem;">✅ Resolução recomendada: 1080p</li>
                        <li style="margin-bottom: 0.5rem;">✅ O vídeo será processado automaticamente</li>
                        <li>✅ Múltiplas qualidades serão geradas</li>
                    </ul>
                </div>
            </div>
        </div>
    </main>

    <footer style="text-align: center; padding: 2rem; color: rgba(255,255,255,0.5); font-size: 0.9rem;">
        <p>© 2026 UniPlus - Universidade Digital. Todos os direitos reservados.</p>
    </footer>

    <script>
        const uploadArea = document.getElementById('uploadArea');
        const fileInput = document.getElementById('fileInput');
        const uploadQueue = document.getElementById('uploadQueue');
        const uploadForm = document.getElementById('uploadForm');

        // Video API base URL (same ALB, different path)
        const VIDEO_API_URL = '/api/videos';

        // Max file size: 5GB
        const MAX_FILE_SIZE = 5 * 1024 * 1024 * 1024;
        const ALLOWED_TYPES = ['video/mp4', 'video/quicktime', 'video/x-msvideo', 'video/x-matroska'];

        let selectedFile = null;
        let isUploading = false;

        // Drag & Drop
        uploadArea.addEventListener('click', () => fileInput.click());
        uploadArea.addEventListener('dragover', (e) => {
            e.preventDefault();
            uploadArea.classList.add('dragover');
        });
        uploadArea.addEventListener('dragleave', () => {
            uploadArea.classList.remove('dragover');
        });
        uploadArea.addEventListener('drop', (e) => {
            e.preventDefault();
            uploadArea.classList.remove('dragover');
            if (e.dataTransfer.files.length) {
                handleFileSelect(e.dataTransfer.files[0]);
            }
        });
        fileInput.addEventListener('change', (e) => {
            if (e.target.files.length) {
                handleFileSelect(e.target.files[0]);
            }
        });

        function handleFileSelect(file) {
            // Validate type
            if (!ALLOWED_TYPES.includes(file.type) && !file.name.match(/\.(mp4|mov|avi|mkv)$/i)) {
                showNotification('❌ Formato não suportado. Use: MP4, MOV, AVI, MKV', 'error');
                return;
            }
            // Validate size
            if (file.size > MAX_FILE_SIZE) {
                showNotification('❌ Arquivo muito grande. Máximo: 5GB', 'error');
                return;
            }

            selectedFile = file;
            showFileInQueue(file);
        }

        function showFileInQueue(file) {
            const sizeFormatted = formatFileSize(file.size);
            uploadQueue.style.display = 'block';
            uploadQueue.innerHTML = `
                <h4 style="margin-bottom: 1rem;">Arquivo Selecionado</h4>
                <div class="file-item" id="fileItem">
                    <div class="file-icon video"><i class="fas fa-video"></i></div>
                    <div style="flex: 1;">
                        <p style="font-weight: 500;">${file.name}</p>
                        <p id="uploadStatus" style="font-size: 0.85rem; color: rgba(255,255,255,0.5);">${sizeFormatted} • Pronto para enviar</p>
                        <div class="file-progress">
                            <div class="file-progress-bar" id="progressBar" style="width: 0%;"></div>
                        </div>
                    </div>
                    <button class="btn btn-secondary" style="padding: 8px;" onclick="removeFile()">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            `;
        }

        function removeFile() {
            if (isUploading) return;
            selectedFile = null;
            uploadQueue.style.display = 'none';
            fileInput.value = '';
        }

        // Form submit = start upload
        uploadForm.addEventListener('submit', async (e) => {
            e.preventDefault();

            if (!selectedFile) {
                showNotification('⚠️ Selecione um vídeo primeiro', 'warning');
                return;
            }
            if (isUploading) return;

            const title = uploadForm.querySelector('input[type="text"]').value;
            const discipline = uploadForm.querySelector('select[required]').value;
            const turma = uploadForm.querySelectorAll('select[required]')[1]?.value || '';

            await startUpload(selectedFile, title, discipline, turma);
        });

        async function startUpload(file, title, discipline, turma) {
            isUploading = true;
            const progressBar = document.getElementById('progressBar');
            const uploadStatus = document.getElementById('uploadStatus');
            const submitBtn = uploadForm.querySelector('button[type="submit"]');

            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Enviando...';

            try {
                // Step 1: Get presigned URL from Video API
                uploadStatus.textContent = 'Obtendo URL de upload...';
                progressBar.style.width = '2%';

                const contentType = file.type || 'video/mp4';
                const response = await fetch(`${VIDEO_API_URL}/upload`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        filename: file.name,
                        content_type: contentType,
                        title: title,
                        discipline: discipline,
                        turma: turma,
                    }),
                });

                const result = await response.json();
                if (!result.success) {
                    throw new Error(result.error || 'Falha ao obter URL de upload');
                }

                const { upload_url, video_id, headers } = result.data;

                // Step 2: Upload file directly to S3 via presigned URL
                uploadStatus.textContent = 'Enviando vídeo para o servidor...';

                await uploadToS3(file, upload_url, contentType, headers, (progress) => {
                    progressBar.style.width = `${progress}%`;
                    uploadStatus.textContent = `${formatFileSize(file.size)} • ${Math.round(progress)}% enviado`;
                });

                // Step 3: Success!
                progressBar.style.width = '100%';
                progressBar.style.background = 'var(--success, #10b981)';
                uploadStatus.innerHTML = `
                    ✅ Upload concluído! ID: <strong>${video_id}</strong><br>
                    <small style="color: rgba(255,255,255,0.5);">O vídeo será processado automaticamente (HLS + MP4 + Thumbnails)</small>
                `;

                showNotification('✅ Vídeo enviado com sucesso! O processamento será iniciado automaticamente.', 'success');

                // Reset form
                uploadForm.reset();
                selectedFile = null;
                fileInput.value = '';

            } catch (error) {
                console.error('Upload error:', error);
                progressBar.style.width = '100%';
                progressBar.style.background = 'var(--danger, #ef4444)';
                uploadStatus.textContent = `❌ Erro: ${error.message}`;
                showNotification(`❌ Erro no upload: ${error.message}`, 'error');
            } finally {
                isUploading = false;
                submitBtn.disabled = false;
                submitBtn.innerHTML = '<i class="fas fa-upload"></i> Iniciar Upload';
            }
        }

        function uploadToS3(file, presignedUrl, contentType, headers, onProgress) {
            return new Promise((resolve, reject) => {
                const xhr = new XMLHttpRequest();

                xhr.upload.addEventListener('progress', (e) => {
                    if (e.lengthComputable) {
                        const percent = (e.loaded / e.total) * 100;
                        onProgress(percent);
                    }
                });

                xhr.addEventListener('load', () => {
                    if (xhr.status >= 200 && xhr.status < 300) {
                        resolve();
                    } else {
                        reject(new Error(`Upload falhou (HTTP ${xhr.status})`));
                    }
                });

                xhr.addEventListener('error', () => reject(new Error('Erro de rede durante upload')));
                xhr.addEventListener('abort', () => reject(new Error('Upload cancelado')));

                xhr.open('PUT', presignedUrl);
                xhr.setRequestHeader('Content-Type', contentType);

                // Set custom metadata headers if provided
                if (headers) {
                    Object.entries(headers).forEach(([key, value]) => {
                        if (key.startsWith('x-amz-meta-')) {
                            xhr.setRequestHeader(key, value);
                        }
                    });
                }

                xhr.send(file);
            });
        }

        function formatFileSize(bytes) {
            if (bytes >= 1073741824) return (bytes / 1073741824).toFixed(1) + ' GB';
            if (bytes >= 1048576) return (bytes / 1048576).toFixed(1) + ' MB';
            if (bytes >= 1024) return (bytes / 1024).toFixed(1) + ' KB';
            return bytes + ' bytes';
        }

        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.style.cssText = `
                position: fixed; top: 80px; right: 20px; z-index: 9999;
                padding: 16px 24px; border-radius: 12px; font-weight: 500;
                color: white; max-width: 400px; font-size: 0.95rem;
                animation: slideIn 0.3s ease-out;
                background: ${type === 'success' ? 'rgba(16,185,129,0.95)' : type === 'error' ? 'rgba(239,68,68,0.95)' : 'rgba(245,158,11,0.95)'};
                backdrop-filter: blur(10px);
                box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            `;
            notification.textContent = message;
            document.body.appendChild(notification);
            setTimeout(() => {
                notification.style.animation = 'fadeOut 0.3s ease-in forwards';
                setTimeout(() => notification.remove(), 300);
            }, 5000);
        }
    </script>
    <style>
        @keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        @keyframes fadeOut { to { opacity: 0; transform: translateY(-10px); } }
    </style>
</body>
</html>
