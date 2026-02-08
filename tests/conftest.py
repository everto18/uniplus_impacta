"""
Pytest configuration and fixtures for infrastructure tests.
"""
import os
import json
import pytest
import boto3
from botocore.config import Config


def get_environment():
    """Get current environment from env var or default to dev."""
    return os.environ.get('ENVIRONMENT', 'dev')


def get_project_name():
    """Get project name from env var or default."""
    return os.environ.get('PROJECT_NAME', 'uniplus')


def get_aws_region():
    """Get AWS region from env var or default."""
    return os.environ.get('AWS_REGION', 'sa-east-1')


@pytest.fixture(scope="session")
def aws_region():
    """AWS region fixture."""
    return get_aws_region()


@pytest.fixture(scope="session")
def environment():
    """Environment name fixture."""
    return get_environment()


@pytest.fixture(scope="session")
def project_name():
    """Project name fixture."""
    return get_project_name()


@pytest.fixture(scope="session")
def resource_prefix(project_name, environment):
    """Resource naming prefix."""
    return f"{project_name}-{environment}"


@pytest.fixture(scope="session")
def aws_account_id():
    """AWS Account ID fixture."""
    sts = boto3.client('sts')
    return sts.get_caller_identity()['Account']


@pytest.fixture(scope="session")
def bucket_prefix(project_name, aws_account_id, environment):
    """S3 bucket naming prefix (includes account ID)."""
    return f"{project_name}-{aws_account_id}-{environment}"


@pytest.fixture(scope="session")
def boto_config():
    """Boto3 configuration with retries."""
    return Config(
        retries={'max_attempts': 3, 'mode': 'standard'},
        connect_timeout=5,
        read_timeout=10
    )


@pytest.fixture(scope="session")
def s3_client(aws_region, boto_config):
    """S3 client fixture."""
    return boto3.client('s3', region_name=aws_region, config=boto_config)


@pytest.fixture(scope="session")
def lambda_client(aws_region, boto_config):
    """Lambda client fixture."""
    return boto3.client('lambda', region_name=aws_region, config=boto_config)


@pytest.fixture(scope="session")
def sfn_client(aws_region, boto_config):
    """Step Functions client fixture."""
    return boto3.client('stepfunctions', region_name=aws_region, config=boto_config)


@pytest.fixture(scope="session")
def sqs_client(aws_region, boto_config):
    """SQS client fixture."""
    return boto3.client('sqs', region_name=aws_region, config=boto_config)


@pytest.fixture(scope="session")
def iam_client(aws_region, boto_config):
    """IAM client fixture."""
    return boto3.client('iam', region_name=aws_region, config=boto_config)


@pytest.fixture(scope="session")
def rds_client(aws_region, boto_config):
    """RDS client fixture."""
    return boto3.client('rds', region_name=aws_region, config=boto_config)


@pytest.fixture(scope="session")
def ecs_client(aws_region, boto_config):
    """ECS client fixture."""
    return boto3.client('ecs', region_name=aws_region, config=boto_config)


@pytest.fixture(scope="session")
def ec2_client(aws_region, boto_config):
    """EC2 client fixture."""
    return boto3.client('ec2', region_name=aws_region, config=boto_config)


@pytest.fixture(scope="session")
def sns_client(aws_region, boto_config):
    """SNS client fixture."""
    return boto3.client('sns', region_name=aws_region, config=boto_config)


@pytest.fixture(scope="session")
def events_client(aws_region, boto_config):
    """EventBridge client fixture."""
    return boto3.client('events', region_name=aws_region, config=boto_config)


@pytest.fixture(scope="session")
def mediaconvert_client(aws_region, boto_config):
    """MediaConvert client fixture."""
    return boto3.client('mediaconvert', region_name=aws_region, config=boto_config)


def pytest_configure(config):
    """Add custom markers."""
    config.addinivalue_line("markers", "infrastructure: Infrastructure validation tests")
    config.addinivalue_line("markers", "s3: S3 bucket tests")
    config.addinivalue_line("markers", "lambda_fn: Lambda function tests")
    config.addinivalue_line("markers", "stepfunctions: Step Functions tests")
    config.addinivalue_line("markers", "sqs: SQS queue tests")
    config.addinivalue_line("markers", "iam: IAM tests")
    config.addinivalue_line("markers", "networking: VPC and networking tests")
    config.addinivalue_line("markers", "database: RDS database tests")
    config.addinivalue_line("markers", "compute: ECS and compute tests")


def pytest_collection_modifyitems(config, items):
    """Skip integration tests if no AWS credentials."""
    skip_integration = pytest.mark.skip(reason="AWS credentials not configured")
    
    for item in items:
        if "integration" in item.keywords:
            # Check if AWS credentials are available
            try:
                boto3.client('sts').get_caller_identity()
            except Exception:
                item.add_marker(skip_integration)
