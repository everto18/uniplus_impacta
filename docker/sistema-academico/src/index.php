<?php
// Sistema Acadêmico - UniPlus
$basePath = getenv('APP_BASE_PATH') !== false ? getenv('APP_BASE_PATH') : '/academico';
$currentPage = 'dashboard';
$userName = 'Admin Sistema';
$userInitials = 'AS';

// Mock data
$stats = [
    ['icon' => 'user-graduate', 'value' => '2,450', 'label' => 'Alunos Matriculados', 'color' => 'blue', 'trend' => '+12%'],
    ['icon' => 'chalkboard-teacher', 'value' => '156', 'label' => 'Professores Ativos', 'color' => 'green', 'trend' => '+5%'],
    ['icon' => 'book', 'value' => '48', 'label' => 'Cursos Disponíveis', 'color' => 'purple', 'trend' => '+3'],
    ['icon' => 'video', 'value' => '1,280', 'label' => 'Aulas Publicadas', 'color' => 'orange', 'trend' => '+89'],
];

$recentActivities = [
    ['user' => 'Prof. João Santos', 'action' => 'publicou nova aula', 'item' => 'Árvores Binárias', 'time' => 'há 5 min'],
    ['user' => 'Maria Silva', 'action' => 'concluiu disciplina', 'item' => 'Banco de Dados', 'time' => 'há 15 min'],
    ['user' => 'Admin', 'action' => 'criou novo curso', 'item' => 'Ciência de Dados', 'time' => 'há 1 hora'],
    ['user' => 'Prof. Ana Costa', 'action' => 'lançou notas', 'item' => 'Turma B - ADS', 'time' => 'há 2 horas'],
];

