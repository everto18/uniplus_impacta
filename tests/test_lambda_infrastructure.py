"""
Lambda Functions Infrastructure Tests
Validates Lambda functions are configured correctly.
"""
import pytest
from botocore.exceptions import ClientError


@pytest.mark.infrastructure
@pytest.mark.lambda_fn
@pytest.mark.integration
class TestLambdaFunctions:
    """Test suite for Lambda function configurations."""

    def test_video_processor_lambda_exists(self, lambda_client, resource_prefix):
        """Verify video processor Lambda function exists."""
        function_name = f"{resource_prefix}-video-processor"
        
        try:
            response = lambda_client.get_function(FunctionName=function_name)
            assert response['Configuration']['FunctionName'] == function_name
        except ClientError as e:
            pytest.fail(f"Lambda {function_name} does not exist: {e}")

    def test_batch_trigger_lambda_exists(self, lambda_client, resource_prefix):
        """Verify batch trigger Lambda function exists."""
        function_name = f"{resource_prefix}-video-batch-trigger"
        
        try:
            response = lambda_client.get_function(FunctionName=function_name)
            assert response['Configuration']['FunctionName'] == function_name
        except ClientError as e:
            pytest.fail(f"Lambda {function_name} does not exist: {e}")

    def test_video_processor_runtime(self, lambda_client, resource_prefix):
        """Verify video processor uses Python 3.11 runtime."""
        function_name = f"{resource_prefix}-video-processor"
        
        response = lambda_client.get_function(FunctionName=function_name)
        runtime = response['Configuration']['Runtime']
        
        assert runtime == 'python3.11', \
            f"Expected runtime python3.11, got {runtime}"

    def test_video_processor_timeout(self, lambda_client, resource_prefix):
        """Verify video processor has appropriate timeout."""
        function_name = f"{resource_prefix}-video-processor"
        
        response = lambda_client.get_function(FunctionName=function_name)
        timeout = response['Configuration']['Timeout']
        
        # Should be at least 300 seconds (5 min) for video processing
        assert timeout >= 300, \
            f"Timeout too low: {timeout}s (should be >= 300s)"

    def test_video_processor_memory(self, lambda_client, resource_prefix):
        """Verify video processor has sufficient memory."""
        function_name = f"{resource_prefix}-video-processor"
        
        response = lambda_client.get_function(FunctionName=function_name)
        memory = response['Configuration']['MemorySize']
        
        # Should have at least 256MB for video processing
        assert memory >= 256, \
            f"Memory too low: {memory}MB (should be >= 256MB)"

    def test_video_processor_environment_variables(self, lambda_client, resource_prefix):
        """Verify video processor has required environment variables."""
        function_name = f"{resource_prefix}-video-processor"
        
        response = lambda_client.get_function(FunctionName=function_name)
        env_vars = response['Configuration'].get('Environment', {}).get('Variables', {})
        
        required_vars = ['OUTPUT_BUCKET', 'MEDIACONVERT_ROLE', 'ENVIRONMENT']
        
        for var in required_vars:
            assert var in env_vars, \
                f"Missing required environment variable: {var}"

    def test_batch_trigger_environment_variables(self, lambda_client, resource_prefix):
        """Verify batch trigger has required environment variables."""
        function_name = f"{resource_prefix}-video-batch-trigger"
        
        response = lambda_client.get_function(FunctionName=function_name)
        env_vars = response['Configuration'].get('Environment', {}).get('Variables', {})
        
        required_vars = ['STATE_MACHINE_ARN', 'BATCH_SIZE']
        
        for var in required_vars:
            assert var in env_vars, \
                f"Missing required environment variable: {var}"

    def test_lambdas_have_execution_role(self, lambda_client, resource_prefix):
        """Verify Lambda functions have execution roles attached."""
        functions = [
            f"{resource_prefix}-video-processor",
            f"{resource_prefix}-video-batch-trigger"
        ]
        
        for function_name in functions:
            try:
                response = lambda_client.get_function(FunctionName=function_name)
                role = response['Configuration'].get('Role')
                
                assert role is not None, \
                    f"No execution role attached to {function_name}"
                assert 'arn:aws:iam::' in role, \
                    f"Invalid role ARN for {function_name}: {role}"
            except ClientError as e:
                pytest.fail(f"Failed to check {function_name}: {e}")
