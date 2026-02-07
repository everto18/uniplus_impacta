<?php
// Portal do Aluno - Assistir Aula
$basePath = '/aluno';
$currentPage = 'assistir';
$studentName = 'Maria Silva';
$studentInitials = 'MS';

$aulaId = isset($_GET['id']) ? (int)$_GET['id'] : 1;

// Mock data
$aula = [
    'id' => $aulaId,
    'title' => 'Árvores Binárias - Conceitos e Implementação',
    'description' => 'Nesta aula você vai aprender os conceitos fundamentais de árvores binárias, incluindo inserção, busca e remoção de elementos. Também veremos implementações práticas em diferentes linguagens.',
    'duration' => '55:00',
    'views' => 432,
    'date' => '05/02/2026',
    'disciplina' => 'Algoritmos e Estrutura de Dados',
    'professor' => 'Prof. João Santos',
    'videoUrl' => 'https://d2zihajmogu5jn.cloudfront.net/elephantsdream/hls/ed_hd.m3u8'
];

$materiais = [
    ['name' => 'Slides da Aula', 'type' => 'pdf', 'size' => '2.4 MB'],
    ['name' => 'Código de Exemplo', 'type' => 'zip', 'size' => '156 KB'],
    ['name' => 'Lista de Exercícios', 'type' => 'pdf', 'size' => '890 KB'],
];

