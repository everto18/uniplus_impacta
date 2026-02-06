# Additional Local Values and Data Sources

# Get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # AWS Account and Region
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # Subnets CIDR calculation
  # Public subnets: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24
  # Private App subnets: 10.0.11.0/24, 10.0.12.0/24, 10.0.13.0/24
  # Private Data subnets: 10.0.21.0/24, 10.0.22.0/24, 10.0.23.0/24
  public_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, 8, 1),
    cidrsubnet(var.vpc_cidr, 8, 2),
    cidrsubnet(var.vpc_cidr, 8, 3)
  ]

  private_app_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, 8, 11),
    cidrsubnet(var.vpc_cidr, 8, 12),
    cidrsubnet(var.vpc_cidr, 8, 13)
  ]

  private_data_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, 8, 21),
    cidrsubnet(var.vpc_cidr, 8, 22),
    cidrsubnet(var.vpc_cidr, 8, 23)
  ]

  # Environment-specific configurations
  env_config = {
    dev = {
      multi_az              = false
      deletion_protection   = false
      backup_retention_days = 7
      min_capacity          = 1
      max_capacity          = 2
      enable_monitoring     = false
    }
    staging = {
      multi_az              = false
      deletion_protection   = false
      backup_retention_days = 14
      min_capacity          = 1
      max_capacity          = 4
      enable_monitoring     = true
    }
    prod = {
      multi_az              = true
      deletion_protection   = true
      backup_retention_days = 30
      min_capacity          = 2
      max_capacity          = 10
      enable_monitoring     = true
    }
  }

  # Get current environment config
  current_env_config = local.env_config[var.environment]

  # S3 bucket naming (globally unique)
  s3_bucket_prefix = "${var.project_name}-${local.account_id}-${var.environment}"

  # Resource naming convention
  resource_name = {
    vpc         = "${local.name_prefix}-vpc"
    alb         = "${local.name_prefix}-alb"
    ecs_cluster = "${local.name_prefix}-cluster"
    rds         = "${local.name_prefix}-db"
    elasticache = "${local.name_prefix}-cache"
    cloudfront  = "${local.name_prefix}-cdn"
  }
}
