<?php
// Sistema Acadêmico - Cursos
$basePath = '/academico';
$currentPage = 'cursos';
$userName = 'Admin Sistema';
$userInitials = 'AS';

$cursos = [
    ['id' => 1, 'name' => 'Análise e Desenvolvimento de Sistemas', 'codigo' => 'ADS', 'alunos' => 850, 'disciplinas' => 24, 'status' => 'ativo'],
    ['id' => 2, 'name' => 'Ciência da Computação', 'codigo' => 'CC', 'alunos' => 620, 'disciplinas' => 32, 'status' => 'ativo'],
    ['id' => 3, 'name' => 'Engenharia de Software', 'codigo' => 'ES', 'alunos' => 480, 'disciplinas' => 28, 'status' => 'ativo'],
    ['id' => 4, 'name' => 'Sistemas de Informação', 'codigo' => 'SI', 'alunos' => 500, 'disciplinas' => 26, 'status' => 'ativo'],
    ['id' => 5, 'name' => 'Ciência de Dados', 'codigo' => 'CD', 'alunos' => 0, 'disciplinas' => 20, 'status' => 'novo'],
];
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cursos - UniPlus</title>
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
    </style>
</head>
<body>
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
        </div>

        <div class="user-menu">
            <span><?= $userName ?></span>
            <div class="user-avatar" style="background: var(--danger);"><?= $userInitials ?></div>
        </div>
    </header>

    <div class="admin-layout">
        <aside class="admin-sidebar">
            <a href="<?= $basePath ?>"><i class="fas fa-th-large"></i> Dashboard</a>
            <h3>Acadêmico</h3>
            <a href="<?= $basePath ?>/cursos.php" class="active"><i class="fas fa-book"></i> Cursos</a>
            <a href="<?= $basePath ?>/disciplinas.php"><i class="fas fa-layer-group"></i> Disciplinas</a>
            <a href="<?= $basePath ?>/turmas.php"><i class="fas fa-users-class"></i> Turmas</a>
            <h3>Usuários</h3>
            <a href="<?= $basePath ?>/alunos.php"><i class="fas fa-user-graduate"></i> Alunos</a>
            <a href="<?= $basePath ?>/professores.php"><i class="fas fa-chalkboard-teacher"></i> Professores</a>
        </aside>

        <main style="padding: 2rem;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem;">
                <div>
                    <h1 class="page-title"><i class="fas fa-book" style="color: var(--primary);"></i> Cursos</h1>
                    <p class="page-subtitle">Gerencie os cursos da instituição</p>
                </div>
                <button class="btn btn-primary"><i class="fas fa-plus"></i> Novo Curso</button>
            </div>

            <div class="glass" style="padding: 1.5rem;">
                <div style="display: flex; gap: 1rem; margin-bottom: 1.5rem;">
                    <input type="text" placeholder="Buscar curso..." class="form-input" style="max-width: 300px;">
                    <select class="form-input" style="max-width: 200px;">
                        <option>Todos os status</option>
                        <option>Ativos</option>
                        <option>Inativos</option>
                        <option>Novos</option>
                    </select>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>Código</th>
                            <th>Nome do Curso</th>
                            <th>Alunos</th>
                            <th>Disciplinas</th>
                            <th>Status</th>
                            <th>Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($cursos as $c): ?>
                        <tr>
                            <td><span class="badge badge-info"><?= $c['codigo'] ?></span></td>
                            <td style="font-weight: 500;"><?= $c['name'] ?></td>
                            <td><?= number_format($c['alunos']) ?></td>
                            <td><?= $c['disciplinas'] ?></td>
                            <td>
                                <?php if ($c['status'] === 'ativo'): ?>
                                <span class="badge badge-success"><i class="fas fa-check"></i> Ativo</span>
                                <?php else: ?>
                                <span class="badge badge-warning"><i class="fas fa-star"></i> Novo</span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <div style="display: flex; gap: 0.5rem;">
                                    <button class="btn btn-secondary" style="padding: 8px;"><i class="fas fa-eye"></i></button>
                                    <button class="btn btn-secondary" style="padding: 8px;"><i class="fas fa-edit"></i></button>
                                    <button class="btn btn-secondary" style="padding: 8px;"><i class="fas fa-trash"></i></button>
                                </div>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
</body>
</html>
