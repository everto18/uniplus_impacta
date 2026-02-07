# Video Processing Module - EventBridge, SQS, EventBridge Pipes, Step Functions, Lambda, MediaConvert
# Full pipeline: S3 → EventBridge → SQS → EventBridge Pipes → Step Functions → Lambda → MediaConvert

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

#------------------------------------------------------------------------------
# SQS - Dead Letter Queue
#------------------------------------------------------------------------------
resource "aws_sqs_queue" "video_processing_dlq" {
  name = "${local.name_prefix}-video-dlq"

  message_retention_seconds = 1209600 # 14 days
  sqs_managed_sse_enabled   = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-video-dlq"
    Type = "video-processing"
  })
}

#------------------------------------------------------------------------------
# SQS - Video Processing Queue
#------------------------------------------------------------------------------
resource "aws_sqs_queue" "video_processing" {
  name = "${local.name_prefix}-video-processing"

  visibility_timeout_seconds = 300   # 5 min (Step Functions timeout)
  message_retention_seconds  = 86400 # 1 day
  receive_wait_time_seconds  = 20    # Long polling
  sqs_managed_sse_enabled    = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.video_processing_dlq.arn
    maxReceiveCount     = 3
  })

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-video-processing"
    Type = "video-processing"
  })
}

# SQS Queue Policy - Allow EventBridge to send messages
resource "aws_sqs_queue_policy" "video_processing" {
  queue_url = aws_sqs_queue.video_processing.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEventBridge"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.video_processing.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.video_uploaded.arn
          }
        }
      }
    ]
  })
}

#------------------------------------------------------------------------------
# EventBridge Rule - Video Upload Detection
#------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "video_uploaded" {
  name        = "${local.name_prefix}-video-uploaded"
  description = "Trigger video processing when video is uploaded to S3"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [var.raw_videos_bucket_id]
      }
      object = {
        key = [
          { suffix = ".mp4" },
          { suffix = ".mov" },
          { suffix = ".avi" },
          { suffix = ".mkv" },
          { suffix = ".MP4" },
          { suffix = ".MOV" }
        ]
      }
    }
  })

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-video-uploaded"
    Type = "video-processing"
  })
}

# EventBridge Target - Send to SQS
resource "aws_cloudwatch_event_target" "video_to_sqs" {
  rule      = aws_cloudwatch_event_rule.video_uploaded.name
  target_id = "send-to-video-processing-queue"
  arn       = aws_sqs_queue.video_processing.arn

  input_transformer {
    input_paths = {
      bucket    = "$.detail.bucket.name"
      key       = "$.detail.object.key"
      size      = "$.detail.object.size"
      requestId = "$.detail.request-id"
    }
    input_template = <<EOF
{
  "bucket": "<bucket>",
  "key": "<key>",
  "size": "<size>",
  "requestId": "<requestId>",
  "timestamp": "<aws.events.event.ingestion-time>"
}
EOF
  }
}

#------------------------------------------------------------------------------
# EventBridge Pipes - SQS → Step Functions
#------------------------------------------------------------------------------
resource "aws_iam_role" "pipes" {
  name = "${local.name_prefix}-pipes-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pipes.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "pipes" {
  name = "${local.name_prefix}-pipes-policy"
  role = aws_iam_role.pipes.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SQSSource"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.video_processing.arn
      },
      {
        Sid    = "StepFunctionsTarget"
        Effect = "Allow"
        Action = [
          "states:StartExecution"
        ]
        Resource = aws_sfn_state_machine.video_processor.arn
      }
    ]
  })
}

resource "aws_pipes_pipe" "sqs_to_sfn" {
  name     = "${local.name_prefix}-video-pipe"
  role_arn = aws_iam_role.pipes.arn

  source = aws_sqs_queue.video_processing.arn
  target = aws_sfn_state_machine.video_processor.arn

  source_parameters {
    sqs_queue_parameters {
      batch_size                         = 1
      maximum_batching_window_in_seconds = 0
    }
  }

  target_parameters {
    step_function_state_machine_parameters {
      invocation_type = "FIRE_AND_FORGET"
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-video-pipe"
    Type = "video-processing"
  })
}

