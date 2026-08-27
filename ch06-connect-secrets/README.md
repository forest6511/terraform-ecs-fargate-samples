# 第6章 サービス間通信と機密情報

`Terraform で作る Amazon ECS 実践入門` 第6章のサンプルコードです。

Service Connect でサービス間を短い名前で接続し、
Secrets Manager と Parameter Store の値をコンテナへ環境変数として渡します。

## 構成

- `namespace.tf` — Service Connect の名前空間
- `secrets.tf` — Secrets Manager のシークレットと Parameter Store のパラメータ
- `iam.tf` — タスク実行ロール（シークレット取得の権限を含む）
- `ecs.tf` — クラスター・タスク定義 2 本・サービス 2 本
- `vpc.tf` / `alb.tf` / `ecr.tf` — 第3章から引き継いだ土台

## 使い方

パスワードはコードに書かず、変数で渡します。

```bash
terraform init
export TF_VAR_db_password='任意のパスワード'
terraform plan
terraform apply
```

## 🔴 注意

- `terraform.tfstate` と保存したプランファイル（`*.tfplan`）には
  シークレットが平文で入ります。リポジトリに入れないでください
- 本書の構成は学習用です。本番にそのまま使わないでください
- 作業が終わったら `terraform destroy` でリソースを削除してください

```bash
terraform destroy -var "db_password=$TF_VAR_db_password"
```
