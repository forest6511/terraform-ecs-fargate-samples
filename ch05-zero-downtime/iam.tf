# タスク実行ロール。第 3 章と同じもの。
# ECR からイメージをプルし、CloudWatch Logs へログを送るために使う

data "aws_iam_policy_document" "task_execution_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  name               = "${var.project}-task-execution"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume.json
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ここからが第 5 章で追加するもの。
# ブルー/グリーンでは ECS 自身がリスナールールの転送先を書き換える。
# その操作を許可するロールを ECS に渡す

data "aws_iam_policy_document" "ecs_deploy_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_deploy" {
  name               = "${var.project}-ecs-deploy"
  assume_role_policy = data.aws_iam_policy_document.ecs_deploy_assume.json
}

# AWS 管理ポリシー。ブルー/グリーンに必要な ELB 操作がまとまっている。
# 中身は DescribeListeners / DescribeRules / DescribeTargetGroups /
# DescribeTargetHealth / RegisterTargets / DeregisterTargets /
# ModifyListener / ModifyRule の 8 アクション
#
# 上の task_execution とパスが違うので注意。
# タスク実行ロール側は  .../policy/service-role/AmazonECSTaskExecutionRolePolicy
# こちらは            .../policy/AmazonECSInfrastructureRolePolicyForLoadBalancers
# service-role/ を付けると NoSuchEntity になる
resource "aws_iam_role_policy_attachment" "ecs_deploy" {
  role       = aws_iam_role.ecs_deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECSInfrastructureRolePolicyForLoadBalancers"
}
