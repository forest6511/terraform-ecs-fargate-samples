resource "aws_ecr_repository" "app" {
  name = "${var.project}-app"

  # 既定の false のままだと、イメージが残った状態で destroy できない。
  # 第 8 章の撤収でつまずかないよう、学習用の構成では true にする
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
