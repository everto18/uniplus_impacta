# ECR Module Outputs

output "repository_urls" {
  description = "Map of service names to ECR repository URLs"
  value = {
    for name, repo in aws_ecr_repository.services :
    name => repo.repository_url
  }
}

output "repository_arns" {
  description = "Map of service names to ECR repository ARNs"
  value = {
    for name, repo in aws_ecr_repository.services :
    name => repo.arn
  }
}

output "registry_id" {
  description = "The registry ID where the repositories were created"
  value       = length(aws_ecr_repository.services) > 0 ? values(aws_ecr_repository.services)[0].registry_id : ""
}
