variable "region" {
  description = "リソースを作るリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "project" {
  description = "リソース名の接頭辞"
  type        = string
  default     = "ecs-book"
}

variable "container_port" {
  description = "コンテナが待ち受けるポート"
  type        = number
  default     = 8080
}

variable "github_sub_claim" {
  description = <<-EOT
    信頼ポリシーで照合する sub クレーム。
    自分の値は次のコマンドで調べる。
      gh api repos/<owner>/<repo>/actions/oidc/customization/sub
    出力の sub_claim_prefix に :ref:refs/heads/main を足したものを入れる
  EOT
  type        = string
  default     = "repo:example-owner/example-repo:ref:refs/heads/main"
}
