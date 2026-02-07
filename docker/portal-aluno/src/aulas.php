<?php
// Portal do Aluno - Aulas
$basePath = '/aluno';
$currentPage = 'aulas';
$studentName = 'Maria Silva';
$studentInitials = 'MS';

// Get filter
$disciplinaId = isset($_GET['disciplina']) ? (int)$_GET['disciplina'] : 0;

// Mock data
$aulas = [
    ['id' => 1, 'title' => 'Introdução a Algoritmos', 'duration' => '45:30', 'views' => 1234, 'completed' => true, 'disciplina' => 'Algoritmos', 'professor' => 'Prof. João'],
    ['id' => 2, 'title' => 'Complexidade de Algoritmos', 'duration' => '52:15', 'views' => 987, 'completed' => true, 'disciplina' => 'Algoritmos', 'professor' => 'Prof. João'],
    ['id' => 3, 'title' => 'Arrays e Listas', 'duration' => '38:45', 'views' => 756, 'completed' => true, 'disciplina' => 'Algoritmos', 'professor' => 'Prof. João'],
    ['id' => 4, 'title' => 'Pilhas e Filas', 'duration' => '41:20', 'views' => 654, 'completed' => false, 'disciplina' => 'Algoritmos', 'professor' => 'Prof. João'],
    ['id' => 5, 'title' => 'Árvores Binárias', 'duration' => '55:00', 'views' => 432, 'completed' => false, 'disciplina' => 'Algoritmos', 'professor' => 'Prof. João'],
    ['id' => 6, 'title' => 'Introdução a SQL', 'duration' => '35:20', 'views' => 2100, 'completed' => true, 'disciplina' => 'Banco de Dados', 'professor' => 'Profa. Ana'],
    ['id' => 7, 'title' => 'Modelagem de Dados', 'duration' => '48:10', 'views' => 1850, 'completed' => true, 'disciplina' => 'Banco de Dados', 'professor' => 'Profa. Ana'],
    ['id' => 8, 'title' => 'HTML5 e CSS3', 'duration' => '42:30', 'views' => 3200, 'completed' => true, 'disciplina' => 'Dev Web', 'professor' => 'Prof. Carlos'],
    ['id' => 9, 'title' => 'JavaScript Moderno', 'duration' => '58:45', 'views' => 2890, 'completed' => true, 'disciplina' => 'Dev Web', 'professor' => 'Prof. Carlos'],
];

$disciplinas = ['Todas', 'Algoritmos', 'Banco de Dados', 'Dev Web', 'Redes'];
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Aulas - UniPlus</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="<?= $basePath ?>/assets/css/style.css">
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
        <div class="page-header fade-in">
            <h1 class="page-title"><i class="fas fa-play-circle" style="color: var(--primary);"></i> Biblioteca de Aulas</h1>
            <p class="page-subtitle">Assista às aulas gravadas no seu próprio ritmo</p>
        </div>

        <!-- Filters -->
        <div class="glass fade-in" style="padding: 1rem 1.5rem; margin-bottom: 2rem; display: flex; gap: 1rem; flex-wrap: wrap; align-items: center;">
            <span style="font-weight: 500;">Filtrar:</span>
            <?php foreach ($disciplinas as $i => $d): ?>
            <button class="btn <?= $i === 0 ? 'btn-primary' : 'btn-secondary' ?>" style="padding: 8px 16px; font-size: 0.85rem;">
                <?= $d ?>
            </button>
            <?php endforeach; ?>
            
            <div style="margin-left: auto; display: flex; gap: 0.5rem;">
                <input type="text" placeholder="Buscar aula..." class="form-input" style="width: 250px; padding: 8px 16px;">
                <button class="btn btn-primary" style="padding: 8px 16px;">
                    <i class="fas fa-search"></i>
                </button>
            </div>
        </div>

        <!-- Lessons Grid -->
        <div class="cards-grid" style="grid-template-columns: repeat(3, 1fr);">
            <?php foreach ($aulas as $i => $aula): ?>
            <a href="<?= $basePath ?>/assistir.php?id=<?= $aula['id'] ?>" class="card glass fade-in stagger-<?= ($i % 4) + 1 ?>" style="text-decoration: none; color: inherit;">
                <div class="card-image" style="position: relative;">
                    <div style="height: 100%; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #667eea, #764ba2);">
                        <i class="fas fa-play-circle" style="font-size: 3rem; color: white; opacity: 0.9;"></i>
                    </div>
                    <span style="position: absolute; bottom: 10px; right: 10px; background: rgba(0,0,0,0.8); padding: 4px 8px; border-radius: 4px; font-size: 0.8rem;">
                        <?= $aula['duration'] ?>
                    </span>
                    <?php if ($aula['completed']): ?>
                    <span style="position: absolute; top: 10px; right: 10px; background: var(--success); padding: 4px 8px; border-radius: 4px; font-size: 0.75rem;">
                        <i class="fas fa-check"></i> Concluída
                    </span>
                    <?php endif; ?>
                </div>
                <span class="card-category"><?= $aula['disciplina'] ?></span>
                <h3 class="card-title"><?= $aula['title'] ?></h3>
                <p class="card-text"><?= $aula['professor'] ?></p>
                <div class="card-meta">
                    <span><i class="fas fa-eye"></i> <?= number_format($aula['views']) ?> visualizações</span>
                </div>
            </a>
            <?php endforeach; ?>
        </div>

        <!-- Pagination -->
        <div style="display: flex; justify-content: center; gap: 0.5rem; margin-top: 2rem;">
            <button class="btn btn-secondary" style="padding: 10px 16px;"><i class="fas fa-chevron-left"></i></button>
            <button class="btn btn-primary" style="padding: 10px 16px;">1</button>
            <button class="btn btn-secondary" style="padding: 10px 16px;">2</button>
            <button class="btn btn-secondary" style="padding: 10px 16px;">3</button>
            <button class="btn btn-secondary" style="padding: 10px 16px;"><i class="fas fa-chevron-right"></i></button>
        </div>
    </main>

    <footer style="text-align: center; padding: 2rem; color: rgba(255,255,255,0.5); font-size: 0.9rem;">
        <p>© 2026 UniPlus - Universidade Digital. Todos os direitos reservados.</p>
    </footer>
</body>
</html>
