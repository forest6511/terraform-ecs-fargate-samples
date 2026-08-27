# 第5章 無停止で更新する

ローリング更新・ブルー/グリーンデプロイ・リニアデプロイ・カナリアデプロイを
Terraform だけで書きます。CodeDeploy のリソースは使いません。

## 第3章との違い

- ターゲットグループが 2 つ（`blue` / `green`）
- 転送をリスナールールで行う（`default_action` ではなく）
- ECS がロードバランサーを操作するための IAM ロールを追加
- `aws_ecs_service` に `deployment_configuration` を書く

## 使い方

```bash
terraform init
terraform plan
```

デプロイ戦略は変数で切り替えられます。

```bash
terraform plan -var deployment_strategy=BLUE_GREEN   # 既定
terraform plan -var deployment_strategy=LINEAR
terraform plan -var deployment_strategy=CANARY
terraform plan -var deployment_strategy=ROLLING
```

イメージを ECR へ置いてから `apply` してください。手順は第3章と同じです。
更新を試すときは `-var image_tag=v2` のようにタグを変えます。

## 🔴 撤収

この章は移行のあいだタスクが一時的に 2 倍になります。
確認が終わったら必ず消してください。

```bash
terraform apply -var desired_count=0   # まずタスクだけ止める
terraform destroy
```

ターゲットグループは 2 つ作るので、2 つとも消えたことを確認してください。

## 注意

本書の構成は学習用です。本番にそのまま使わないでください。
実行には AWS の利用料金が発生します。詳細は repo 直下の `DISCLAIMER.md` を参照してください。
