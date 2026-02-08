# Development Environment - Main Configuration
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
  backend "s3" {
    bucket       = "uniplus-terraform-state-395841058738"
    key          = "dev/terraform.tfstate"
    region       = "sa-east-1"
    encrypt      = true
    use_lockfile = true
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
    DeleteAfter = "2026-03-31" # Para recursos temporários de dev
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
# ECR Module - Container Registries
#------------------------------------------------------------------------------
module "ecr" {
  source = "../../modules/ecr"

  services = ["portal-aluno", "portal-professor", "sistema-academico", "video-api"]
  tags     = local.common_tags
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
  single_nat_gateway        = true # Cost saving for dev

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
  allocated_storage       = 20 # Mínimo permitido
  max_allocated_storage   = 20 # Sem autoscaling
  multi_az                = false
  backup_retention_period = 0 # Sem backup
  deletion_protection     = false
  skip_final_snapshot     = true

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
  force_destroy     = true  # Allow destruction in dev
  enable_versioning = false # Disable for dev

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

  # Services configuration - dev uses minimal resources
  services = {
    portal-aluno = {
      container_image   = "${local.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/uniplus-portal-aluno:dev"
      container_port    = 80
      cpu               = 256
      memory            = 512
      desired_count     = 1
      min_capacity      = 1
      max_capacity      = 1 # Single task
      health_check_path = "/health"
      path_patterns     = ["/aluno/*", "/aluno"]
      priority          = 100
      environment_vars  = {}
    }
    portal-professor = {
      container_image   = "${local.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/uniplus-portal-professor:dev"
      container_port    = 80
      cpu               = 256
      memory            = 512
      desired_count     = 1
      min_capacity      = 1
      max_capacity      = 1 # Single task
      health_check_path = "/health"
      path_patterns     = ["/professor/*", "/professor"]
      priority          = 200
      environment_vars  = {}
    }
    sistema-academico = {
      container_image   = "${local.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/uniplus-sistema-academico:dev"
      container_port    = 80
      cpu               = 256
      memory            = 512
      desired_count     = 1
      min_capacity      = 1
      max_capacity      = 1 # Single task
      health_check_path = "/health"
      path_patterns     = ["/academico/*", "/academico"]
      priority          = 300
      environment_vars  = {}
    }
    video-api = {
      container_image   = "${local.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/uniplus-video-api:dev"
      container_port    = 3000
      cpu               = 256
      memory            = 512
      desired_count     = 1
      min_capacity      = 1
      max_capacity      = 1 # Single task
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

  # Scheduled Scaling desabilitado - DEV usa task fixa
  # Para produção, descomentar e ajustar conforme necessidade
  # scheduled_scaling = { ... }

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
  price_class                         = "PriceClass_100"

  # Configuração de Domínio Personalizado (Opção 2)
  # Para usar www.uniplus.com.br (Registro.br), descomente abaixo:
  # aliases         = ["www.uniplus.com.br"]
  # certificate_arn = "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/..."

  tags = local.common_tags
}

#------------------------------------------------------------------------------
# Monitoring Module (CloudWatch Dashboard)
#------------------------------------------------------------------------------
module "monitoring" {
  source = "../../modules/monitoring"

  project_name              = local.project_name
  environment               = local.environment
  aws_region                = local.aws_region
  cluster_name              = module.compute.cluster_name
  service_names             = module.compute.service_names
  alb_arn_suffix            = module.compute.alb_arn_suffix
  target_group_arn_suffixes = module.compute.target_group_arn_suffixes
}

#------------------------------------------------------------------------------
# S3 CORS Configuration (after CDN to use CloudFront domain)
# This overrides the default CORS in storage module with CloudFront URL
#------------------------------------------------------------------------------
locals {
  cloudfront_origins = ["https://${module.cdn.distribution_domain_name}"]
}

resource "aws_s3_bucket_cors_configuration" "assets_cloudfront" {
  bucket = module.storage.assets_bucket_id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = local.cloudfront_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket_cors_configuration" "processed_videos_cloudfront" {
  bucket = module.storage.processed_videos_bucket_id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = local.cloudfront_origins
    expose_headers  = ["ETag", "Content-Length", "Content-Type"]
    max_age_seconds = 86400
  }
}

resource "aws_s3_bucket_cors_configuration" "raw_videos_cloudfront" {
  bucket = module.storage.raw_videos_bucket_id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = local.cloudfront_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket_cors_configuration" "uploads_cloudfront" {
  bucket = module.storage.uploads_bucket_id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE"]
    allowed_origins = local.cloudfront_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
}
