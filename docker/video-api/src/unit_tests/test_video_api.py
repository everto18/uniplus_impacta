"""
Unit tests for UniPlus Video API PHP files.
Tests validate file structure, API endpoints, and response format.
"""
import os
import pytest

# Base path for video-api source files (relative to this test file)
VIDEO_API_SRC = os.path.dirname(os.path.dirname(__file__))


class TestVideoApiFiles:
    """Test that all required files exist in video-api."""

    def test_index_php_exists(self):
        """Test that index.php exists."""
        assert os.path.exists(os.path.join(VIDEO_API_SRC, 'index.php'))

    def test_health_php_exists(self):
        """Test that health.php exists."""
        assert os.path.exists(os.path.join(VIDEO_API_SRC, 'health.php'))


class TestVideoApiIndexContent:
    """Test index.php API content and structure."""

    @pytest.fixture
    def index_content(self):
        """Load index.php content."""
        with open(os.path.join(VIDEO_API_SRC, 'index.php'), 'r', encoding='utf-8') as f:
            return f.read()

    def test_returns_json(self, index_content):
        """Test that API returns JSON."""
        assert 'application/json' in index_content
        assert 'json_encode' in index_content

    def test_has_cors_headers(self, index_content):
        """Test that API has CORS headers."""
        assert 'Access-Control-Allow-Origin' in index_content
        assert 'Access-Control-Allow-Methods' in index_content

    def test_has_video_list_endpoint(self, index_content):
        """Test that API has video list endpoint."""
        assert '$videos' in index_content
        assert 'GET' in index_content

    def test_has_video_mock_data(self, index_content):
        """Test that API has mock video data."""
        assert 'title' in index_content
        assert 'duration' in index_content
        assert 'thumbnail' in index_content

    def test_has_upload_endpoint(self, index_content):
        """Test that API has upload endpoint."""
        assert 'upload' in index_content.lower()
        assert 'POST' in index_content

    def test_has_presigned_url_generation(self, index_content):
        """Test that API generates presigned URLs for upload."""
        assert 'upload_url' in index_content or 'presigned' in index_content.lower()

    def test_has_video_status_endpoint(self, index_content):
        """Test that API has video status endpoint."""
        assert 'status' in index_content.lower()
        assert 'processing' in index_content.lower()

    def test_has_pagination(self, index_content):
        """Test that API supports pagination."""
        assert 'page' in index_content.lower()
        assert 'limit' in index_content.lower()

    def test_has_hls_url(self, index_content):
        """Test that API returns HLS streaming URLs."""
        assert 'm3u8' in index_content or 'hls' in index_content.lower()

    def test_has_error_handling(self, index_content):
        """Test that API has error handling."""
        assert '404' in index_content or 'not found' in index_content.lower()
        assert 'error' in index_content.lower()

    def test_has_available_endpoints_documentation(self, index_content):
        """Test that API documents available endpoints."""
        assert 'available_endpoints' in index_content or 'endpoints' in index_content


class TestVideoApiHealthCheck:
    """Test health.php endpoint."""

    @pytest.fixture
    def health_content(self):
        """Load health.php content."""
        with open(os.path.join(VIDEO_API_SRC, 'health.php'), 'r', encoding='utf-8') as f:
            return f.read()

    def test_returns_json(self, health_content):
        """Test that health.php returns JSON."""
        assert 'json' in health_content.lower()
        assert 'application/json' in health_content

    def test_has_status_field(self, health_content):
        """Test that health.php returns status field."""
        assert 'status' in health_content
        assert 'healthy' in health_content

    def test_has_service_name(self, health_content):
        """Test that health.php includes service name."""
        assert 'video-api' in health_content

    def test_has_version(self, health_content):
        """Test that health.php includes version."""
        assert 'version' in health_content

    def test_has_timestamp(self, health_content):
        """Test that health.php includes timestamp."""
        assert 'timestamp' in health_content