$cursos = [
    ['id' => 1, 'name' => 'Análise e Desenvolvimento de Sistemas', 'alunos' => 850, 'disciplinas' => 24],
    ['id' => 2, 'name' => 'Ciência da Computação', 'alunos' => 620, 'disciplinas' => 32],
    ['id' => 3, 'name' => 'Engenharia de Software', 'alunos' => 480, 'disciplinas' => 28],
    ['id' => 4, 'name' => 'Sistemas de Informação', 'alunos' => 500, 'disciplinas' => 26],
];
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sistema Acadêmico - UniPlus</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="<?= $basePath ?>/assets/css/style.css">
    <style>
        .admin-layout {
            display: grid;
            grid-template-columns: 260px 1fr;
            min-height: calc(100vh - 80px);
        }
        .admin-sidebar {
            background: rgba(0,0,0,0.2);
            padding: 1.5rem;
            border-right: 1px solid rgba(255,255,255,0.1);
        }
        .admin-sidebar h3 {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.1em;
            color: rgba(255,255,255,0.4);
            margin: 1.5rem 0 0.75rem;
        }
        .admin-sidebar a {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            color: rgba(255,255,255,0.7);
            text-decoration: none;
            border-radius: 10px;
            transition: all 0.3s;
            margin-bottom: 4px;
        }
        .admin-sidebar a:hover, .admin-sidebar a.active {
            background: var(--glass);
            color: var(--light);
        }
        .admin-sidebar a.active {
            background: var(--gradient);
        }
        .admin-sidebar a i {
            width: 20px;
            text-align: center;
        }
        .trend-up { color: var(--success); }
        .trend-down { color: var(--danger); }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header glass">
        <a href="<?= $basePath ?>" class="logo">
            <i class="fas fa-graduation-cap"></i>
            <span>UniPlus</span>
            <span style="font-size: 0.8rem; color: rgba(255,255,255,0.5); margin-left: 8px;">Admin</span>
        </a>
        
        <div style="display: flex; align-items: center; gap: 1rem;">
            <div style="position: relative;">
                <input type="text" placeholder="Buscar..." class="form-input" style="width: 300px; padding: 10px 16px; padding-left: 40px;">
                <i class="fas fa-search" style="position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: rgba(255,255,255,0.4);"></i>
            </div>
            
            <button class="btn btn-secondary" style="padding: 10px; position: relative;">
                <i class="fas fa-bell"></i>
                <span style="position: absolute; top: -4px; right: -4px; width: 18px; height: 18px; background: var(--danger); border-radius: 50%; font-size: 0.7rem; display: flex; align-items: center; justify-content: center;">5</span>
            </button>
        </div>

        <div class="user-menu">
            <span><?= $userName ?></span>
            <div class="user-avatar" style="background: var(--danger);"><?= $userInitials ?></div>
        </div>
    </header>

    <div class="admin-layout">
        <!-- Sidebar -->
        <aside class="admin-sidebar">
            <a href="<?= $basePath ?>" class="active"><i class="fas fa-th-large"></i> Dashboard</a>
            
            <h3>Acadêmico</h3>
            <a href="<?= $basePath ?>/cursos.php"><i class="fas fa-book"></i> Cursos</a>
            <a href="<?= $basePath ?>/disciplinas.php"><i class="fas fa-layer-group"></i> Disciplinas</a>
            <a href="<?= $basePath ?>/turmas.php"><i class="fas fa-users-class"></i> Turmas</a>
            
            <h3>Usuários</h3>
            <a href="<?= $basePath ?>/alunos.php"><i class="fas fa-user-graduate"></i> Alunos</a>
            <a href="<?= $basePath ?>/professores.php"><i class="fas fa-chalkboard-teacher"></i> Professores</a>
            <a href="<?= $basePath ?>/admins.php"><i class="fas fa-user-shield"></i> Administradores</a>
            
            <h3>Conteúdo</h3>
            <a href="<?= $basePath ?>/videos.php"><i class="fas fa-video"></i> Vídeos</a>
            <a href="<?= $basePath ?>/materiais.php"><i class="fas fa-file-alt"></i> Materiais</a>
            
            <h3>Relatórios</h3>
            <a href="<?= $basePath ?>/relatorios.php"><i class="fas fa-chart-bar"></i> Estatísticas</a>
            <a href="<?= $basePath ?>/logs.php"><i class="fas fa-history"></i> Logs</a>
            
            <h3>Sistema</h3>
            <a href="<?= $basePath ?>/configuracoes.php"><i class="fas fa-cog"></i> Configurações</a>
        </aside>

        <!-- Main Content -->
        <main style="padding: 2rem;">
            <div class="page-header fade-in">
                <h1 class="page-title">Dashboard Administrativo</h1>
                <p class="page-subtitle">Visão geral do sistema UniPlus</p>
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
                    <span class="trend-up" style="font-size: 0.85rem; font-weight: 600;"><?= $s['trend'] ?></span>
                </div>
                <?php endforeach; ?>
            </div>

            <!-- Two Column -->
            <div style="display: grid; grid-template-columns: 1.5fr 1fr; gap: 2rem; margin-top: 2rem;">
                <!-- Cursos -->
                <div class="glass fade-in" style="padding: 1.5rem;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                        <h3><i class="fas fa-book" style="color: var(--primary);"></i> Cursos</h3>
                        <a href="<?= $basePath ?>/cursos.php" class="btn btn-secondary" style="padding: 8px 16px; font-size: 0.85rem;">Ver Todos</a>
                    </div>
                    
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th>Curso</th>
                                    <th>Alunos</th>
                                    <th>Disciplinas</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($cursos as $c): ?>
                                <tr>
                                    <td style="font-weight: 500;"><?= $c['name'] ?></td>
                                    <td><?= $c['alunos'] ?></td>
                                    <td><?= $c['disciplinas'] ?></td>
                                    <td><a href="#" style="color: var(--primary);"><i class="fas fa-eye"></i></a></td>
                                </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Atividades Recentes -->
                <div class="glass fade-in stagger-2" style="padding: 1.5rem;">
                    <h3 style="margin-bottom: 1.5rem;"><i class="fas fa-clock" style="color: var(--accent);"></i> Atividades Recentes</h3>
                    
                    <?php foreach ($recentActivities as $a): ?>
                    <div style="display: flex; gap: 1rem; padding: 1rem 0; border-bottom: 1px solid rgba(255,255,255,0.1);">
                        <div style="width: 40px; height: 40px; border-radius: 50%; background: var(--gradient); display: flex; align-items: center; justify-content: center; font-size: 0.8rem; font-weight: 600;">
                            <?= substr($a['user'], 0, 1) ?>
                        </div>
                        <div style="flex: 1;">
                            <p><strong><?= $a['user'] ?></strong> <?= $a['action'] ?></p>
                            <p style="font-size: 0.9rem; color: var(--secondary);"><?= $a['item'] ?></p>
                        </div>
                        <span style="font-size: 0.8rem; color: rgba(255,255,255,0.5);"><?= $a['time'] ?></span>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="glass fade-in" style="padding: 1.5rem; margin-top: 2rem;">
                <h3 style="margin-bottom: 1rem;"><i class="fas fa-bolt" style="color: var(--accent);"></i> Ações Rápidas</h3>
                <div style="display: flex; gap: 1rem; flex-wrap: wrap;">
                    <a href="<?= $basePath ?>/cursos.php?novo=1" class="btn btn-primary"><i class="fas fa-plus"></i> Novo Curso</a>
                    <a href="<?= $basePath ?>/alunos.php?novo=1" class="btn btn-secondary"><i class="fas fa-user-plus"></i> Matricular Aluno</a>
                    <a href="<?= $basePath ?>/professores.php?novo=1" class="btn btn-secondary"><i class="fas fa-user-tie"></i> Cadastrar Professor</a>
                    <a href="<?= $basePath ?>/relatorios.php" class="btn btn-secondary"><i class="fas fa-file-export"></i> Gerar Relatório</a>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
