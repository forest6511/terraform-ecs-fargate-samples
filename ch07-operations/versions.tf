terraform {
  # 第 6 章までは ">= 1.9" だった。
  # S3 バックエンドの use_lockfile が v1.10 で入った機能なので、この章だけ上げる
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
