# Terraform で作る Amazon ECS 実践入門 — サンプルコード

書籍『Terraform で作る Amazon ECS 実践入門 ― AWS Fargate・無停止デプロイ・撤収まで、
コンテナ本番運用の全手順』のサンプルコードです。

> **本書および本リポジトリは Amazon Web Services, Inc. とは無関係の非公式な出版物です。**

## 🔴 料金が発生します

**このコードを `terraform apply` すると、AWS の利用料金が発生します。**

- 各章の冒頭に費用の目安を記載しています
- **各章末の撤収手順を必ず実行してください**。削除を忘れると課金が続きます
- 作業を終えたら請求ダッシュボードで課金が止まったことを確認してください
- 実行前に AWS Budgets で予算アラートを設定してください（書籍 第2章）

特に **NAT ゲートウェイ・Application Load Balancer** は起動しているだけで
時間課金されます。使い終えたら必ず削除してください。

詳細は [DISCLAIMER.md](DISCLAIMER.md) を参照してください。

## 動作環境

- Terraform `>= 1.9`
- AWS provider `~> 6.61`
- AWS CLI v2
- リージョン: `ap-northeast-1`（東京）

各ディレクトリの `versions.tf` でバージョンを固定しています。
`.terraform.lock.hcl` も含めているため、同じ provider 版で再現できます。

## 使い方

```bash
# 認証情報を設定（アクセスキーをコードに書かないこと）
aws configure --profile your-profile
export AWS_PROFILE=your-profile

cd ch03-minimum-stack
terraform init
terraform plan
terraform apply

# 🔴 終わったら必ず
terraform destroy
```

## ディレクトリ構成

章ごとに独立したディレクトリになっています。前の章の続きから始める構成ではないので、
どの章からでも `terraform apply` できます。

（章の追加にあわせて記載します）

## 🔴 このコードは学習用です

本書の構成は、手順を追いやすくするために単純化しています。
**本番環境にそのまま使わないでください。** 実運用では以下の検討が必要です。

- ステートのリモートバックエンド（S3 + DynamoDB ロック）
- 最小権限の IAM ポリシー（本書では簡略化しています）
- マルチアカウント構成、タグ付けの方針
- 監視・アラートの設計

## ライセンス

[MIT License](LICENSE)

ライセンスはコードの利用許諾です。損害の免責については [DISCLAIMER.md](DISCLAIMER.md) を参照してください。
