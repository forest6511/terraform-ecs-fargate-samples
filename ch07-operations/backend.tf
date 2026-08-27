# ステートを S3 に置く。bootstrap/ でバケットを作ってから init する。
#
# use_lockfile は v1.10 で入った S3 だけで完結するロック。
# 以前は dynamodb_table で DynamoDB を併用したが、こちらは非推奨になった。
#
# bucket は世界で一意でなければならないので、自分の値に書き換えること
terraform {
  backend "s3" {
    bucket       = "REPLACE-ME-tfstate-example"
    key          = "ch07-operations/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
