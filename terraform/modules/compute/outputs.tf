# Compute Module - Outputs

output "cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB Zone ID"
  value       = aws_lb.main.zone_id
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics"
  value       = aws_lb.main.arn_suffix
}

# Per-service outputs
output "services" {
  description = "Map of service details"
  value = {
    for key, service in var.services : key => {
      service_name     = aws_ecs_service.services[key].name
      service_arn      = aws_ecs_service.services[key].id
      target_group_arn = aws_lb_target_group.services[key].arn
      task_definition  = aws_ecs_task_definition.services[key].arn
      log_group        = aws_cloudwatch_log_group.services[key].name
      min_capacity     = service.min_capacity
      max_capacity     = service.max_capacity
      path_patterns    = service.path_patterns
    }
  }
}

output "target_group_arns" {
  description = "Map of target group ARNs by service name"
  value = {
    for key, _ in var.services : key => aws_lb_target_group.services[key].arn
  }
}

output "target_group_arn_suffixes" {
  description = "Map of target group ARN suffixes by service name"
  value = {
    for key, _ in var.services : key => aws_lb_target_group.services[key].arn_suffix
  }
}

output "service_names" {
  description = "List of ECS service names"
  value       = [for key, _ in var.services : aws_ecs_service.services[key].name]
}

# Autoscaling outputs
output "autoscaling_targets" {
  description = "Map of autoscaling target ARNs by service name"
  value = {
    for key, _ in var.services : key => aws_appautoscaling_target.services[key].arn
  }
}

output "cpu_scaling_policies" {
  description = "Map of CPU autoscaling policy ARNs by service name"
  value = {
    for key, _ in var.services : key => aws_appautoscaling_policy.cpu[key].arn
  }
}

output "memory_scaling_policies" {
  description = "Map of memory autoscaling policy ARNs by service name"
  value = {
    for key, _ in var.services : key => aws_appautoscaling_policy.memory[key].arn
  }
}

output "requests_scaling_policies" {
  description = "Map of requests autoscaling policy ARNs by service name"
  value = {
    for key, _ in var.services : key => aws_appautoscaling_policy.requests[key].arn
  }
}

output "scheduled_scaling_actions" {
  description = "Map of scheduled scaling action ARNs by service name"
  value = {
    for key, _ in var.services : key => {
      for action in var.scheduled_scaling[key] : action.name => aws_appautoscaling_scheduled_action.services["${key}-${action.name}"].arn
    }
  }
}

output "http_listener_arn" {
  description = "HTTP listener ARN"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "HTTPS listener ARN (if exists)"
  value       = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : null
}
