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

variable "image_tag" {
  description = "デプロイするイメージのタグ。v1 と v2 を入れ替えて更新を試す"
  type        = string
  default     = "v1"
}

variable "desired_count" {
  description = "動かすタスクの数。撤収時に 0 を渡して課金を止められる"
  type        = number
  default     = 2
}

variable "test_listener_port" {
  description = "テストトラフィックを受けるポート。本番の 80 とは分ける"
  type        = number
  default     = 8080
}

variable "deployment_strategy" {
  description = "デプロイ戦略。ROLLING / BLUE_GREEN / LINEAR / CANARY"
  type        = string
  default     = "BLUE_GREEN"

  validation {
    condition = contains(
      ["ROLLING", "BLUE_GREEN", "LINEAR", "CANARY"],
      var.deployment_strategy
    )
    error_message = "ROLLING / BLUE_GREEN / LINEAR / CANARY のいずれかにしてください。"
  }
}

variable "bake_time_in_minutes" {
  description = "本番トラフィックの移行後、古い版を残して様子を見る分数（0〜1440）"
  type        = number
  default     = 5
}

variable "canary_percent" {
  description = "カナリアデプロイで最初に移すトラフィックの割合（0.1〜100.0）"
  type        = number
  default     = 10
}

variable "step_percent" {
  description = "リニアデプロイで 1 ステップごとに移す割合（3.0〜100.0）"
  type        = number
  default     = 25
}

variable "step_bake_time_in_minutes" {
  description = "各ステップのあとに待つ分数（0〜1440）"
  type        = number
  default     = 1
}
