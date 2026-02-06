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
        """Verify queue visibility timeout is appropriate for Lambda."""
        queue_name = f"{resource_prefix}-video-processing"
        
        response = sqs_client.get_queue_url(QueueName=queue_name)
        queue_url = response['QueueUrl']
        
        attrs = sqs_client.get_queue_attributes(
            QueueUrl=queue_url,
            AttributeNames=['VisibilityTimeout']
        )
        
        visibility_timeout = int(attrs['Attributes']['VisibilityTimeout'])
        
        # Should be at least 900 seconds (15 min) for video processing
        assert visibility_timeout >= 900, \
            f"Visibility timeout too low: {visibility_timeout}s (should be >= 900s)"

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
        
        # Should have long polling enabled (> 0)
        assert wait_time > 0, \
            f"Long polling not enabled (ReceiveMessageWaitTimeSeconds = {wait_time})"

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
        
        # DLQ should retain messages for at least 7 days (604800 seconds)
        assert retention >= 604800, \
            f"DLQ retention too short: {retention}s (should be >= 7 days)"
