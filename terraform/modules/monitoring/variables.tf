variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "cluster_name" {
  description = "ECS Cluster Name"
  type        = string
}

variable "service_names" {
  description = "List of ECS Service Names"
  type        = list(string)
}

variable "alb_arn_suffix" {
  description = "ALB ARN Suffix for metrics"
  type        = string
}

variable "target_group_arn_suffixes" {
  description = "Map of Target Group ARN Suffixes for metrics"
  type        = map(string)
}
