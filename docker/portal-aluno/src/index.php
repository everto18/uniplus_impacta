<?php
// Portal do Aluno - UniPlus
$basePath = getenv('APP_BASE_PATH') !== false ? getenv('APP_BASE_PATH') : '/aluno';
$currentPage = 'dashboard';
$studentName = 'Maria Silva';
$studentInitials = 'MS';

// Mock data
$disciplines = [
    [
        'id' => 1,
        'name' => 'Algoritmos e Estrutura de Dados',
        'professor' => 'Prof. João Santos',
        'progress' => 75,
        'lessons' => 24,
        'completed' => 18,
        'color' => '#6366f1'
    ],
    [
        'id' => 2,
        'name' => 'Banco de Dados',
        'professor' => 'Profa. Ana Costa',
        'progress' => 60,
        'lessons' => 20,
        'completed' => 12,
        'color' => '#0ea5e9'
    ],
    [
        'id' => 3,
        'name' => 'Desenvolvimento Web',
        'professor' => 'Prof. Carlos Oliveira',
        'progress' => 90,
        'lessons' => 16,
        'completed' => 14,
        'color' => '#10b981'
    ],
    [
        'id' => 4,
        'name' => 'Redes de Computadores',
        'professor' => 'Prof. Roberto Lima',
        'progress' => 45,
        'lessons' => 18,
        'completed' => 8,
        'color' => '#f59e0b'
    ]
];

$nextLessons = [
    ['time' => '14:00', 'title' => 'Árvores Binárias', 'discipline' => 'Algoritmos'],
    ['time' => '16:00', 'title' => 'SQL Avançado', 'discipline' => 'Banco de Dados'],
    ['time' => '19:00', 'title' => 'React Hooks', 'discipline' => 'Dev Web']
];
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portal do Aluno - UniPlus</title>
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
            <a href="<?= $basePath ?>" class="active"><i class="fas fa-home"></i> Início</a>
            <a href="<?= $basePath ?>/aulas.php"><i class="fas fa-play-circle"></i> Aulas</a>
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
            <h1 class="page-title">Olá, <?= explode(' ', $studentName)[0] ?>! 👋</h1>
            <p class="page-subtitle">Continue de onde parou. Você está indo muito bem!</p>
        </div>

        <!-- Stats -->
        <div class="stats-grid">
            <div class="stat-card glass fade-in stagger-1">
                <div class="stat-icon blue"><i class="fas fa-book-open"></i></div>
                <div class="stat-info">
                    <h3>4</h3>
                    <p>Disciplinas Ativas</p>
                </div>
            </div>
            <div class="stat-card glass fade-in stagger-2">
                <div class="stat-icon green"><i class="fas fa-check-circle"></i></div>
                <div class="stat-info">
                    <h3>52</h3>
                    <p>Aulas Concluídas</p>
                </div>
            </div>
            <div class="stat-card glass fade-in stagger-3">
                <div class="stat-icon purple"><i class="fas fa-clock"></i></div>
                <div class="stat-info">
                    <h3>48h</h3>
                    <p>Tempo de Estudo</p>
                </div>
            </div>
            <div class="stat-card glass fade-in stagger-4">
                <div class="stat-icon orange"><i class="fas fa-trophy"></i></div>
                <div class="stat-info">
                    <h3>8.5</h3>
                    <p>Média Geral</p>
                </div>
            </div>
        </div>

        <!-- Two Column Layout -->
        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 2rem; margin-top: 2rem;">
            <!-- Disciplines -->
            <section>
                <h2 style="font-size: 1.3rem; margin-bottom: 1.5rem;">
                    <i class="fas fa-graduation-cap" style="color: var(--primary);"></i>
                    Minhas Disciplinas
                </h2>
                <div class="cards-grid" style="grid-template-columns: repeat(2, 1fr);">
                    <?php foreach ($disciplines as $i => $d): ?>
                    <div class="card glass fade-in stagger-<?= ($i % 4) + 1 ?>">
                        <div class="card-image" style="background: linear-gradient(135deg, <?= $d['color'] ?>, <?= $d['color'] ?>88);">
                            <div style="height: 100%; display: flex; align-items: center; justify-content: center;">
                                <i class="fas fa-laptop-code" style="font-size: 3rem; color: white;"></i>
                            </div>
                        </div>
                        <span class="card-category"><?= $d['completed'] ?>/<?= $d['lessons'] ?> aulas</span>
                        <h3 class="card-title"><?= $d['name'] ?></h3>
                        <p class="card-text"><?= $d['professor'] ?></p>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: <?= $d['progress'] ?>%;"></div>
                        </div>
                        <div class="card-meta" style="margin-top: 0.75rem;">
                            <span><?= $d['progress'] ?>% concluído</span>
                            <a href="<?= $basePath ?>/aulas.php?disciplina=<?= $d['id'] ?>" class="btn btn-secondary" style="padding: 6px 12px; font-size: 0.8rem;">
                                Continuar <i class="fas fa-arrow-right"></i>
                            </a>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            </section>

            <!-- Sidebar - Next Lessons -->
            <aside>
                <div class="glass" style="padding: 1.5rem;">
                    <h3 style="margin-bottom: 1.5rem; display: flex; align-items: center; gap: 10px;">
                        <i class="fas fa-calendar-alt" style="color: var(--accent);"></i>
                        Próximas Aulas
                    </h3>
                    <?php foreach ($nextLessons as $lesson): ?>
                    <div style="display: flex; gap: 1rem; padding: 1rem 0; border-bottom: 1px solid rgba(255,255,255,0.1);">
                        <div style="background: var(--gradient); padding: 8px 12px; border-radius: 8px; font-weight: 600; font-size: 0.85rem;">
                            <?= $lesson['time'] ?>
                        </div>
                        <div>
                            <p style="font-weight: 500;"><?= $lesson['title'] ?></p>
                            <p style="font-size: 0.85rem; color: rgba(255,255,255,0.6);"><?= $lesson['discipline'] ?></p>
                        </div>
                    </div>
                    <?php endforeach; ?>

                    <a href="<?= $basePath ?>/calendario.php" class="btn btn-primary" style="width: 100%; justify-content: center; margin-top: 1rem;">
                        <i class="fas fa-calendar"></i> Ver Calendário
                    </a>
                </div>

                <!-- Quick Stats -->
                <div class="glass" style="padding: 1.5rem; margin-top: 1.5rem;">
                    <h3 style="margin-bottom: 1rem;">
                        <i class="fas fa-fire" style="color: var(--danger);"></i>
                        Sequência de Estudos
                    </h3>
                    <div style="text-align: center; padding: 1rem 0;">
                        <div style="font-size: 3rem; font-weight: 700; background: var(--gradient); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">
                            🔥 12 dias
                        </div>
                        <p style="color: rgba(255,255,255,0.6); margin-top: 0.5rem;">Continue assim!</p>
                    </div>
                </div>
            </aside>
        </div>
    </main>

    <!-- Footer -->
    <footer style="text-align: center; padding: 2rem; color: rgba(255,255,255,0.5); font-size: 0.9rem;">
        <p>© 2026 UniPlus - Universidade Digital. Todos os direitos reservados.</p>
    </footer>

    <script src="<?= $basePath ?>/assets/js/app.js"></script>
</body>
</html>
