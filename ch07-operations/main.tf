data "aws_caller_identity" "current" {}

module "network" {
  source = "./modules/network"

  project = var.project
}

resource "aws_security_group" "task" {
  name        = "${var.project}-task"
  description = "ECS task"
  vpc_id      = module.network.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "main" {
  name = var.project
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project}-ch07"
  retention_in_days = 7
}

resource "aws_ecr_repository" "app" {
  name         = "${var.project}-app-ch07"
  force_delete = true
}

# 同じ module を、引数だけ変えて 2 回呼ぶ。
# on-demand 側はオンデマンドのみ、spot 側は Spot を混ぜる
module "app" {
  source = "./modules/ecs-service"

  project = var.project
  name    = "app"
  region  = var.region

  cluster_id         = aws_ecs_cluster.main.id
  subnet_ids         = module.network.public_subnet_ids
  security_group_ids = [aws_security_group.task.id]
  image              = "${aws_ecr_repository.app.repository_url}:v1"
  container_port     = var.container_port
  execution_role_arn = aws_iam_role.task_execution.arn
  log_group_name     = aws_cloudwatch_log_group.app.name

  # 1 タスクはオンデマンドで確保し、それを超えたぶんを Spot に寄せる。
  # weight を書かないと API 経由では 0 と扱われ、タスクが置かれない
  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    },
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 3
    },
  ]

  desired_count = 2
}

module "batch" {
  source = "./modules/ecs-service"

  project = var.project
  name    = "batch"
  region  = var.region

  cluster_id         = aws_ecs_cluster.main.id
  subnet_ids         = module.network.public_subnet_ids
  security_group_ids = [aws_security_group.task.id]
  image              = "${aws_ecr_repository.app.repository_url}:v1"
  container_port     = var.container_port
  execution_role_arn = aws_iam_role.task_execution.arn
  log_group_name     = aws_cloudwatch_log_group.app.name

  # 中断されても構わない処理なので、全部 Spot に寄せる
  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
    },
  ]

  # ARM に切り替えて単価を下げる。イメージ側も ARM64 で作る必要がある
  cpu_architecture = "ARM64"

  desired_count = 1
}
