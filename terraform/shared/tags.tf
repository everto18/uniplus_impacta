# Common Tags for FinOps and Resource Management
# All resources will inherit these tags

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Team        = var.team_name
    CostCenter  = var.cost_center
    Owner       = var.owner_email
    Application = "uniplus-platform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }

  # Environment-specific naming prefix
  name_prefix = "${var.project_name}-${var.environment}"

  # Environment-specific configuration
  is_production = var.environment == "prod"
}
