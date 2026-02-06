# Video Processing Module - Outputs

output "video_processing_queue_arn" {
  description = "ARN of the video processing SQS queue"
  value       = aws_sqs_queue.video_processing.arn
}

output "video_processing_queue_url" {
  description = "URL of the video processing SQS queue"
  value       = aws_sqs_queue.video_processing.url
}

output "video_processing_dlq_arn" {
  description = "ARN of the video processing DLQ"
  value       = aws_sqs_queue.video_processing_dlq.arn
}

output "video_processor_lambda_arn" {
  description = "ARN of the video processor Lambda function"
  value       = aws_lambda_function.video_processor.arn
}

output "video_processor_lambda_name" {
  description = "Name of the video processor Lambda function"
  value       = aws_lambda_function.video_processor.function_name
}

output "mediaconvert_queue_arn" {
  description = "ARN of the MediaConvert queue"
  value       = aws_media_convert_queue.main.arn
}

output "video_notifications_topic_arn" {
  description = "ARN of the SNS topic for video notifications"
  value       = aws_sns_topic.video_notifications.arn
}

output "eventbridge_rule_video_uploaded_arn" {
  description = "ARN of the EventBridge rule for video uploads"
  value       = aws_cloudwatch_event_rule.video_uploaded.arn
}

output "eventbridge_rule_mc_complete_arn" {
  description = "ARN of the EventBridge rule for MediaConvert completion"
  value       = aws_cloudwatch_event_rule.mediaconvert_complete.arn
}

output "step_functions_state_machine_arn" {
  description = "ARN of the Step Functions state machine for video processing"
  value       = aws_sfn_state_machine.video_processor.arn
}

output "step_functions_state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = aws_sfn_state_machine.video_processor.name
}

output "eventbridge_pipe_arn" {
  description = "ARN of the EventBridge Pipe (SQS → Step Functions)"
  value       = aws_pipes_pipe.sqs_to_sfn.arn
}

output "eventbridge_pipe_name" {
  description = "Name of the EventBridge Pipe"
  value       = aws_pipes_pipe.sqs_to_sfn.name
}
