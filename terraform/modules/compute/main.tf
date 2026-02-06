# Compute Module - ECS Fargate with Multiple Services
# Each service scales independently

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

#------------------------------------------------------------------------------
# ECS Cluster (shared by all services)
#------------------------------------------------------------------------------
resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = var.environment == "prod" ? "enabled" : "disabled"
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-cluster"
  })
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

#------------------------------------------------------------------------------
# Application Load Balancer (shared, routes to different target groups)
#------------------------------------------------------------------------------
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.environment == "prod"
  enable_http2               = true
  idle_timeout               = 60

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-alb"
  })
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = var.certificate_arn != "" ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.certificate_arn != "" ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = var.certificate_arn == "" ? [1] : []
      content {
        target_group {
          arn = aws_lb_target_group.services[var.default_service].arn
        }
      }
    }
  }

  tags = var.tags
}

# HTTPS Listener (if certificate provided)
resource "aws_lb_listener" "https" {
  count = var.certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services[var.default_service].arn
  }

  tags = var.tags
}

#------------------------------------------------------------------------------
# Target Groups - One per service
#------------------------------------------------------------------------------
resource "aws_lb_target_group" "services" {
  for_each = var.services

  name        = "${local.name_prefix}-${each.key}-tg"
  port        = each.value.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200-299"
    path                = each.value.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name    = "${local.name_prefix}-${each.key}-tg"
    Service = each.key
  })
}

#------------------------------------------------------------------------------
# Listener Rules - Route by path to each service
#------------------------------------------------------------------------------
resource "aws_lb_listener_rule" "services" {
  for_each = var.services

  listener_arn = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : aws_lb_listener.http.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }

  tags = merge(var.tags, {
    Name    = "${local.name_prefix}-${each.key}-rule"
    Service = each.key
  })
}

#------------------------------------------------------------------------------
# CloudWatch Log Groups - One per service
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "services" {
  for_each = var.services

  name              = "/ecs/${local.name_prefix}/${each.key}"
  retention_in_days = var.environment == "prod" ? 90 : 30

  tags = merge(var.tags, {
    Name    = "${local.name_prefix}-${each.key}-logs"
    Service = each.key
  })
}

#------------------------------------------------------------------------------
# ECS Task Definitions - One per service
#------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "services" {
  for_each = var.services

  family                   = "${local.name_prefix}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = each.key
      image     = each.value.container_image
      essential = true

      portMappings = [
        {
          containerPort = each.value.container_port
          hostPort      = each.value.container_port
          protocol      = "tcp"
        }
      ]

      environment = concat(
        [
          { name = "SERVICE_NAME", value = each.key },
          { name = "ENVIRONMENT", value = var.environment },
          { name = "PORT", value = tostring(each.value.container_port) }
        ],
        [for k, v in each.value.environment_vars : { name = k, value = v }]
      )

      secrets = var.db_credentials_secret_arn != "" && each.key != "video-api" ? [
        {
          name      = "DB_HOST"
          valueFrom = "${var.db_credentials_secret_arn}:host::"
        },
        {
          name      = "DB_PORT"
          valueFrom = "${var.db_credentials_secret_arn}:port::"
        },
        {
          name      = "DB_USER"
          valueFrom = "${var.db_credentials_secret_arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.db_credentials_secret_arn}:password::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${var.db_credentials_secret_arn}:dbname::"
        }
      ] : []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.services[each.key].name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${each.value.container_port}${each.value.health_check_path} || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = merge(var.tags, {
    Name    = "${local.name_prefix}-${each.key}"
    Service = each.key
  })
}

data "aws_region" "current" {}

#------------------------------------------------------------------------------
# ECS Services - One per service, each scales independently
#------------------------------------------------------------------------------
resource "aws_ecs_service" "services" {
  for_each = var.services

  name                               = "${local.name_prefix}-${each.key}"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.services[each.key].arn
  desired_count                      = each.value.desired_count
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  health_check_grace_period_seconds  = 60
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.services[each.key].arn
    container_name   = each.key
    container_port   = each.value.container_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = merge(var.tags, {
    Name    = "${local.name_prefix}-${each.key}"
    Service = each.key
  })

  depends_on = [aws_lb_listener.http]
}

#------------------------------------------------------------------------------
# Auto Scaling - Independent scaling per service
#------------------------------------------------------------------------------
resource "aws_appautoscaling_target" "services" {
  for_each = var.services

  max_capacity       = each.value.max_capacity
  min_capacity       = each.value.min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.services[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU-based scaling
resource "aws_appautoscaling_policy" "cpu" {
  for_each = var.services

  name               = "${local.name_prefix}-${each.key}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.services[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.services[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.services[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Memory-based scaling
resource "aws_appautoscaling_policy" "memory" {
  for_each = var.services

  name               = "${local.name_prefix}-${each.key}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.services[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.services[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.services[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 80.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Request count scaling
resource "aws_appautoscaling_policy" "requests" {
  for_each = var.services

  name               = "${local.name_prefix}-${each.key}-requests-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.services[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.services[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.services[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.main.arn_suffix}/${aws_lb_target_group.services[each.key].arn_suffix}"
    }
    target_value       = 1000.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
