# 第3章 最小構成を Terraform で立てる

`compose.yaml` 1 枚の状態から、AWS Fargate で動くサービスまでを組み立てます。

## 構成

VPC、パブリックサブネット 2 つ、ALB、ECR、Fargate サービスの計 23 リソース。
第 2 章で選んだ「パブリック IP 方式」を採り、NAT ゲートウェイと
VPC エンドポイントは置きません。

## 費用

ALB・Fargate タスク 1 個・パブリック IPv4 で、おおむね 1 時間あたり 0.05 USD 前後です
（執筆時点の東京リージョンの単価に基づく参考値）。

**使い終わったら必ず `terraform destroy` を実行してください。**

## 使い方

```bash
terraform init

# 先に ECR だけ作る（タスク定義がイメージを参照するため）
terraform apply -target=aws_ecr_repository.app

# イメージをビルドしてプッシュ
ACC=$(aws sts get-caller-identity --query Account --output text)
REG=ap-northeast-1
REPO="$ACC.dkr.ecr.$REG.amazonaws.com/ecs-book-app"

aws ecr get-login-password --region $REG \
  | docker login --username AWS \
      --password-stdin "$ACC.dkr.ecr.$REG.amazonaws.com"

cd app
docker build --platform linux/amd64 -t "$REPO:v1" .
docker push "$REPO:v1"
cd ..

# 残りを作る
terraform apply

# 動作確認
curl "http://$(terraform output -raw alb_dns_name)/"

# 撤収（必ず実行する）
terraform destroy
```

`--platform linux/amd64` を忘れると、Apple シリコンの Mac では
ARM 向けイメージができてタスクが起動しません。
