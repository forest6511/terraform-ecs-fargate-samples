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

  # 以降に作るリソースへ自動でタグを付ける。
  # あとでコスト配分タグとして有効化すると、本書ぶんの金額だけを抽出できる
  default_tags {
    tags = {
      Project = "terraform-ecs-fargate-book"
    }
  }
}
