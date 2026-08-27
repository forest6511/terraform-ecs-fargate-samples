data "aws_caller_identity" "current" {}
output "r" { value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/x" }
# 例: arn:aws:iam::123456789012:role/example
