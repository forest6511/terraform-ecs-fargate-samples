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

variable "enable_exec" {
  description = "調査のときだけ true にする。本番では false のまま"
  type        = bool
  default     = false
}

variable "desired_count" {
  description = "動かすタスク数。調査を中断するときは 0 にする"
  type        = number
  default     = 1
}
