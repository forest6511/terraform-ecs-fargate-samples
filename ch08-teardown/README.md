# 第8章 撤収

本章のスクリプト。**課金の対象になるリソースは作らない。**

## sweep.sh

本書で作ったリソースが残っていないかを確認する。**何も削除しない。**

```bash
./sweep.sh
```

削除を自動化していないのは、同じ AWS アカウントで動かしている
別のプロジェクトを巻き込んで壊す事故を避けるため。
出力を目で見て、本書のものだけを判断して消す。

### 出力の読み方

- **時間課金が続くもの**（ECS / ALB / NAT Gateway / Elastic IP）が空であれば、
  主な課金は止まっている。ここを最優先で確認する
- **目視で判断するもの**（ECR / S3）には、本書と無関係なものが混ざる。
  名前を見て判断する
- **タグで絞る**の結果に、削除済みの ECS クラスターやサービスが出てくることがある。
  削除すると `INACTIVE` になり、タグも残るため。課金はされない。
  `ACTIVE` なものが無いことは `list-clusters` が空であることで判断する

## empty-versioned-bucket.sh

バージョニングを有効にした S3 バケットを空にする。

```bash
./empty-versioned-bucket.sh ecs-book-tfstate-123456789012
```

`aws s3 rm --recursive` では空にならない。
削除マーカーが積まれるだけで古いバージョンが残り、
バケットの削除は `BucketNotEmpty` で失敗する。
バージョンと削除マーカーの両方を `delete-objects` に渡す必要がある。

空にしたあと、バケット本体は `bootstrap` 側の `terraform destroy` で消す。

```bash
cd ../ch07-operations/bootstrap
terraform destroy -var "bucket_name=ecs-book-tfstate-123456789012"
```
