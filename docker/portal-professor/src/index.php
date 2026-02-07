<?php
// Portal do Professor - UniPlus
$basePath = '/professor';
$currentPage = 'dashboard';
$professorName = 'Prof. João Santos';
$professorInitials = 'JS';

// Mock data
$turmas = [
    ['id' => 1, 'name' => 'Algoritmos - Turma A', 'alunos' => 45, 'aulas' => 24, 'progresso' => 75],
    ['id' => 2, 'name' => 'Algoritmos - Turma B', 'alunos' => 38, 'aulas' => 24, 'progresso' => 70],
    ['id' => 3, 'name' => 'Estrutura de Dados', 'alunos' => 42, 'aulas' => 20, 'progresso' => 55],
];

$uploadsRecentes = [
    ['title' => 'Árvores Binárias.mp4', 'date' => '05/02/2026', 'status' => 'processando', 'size' => '1.2 GB'],
    ['title' => 'Slides Aula 15.pdf', 'date' => '04/02/2026', 'status' => 'concluido', 'size' => '8.5 MB'],
    ['title' => 'Exercícios Lista 5.pdf', 'date' => '03/02/2026', 'status' => 'concluido', 'size' => '2.1 MB'],
];

$stats = [
    ['icon' => 'users', 'value' => '125', 'label' => 'Alunos Ativos', 'color' => 'blue'],
    ['icon' => 'video', 'value' => '68', 'label' => 'Vídeos Publicados', 'color' => 'green'],
    ['icon' => 'eye', 'value' => '12.5K', 'label' => 'Visualizações', 'color' => 'purple'],
    ['icon' => 'star', 'value' => '4.8', 'label' => 'Avaliação Média', 'color' => 'orange'],
];
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portal do Professor - UniPlus</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="<?= $basePath ?>/assets/css/style.css">
    <style>
        .status-processando { color: var(--accent); }
        .status-concluido { color: var(--success); }
        .upload-progress {
            background: linear-gradient(90deg, var(--primary) 0%, var(--secondary) 100%);
            background-size: 200% 100%;
            animation: shimmer 2s infinite;
        }
        @keyframes shimmer {
            0% { background-position: 200% 0; }
            100% { background-position: -200% 0; }
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
            <a href="<?= $basePath ?>" class="active"><i class="fas fa-home"></i> Início</a>
            <a href="<?= $basePath ?>/turmas.php"><i class="fas fa-users"></i> Turmas</a>
            <a href="<?= $basePath ?>/upload.php"><i class="fas fa-cloud-upload-alt"></i> Upload</a>
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
            <h1 class="page-title">Bem-vindo, <?= explode(' ', $professorName)[1] ?>! 📚</h1>
            <p class="page-subtitle">Gerencie suas turmas e conteúdos</p>
        </div>

        <!-- Stats -->
        <div class="stats-grid">
            <?php foreach ($stats as $i => $s): ?>
            <div class="stat-card glass fade-in stagger-<?= $i + 1 ?>">
                <div class="stat-icon <?= $s['color'] ?>"><i class="fas fa-<?= $s['icon'] ?>"></i></div>
                <div class="stat-info">
                    <h3><?= $s['value'] ?></h3>
                    <p><?= $s['label'] ?></p>
                </div>
            </div>
            <?php endforeach; ?>
        </div>

        <!-- Two Column Layout -->
        <div style="display: grid; grid-template-columns: 1.5fr 1fr; gap: 2rem; margin-top: 2rem;">
            <!-- Turmas -->
            <section>
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                    <h2 style="font-size: 1.3rem;">
                        <i class="fas fa-chalkboard-teacher" style="color: var(--primary);"></i>
                        Minhas Turmas
                    </h2>
                    <a href="<?= $basePath ?>/turmas.php" class="btn btn-secondary" style="padding: 8px 16px; font-size: 0.85rem;">
                        Ver Todas <i class="fas fa-arrow-right"></i>
                    </a>
                </div>

                <?php foreach ($turmas as $i => $t): ?>
                <div class="card glass fade-in stagger-<?= $i + 1 ?>" style="margin-bottom: 1rem; display: flex; align-items: center; gap: 1.5rem;">
                    <div style="width: 60px; height: 60px; border-radius: 12px; background: var(--gradient); display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-users" style="font-size: 1.5rem; color: white;"></i>
                    </div>
                    <div style="flex: 1;">
                        <h3 style="font-size: 1.1rem; margin-bottom: 0.25rem;"><?= $t['name'] ?></h3>
                        <p style="font-size: 0.9rem; color: rgba(255,255,255,0.6);">
                            <?= $t['alunos'] ?> alunos • <?= $t['aulas'] ?> aulas
                        </p>
                        <div class="progress-bar" style="margin-top: 0.5rem; max-width: 200px;">
                            <div class="progress-fill" style="width: <?= $t['progresso'] ?>%;"></div>
                        </div>
                    </div>
                    <div style="text-align: right;">
                        <span style="font-size: 1.5rem; font-weight: 700; color: var(--primary);"><?= $t['progresso'] ?>%</span>
                        <p style="font-size: 0.8rem; color: rgba(255,255,255,0.5);">concluído</p>
                    </div>
                    <a href="<?= $basePath ?>/turmas.php?id=<?= $t['id'] ?>" class="btn btn-primary" style="padding: 10px 20px;">
                        <i class="fas fa-eye"></i>
                    </a>
                </div>
                <?php endforeach; ?>
            </section>

            <!-- Sidebar -->
            <aside>
                <!-- Quick Upload -->
                <div class="glass" style="padding: 1.5rem; margin-bottom: 1.5rem;">
                    <h3 style="margin-bottom: 1rem;">
                        <i class="fas fa-rocket" style="color: var(--accent);"></i>
                        Upload Rápido
                    </h3>
                    <a href="<?= $basePath ?>/upload.php" class="upload-zone" style="display: block; text-decoration: none; color: inherit;">
                        <i class="fas fa-cloud-upload-alt"></i>
                        <p style="font-weight: 500;">Arraste arquivos aqui</p>
                        <p style="font-size: 0.85rem; color: rgba(255,255,255,0.5);">ou clique para selecionar</p>
                    </a>
                </div>

                <!-- Recent Uploads -->
                <div class="glass" style="padding: 1.5rem;">
                    <h3 style="margin-bottom: 1rem;">
                        <i class="fas fa-history" style="color: var(--secondary);"></i>
                        Uploads Recentes
                    </h3>
                    <?php foreach ($uploadsRecentes as $u): ?>
                    <div style="display: flex; align-items: center; gap: 1rem; padding: 0.75rem 0; border-bottom: 1px solid rgba(255,255,255,0.1);">
                        <div style="width: 40px; height: 40px; border-radius: 8px; background: <?= strpos($u['title'], '.mp4') !== false ? 'var(--primary)' : 'var(--danger)' ?>; display: flex; align-items: center; justify-content: center;">
                            <i class="fas fa-<?= strpos($u['title'], '.mp4') !== false ? 'video' : 'file-pdf' ?>" style="color: white;"></i>
                        </div>
                        <div style="flex: 1; min-width: 0;">
                            <p style="font-weight: 500; font-size: 0.9rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><?= $u['title'] ?></p>
                            <p style="font-size: 0.8rem; color: rgba(255,255,255,0.5);"><?= $u['date'] ?> • <?= $u['size'] ?></p>
                        </div>
                        <?php if ($u['status'] === 'processando'): ?>
                        <span class="badge badge-warning"><i class="fas fa-spinner fa-spin"></i> Processando</span>
                        <?php else: ?>
                        <span class="badge badge-success"><i class="fas fa-check"></i> Pronto</span>
                        <?php endif; ?>
                    </div>
                    <?php endforeach; ?>
                </div>
            </aside>
        </div>
    </main>

    <footer style="text-align: center; padding: 2rem; color: rgba(255,255,255,0.5); font-size: 0.9rem;">
        <p>© 2026 UniPlus - Universidade Digital. Todos os direitos reservados.</p>
    </footer>
</body>
</html>
