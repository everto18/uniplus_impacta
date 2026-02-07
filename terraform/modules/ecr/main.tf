# ECR Repositories for UniPlus Services
# Created when apply=true, destroyed when destroy=true

variable "services" {
  description = "List of service names to create ECR repositories for"
  type        = list(string)
  default     = ["portal-aluno", "portal-professor", "sistema-academico", "video-api"]
}

variable "tags" {
  description = "Tags to apply to ECR repositories"
  type        = map(string)
  default     = {}
}

variable "image_retention_count" {
  description = "Number of images to retain per repository"
  type        = number
  default     = 10
}

resource "aws_ecr_repository" "services" {
  for_each = toset(var.services)

  name                 = "uniplus-${each.value}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # Allows deletion even with images present

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Name    = "uniplus-${each.value}"
    Service = each.value
  })
}

# Lifecycle policy - keep only the last N images
resource "aws_ecr_lifecycle_policy" "cleanup" {
  for_each   = aws_ecr_repository.services
  repository = each.value.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last ${var.image_retention_count} images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.image_retention_count
      }
      action = {
        type = "expire"
      }
    }]
  })
}
