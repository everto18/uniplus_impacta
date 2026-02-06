# Production Environment - Main Configuration
# UniPlus Platform - AWS Infrastructure

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.30"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  # S3 Backend with Native Locking (Terraform 1.10+)
  # IMPORTANT: First run 'terraform apply' in terraform/bootstrap/ to create the bucket
  backend "s3" {
    bucket       = "uniplus-terraform-state-395841058738"
    key          = "prod/terraform.tfstate"
    region       = "sa-east-1"
    encrypt      = true
    use_lockfile = true # S3 Native Locking - no DynamoDB needed!
  }
}

provider "aws" {
  region = local.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# Data sources
data "aws_caller_identity" "current" {}

#------------------------------------------------------------------------------
# Computed Locals (derived from config locals)
#------------------------------------------------------------------------------
locals {
  name_prefix = "${local.project_name}-${local.environment}"
  account_id  = data.aws_caller_identity.current.account_id
  region      = local.aws_region

  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "terraform"
    Team        = local.team_name
    CostCenter  = local.cost_center
    Owner       = local.owner_email
    Application = "uniplus-platform"
    Repository  = "github.com/your-org/bootcamp"
    CreatedBy   = "terraform-iac"
  }

  # Subnet CIDRs
  public_subnet_cidrs = [
    cidrsubnet(local.vpc_cidr, 8, 1),
    cidrsubnet(local.vpc_cidr, 8, 2),
    cidrsubnet(local.vpc_cidr, 8, 3)
  ]
  private_app_subnet_cidrs = [
    cidrsubnet(local.vpc_cidr, 8, 11),
    cidrsubnet(local.vpc_cidr, 8, 12),
    cidrsubnet(local.vpc_cidr, 8, 13)
  ]
  private_data_subnet_cidrs = [
    cidrsubnet(local.vpc_cidr, 8, 21),
    cidrsubnet(local.vpc_cidr, 8, 22),
    cidrsubnet(local.vpc_cidr, 8, 23)
  ]
}

#------------------------------------------------------------------------------
# Networking Module
#------------------------------------------------------------------------------
module "networking" {
  source = "../../modules/networking"

  project_name              = local.project_name
  environment               = local.environment
  vpc_cidr                  = local.vpc_cidr
  availability_zones        = local.availability_zones
  public_subnet_cidrs       = local.public_subnet_cidrs
  private_app_subnet_cidrs  = local.private_app_subnet_cidrs
  private_data_subnet_cidrs = local.private_data_subnet_cidrs
  enable_nat_gateway        = true
  single_nat_gateway        = false # HA: NAT per AZ

  tags = local.common_tags
}

#------------------------------------------------------------------------------
# Security Module
#------------------------------------------------------------------------------
module "security" {
  source = "../../modules/security"

  project_name = local.project_name
  environment  = local.environment
  vpc_id       = module.networking.vpc_id
  vpc_cidr     = local.vpc_cidr

  tags = local.common_tags
}

#------------------------------------------------------------------------------
# Database Module
#------------------------------------------------------------------------------
module "database" {
  source = "../../modules/database"

  project_name            = local.project_name
  environment             = local.environment
  vpc_id                  = module.networking.vpc_id
  subnet_ids              = module.networking.private_data_subnet_ids
  security_group_id       = module.security.rds_security_group_id
  db_name                 = local.db_name
  db_username             = local.db_username
  instance_class          = local.db_instance_class
  allocated_storage       = 100
  max_allocated_storage   = 500
  multi_az                = true # HA: Multi-AZ
  backup_retention_period = 30
  deletion_protection     = true
  skip_final_snapshot     = false

  tags = local.common_tags
}

#------------------------------------------------------------------------------
# Storage Module
#------------------------------------------------------------------------------
module "storage" {
  source = "../../modules/storage"

  project_name      = local.project_name
  environment       = local.environment
  account_id        = local.account_id
  force_destroy     = false # Protect production data
  enable_versioning = true

  tags = local.common_tags
}

