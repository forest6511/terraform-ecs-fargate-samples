variable "project" {
  description = "リソース名の接頭辞"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC の CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "使うアベイラビリティーゾーンの数。ALB が 2 以上を要求する"
  type        = number
  default     = 2
}
