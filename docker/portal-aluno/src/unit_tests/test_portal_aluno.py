"""
Unit tests for UniPlus Portal Aluno PHP files.
Tests validate file structure, HTML content, and mock data integrity.
"""
import os
import pytest

# Base path for portal-aluno source files (relative to this test file)
PORTAL_ALUNO_SRC = os.path.dirname(os.path.dirname(__file__))


class TestPortalAlunoFiles:
    """Test that all required files exist in portal-aluno."""

    def test_index_php_exists(self):
        """Test that index.php exists."""
        assert os.path.exists(os.path.join(PORTAL_ALUNO_SRC, 'index.php'))

    def test_aulas_php_exists(self):
        """Test that aulas.php exists."""
        assert os.path.exists(os.path.join(PORTAL_ALUNO_SRC, 'aulas.php'))

    def test_assistir_php_exists(self):
        """Test that assistir.php exists."""
        assert os.path.exists(os.path.join(PORTAL_ALUNO_SRC, 'assistir.php'))

    def test_health_php_exists(self):
        """Test that health.php exists."""
        assert os.path.exists(os.path.join(PORTAL_ALUNO_SRC, 'health.php'))

    def test_css_exists(self):
        """Test that style.css exists."""
        css_path = os.path.join(PORTAL_ALUNO_SRC, 'assets', 'css', 'style.css')
        assert os.path.exists(css_path)

    def test_js_exists(self):
        """Test that app.js exists."""
        js_path = os.path.join(PORTAL_ALUNO_SRC, 'assets', 'js', 'app.js')
        assert os.path.exists(js_path)


class TestPortalAlunoIndexContent:
    """Test index.php content and structure."""

    @pytest.fixture
    def index_content(self):
        """Load index.php content."""
        with open(os.path.join(PORTAL_ALUNO_SRC, 'index.php'), 'r', encoding='utf-8') as f:
            return f.read()

    def test_has_doctype(self, index_content):
        """Test that index.php has HTML5 doctype."""
        assert '<!DOCTYPE html>' in index_content

    def test_has_meta_viewport(self, index_content):
        """Test that index.php has viewport meta tag for responsiveness."""
        assert 'viewport' in index_content

    def test_has_title(self, index_content):
        """Test that index.php has a title."""
        assert '<title>' in index_content
        assert 'UniPlus' in index_content

    def test_has_css_link(self, index_content):
        """Test that index.php links to style.css."""
        assert 'style.css' in index_content

    def test_has_navigation(self, index_content):
        """Test that index.php has navigation menu."""
        assert '<nav' in index_content
        assert 'Aulas' in index_content

    def test_has_stats_section(self, index_content):
        """Test that index.php has statistics cards."""
        assert 'stat-card' in index_content
        assert 'Disciplinas' in index_content

    def test_has_disciplines_mock_data(self, index_content):
        """Test that index.php has mock discipline data."""
        assert '$disciplines' in index_content
        assert 'Algoritmos' in index_content
        assert 'Banco de Dados' in index_content

    def test_has_footer(self, index_content):
        """Test that index.php has footer."""
        assert '<footer' in index_content or 'footer' in index_content


class TestPortalAlunoAulasContent:
    """Test aulas.php content and structure."""

    @pytest.fixture
    def aulas_content(self):
        """Load aulas.php content."""
        with open(os.path.join(PORTAL_ALUNO_SRC, 'aulas.php'), 'r', encoding='utf-8') as f:
            return f.read()

    def test_has_lesson_list(self, aulas_content):
        """Test that aulas.php has lesson listing."""
        assert '$aulas' in aulas_content or 'aula' in aulas_content.lower()

    def test_has_search_functionality(self, aulas_content):
        """Test that aulas.php has search input."""
        assert 'search' in aulas_content.lower() or 'buscar' in aulas_content.lower()

    def test_has_filter_by_discipline(self, aulas_content):
        """Test that aulas.php has discipline filter."""
        assert 'disciplina' in aulas_content.lower()

    def test_has_lesson_cards(self, aulas_content):
        """Test that aulas.php displays lesson cards."""
        assert 'card' in aulas_content.lower()


class TestPortalAlunoAssistirContent:
    """Test assistir.php content and structure."""

    @pytest.fixture
    def assistir_content(self):
        """Load assistir.php content."""
        with open(os.path.join(PORTAL_ALUNO_SRC, 'assistir.php'), 'r', encoding='utf-8') as f:
            return f.read()

    def test_has_video_player(self, assistir_content):
        """Test that assistir.php has video player."""
        assert 'video' in assistir_content.lower()

    def test_has_videojs(self, assistir_content):
        """Test that assistir.php uses Video.js for HLS streaming."""
        assert 'video.js' in assistir_content.lower() or 'videojs' in assistir_content.lower()

    def test_has_hls_support(self, assistir_content):
        """Test that assistir.php supports HLS streaming."""
        assert 'hls' in assistir_content.lower() or 'm3u8' in assistir_content.lower()

    def test_has_lesson_info(self, assistir_content):
        """Test that assistir.php displays lesson information."""
        assert 'title' in assistir_content.lower() or 'titulo' in assistir_content.lower()


class TestPortalAlunoHealthCheck:
    """Test health.php endpoint."""

    @pytest.fixture
    def health_content(self):
        """Load health.php content."""
        with open(os.path.join(PORTAL_ALUNO_SRC, 'health.php'), 'r', encoding='utf-8') as f:
            return f.read()

    def test_returns_json(self, health_content):
        """Test that health.php returns JSON."""
        assert 'json' in health_content.lower()
        assert 'application/json' in health_content

    def test_has_status_field(self, health_content):
        """Test that health.php returns status field."""
        assert 'status' in health_content

    def test_has_service_name(self, health_content):
        """Test that health.php includes service name."""
        assert 'portal-aluno' in health_content


class TestPortalAlunoCSS:
    """Test style.css content."""

    @pytest.fixture
    def css_content(self):
        """Load style.css content."""
        css_path = os.path.join(PORTAL_ALUNO_SRC, 'assets', 'css', 'style.css')
        with open(css_path, 'r', encoding='utf-8') as f:
            return f.read()

    def test_has_css_variables(self, css_content):
        """Test that CSS uses custom properties (variables)."""
        assert ':root' in css_content
        assert '--primary' in css_content

    def test_has_glassmorphism(self, css_content):
        """Test that CSS implements glassmorphism effect."""
        assert 'backdrop-filter' in css_content or 'blur' in css_content

    def test_has_gradient(self, css_content):
        """Test that CSS has gradient definitions."""
        assert 'gradient' in css_content.lower()

    def test_has_animations(self, css_content):
        """Test that CSS has animations."""
        assert '@keyframes' in css_content or 'animation' in css_content

    def test_has_responsive_design(self, css_content):
        """Test that CSS has media queries for responsiveness."""
        assert '@media' in css_content

    def test_has_dark_theme(self, css_content):
        """Test that CSS implements dark theme."""
        assert '#0f0f1a' in css_content or '#1a1a2e' in css_content or 'dark' in css_content.lower()