$proximas = [
    ['id' => 6, 'title' => 'Grafos - Introdução', 'duration' => '48:20'],
    ['id' => 7, 'title' => 'Algoritmos de Busca em Grafos', 'duration' => '52:15'],
    ['id' => 8, 'title' => 'Árvores AVL', 'duration' => '45:30'],
];
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= $aula['title'] ?> - UniPlus</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="<?= $basePath ?>/assets/css/style.css">
    <link href="https://vjs.zencdn.net/8.6.1/video-js.css" rel="stylesheet">
    <style>
        .video-section {
            display: grid;
            grid-template-columns: 1fr 380px;
            gap: 2rem;
        }
        .video-wrapper {
            border-radius: 16px;
            overflow: hidden;
            background: #000;
        }
        .video-js {
            width: 100%;
            height: 500px;
        }
        .playlist-item {
            display: flex;
            gap: 1rem;
            padding: 1rem;
            border-radius: 10px;
            transition: all 0.3s;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
        }
        .playlist-item:hover {
            background: rgba(255,255,255,0.1);
        }
        .playlist-thumb {
            width: 120px;
            height: 68px;
            border-radius: 8px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        @media (max-width: 1024px) {
            .video-section {
                grid-template-columns: 1fr;
            }
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
            <a href="<?= $basePath ?>/aulas.php" class="active"><i class="fas fa-play-circle"></i> Aulas</a>
            <a href="<?= $basePath ?>/materiais.php"><i class="fas fa-book"></i> Materiais</a>
            <a href="<?= $basePath ?>/notas.php"><i class="fas fa-chart-line"></i> Notas</a>
        </nav>

        <div class="user-menu">
            <span><?= $studentName ?></span>
            <div class="user-avatar"><?= $studentInitials ?></div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="container">
        <!-- Breadcrumb -->
        <div class="fade-in" style="margin-bottom: 1.5rem;">
            <a href="<?= $basePath ?>/aulas.php" style="color: rgba(255,255,255,0.6); text-decoration: none;">
                <i class="fas fa-arrow-left"></i> Voltar para Aulas
            </a>
        </div>

        <div class="video-section">
            <!-- Main Video Area -->
            <div class="fade-in">
                <div class="video-wrapper">
                    <video id="video-player" class="video-js vjs-theme-fantasy" controls preload="auto" poster="">
                        <source src="<?= $aula['videoUrl'] ?>" type="application/x-mpegURL">
                        <p class="vjs-no-js">Para assistir este vídeo, habilite JavaScript.</p>
                    </video>
                </div>

                <!-- Video Info -->
                <div class="glass" style="padding: 1.5rem; margin-top: 1rem;">
                    <span class="badge badge-info"><?= $aula['disciplina'] ?></span>
                    <h1 style="font-size: 1.5rem; margin: 1rem 0 0.5rem;"><?= $aula['title'] ?></h1>
                    
                    <div style="display: flex; gap: 2rem; color: rgba(255,255,255,0.6); font-size: 0.9rem; margin-bottom: 1rem;">
                        <span><i class="fas fa-user"></i> <?= $aula['professor'] ?></span>
                        <span><i class="fas fa-calendar"></i> <?= $aula['date'] ?></span>
                        <span><i class="fas fa-eye"></i> <?= number_format($aula['views']) ?> visualizações</span>
                        <span><i class="fas fa-clock"></i> <?= $aula['duration'] ?></span>
                    </div>

                    <p style="color: rgba(255,255,255,0.8); line-height: 1.7;"><?= $aula['description'] ?></p>

                    <div style="display: flex; gap: 1rem; margin-top: 1.5rem;">
                        <button class="btn btn-primary"><i class="fas fa-check"></i> Marcar como Concluída</button>
                        <button class="btn btn-secondary"><i class="fas fa-bookmark"></i> Salvar</button>
                        <button class="btn btn-secondary"><i class="fas fa-share"></i> Compartilhar</button>
                    </div>
                </div>

                <!-- Materials -->
                <div class="glass" style="padding: 1.5rem; margin-top: 1rem;">
                    <h3 style="margin-bottom: 1rem;"><i class="fas fa-folder-open" style="color: var(--accent);"></i> Materiais da Aula</h3>
                    <div style="display: flex; flex-direction: column; gap: 0.75rem;">
                        <?php foreach ($materiais as $m): ?>
                        <a href="#" style="display: flex; align-items: center; gap: 1rem; padding: 1rem; background: rgba(255,255,255,0.05); border-radius: 10px; text-decoration: none; color: inherit; transition: all 0.3s;">
                            <div style="width: 45px; height: 45px; border-radius: 10px; background: <?= $m['type'] === 'pdf' ? 'var(--danger)' : 'var(--primary)' ?>; display: flex; align-items: center; justify-content: center;">
                                <i class="fas fa-file-<?= $m['type'] === 'pdf' ? 'pdf' : 'archive' ?>" style="color: white;"></i>
                            </div>
                            <div style="flex: 1;">
                                <p style="font-weight: 500;"><?= $m['name'] ?></p>
                                <p style="font-size: 0.85rem; color: rgba(255,255,255,0.5);"><?= strtoupper($m['type']) ?> • <?= $m['size'] ?></p>
                            </div>
                            <i class="fas fa-download" style="color: var(--primary);"></i>
                        </a>
                        <?php endforeach; ?>
                    </div>
                </div>
            </div>

            <!-- Sidebar - Playlist -->
            <aside class="fade-in stagger-2">
                <div class="glass" style="padding: 1rem;">
                    <h3 style="padding: 0.5rem 1rem; margin-bottom: 0.5rem;">
                        <i class="fas fa-list" style="color: var(--primary);"></i> Próximas Aulas
                    </h3>
                    
                    <?php foreach ($proximas as $p): ?>
                    <a href="<?= $basePath ?>/assistir.php?id=<?= $p['id'] ?>" class="playlist-item">
                        <div class="playlist-thumb">
                            <i class="fas fa-play" style="color: white;"></i>
                        </div>
                        <div>
                            <p style="font-weight: 500; font-size: 0.9rem; margin-bottom: 4px;"><?= $p['title'] ?></p>
                            <p style="font-size: 0.8rem; color: rgba(255,255,255,0.5);"><?= $p['duration'] ?></p>
                        </div>
                    </a>
                    <?php endforeach; ?>
                </div>

                <!-- Notes -->
                <div class="glass" style="padding: 1.5rem; margin-top: 1rem;">
                    <h3 style="margin-bottom: 1rem;"><i class="fas fa-sticky-note" style="color: var(--accent);"></i> Minhas Anotações</h3>
                    <textarea class="form-input" rows="6" placeholder="Faça suas anotações aqui..." style="resize: vertical;"></textarea>
                    <button class="btn btn-primary" style="width: 100%; margin-top: 1rem; justify-content: center;">
                        <i class="fas fa-save"></i> Salvar Anotações
                    </button>
                </div>
            </aside>
        </div>
    </main>

    <footer style="text-align: center; padding: 2rem; color: rgba(255,255,255,0.5); font-size: 0.9rem;">
        <p>© 2026 UniPlus - Universidade Digital. Todos os direitos reservados.</p>
    </footer>

    <script src="https://vjs.zencdn.net/8.6.1/video.min.js"></script>
    <script>
        var player = videojs('video-player', {
            fluid: true,
            playbackRates: [0.5, 1, 1.25, 1.5, 2],
            controlBar: {
                children: [
                    'playToggle',
                    'volumePanel',
                    'currentTimeDisplay',
                    'timeDivider',
                    'durationDisplay',
                    'progressControl',
                    'playbackRateMenuButton',
                    'fullscreenToggle'
                ]
            }
        });
    </script>
</body>
</html>
