# Storage Module - S3 Buckets
# Assets, Raw Videos, Processed Videos with lifecycle policies

locals {
  name_prefix   = "${var.project_name}-${var.environment}"
  bucket_prefix = "${var.project_name}-${var.account_id}-${var.environment}"
}

#------------------------------------------------------------------------------
# S3 Bucket - Static Assets (CSS, JS, Images)
#------------------------------------------------------------------------------
resource "aws_s3_bucket" "assets" {
  bucket        = "${local.bucket_prefix}-assets"
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-assets"
    Type = "static-assets"
  })
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#------------------------------------------------------------------------------
# S3 Bucket - Raw Videos (Uploads from professors)
#------------------------------------------------------------------------------
resource "aws_s3_bucket" "raw_videos" {
  bucket        = "${local.bucket_prefix}-raw-videos"
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-raw-videos"
    Type = "video-processing"
  })
}

resource "aws_s3_bucket_versioning" "raw_videos" {
  bucket = aws_s3_bucket.raw_videos.id
  versioning_configuration {
    status = "Disabled" # Raw videos don't need versioning
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "raw_videos" {
  bucket = aws_s3_bucket.raw_videos.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "raw_videos" {
  bucket = aws_s3_bucket.raw_videos.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable EventBridge notifications for video processing
resource "aws_s3_bucket_notification" "raw_videos" {
  bucket      = aws_s3_bucket.raw_videos.id
  eventbridge = true
}

# Lifecycle policy - delete raw videos after 7 days (already processed)
resource "aws_s3_bucket_lifecycle_configuration" "raw_videos" {
  bucket = aws_s3_bucket.raw_videos.id

  rule {
    id     = "delete-after-processing"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    expiration {
      days = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}


#------------------------------------------------------------------------------
# S3 Bucket - Processed Videos (HLS, MP4)
#------------------------------------------------------------------------------
resource "aws_s3_bucket" "processed_videos" {
  bucket        = "${local.bucket_prefix}-processed-videos"
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-processed-videos"
    Type = "video-processing"
  })
}

resource "aws_s3_bucket_versioning" "processed_videos" {
  bucket = aws_s3_bucket.processed_videos.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "processed_videos" {
  bucket = aws_s3_bucket.processed_videos.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "processed_videos" {
  bucket = aws_s3_bucket.processed_videos.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Intelligent tiering for cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "processed_videos" {
  bucket = aws_s3_bucket.processed_videos.id

  rule {
    id     = "intelligent-tiering"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}


#------------------------------------------------------------------------------
# S3 Bucket - User Uploads (documents, assignments)
#------------------------------------------------------------------------------
resource "aws_s3_bucket" "uploads" {
  bucket        = "${local.bucket_prefix}-uploads"
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-uploads"
    Type = "user-data"
  })
}

resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
