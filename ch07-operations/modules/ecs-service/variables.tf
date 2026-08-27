variable "project" {
  description = "リソース名の接頭辞"
  type        = string
}

variable "name" {
  description = "サービス名。クラスター内で一意にする"
  type        = string
}

variable "cluster_id" {
  description = "配置先クラスターの ID"
  type        = string
}

variable "subnet_ids" {
  description = "タスクを置くサブネット"
  type        = list(string)
}

variable "security_group_ids" {
  description = "タスクに付けるセキュリティグループ"
  type        = list(string)
}

variable "image" {
  description = "コンテナイメージ。タグまで含める"
  type        = string
}

variable "container_port" {
  description = "コンテナが待ち受けるポート"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "タスクの CPU ユニット"
  type        = string
  default     = "512"
}

variable "memory" {
  description = "タスクのメモリ (MiB)"
  type        = string
  default     = "1024"
}

variable "desired_count" {
  description = "維持するタスク数"
  type        = number
  default     = 1
}

variable "execution_role_arn" {
  description = "タスク実行ロールの ARN"
  type        = string
}

variable "log_group_name" {
  description = "ログの送り先ロググループ名"
  type        = string
}

variable "region" {
  description = "ログドライバーに渡すリージョン"
  type        = string
}

# ここから下が第 7 章で足す引数

variable "cpu_architecture" {
  description = "X86_64 または ARM64。ARM64 にするとイメージ側も ARM64 が要る"
  type        = string
  default     = "X86_64"

  validation {
    condition     = contains(["X86_64", "ARM64"], var.cpu_architecture)
    error_message = "cpu_architecture は X86_64 か ARM64 のどちらかにしてください。"
  }
}

variable "capacity_provider_strategy" {
  description = <<-EOT
    キャパシティプロバイダー戦略。空にすると launch_type = FARGATE になる。
    weight を省くと API 経由では 0 と扱われ、そのプロバイダーにタスクが置かれない
  EOT
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = optional(number)
  }))
  default = []
}

variable "assign_public_ip" {
  description = "パブリック IP を割り当てるか。NAT を置かない構成では true"
  type        = bool
  default     = true
}
