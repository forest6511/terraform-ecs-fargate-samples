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
