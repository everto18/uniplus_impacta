"""
Unit tests for UniPlus Portal Professor PHP files.
Tests validate file structure, HTML content, and mock data integrity.
"""
import os
import pytest

# Base path for portal-professor source files (relative to this test file)
PORTAL_PROFESSOR_SRC = os.path.dirname(os.path.dirname(__file__))


class TestPortalProfessorFiles:
    """Test that all required files exist in portal-professor."""

    def test_index_php_exists(self):
        """Test that index.php exists."""
        assert os.path.exists(os.path.join(PORTAL_PROFESSOR_SRC, 'index.php'))

    def test_upload_php_exists(self):
        """Test that upload.php exists."""
        assert os.path.exists(os.path.join(PORTAL_PROFESSOR_SRC, 'upload.php'))

    def test_turmas_php_exists(self):
        """Test that turmas.php exists."""
        assert os.path.exists(os.path.join(PORTAL_PROFESSOR_SRC, 'turmas.php'))

    def test_health_php_exists(self):
        """Test that health.php exists."""
        assert os.path.exists(os.path.join(PORTAL_PROFESSOR_SRC, 'health.php'))

    def test_css_exists(self):
        """Test that style.css exists."""
        css_path = os.path.join(PORTAL_PROFESSOR_SRC, 'assets', 'css', 'style.css')
        assert os.path.exists(css_path)


class TestPortalProfessorIndexContent:
    """Test index.php content and structure."""

    @pytest.fixture
    def index_content(self):
        """Load index.php content."""
        with open(os.path.join(PORTAL_PROFESSOR_SRC, 'index.php'), 'r', encoding='utf-8') as f:
            return f.read()

    def test_has_doctype(self, index_content):
        """Test that index.php has HTML5 doctype."""
        assert '<!DOCTYPE html>' in index_content

    def test_has_professor_dashboard(self, index_content):
        """Test that index.php has professor dashboard elements."""
        assert 'professor' in index_content.lower()

    def test_has_turmas_section(self, index_content):
        """Test that index.php has classes section."""
        assert 'turma' in index_content.lower()

    def test_has_stats(self, index_content):
        """Test that index.php has statistics."""
        assert 'stat' in index_content.lower()
        assert 'Alunos' in index_content

    def test_has_upload_link(self, index_content):
        """Test that index.php has link to upload page."""
        assert 'upload' in index_content.lower()

    def test_has_mock_turmas_data(self, index_content):
        """Test that index.php has mock class data."""
        assert '$turmas' in index_content
        assert 'Algoritmos' in index_content


class TestPortalProfessorUploadContent:
    """Test upload.php content and structure."""

    @pytest.fixture
    def upload_content(self):
        """Load upload.php content."""
        with open(os.path.join(PORTAL_PROFESSOR_SRC, 'upload.php'), 'r', encoding='utf-8') as f:
            return f.read()

    def test_has_upload_form(self, upload_content):
        """Test that upload.php has upload form."""
        assert 'form' in upload_content.lower() or 'upload' in upload_content.lower()

    def test_has_drag_drop_zone(self, upload_content):
        """Test that upload.php has drag and drop zone."""
        assert 'drag' in upload_content.lower() or 'drop' in upload_content.lower()

    def test_has_file_input(self, upload_content):
        """Test that upload.php has file input."""
        assert 'file' in upload_content.lower()
        assert 'input' in upload_content.lower()

    def test_has_video_formats(self, upload_content):
        """Test that upload.php mentions supported video formats."""
        assert 'mp4' in upload_content.lower() or 'video' in upload_content.lower()

    def test_has_discipline_selector(self, upload_content):
        """Test that upload.php has discipline selector."""
        assert 'disciplina' in upload_content.lower()

    def test_has_javascript_handlers(self, upload_content):
        """Test that upload.php has JavaScript for upload handling."""
        assert '<script' in upload_content
        assert 'addEventListener' in upload_content or 'handleFiles' in upload_content


class TestPortalProfessorTurmasContent:
    """Test turmas.php content and structure."""

    @pytest.fixture
    def turmas_content(self):
        """Load turmas.php content."""
        with open(os.path.join(PORTAL_PROFESSOR_SRC, 'turmas.php'), 'r', encoding='utf-8') as f:
            return f.read()

    def test_has_turmas_list(self, turmas_content):
        """Test that turmas.php displays class list."""
        assert '$turmas' in turmas_content

    def test_has_class_details(self, turmas_content):
        """Test that turmas.php shows class details."""
        assert 'alunos' in turmas_content.lower()
        assert 'aulas' in turmas_content.lower()

    def test_has_progress_indicator(self, turmas_content):
        """Test that turmas.php shows progress."""
        assert 'progress' in turmas_content.lower()

    def test_has_class_cards(self, turmas_content):
        """Test that turmas.php uses card layout."""
        assert 'card' in turmas_content.lower()


class TestPortalProfessorHealthCheck:
    """Test health.php endpoint."""

    @pytest.fixture
    def health_content(self):
        """Load health.php content."""
        with open(os.path.join(PORTAL_PROFESSOR_SRC, 'health.php'), 'r', encoding='utf-8') as f:
            return f.read()

    def test_returns_json(self, health_content):
        """Test that health.php returns JSON."""
        assert 'json' in health_content.lower()

    def test_has_status_field(self, health_content):
        """Test that health.php returns status field."""
        assert 'status' in health_content

    def test_has_service_name(self, health_content):
        """Test that health.php includes service name."""
        assert 'portal-professor' in health_content
