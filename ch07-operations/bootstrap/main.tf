# ステートを置く S3 バケットを作る。
#
# ここだけはローカルステートで動かす。ステートの置き場を作るのに
# ステートの置き場が要る、という循環を避けるため。
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.61"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project = "terraform-ecs-fargate-book"
    }
  }
}

variable "region" {
  description = "バケットを作るリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "bucket_name" {
  description = "ステート用バケット名。世界で一意にする"
  type        = string
}

resource "aws_s3_bucket" "tfstate" {
  bucket = var.bucket_name
}

# 上書きや誤削除から戻せるようにする。
# 第 6 章で見たとおり、ステートには機密が入りうる
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket_name" {
  description = "backend.tf の bucket に書く値"
  value       = aws_s3_bucket.tfstate.id
}