#------------------------------------------------------------------------------
# Lambda Function - Video Processor
#------------------------------------------------------------------------------

# Package Lambda code
data "archive_file" "video_processor" {
  type        = "zip"
  output_path = "${path.module}/lambda/video_processor.zip"

  source {
    content  = file("${path.module}/lambda/index.py")
    filename = "index.py"
  }
}

resource "aws_lambda_function" "video_processor" {
  function_name = "${local.name_prefix}-video-processor"
  role          = var.lambda_execution_role_arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 300 # 5 minutes
  memory_size   = 256

  filename         = data.archive_file.video_processor.output_path
  source_code_hash = data.archive_file.video_processor.output_base64sha256

  environment {
    variables = {
      OUTPUT_BUCKET     = var.processed_videos_bucket_id
      MEDIACONVERT_ROLE = var.mediaconvert_role_arn
      ENVIRONMENT       = var.environment
      AWS_REGION_NAME   = data.aws_region.current.name
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-video-processor"
    Type = "video-processing"
  })
}

# Additional IAM permissions for Lambda
resource "aws_iam_role_policy" "video_processor" {
  name = "${local.name_prefix}-video-processor-policy"
  role = var.lambda_execution_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:HeadObject"
        ]
        Resource = "${var.raw_videos_bucket_arn}/*"
      },
      {
        Sid    = "S3OutputAccess"
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "${var.processed_videos_bucket_arn}/*"
      },
      {
        Sid    = "MediaConvertAccess"
        Effect = "Allow"
        Action = [
          "mediaconvert:CreateJob",
          "mediaconvert:GetJob",
          "mediaconvert:DescribeEndpoints"
        ]
        Resource = "*"
      },
      {
        Sid    = "PassRoleToMediaConvert"
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = var.mediaconvert_role_arn
      }
    ]
  })
}

#------------------------------------------------------------------------------
# MediaConvert Queue
#------------------------------------------------------------------------------
resource "aws_media_convert_queue" "main" {
  name   = "${local.name_prefix}-video-queue"
  status = "ACTIVE"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-video-queue"
    Type = "video-processing"
  })
}

#------------------------------------------------------------------------------
# SNS Topic - Video Processing Notifications
#------------------------------------------------------------------------------
resource "aws_sns_topic" "video_notifications" {
  name              = "${local.name_prefix}-video-notifications"
  kms_master_key_id = "alias/aws/sns"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-video-notifications"
    Type = "video-processing"
  })
}

resource "aws_sns_topic_policy" "video_notifications" {
  arn = aws_sns_topic.video_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEventBridge"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.video_notifications.arn
      }
    ]
  })
}

#------------------------------------------------------------------------------
# EventBridge Rule - MediaConvert Job Complete
#------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "mediaconvert_complete" {
  name        = "${local.name_prefix}-mc-complete"
  description = "Trigger when MediaConvert job completes"

  event_pattern = jsonencode({
    source      = ["aws.mediaconvert"]
    detail-type = ["MediaConvert Job State Change"]
    detail = {
      status = ["COMPLETE", "ERROR"]
    }
  })

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-mc-complete"
    Type = "video-processing"
  })
}

# Notify via SNS when job completes
resource "aws_cloudwatch_event_target" "mc_to_sns" {
  rule      = aws_cloudwatch_event_rule.mediaconvert_complete.name
  target_id = "notify-video-complete"
  arn       = aws_sns_topic.video_notifications.arn

  input_transformer {
    input_paths = {
      status = "$.detail.status"
      jobId  = "$.detail.jobId"
    }
    input_template = <<EOF
{
  "message": "Video processing <status>",
  "jobId": "<jobId>",
  "status": "<status>"
}
EOF
  }
}

#------------------------------------------------------------------------------
# CloudWatch Alarms
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${local.name_prefix}-video-dlq-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Messages in video processing DLQ"

  dimensions = {
    QueueName = aws_sqs_queue.video_processing_dlq.name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.name_prefix}-video-processor-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Video processor Lambda errors"

  dimensions = {
    FunctionName = aws_lambda_function.video_processor.function_name
  }

  tags = var.tags
}

