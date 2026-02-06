# Video Processing Module - Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "raw_videos_bucket_id" {
  description = "ID of the raw videos S3 bucket"
  type        = string
}

variable "raw_videos_bucket_arn" {
  description = "ARN of the raw videos S3 bucket"
  type        = string
}

variable "processed_videos_bucket_id" {
  description = "ID of the processed videos S3 bucket"
  type        = string
}

variable "processed_videos_bucket_arn" {
  description = "ARN of the processed videos S3 bucket"
  type        = string
}

variable "lambda_execution_role_arn" {
  description = "ARN of Lambda execution role"
  type        = string
}

variable "lambda_execution_role_name" {
  description = "Name of Lambda execution role"
  type        = string
}

variable "mediaconvert_role_arn" {
  description = "ARN of MediaConvert role"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for Lambda"
  type        = string
  default     = null
}

variable "lambda_subnet_ids" {
  description = "Subnet IDs for Lambda"
  type        = list(string)
  default     = []
}

variable "lambda_security_group_id" {
  description = "Security group ID for Lambda"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
