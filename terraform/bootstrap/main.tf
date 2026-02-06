# Terraform Backend Infrastructure (S3 Native Locking - Terraform 1.10+)
# Run this FIRST to create the S3 bucket for state management
# No DynamoDB needed - uses S3 native conditional writes for locking

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.30"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "uniplus"
      ManagedBy = "terraform"
      Purpose   = "terraform-state"
    }
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "sa-east-1"
}

variable "project_name" {
  description = "Project name for bucket naming"
  type        = string
  default     = "uniplus"
}

data "aws_caller_identity" "current" {}

locals {
  bucket_name = "${var.project_name}-terraform-state-${data.aws_caller_identity.current.account_id}"
}

#------------------------------------------------------------------------------
# S3 Bucket for Terraform State (with Native Locking support)
#------------------------------------------------------------------------------
resource "aws_s3_bucket" "terraform_state" {
  bucket = local.bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "Terraform State Bucket"
  }
}

# Enable versioning (REQUIRED for state recovery)
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle rule - keep old versions for 90 days
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

#------------------------------------------------------------------------------
# Outputs
#------------------------------------------------------------------------------
output "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "backend_config" {
  description = "Backend configuration to use in your Terraform files"
  value       = <<-EOT
    
    # Add this to your Terraform configuration (Terraform 1.10+):
    terraform {
      backend "s3" {
        bucket       = "${aws_s3_bucket.terraform_state.id}"
        key          = "ENV_NAME/terraform.tfstate"  # Replace ENV_NAME with dev or prod
        region       = "${var.aws_region}"
        encrypt      = true
        use_lockfile = true  # S3 Native Locking - no DynamoDB needed!
      }
    }
    
  EOT
}
