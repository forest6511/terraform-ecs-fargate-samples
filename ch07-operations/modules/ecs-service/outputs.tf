output "service_name" {
  description = "作成した ECS サービス名"
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "登録したタスク定義の ARN"
  value       = aws_ecs_task_definition.this.arn
}
