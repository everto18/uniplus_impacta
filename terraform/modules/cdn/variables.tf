# CDN Module - Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "alb_origin_id" {
  description = "Origin ID for ALB"
  type        = string
  default     = "alb"
}

variable "assets_bucket_domain_name" {
  description = "Domain name of assets S3 bucket"
  type        = string
}

variable "processed_videos_bucket_domain_name" {
  description = "Domain name of processed videos S3 bucket"
  type        = string
}

variable "processed_videos_bucket_id" {
  description = "ID of processed videos S3 bucket"
  type        = string
}

variable "assets_bucket_id" {
  description = "ID of assets S3 bucket"
  type        = string
}

variable "domain_name" {
  description = "Custom domain name"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ARN of ACM certificate (must be in us-east-1)"
  type        = string
  default     = ""
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100" # US, Canada, Europe
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
