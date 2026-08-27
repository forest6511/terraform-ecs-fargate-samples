terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.61"
    }
  }
}

provider "aws" {
  region = var.region

  # 第 2 章で付けたタグを引き継ぐ。Cost Explorer で本書ぶんだけ絞り込める
  default_tags {
    tags = {
      Project = "terraform-ecs-fargate-book"
    }
  }
}