#------------------------------------------------------------------------------
# Step Functions - Video Processing Orchestrator
#------------------------------------------------------------------------------

# IAM Role for Step Functions
resource "aws_iam_role" "step_functions" {
  name = "${local.name_prefix}-sfn-video-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "step_functions" {
  name = "${local.name_prefix}-sfn-video-policy"
  role = aws_iam_role.step_functions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "InvokeLambda"
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          aws_lambda_function.video_processor.arn,
          "${aws_lambda_function.video_processor.arn}:*"
        ]
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      },
      {
        Sid    = "XRay"
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets"
        ]
        Resource = "*"
      },
      {
        Sid    = "SNSPublish"
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.video_notifications.arn
      }
    ]
  })
}

# Step Functions State Machine - Video Processing
resource "aws_sfn_state_machine" "video_processor" {
  name     = "${local.name_prefix}-video-processor"
  role_arn = aws_iam_role.step_functions.arn

  definition = jsonencode({
    Comment = "Process video: validate, transcode via Lambda+MediaConvert, notify"
    StartAt = "ParseSQSMessage"
    States = {
      # Parse the SQS message from EventBridge Pipes
      ParseSQSMessage = {
        Type = "Pass"
        Parameters = {
          "video.$" = "States.StringToJson($.body)"
        }
        ResultPath = "$.parsed"
        Next       = "ValidateInput"
      }

      ValidateInput = {
        Type = "Choice"
        Choices = [
          {
            And = [
              { Variable = "$.parsed.video.bucket", IsPresent = true },
              { Variable = "$.parsed.video.key", IsPresent = true }
            ]
            Next = "ProcessVideo"
          }
        ]
        Default = "InvalidInput"
      }

      InvalidInput = {
        Type  = "Fail"
        Error = "InvalidInputError"
        Cause = "Missing bucket or key in input"
      }

      ProcessVideo = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.video_processor.arn
          Payload = {
            "bucket.$" = "$.parsed.video.bucket"
            "key.$"    = "$.parsed.video.key"
          }
        }
        ResultPath = "$.lambdaResult"
        Next       = "CheckProcessingResult"
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.TooManyRequestsException"]
            IntervalSeconds = 5
            MaxAttempts     = 3
            BackoffRate     = 2
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            ResultPath  = "$.error"
            Next        = "NotifyError"
          }
        ]
      }

      CheckProcessingResult = {
        Type = "Choice"
        Choices = [
          {
            Variable      = "$.lambdaResult.Payload.statusCode"
            NumericEquals = 200
            Next          = "ProcessingComplete"
          }
        ]
        Default = "NotifyError"
      }

      ProcessingComplete = {
        Type     = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = aws_sns_topic.video_notifications.arn
          Message = {
            "status"    = "PROCESSING_STARTED"
            "bucket.$"  = "$.parsed.video.bucket"
            "key.$"     = "$.parsed.video.key"
            "jobId.$"   = "$.lambdaResult.Payload.body"
            "timestamp" = "$$.State.EnteredTime"
          }
        }
        End = true
      }

      NotifyError = {
        Type     = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = aws_sns_topic.video_notifications.arn
          Message = {
            "status"    = "ERROR"
            "bucket.$"  = "$.parsed.video.bucket"
            "key.$"     = "$.parsed.video.key"
            "error.$"   = "$.error"
            "timestamp" = "$$.State.EnteredTime"
          }
        }
        Next = "FailExecution"
      }

      FailExecution = {
        Type  = "Fail"
        Error = "VideoProcessingError"
        Cause = "Video processing failed"
      }
    }
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.step_functions.arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }

  tracing_configuration {
    enabled = true
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-video-processor"
    Type = "video-processing"
  })
}

# CloudWatch Log Group for Step Functions
resource "aws_cloudwatch_log_group" "step_functions" {
  name              = "/aws/states/${local.name_prefix}-video-processor"
  retention_in_days = 14

  tags = var.tags
}
