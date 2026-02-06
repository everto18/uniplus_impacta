# Common Variables for All Environments

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "uniplus"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "sa-east-1" # São Paulo - closest to Brazil
}

variable "team_name" {
  description = "Team responsible for the resources"
  type        = string
  default     = "platform-engineering"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "education-tech"
}

variable "owner_email" {
  description = "Email of the resource owner"
  type        = string
  default     = "devops@uniplus.com"
}

# Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
}

# Database Variables
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "uniplus"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "uniplus_admin"
  sensitive   = true
}

# ECS Variables
variable "ecs_task_cpu" {
  description = "CPU units for ECS tasks"
  type        = number
  default     = 256
}

variable "ecs_task_memory" {
  description = "Memory (MB) for ECS tasks"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

# Cache Variables
variable "cache_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "cache_num_nodes" {
  description = "Number of cache nodes"
  type        = number
  default     = 1
}

# Domain Variables
variable "domain_name" {
  description = "Primary domain name for the application"
  type        = string
  default     = ""
}

variable "create_dns_records" {
  description = "Whether to create DNS records in Route53"
  type        = bool
  default     = false
}
