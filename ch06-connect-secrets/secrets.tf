# データベースの接続情報。JSON で複数の値をまとめて持たせる
resource "aws_secretsmanager_secret" "db" {
  name = "${var.project}/db"

  # 既定は 30 日。destroy しても待機期間が明けるまで同じ名前で作り直せない。
  # 学習用なので待機なしで即座に消えるようにする
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = "app"
    password = var.db_password
  })
}

# 機密ではないがコードに埋めたくない設定値は Parameter Store に置く
resource "aws_ssm_parameter" "api_endpoint" {
  name  = "/${var.project}/api-endpoint"
  type  = "String"
  value = "http://api:8080"
}
