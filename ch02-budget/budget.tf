# file: budget.tf
resource "aws_budgets_budget" "monthly" {
  name        = "ecs-book-monthly"
  budget_type = "COST"
  time_unit   = "MONTHLY"

  limit_amount = var.monthly_budget_usd
  limit_unit   = "USD"

  # 実績が 80% に達した時点で知らせる。100% を待つと手遅れになる
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  # 予測は実績より先に届く。使い始めた直後の異常を捕まえる役割
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}

# file: budget.tf（続き）
resource "aws_budgets_budget" "daily" {
  name        = "ecs-book-daily"
  budget_type = "COST"
  time_unit   = "DAILY"

  limit_amount = var.daily_budget_usd
  limit_unit   = "USD"

  # 日次では予測を使わない。1 日の途中の予測は振れが大きく、通知が増えすぎる
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
}
