# Compute Module - Variables
# Supports multiple ECS services with independent scaling

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of ECS task execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of ECS task role"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of ACM certificate for HTTPS"
  type        = string
  default     = ""
}

variable "db_credentials_secret_arn" {
  description = "ARN of database credentials secret"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# Services Configuration - Each service scales independently
#------------------------------------------------------------------------------
variable "services" {
  description = "Map of ECS services to create with independent scaling"
  type = map(object({
    container_image   = string
    container_port    = number
    cpu               = number
    memory            = number
    desired_count     = number
    min_capacity      = number
    max_capacity      = number
    health_check_path = string
    path_patterns     = list(string) # ALB routing patterns, e.g., ["/aluno/*", "/aluno"]
    priority          = number       # Listener rule priority
    environment_vars  = optional(map(string), {})
  }))

  default = {
    portal-aluno = {
      container_image   = "nginx:alpine"
      container_port    = 80
      cpu               = 512
      memory            = 1024
      desired_count     = 2
      min_capacity      = 1
      max_capacity      = 10
      health_check_path = "/health"
      path_patterns     = ["/aluno/*", "/aluno"]
      priority          = 100
      environment_vars  = {}
    }
    portal-professor = {
      container_image   = "nginx:alpine"
      container_port    = 80
      cpu               = 512
      memory            = 1024
      desired_count     = 1
      min_capacity      = 1
      max_capacity      = 5
      health_check_path = "/health"
      path_patterns     = ["/professor/*", "/professor"]
      priority          = 200
      environment_vars  = {}
    }
    sistema-academico = {
      container_image   = "nginx:alpine"
      container_port    = 80
      cpu               = 512
      memory            = 1024
      desired_count     = 1
      min_capacity      = 1
      max_capacity      = 5
      health_check_path = "/health"
      path_patterns     = ["/academico/*", "/academico"]
      priority          = 300
      environment_vars  = {}
    }
    video-api = {
      container_image   = "nginx:alpine"
      container_port    = 80
      cpu               = 512
      memory            = 1024
      desired_count     = 1
      min_capacity      = 1
      max_capacity      = 8
      health_check_path = "/health"
      path_patterns     = ["/api/videos/*", "/api/videos"]
      priority          = 400
      environment_vars  = {}
    }
  }
}

# Default service for root path
variable "default_service" {
  description = "Service name to use as default (for root path)"
  type        = string
  default     = "portal-aluno"
}
