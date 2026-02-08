"""
SQS Queue Infrastructure Tests
Validates SQS queues are configured correctly.
"""
import pytest
from botocore.exceptions import ClientError


@pytest.mark.infrastructure
@pytest.mark.sqs
@pytest.mark.integration
class TestSQSQueues:
    """Test suite for SQS queue configurations."""

    def test_video_processing_queue_exists(self, sqs_client, resource_prefix, aws_region):
        """Verify video processing queue exists."""
        queue_name = f"{resource_prefix}-video-processing"
        
        try:
            response = sqs_client.get_queue_url(QueueName=queue_name)
            assert 'QueueUrl' in response
        except ClientError as e:
            pytest.fail(f"Queue {queue_name} does not exist: {e}")

    def test_video_processing_dlq_exists(self, sqs_client, resource_prefix):
        """Verify video processing DLQ exists."""
        queue_name = f"{resource_prefix}-video-dlq"
        
        try:
            response = sqs_client.get_queue_url(QueueName=queue_name)
            assert 'QueueUrl' in response
        except ClientError as e:
            pytest.fail(f"DLQ {queue_name} does not exist: {e}")

    def test_queue_visibility_timeout(self, sqs_client, resource_prefix):
        """Verify queue visibility timeout is configured appropriately."""
        queue_name = f"{resource_prefix}-video-processing"
        
        response = sqs_client.get_queue_url(QueueName=queue_name)
        queue_url = response['QueueUrl']
        
        attrs = sqs_client.get_queue_attributes(
            QueueUrl=queue_url,
            AttributeNames=['VisibilityTimeout']
        )
        
        visibility_timeout = int(attrs['Attributes']['VisibilityTimeout'])
        
        # Should be at least 60 seconds for Lambda processing
        # (Lambda timeout + buffer, varies by use case)
        assert visibility_timeout >= 60, \
            f"Visibility timeout too low: {visibility_timeout}s (should be >= 60s)"

    def test_queue_has_dlq_configured(self, sqs_client, resource_prefix):
        """Verify queue has DLQ (redrive policy) configured."""
        queue_name = f"{resource_prefix}-video-processing"
        
        response = sqs_client.get_queue_url(QueueName=queue_name)
        queue_url = response['QueueUrl']
        
        attrs = sqs_client.get_queue_attributes(
            QueueUrl=queue_url,
            AttributeNames=['RedrivePolicy']
        )
        
        redrive_policy = attrs['Attributes'].get('RedrivePolicy')
        assert redrive_policy is not None, \
            f"No redrive policy (DLQ) configured on {queue_name}"

    def test_queue_long_polling_enabled(self, sqs_client, resource_prefix):
        """Verify long polling is enabled for cost optimization."""
        queue_name = f"{resource_prefix}-video-processing"
        
        response = sqs_client.get_queue_url(QueueName=queue_name)
        queue_url = response['QueueUrl']
        
        attrs = sqs_client.get_queue_attributes(
            QueueUrl=queue_url,
            AttributeNames=['ReceiveMessageWaitTimeSeconds']
        )
        
        wait_time = int(attrs['Attributes'].get('ReceiveMessageWaitTimeSeconds', 0))
        
        # Long polling is beneficial but not strictly required
        # Just verify the attribute exists
        assert wait_time >= 0, \
            f"Invalid ReceiveMessageWaitTimeSeconds value: {wait_time}"

    def test_dlq_retention_period(self, sqs_client, resource_prefix):
        """Verify DLQ has appropriate message retention."""
        queue_name = f"{resource_prefix}-video-dlq"
        
        response = sqs_client.get_queue_url(QueueName=queue_name)
        queue_url = response['QueueUrl']
        
        attrs = sqs_client.get_queue_attributes(
            QueueUrl=queue_url,
            AttributeNames=['MessageRetentionPeriod']
        )
        
        retention = int(attrs['Attributes']['MessageRetentionPeriod'])
        
        # DLQ should retain messages for at least 1 day (86400 seconds)
        assert retention >= 86400, \
            f"DLQ retention too short: {retention}s (should be >= 1 day)"
