# CDN Module - CloudFront Distribution
# Global CDN for assets, videos, and application

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Origin IDs
  alb_origin_id    = "alb-origin"
  assets_origin_id = "s3-assets-origin"
  videos_origin_id = "s3-videos-origin"
}

data "aws_caller_identity" "current" {}

#------------------------------------------------------------------------------
# Origin Access Control for S3
#------------------------------------------------------------------------------
resource "aws_cloudfront_origin_access_control" "assets" {
  name                              = "${local.name_prefix}-assets-oac"
  description                       = "OAC for assets bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "videos" {
  name                              = "${local.name_prefix}-videos-oac"
  description                       = "OAC for videos bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#------------------------------------------------------------------------------
# CloudFront Distribution
#------------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${local.name_prefix} CDN"
  default_root_object = ""
  price_class         = var.price_class
  aliases             = var.domain_name != "" && var.certificate_arn != "" ? [var.domain_name, "www.${var.domain_name}"] : []

  # Origin: Application Load Balancer
  origin {
    domain_name = var.alb_dns_name
    origin_id   = local.alb_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # ALB handles HTTPS termination
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Origin: Assets S3 Bucket
  origin {
    domain_name              = var.assets_bucket_domain_name
    origin_id                = local.assets_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.assets.id
  }

  # Origin: Videos S3 Bucket
  origin {
    domain_name              = var.processed_videos_bucket_domain_name
    origin_id                = local.videos_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.videos.id
  }

  # Default behavior - ALB (application)
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.alb_origin_id

    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin", "Authorization"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
  }

  # Cache behavior: Static assets
  ordered_cache_behavior {
    path_pattern     = "/assets/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.assets_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400    # 1 day
    max_ttl                = 31536000 # 1 year
    compress               = true
  }

  # Cache behavior: Videos (HLS segments)
  ordered_cache_behavior {
    path_pattern     = "/videos/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.videos_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400  # 1 day
    max_ttl                = 604800 # 1 week
    compress               = true
  }

  # Geo restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # SSL Certificate
  viewer_certificate {
    cloudfront_default_certificate = var.certificate_arn == ""
    acm_certificate_arn            = var.certificate_arn != "" ? var.certificate_arn : null
    ssl_support_method             = var.certificate_arn != "" ? "sni-only" : null
    minimum_protocol_version       = var.certificate_arn != "" ? "TLSv1.2_2021" : null
  }

  # Custom error responses
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-cdn"
  })
}

#------------------------------------------------------------------------------
# S3 Bucket Policies for CloudFront OAC
#------------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "assets" {
  bucket = var.assets_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${var.assets_bucket_id}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main.arn
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "videos" {
  bucket = var.processed_videos_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${var.processed_videos_bucket_id}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main.arn
          }
        }
      }
    ]
  })
}
