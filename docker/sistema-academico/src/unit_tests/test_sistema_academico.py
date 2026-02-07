"""
Unit tests for UniPlus Sistema Academico PHP files.
Tests validate file structure, HTML content, and mock data integrity.
"""
import os
import pytest

# Base path for sistema-academico source files (relative to this test file)
SISTEMA_ACADEMICO_SRC = os.path.dirname(os.path.dirname(__file__))


class TestSistemaAcademicoFiles:
    """Test that all required files exist in sistema-academico."""

    def test_index_php_exists(self):
        """Test that index.php exists."""
        assert os.path.exists(os.path.join(SISTEMA_ACADEMICO_SRC, 'index.php'))

    def test_cursos_php_exists(self):
        """Test that cursos.php exists."""
        assert os.path.exists(os.path.join(SISTEMA_ACADEMICO_SRC, 'cursos.php'))

    def test_health_php_exists(self):
        """Test that health.php exists."""
        assert os.path.exists(os.path.join(SISTEMA_ACADEMICO_SRC, 'health.php'))

    def test_css_exists(self):
        """Test that style.css exists."""
        css_path = os.path.join(SISTEMA_ACADEMICO_SRC, 'assets', 'css', 'style.css')
        assert os.path.exists(css_path)


class TestSistemaAcademicoIndexContent:
    """Test index.php content and structure."""

    @pytest.fixture
    def index_content(self):
        """Load index.php content."""
        with open(os.path.join(SISTEMA_ACADEMICO_SRC, 'index.php'), 'r', encoding='utf-8') as f:
            return f.read()

    def test_has_doctype(self, index_content):
        """Test that index.php has HTML5 doctype."""
        assert '<!DOCTYPE html>' in index_content

    def test_has_admin_layout(self, index_content):
        """Test that index.php has admin layout with sidebar."""
        assert 'sidebar' in index_content.lower() or 'admin-sidebar' in index_content

    def test_has_dashboard_stats(self, index_content):
        """Test that index.php has dashboard statistics."""
        assert 'stat' in index_content.lower()
        assert 'Alunos' in index_content
        assert 'Professores' in index_content

    def test_has_navigation_menu(self, index_content):
        """Test that index.php has sidebar navigation."""
        assert 'Cursos' in index_content
        assert 'Disciplinas' in index_content
        assert 'Turmas' in index_content

    def test_has_courses_section(self, index_content):
        """Test that index.php has courses section."""
        assert '$cursos' in index_content or 'cursos' in index_content.lower()

    def test_has_recent_activities(self, index_content):
        """Test that index.php has recent activities feed."""
        assert 'recente' in index_content.lower() or 'atividade' in index_content.lower()

    def test_has_quick_actions(self, index_content):
        """Test that index.php has quick action buttons."""
        assert 'Novo Curso' in index_content or 'novo' in index_content.lower()


class TestSistemaAcademicoCursosContent:
    """Test cursos.php content and structure."""

    @pytest.fixture
    def cursos_content(self):
        """Load cursos.php content."""
        with open(os.path.join(SISTEMA_ACADEMICO_SRC, 'cursos.php'), 'r', encoding='utf-8') as f:
            return f.read()

    def test_has_courses_table(self, cursos_content):
        """Test that cursos.php has courses table."""
        assert '<table' in cursos_content or 'table' in cursos_content.lower()

    def test_has_course_data(self, cursos_content):
        """Test that cursos.php has course mock data."""
        assert '$cursos' in cursos_content
        assert 'Análise' in cursos_content or 'ADS' in cursos_content

    def test_has_crud_actions(self, cursos_content):
        """Test that cursos.php has CRUD action buttons."""
        assert 'edit' in cursos_content.lower() or 'editar' in cursos_content.lower()
        assert 'eye' in cursos_content.lower() or 'ver' in cursos_content.lower()

    def test_has_search_filter(self, cursos_content):
        """Test that cursos.php has search/filter functionality."""
        assert 'search' in cursos_content.lower() or 'buscar' in cursos_content.lower()

    def test_has_status_badges(self, cursos_content):
        """Test that cursos.php shows course status."""
        assert 'status' in cursos_content.lower() or 'badge' in cursos_content.lower()


class TestSistemaAcademicoHealthCheck:
    """Test health.php endpoint."""

    @pytest.fixture
    def health_content(self):
        """Load health.php content."""
        with open(os.path.join(SISTEMA_ACADEMICO_SRC, 'health.php'), 'r', encoding='utf-8') as f:
            return f.read()

    def test_returns_json(self, health_content):
        """Test that health.php returns JSON."""
        assert 'json' in health_content.lower()

    def test_has_status_field(self, health_content):
        """Test that health.php returns status field."""
        assert 'status' in health_content

    def test_has_service_name(self, health_content):
        """Test that health.php includes service name."""
        assert 'sistema-academico' in health_content
