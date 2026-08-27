# ch02-budget — 予算アラート

『Terraform で作る Amazon ECS 実践入門』第 2 章のサンプルコードです。

## これは何か

リソースを作り始める前に、AWS Budgets で予算アラートを 2 本張ります。

- `ecs-book-monthly`: 月次のコスト予算。実際 (発生後) 80% と 予測 (発生前) 100% で通知
- `ecs-book-daily`: 日次のコスト予算。実際 (発生後) 100% で通知

月次だけでは消し忘れに気づくのが遅れるため、日次を併用します。

## 料金について

**この構成に追加料金は発生しません。**
AWS Pricing API で確認したところ、通知のみを行う通常の予算は
`BudgetsUsage` が $0.00 per Budget-day でした（2026-08 時点・東京リージョン）。

ただし予算に「アクション」を付けると課金対象になります。本サンプルは使っていません。

最新の単価はご自身で確認してください。

```bash
aws pricing get-products --region us-east-1 --service-code AWSBudgets --output json
```

## 使い方

```bash
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars を編集して alert_email を自分のアドレスにする

terraform init
terraform plan
terraform apply
```

## 撤収

```bash
terraform destroy
```

予算そのものは無料なので、第 3 章以降の安全網として残しておくことを勧めます。

## 注意

- 予算名はアカウント内で一意です。既存の予算と名前が衝突しないよう
  `ecs-book-` の接頭辞を付けています
- 本書の構成は学習用です。本番環境にそのまま使わないでください
