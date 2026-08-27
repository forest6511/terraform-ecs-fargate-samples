variable "region" {
  description = "リソースを作成するリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "alert_email" {
  description = "予算アラートの通知先メールアドレス"
  type        = string
}

variable "monthly_budget_usd" {
  description = "月次予算の上限（USD）"
  type        = string
  default     = "20"
}

variable "daily_budget_usd" {
  description = "日次予算の上限（USD）"
  type        = string
  default     = "3"
}
