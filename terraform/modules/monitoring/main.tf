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

  unhealthy_host_metrics = [
    for name, suffix in var.target_group_arn_suffixes : [
      "AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", suffix, "LoadBalancer", var.alb_arn_suffix
    ]
  ]

  # Running task count metrics
  running_task_metrics = [
    for service in var.service_names : [
      "ECS/ContainerInsights", "RunningTaskCount", "ServiceName", service, "ClusterName", var.cluster_name
    ]
  ]

  desired_task_metrics = [
    for service in var.service_names : [
      "ECS/ContainerInsights", "DesiredTaskCount", "ServiceName", service, "ClusterName", var.cluster_name
    ]
  ]
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-overview"

  dashboard_body = jsonencode({
    widgets = [
      # Row 0: Service Status Header
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 1
        properties = {
          markdown = "# 📊 Status dos Serviços ECS - ${var.project_name} (${var.environment})"
        }
      },

      # Row 1: Running vs Desired Tasks (per service)
      {
        type   = "metric"
        x      = 0
        y      = 1
        width  = 12
        height = 6
        properties = {
          metrics = concat(
            [[for service in var.service_names : ["AWS/ECS", "RunningTaskCount", "ServiceName", service, "ClusterName", var.cluster_name]][0]],
            [[for service in var.service_names : [{ expression = "1", label = "${service} Target", id = "target_${index(var.service_names, service)}" }]][0]]
          )
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "⚡ Tasks Rodando por Serviço"
          period  = 60
          stat    = "Average"
          yAxis = {
            left = { min = 0, label = "Tasks" }
          }
          annotations = {
            horizontal = [
              { value = 1, label = "Mínimo Esperado", color = "#2ca02c" }
            ]
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 1
        width  = 12
        height = 6
        properties = {
          metrics              = local.healthy_host_metrics
          view                 = "singleValue"
          region               = var.aws_region
          title                = "✅ Hosts Saudáveis por Serviço"
          period               = 60
          stat                 = "Average"
          setPeriodToTimeRange = true
        }
      },

      # Row 2: Unhealthy Hosts & Errors
      {
        type   = "metric"
        x      = 0
        y      = 7
        width  = 12
        height = 4
        properties = {
          metrics = local.unhealthy_host_metrics
          view    = "singleValue"
          region  = var.aws_region
          title   = "❌ Hosts Não Saudáveis"
          period  = 60
          stat    = "Average"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 7
        width  = 12
        height = 4
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetConnectionErrorCount", "LoadBalancer", var.alb_arn_suffix, { color = "#d62728", label = "Connection Errors" }],
            [".", "HTTPCode_ELB_5XX_Count", ".", ".", { color = "#ff7f0e", label = "ALB 5XX" }]
          ]
          view   = "singleValue"
          region = var.aws_region
          title  = "🚨 Erros de Conexão"
          period = 300
          stat   = "Sum"
        }
      },

      # Row 3: CPU Utilization with Autoscaling Target
      {
        type   = "text"
        x      = 0
        y      = 11
        width  = 24
        height = 1
        properties = {
          markdown = "## 📈 Métricas de Performance (Targets de Autoscaling: CPU 70%, Memória 80%)"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = local.cpu_metrics
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "🔥 Utilização de CPU (%)"
          period  = 60
          stat    = "Average"
          yAxis = {
            left = { min = 0, max = 100 }
          }
          annotations = {
            horizontal = [
              { value = 70, label = "Autoscaling Target (70%)", color = "#ff7f0e" },
              { value = 90, label = "Crítico (90%)", color = "#d62728" }
            ]
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = local.memory_metrics
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "💾 Utilização de Memória (%)"
          period  = 60
          stat    = "Average"
          yAxis = {
            left = { min = 0, max = 100 }
          }
          annotations = {
            horizontal = [
              { value = 80, label = "Autoscaling Target (80%)", color = "#ff7f0e" },
              { value = 95, label = "Crítico (95%)", color = "#d62728" }
            ]
          }
        }
      },

      # Row 4: Network & Latency
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "ProcessedBytes", "LoadBalancer", var.alb_arn_suffix]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "🌐 Throughput de Rede (Bytes)"
          period  = 60
          stat    = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 18
        width  = 12
        height = 6
        properties = {
          metrics = local.latency_metrics
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "⏱️ Latência HTTP (ms)"
          period  = 60
          stat    = "Average"
          yAxis = {
            left = { label = "ms", min = 0 }
          }
          annotations = {
            horizontal = [
              { value = 1, label = "Bom (<1s)", color = "#2ca02c" },
              { value = 3, label = "Atenção (>3s)", color = "#ff7f0e" }
            ]
          }
        }
      },

      # Row 5: Requests & Errors
      {
        type   = "metric"
        x      = 0
        y      = 24
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "📊 Requisições por Minuto"
          period = 60
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 24
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", var.alb_arn_suffix, { color = "#2ca02c", label = "2XX Success" }],
            [".", "HTTPCode_Target_3XX_Count", ".", ".", { color = "#1f77b4", label = "3XX Redirect" }]
          ]
          view    = "timeSeries"
          stacked = true
          region  = var.aws_region
          title   = "✅ Respostas de Sucesso"
          period  = 60
          stat    = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 24
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix, { color = "#d62728", label = "5XX Server Error" }],
            [".", "HTTPCode_Target_4XX_Count", ".", ".", { color = "#ff7f0e", label = "4XX Client Error" }]
          ]
          view    = "timeSeries"
          stacked = true
          region  = var.aws_region
          title   = "❌ Erros HTTP (4XX / 5XX)"
          period  = 60
          stat    = "Sum"
        }
      },

      # Row 6: Summary Table
      {
        type   = "text"
        x      = 0
        y      = 30
        width  = 24
        height = 2
        properties = {
          markdown = <<-EOT
## 📋 Resumo de Autoscaling
| Métrica | Target | Scale Out | Scale In Cooldown |
|---------|--------|-----------|-------------------|
| CPU | 70% | Quando > 70% | 300s |
| Memória | 80% | Quando > 80% | 300s |
| Requisições/Target | 1000 | Quando > 1000 req/target | 300s |
EOT
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