#------------------------------------------------------------------------------
# Video Processing Module
#------------------------------------------------------------------------------
module "video_processing" {
  source = "../../modules/video-processing"

  project_name                = local.project_name
  environment                 = local.environment
  raw_videos_bucket_id        = module.storage.raw_videos_bucket_id
  raw_videos_bucket_arn       = module.storage.raw_videos_bucket_arn
  processed_videos_bucket_id  = module.storage.processed_videos_bucket_id
  processed_videos_bucket_arn = module.storage.processed_videos_bucket_arn
  lambda_execution_role_arn   = module.security.lambda_execution_role_arn
  lambda_execution_role_name  = module.security.lambda_execution_role_name
  mediaconvert_role_arn       = module.security.mediaconvert_role_arn

  tags = local.common_tags
}

#------------------------------------------------------------------------------
# Compute Module - Multiple Services with Independent Scaling
#------------------------------------------------------------------------------
module "compute" {
  source = "../../modules/compute"

  project_name                = local.project_name
  environment                 = local.environment
  vpc_id                      = module.networking.vpc_id
  public_subnet_ids           = module.networking.public_subnet_ids
  private_subnet_ids          = module.networking.private_app_subnet_ids
  alb_security_group_id       = module.security.alb_security_group_id
  ecs_security_group_id       = module.security.ecs_tasks_security_group_id
  ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.security.ecs_task_role_arn
  db_credentials_secret_arn   = module.database.db_credentials_secret_arn
  certificate_arn             = local.certificate_arn

  # Services configuration - each scales independently
  services = {
    portal-aluno = {
      container_image   = "${local.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/uniplus-portal-aluno:latest"
      container_port    = 80
      cpu               = 512
      memory            = 1024
      desired_count     = 3
      min_capacity      = 2
      max_capacity      = 15
      health_check_path = "/health"
      path_patterns     = ["/aluno/*", "/aluno"]
      priority          = 100
      environment_vars  = {}
    }
    portal-professor = {
      container_image   = "${local.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/uniplus-portal-professor:latest"
      container_port    = 80
      cpu               = 512
      memory            = 1024
      desired_count     = 2
      min_capacity      = 1
      max_capacity      = 8
      health_check_path = "/health"
      path_patterns     = ["/professor/*", "/professor"]
      priority          = 200
      environment_vars  = {}
    }
    sistema-academico = {
      container_image   = "${local.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/uniplus-sistema-academico:latest"
      container_port    = 80
      cpu               = 512
      memory            = 1024
      desired_count     = 2
      min_capacity      = 1
      max_capacity      = 6
      health_check_path = "/health"
      path_patterns     = ["/academico/*", "/academico"]
      priority          = 300
      environment_vars  = {}
    }
    video-api = {
      container_image   = "${local.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/uniplus-video-api:latest"
      container_port    = 3000
      cpu               = 512
      memory            = 1024
      desired_count     = 2
      min_capacity      = 1
      max_capacity      = 10
      health_check_path = "/health"
      path_patterns     = ["/api/videos/*", "/api/videos"]
      priority          = 400
      environment_vars = {
        RAW_BUCKET       = module.storage.raw_videos_bucket_id
        PROCESSED_BUCKET = module.storage.processed_videos_bucket_id
      }
    }
  }

  default_service = "portal-aluno"

  tags = local.common_tags
}


#------------------------------------------------------------------------------
# CDN Module
#------------------------------------------------------------------------------
module "cdn" {
  source = "../../modules/cdn"

  project_name                        = local.project_name
  environment                         = local.environment
  alb_dns_name                        = module.compute.alb_dns_name
  assets_bucket_domain_name           = module.storage.assets_bucket_domain_name
  processed_videos_bucket_domain_name = module.storage.processed_videos_bucket_domain_name
  assets_bucket_id                    = module.storage.assets_bucket_id
  processed_videos_bucket_id          = module.storage.processed_videos_bucket_id
  domain_name                         = local.domain_name
  certificate_arn                     = local.cloudfront_certificate_arn
  price_class                         = "PriceClass_All" # Global distribution

  tags = local.common_tags
}
