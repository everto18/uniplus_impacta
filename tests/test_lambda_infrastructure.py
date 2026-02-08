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

    def test_video_processor_runtime(self, lambda_client, resource_prefix):
        """Verify video processor uses Python 3.11 runtime."""
        function_name = f"{resource_prefix}-video-processor"
        
        try:
            response = lambda_client.get_function(FunctionName=function_name)
            runtime = response['Configuration']['Runtime']
            
            assert runtime == 'python3.11', \
                f"Expected runtime python3.11, got {runtime}"
        except ClientError as e:
            pytest.skip(f"Lambda {function_name} not found: {e}")

    def test_video_processor_timeout(self, lambda_client, resource_prefix):
        """Verify video processor has appropriate timeout."""
        function_name = f"{resource_prefix}-video-processor"
        
        try:
            response = lambda_client.get_function(FunctionName=function_name)
            timeout = response['Configuration']['Timeout']
            
            # Should be at least 60 seconds for video processing initiation
            assert timeout >= 60, \
                f"Timeout too low: {timeout}s (should be >= 60s)"
        except ClientError as e:
            pytest.skip(f"Lambda {function_name} not found: {e}")

    def test_video_processor_memory(self, lambda_client, resource_prefix):
        """Verify video processor has sufficient memory."""
        function_name = f"{resource_prefix}-video-processor"
        
        try:
            response = lambda_client.get_function(FunctionName=function_name)
            memory = response['Configuration']['MemorySize']
            
            # Should have at least 128MB for video processing
            assert memory >= 128, \
                f"Memory too low: {memory}MB (should be >= 128MB)"
        except ClientError as e:
            pytest.skip(f"Lambda {function_name} not found: {e}")

    def test_video_processor_environment_variables(self, lambda_client, resource_prefix):
        """Verify video processor has required environment variables."""
        function_name = f"{resource_prefix}-video-processor"
        
        try:
            response = lambda_client.get_function(FunctionName=function_name)
            env_vars = response['Configuration'].get('Environment', {}).get('Variables', {})
            
            # Check for essential environment variables
            required_vars = ['ENVIRONMENT']
            
            for var in required_vars:
                assert var in env_vars, \
                    f"Missing required environment variable: {var}"
        except ClientError as e:
            pytest.skip(f"Lambda {function_name} not found: {e}")

    def test_lambdas_have_execution_role(self, lambda_client, resource_prefix):
        """Verify Lambda functions have execution roles attached."""
        function_name = f"{resource_prefix}-video-processor"
        
        try:
            response = lambda_client.get_function(FunctionName=function_name)
            role = response['Configuration'].get('Role')
            
            assert role is not None, \
                f"No execution role attached to {function_name}"
            assert 'arn:aws:iam::' in role, \
                f"Invalid role ARN for {function_name}: {role}"
        except ClientError as e:
            pytest.skip(f"Lambda {function_name} not found: {e}")

    def test_video_processor_vpc_config(self, lambda_client, resource_prefix):
        """Verify video processor Lambda is configured with VPC (optional)."""
        function_name = f"{resource_prefix}-video-processor"
        
        try:
            response = lambda_client.get_function(FunctionName=function_name)
            vpc_config = response['Configuration'].get('VpcConfig', {})
            
            # VPC config is optional but should be valid if present
            if vpc_config and vpc_config.get('SubnetIds'):
                assert len(vpc_config['SubnetIds']) > 0, \
                    "VPC config present but no subnets configured"
        except ClientError as e:
            pytest.skip(f"Lambda {function_name} not found: {e}")
