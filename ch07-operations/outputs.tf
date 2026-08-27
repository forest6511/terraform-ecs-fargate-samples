output "github_actions_role_arn" {
  description = "ワークフローの role-to-assume に渡す ARN"
  value       = aws_iam_role.github_actions.arn
}

output "ecr_repository_url" {
  description = "イメージの push 先"
  value       = aws_ecr_repository.app.repository_url
}

output "expected_sub_claim" {
  description = "信頼ポリシーが照合している sub クレーム。実値と突き合わせる"
  value       = var.github_sub_claim
}
