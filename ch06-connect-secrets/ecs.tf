resource "aws_ecs_cluster" "main" {
  name = var.project

  # クラスターに既定の名前空間を持たせる。
  # 各サービスで namespace を書かなくてよくなる
  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.main.arn
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.project}-api"
  retention_in_days = 7
}

# 呼ばれる側。Service Connect で api という名前で公開する
resource "aws_ecs_task_definition" "api" {
  family                   = "${var.project}-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  # 第3章は 256 だった。Service Connect のプロキシが同じタスクに入るため、
  # 公式の推奨に従って 256 CPU ユニットと 64 MiB を上乗せしている
  cpu    = "512"
  memory = "1024"

  execution_role_arn = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "api"
      image     = "${aws_ecr_repository.app.repository_url}:v1"
      essential = true

      # name を付けたポートだけが Service Connect の対象になる
      portMappings = [
        {
          name          = "api"
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      # json-key を付けて、JSON の中の 1 つのキーだけを取り出す。
      # 付けないとシークレット全体が文字列のまま環境変数に入る
      secrets = [
        {
          name      = "DB_USERNAME"
          valueFrom = "${aws_secretsmanager_secret.db.arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.db.arn}:password::"
        },
        {
          name      = "API_ENDPOINT"
          valueFrom = aws_ssm_parameter.api_endpoint.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.api.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "api"
        }
      }
    }
  ])
}

# 呼ぶ側。ALB から受けたリクエストを api に転送する
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.app.repository_url}:v1"
      essential = true

      portMappings = [
        {
          name          = "app"
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
  description = "Allow traffic from the ALB and within the namespace"
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

# タスク同士の通信を許可する。これがないと app から api へ届かない
resource "aws_vpc_security_group_ingress_rule" "task_from_task" {
  security_group_id            = aws_security_group.task.id
  referenced_security_group_id = aws_security_group.task.id
  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "task_all" {
  security_group_id = aws_security_group.task.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# 呼ばれる側のサービス。client_alias で公開する名前とポートを決める
resource "aws_ecs_service" "api" {
  name            = "${var.project}-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.task.id]
    assign_public_ip = true
  }

  service_connect_configuration {
    enabled = true

    service {
      # タスク定義の portMappings.name と一致させる
      port_name      = "api"
      discovery_name = "api"

      client_alias {
        # 呼ぶ側は http://api:8080 で届くようになる
        dns_name = "api"
        port     = var.container_port
      }
    }

    log_configuration {
      log_driver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.api.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "sc-proxy"
      }
    }
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
}

# 呼ぶ側のサービス。service ブロックを書かず enabled だけにすると
# 「呼ぶだけ」の参加になる
resource "aws_ecs_service" "app" {
  name            = "${var.project}-app"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.task.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = var.container_port
  }

  service_connect_configuration {
    enabled = true

    log_configuration {
      log_driver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.app.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "sc-proxy"
      }
    }
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [aws_lb_listener.http]
}
