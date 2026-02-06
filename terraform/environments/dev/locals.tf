# Development Environment - Local Configuration
# All environment-specific values defined here instead of terraform.tfvars

locals {
  #----------------------------------------------------------------------------
  # Project Configuration
  #----------------------------------------------------------------------------
  project_name = "uniplus"
  environment  = "dev"
  aws_region   = "sa-east-1"

  team_name   = "platform-engineering"
  cost_center = "education-tech"
  owner_email = "devops@uniplus.com"

  #----------------------------------------------------------------------------
  # Networking Configuration
  #----------------------------------------------------------------------------
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]

  #----------------------------------------------------------------------------
  # Database Configuration
  #----------------------------------------------------------------------------
  db_name           = "uniplus_dev"
  db_username       = "uniplus_admin"
  db_instance_class = "db.t3.micro" # Small for dev

  #----------------------------------------------------------------------------
  # ECS Configuration
  #----------------------------------------------------------------------------
  container_image = "nginx:alpine" # Placeholder - replace with your ECR image
  ecs_task_cpu    = 256
  ecs_task_memory = 512
}
