output "alb_dns_name" {
  description = "ブラウザや curl でアクセスする先"
  value       = aws_lb.main.dns_name
}

output "ecr_repository_url" {
  description = "docker push する先"
  value       = aws_ecr_repository.app.repository_url
}
