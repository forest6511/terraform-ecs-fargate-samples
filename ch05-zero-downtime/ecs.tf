resource "aws_ecs_cluster" "main" {
  name = var.project
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])
}

resource "aws_security_group" "task" {
  name        = "${var.project}-task"
  description = "Allow traffic from the ALB only"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project}-task"
  }
}

resource "aws_vpc_security_group_ingress_rule" "task_from_alb" {
  security_group_id            = aws_security_group.task.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "task_all" {
  security_group_id = aws_security_group.task.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_ecs_service" "app" {
  name            = "${var.project}-app"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.task.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = "app"
    container_port   = var.container_port

    # ブルー/グリーンで ECS に渡す 3 点。
    # グリーン側の受け皿と、書き換えるルールと、書き換える権限
    advanced_configuration {
      alternate_target_group_arn = aws_lb_target_group.green.arn
      production_listener_rule   = aws_lb_listener_rule.production.arn
      test_listener_rule         = aws_lb_listener_rule.test.arn
      role_arn                   = aws_iam_role.ecs_deploy.arn
    }
  }

  # 本書の中心。CodeDeploy を挟まずにブルー/グリーンを指定する。
  # strategy を LINEAR / CANARY に変えると段階的な移行になる
  deployment_configuration {
    strategy             = var.deployment_strategy
    bake_time_in_minutes = var.bake_time_in_minutes

    # strategy が CANARY のときだけ使われる
    dynamic "canary_configuration" {
      for_each = var.deployment_strategy == "CANARY" ? [1] : []

      content {
        canary_percent              = var.canary_percent
        canary_bake_time_in_minutes = var.step_bake_time_in_minutes
      }
    }

    # strategy が LINEAR のときだけ使われる
    dynamic "linear_configuration" {
      for_each = var.deployment_strategy == "LINEAR" ? [1] : []

      content {
        step_percent              = var.step_percent
        step_bake_time_in_minutes = var.step_bake_time_in_minutes
      }
    }
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [
    aws_lb_listener_rule.production,
    aws_lb_listener_rule.test,
    aws_iam_role_policy_attachment.ecs_deploy,
  ]
}
