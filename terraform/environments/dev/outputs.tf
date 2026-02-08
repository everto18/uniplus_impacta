# Development Environment - Outputs

# Networking
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private app subnet IDs"
  value       = module.networking.private_app_subnet_ids
}

output "private_data_subnet_ids" {
  description = "Private data subnet IDs"
  value       = module.networking.private_data_subnet_ids
}

# Database
output "database_endpoint" {
  description = "RDS endpoint"
  value       = module.database.db_instance_endpoint
}

output "database_credentials_secret_arn" {
  description = "ARN of database credentials secret"
  value       = module.database.db_credentials_secret_arn
}

# Compute
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.compute.alb_dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.compute.cluster_name
}

output "ecs_service_names" {
  description = "ECS service names"
  value       = module.compute.service_names
}

# Storage
output "assets_bucket" {
  description = "Assets S3 bucket"
  value       = module.storage.assets_bucket_id
}

output "raw_videos_bucket" {
  description = "Raw videos S3 bucket"
  value       = module.storage.raw_videos_bucket_id
}

output "processed_videos_bucket" {
  description = "Processed videos S3 bucket"
  value       = module.storage.processed_videos_bucket_id
}

# CDN
output "cloudfront_distribution_domain" {
  description = "CloudFront distribution domain"
  value       = module.cdn.distribution_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cdn.distribution_id
}

# Video Processing
output "video_processing_queue_url" {
  description = "SQS queue URL for video processing"
  value       = module.video_processing.video_processing_queue_url
}

output "video_notifications_topic_arn" {
  description = "SNS topic ARN for video notifications"
  value       = module.video_processing.video_notifications_topic_arn
}

#------------------------------------------------------------------------------
# Access URLs (use these to access the application)
#------------------------------------------------------------------------------
output "app_url" {
  description = "Main application URL via CloudFront"
  value       = "https://${module.cdn.distribution_domain_name}"
}

output "portal_aluno_url" {
  description = "Portal do Aluno URL"
  value       = "https://${module.cdn.distribution_domain_name}/aluno"
}

output "portal_professor_url" {
  description = "Portal do Professor URL"
  value       = "https://${module.cdn.distribution_domain_name}/professor"
}

output "sistema_academico_url" {
  description = "Sistema Acadêmico URL"
  value       = "https://${module.cdn.distribution_domain_name}/academico"
}

output "video_api_url" {
  description = "Video API URL"
  value       = "https://${module.cdn.distribution_domain_name}/api/videos"
}

output "alb_direct_url" {
  description = "Direct ALB URL (without CloudFront)"
  value       = "http://${module.compute.alb_dns_name}"
}

# Monitoring
output "cloudwatch_dashboard_url" {
  description = "CloudWatch Dashboard URL"
  value       = module.monitoring.dashboard_url
}
