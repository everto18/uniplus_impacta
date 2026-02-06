# Production Environment - Local Configuration
# All environment-specific values defined here instead of terraform.tfvars

locals {
  #----------------------------------------------------------------------------
  # Project Configuration
  #----------------------------------------------------------------------------
  project_name = "uniplus"
  environment  = "prod"
  aws_region   = "sa-east-1"

  team_name   = "platform-engineering"
  cost_center = "education-tech"
  owner_email = "devops@uniplus.com"

  #----------------------------------------------------------------------------
  # Networking Configuration
  #----------------------------------------------------------------------------
  vpc_cidr           = "10.1.0.0/16" # Different CIDR for prod
  availability_zones = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]

  #----------------------------------------------------------------------------
  # Database Configuration
  #----------------------------------------------------------------------------
  db_name           = "uniplus_prod"
  db_username       = "uniplus_admin"
  db_instance_class = "db.r6g.large" # Production size

  #----------------------------------------------------------------------------
  # ECS Configuration
  #----------------------------------------------------------------------------
  container_image = "ACCOUNT_ID.dkr.ecr.sa-east-1.amazonaws.com/uniplus-app:latest" # Replace ACCOUNT_ID
  ecs_task_cpu    = 1024                                                            # 1 vCPU
  ecs_task_memory = 2048                                                            # 2 GB

  #----------------------------------------------------------------------------
  # SSL/TLS Configuration (required for production)
  #----------------------------------------------------------------------------
  certificate_arn            = "" # ARN of ACM certificate for ALB (same region)
  cloudfront_certificate_arn = "" # ARN of ACM certificate for CloudFront (us-east-1)
  domain_name                = "" # Custom domain name (e.g., app.uniplus.com)
}
