# Service Connect が使う名前空間。
# ここに登録されたサービスだけが、短い名前でお互いを呼べる
resource "aws_service_discovery_http_namespace" "main" {
  name        = var.project
  description = "Service Connect namespace for ${var.project}"
}
