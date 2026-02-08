resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-overview"

  dashboard_body = jsonencode({
    widgets = [
      # Line 1: CPU & Memory (Infrastructure Health)
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            for service in var.service_names :
            ["AWS/ECS", "CPUUtilization", "ServiceName", service, "ClusterName", var.cluster_name, { "label" : "${service}" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Utilização de CPU (%)"
          period  = 300
          stat    = "Average"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            for service in var.service_names :
            ["AWS/ECS", "MemoryUtilization", "ServiceName", service, "ClusterName", var.cluster_name, { "label" : "${service}" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Utilização de Memória (%)"
          period  = 300
          stat    = "Average"
        }
      },

      # Line 2: Network Traffic & Latency
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "ProcessedBytes", "LoadBalancer", var.alb_arn_suffix, { "label" : "Bytes Processados", "stat" : "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Throughput de Rede (Bytes)"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            for name, suffix in var.target_group_arn_suffixes :
            ["AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", suffix, "LoadBalancer", var.alb_arn_suffix, { "label" : "${name} p95", "stat" : "p95" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Latência HTTP (p95)"
          period  = 300
        }
      },

      # Line 3: Availability & Errors
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 6
        height = 6
        properties = {
          metrics = [
            for name, suffix in var.target_group_arn_suffixes :
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", suffix, "LoadBalancer", var.alb_arn_suffix, { "label" : "${name}" }]
          ]
          view   = "singleValue" # Stat widget style
          region = var.aws_region
          title  = "Hosts Saudáveis (Uptime)"
          period = 60
          stat   = "Minimum"
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
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix, { "label" : "Requisições Totais", "stat" : "Sum" }]
          ]
          view   = "singleValue"
          region = var.aws_region
          title  = "Requisições (Total)"
          period = 300
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
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix, { "label" : "Erros 5XX", "color" : "#d62728" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", var.alb_arn_suffix, { "label" : "Erros 4XX", "color" : "#ff7f0e" }]
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
