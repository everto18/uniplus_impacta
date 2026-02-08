# CloudWatch Dashboard for UniPlus Platform
# Replicates key metrics from Grafana dashboard

locals {
  # Pre-compute metrics arrays to avoid complex for expressions in jsonencode
  cpu_metrics = [
    for service in var.service_names : [
      "AWS/ECS", "CPUUtilization", "ServiceName", service, "ClusterName", var.cluster_name
    ]
  ]

  memory_metrics = [
    for service in var.service_names : [
      "AWS/ECS", "MemoryUtilization", "ServiceName", service, "ClusterName", var.cluster_name
    ]
  ]

  latency_metrics = [
    for name, suffix in var.target_group_arn_suffixes : [
      "AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", suffix, "LoadBalancer", var.alb_arn_suffix
    ]
  ]

  healthy_host_metrics = [
    for name, suffix in var.target_group_arn_suffixes : [
      "AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", suffix, "LoadBalancer", var.alb_arn_suffix
    ]
  ]
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-overview"

  dashboard_body = jsonencode({
    widgets = [
      # Row 1: CPU & Memory Utilization
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = local.cpu_metrics
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Utilização de CPU (%)"
          period  = 300
          stat    = "Average"
          yAxis = {
            left = { min = 0, max = 100 }
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = local.memory_metrics
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Utilização de Memória (%)"
          period  = 300
          stat    = "Average"
          yAxis = {
            left = { min = 0, max = 100 }
          }
        }
      },

      # Row 2: Network & Latency
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "ProcessedBytes", "LoadBalancer", var.alb_arn_suffix]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Throughput de Rede (Bytes)"
          period  = 300
          stat    = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = local.latency_metrics
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Latência HTTP (Média)"
          period  = 300
          stat    = "Average"
          yAxis = {
            left = { label = "ms" }
          }
        }
      },

      # Row 3: Availability & Errors
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 6
        height = 6
        properties = {
          metrics = local.healthy_host_metrics
          view    = "singleValue"
          region  = var.aws_region
          title   = "Hosts Saudáveis"
          period  = 60
          stat    = "Minimum"
        }
      },
      {
        type   = "metric"
        x      = 6
        y      = 12
        width  = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]
          ]
          view   = "singleValue"
          region = var.aws_region
          title  = "Requisições (5min)"
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix, { color = "#d62728" }],
            [".", "HTTPCode_Target_4XX_Count", ".", ".", { color = "#ff7f0e" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Erros HTTP (4XX / 5XX)"
          period  = 300
          stat    = "Sum"
        }
      }
    ]
  })
}

# Output dashboard URL
output "dashboard_url" {
  description = "URL to access the CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}
