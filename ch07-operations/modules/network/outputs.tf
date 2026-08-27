output "vpc_id" {
  description = "作成した VPC の ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "パブリックサブネットの ID"
  value       = aws_subnet.public[*].id
}
