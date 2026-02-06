# Storage Module - Outputs

output "assets_bucket_id" {
  description = "ID of the assets bucket"
  value       = aws_s3_bucket.assets.id
}

output "assets_bucket_arn" {
  description = "ARN of the assets bucket"
  value       = aws_s3_bucket.assets.arn
}

output "assets_bucket_domain_name" {
  description = "Domain name of the assets bucket"
  value       = aws_s3_bucket.assets.bucket_regional_domain_name
}

output "raw_videos_bucket_id" {
  description = "ID of the raw videos bucket"
  value       = aws_s3_bucket.raw_videos.id
}

output "raw_videos_bucket_arn" {
  description = "ARN of the raw videos bucket"
  value       = aws_s3_bucket.raw_videos.arn
}

output "processed_videos_bucket_id" {
  description = "ID of the processed videos bucket"
  value       = aws_s3_bucket.processed_videos.id
}

output "processed_videos_bucket_arn" {
  description = "ARN of the processed videos bucket"
  value       = aws_s3_bucket.processed_videos.arn
}

output "processed_videos_bucket_domain_name" {
  description = "Domain name of the processed videos bucket"
  value       = aws_s3_bucket.processed_videos.bucket_regional_domain_name
}

output "uploads_bucket_id" {
  description = "ID of the uploads bucket"
  value       = aws_s3_bucket.uploads.id
}

output "uploads_bucket_arn" {
  description = "ARN of the uploads bucket"
  value       = aws_s3_bucket.uploads.arn
}
