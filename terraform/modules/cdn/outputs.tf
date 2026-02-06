# CDN Module - Outputs

output "distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.id
}

output "distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.arn
}

output "distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "distribution_hosted_zone_id" {
  description = "Hosted zone ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}

output "assets_oac_id" {
  description = "ID of the assets Origin Access Control"
  value       = aws_cloudfront_origin_access_control.assets.id
}

output "videos_oac_id" {
  description = "ID of the videos Origin Access Control"
  value       = aws_cloudfront_origin_access_control.videos.id
}
