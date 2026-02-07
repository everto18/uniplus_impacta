<?php
// Portal do Professor - Turmas
$basePath = '/professor';
$currentPage = 'turmas';
$professorName = 'Prof. João Santos';
$professorInitials = 'JS';

$turmas = [
    [
        'id' => 1, 
        'name' => 'Algoritmos - Turma A',
        'codigo' => 'ALG-2026A',
        'periodo' => '2026.1',
        'alunos' => 45,
        'aulas' => 24,
        'mediaNotas' => 7.8,
        'frequencia' => 92
    ],
    [
        'id' => 2,
        'name' => 'Algoritmos - Turma B', 
        'codigo' => 'ALG-2026B',
        'periodo' => '2026.1',
        'alunos' => 38,
        'aulas' => 24,
        'mediaNotas' => 8.1,
        'frequencia' => 88
    ],
    [
        'id' => 3,
        'name' => 'Estrutura de Dados',
        'codigo' => 'ED-2026A', 
        'periodo' => '2026.1',
        'alunos' => 42,
        'aulas' => 20,
        'mediaNotas' => 7.5,
        'frequencia' => 85
    ],
];
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Turmas - UniPlus</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="<?= $basePath ?>/assets/css/style.css">
</head>
<body>
    <header class="header glass">
        <a href="<?= $basePath ?>" class="logo">
            <i class="fas fa-graduation-cap"></i>
            <span>UniPlus</span>
        </a>
        
        <nav class="nav">
            <a href="<?= $basePath ?>"><i class="fas fa-home"></i> Início</a>
            <a href="<?= $basePath ?>/turmas.php" class="active"><i class="fas fa-users"></i> Turmas</a>
            <a href="<?= $basePath ?>/upload.php"><i class="fas fa-cloud-upload-alt"></i> Upload</a>
            <a href="<?= $basePath ?>/conteudos.php"><i class="fas fa-folder"></i> Conteúdos</a>
        </nav>

        <div class="user-menu">
            <span><?= $professorName ?></span>
            <div class="user-avatar"><?= $professorInitials ?></div>
        </div>
    </header>

    <main class="container">
        <div class="page-header fade-in">
            <h1 class="page-title"><i class="fas fa-users" style="color: var(--primary);"></i> Minhas Turmas</h1>
            <p class="page-subtitle">Gerencie suas turmas e acompanhe o desempenho dos alunos</p>
        </div>

        <div class="cards-grid" style="grid-template-columns: repeat(3, 1fr);">
            <?php foreach ($turmas as $i => $t): ?>
            <div class="card glass fade-in stagger-<?= $i + 1 ?>">
                <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 1rem;">
                    <div>
                        <span class="badge badge-info"><?= $t['codigo'] ?></span>
                        <h3 style="margin-top: 0.75rem; font-size: 1.2rem;"><?= $t['name'] ?></h3>
                        <p style="color: rgba(255,255,255,0.5); font-size: 0.9rem;">Período <?= $t['periodo'] ?></p>
                    </div>
                    <div style="width: 50px; height: 50px; background: var(--gradient); border-radius: 12px; display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-users" style="color: white; font-size: 1.2rem;"></i>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem; margin: 1.5rem 0;">
                    <div style="text-align: center; padding: 1rem; background: rgba(255,255,255,0.05); border-radius: 10px;">
                        <p style="font-size: 1.5rem; font-weight: 700; color: var(--primary);"><?= $t['alunos'] ?></p>
                        <p style="font-size: 0.8rem; color: rgba(255,255,255,0.5);">Alunos</p>
                    </div>
                    <div style="text-align: center; padding: 1rem; background: rgba(255,255,255,0.05); border-radius: 10px;">
                        <p style="font-size: 1.5rem; font-weight: 700; color: var(--success);"><?= $t['mediaNotas'] ?></p>
                        <p style="font-size: 0.8rem; color: rgba(255,255,255,0.5);">Média</p>
                    </div>
                </div>

                <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem;">
                    <span style="font-size: 0.9rem; color: rgba(255,255,255,0.6);">Frequência:</span>
                    <div class="progress-bar" style="flex: 1;">
                        <div class="progress-fill" style="width: <?= $t['frequencia'] ?>%;"></div>
                    </div>
                    <span style="font-weight: 600;"><?= $t['frequencia'] ?>%</span>
                </div>

                <div style="display: flex; gap: 0.5rem;">
                    <a href="<?= $basePath ?>/turmas.php?id=<?= $t['id'] ?>" class="btn btn-primary" style="flex: 1; justify-content: center;">
                        <i class="fas fa-eye"></i> Ver Detalhes
                    </a>
                    <button class="btn btn-secondary" style="padding: 12px;">
                        <i class="fas fa-cog"></i>
                    </button>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </main>

    <footer style="text-align: center; padding: 2rem; color: rgba(255,255,255,0.5); font-size: 0.9rem;">
        <p>© 2026 UniPlus - Universidade Digital. Todos os direitos reservados.</p>
    </footer>
</body>
</html>
