# GitHub Actions から AWS に入るための OIDC プロバイダー。
#
# thumbprint_list は書かない。AWS が信頼済みルート CA で検証するため不要で、
# 一度書くとあとで消しても Terraform が元のリストを保持してしまう
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

resource "aws_iam_role" "github_actions" {
  name = "${var.project}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"

          # ここが 2026-07-15 で変わった箇所。
          # 変数の既定値のままでは自分の repo と一致しない
          "token.actions.githubusercontent.com:sub" = var.github_sub_claim
        }
      }
    }]
  })
}

# 学習用に広めの権限を付けている。実務では apply するリソースに絞ること
resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
