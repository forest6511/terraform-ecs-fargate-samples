#!/usr/bin/env bash
# バージョニングを有効にした S3 バケットを空にする。
#
# aws s3 rm --recursive では空にならない。削除マーカーが積まれるだけで、
# 古いバージョンは残り、bucket の削除は BucketNotEmpty で失敗する。
# バージョンと削除マーカーの両方を delete-objects に渡す必要がある。
#
# 使い方: ./empty-versioned-bucket.sh <bucket-name>
set -euo pipefail

BUCKET="${1:?usage: $0 <bucket-name>}"

# delete-objects は 1 リクエスト 1,000 キーまで。残りがなくなるまで繰り返す。
while :; do
  PAYLOAD="$(aws s3api list-object-versions --bucket "$BUCKET" \
    --max-keys 1000 \
    --query '{Objects: [Versions, DeleteMarkers][][].
                {Key:Key,VersionId:VersionId}}' \
    --output json)"

  # 対象が無くなったら終了。null または空配列になる。
  COUNT="$(printf '%s' "$PAYLOAD" | python3 -c \
    'import json,sys
o = json.load(sys.stdin).get("Objects")
print(len(o or []))')"
  [ "$COUNT" -eq 0 ] && break

  aws s3api delete-objects --bucket "$BUCKET" --delete "$PAYLOAD" >/dev/null
  echo "deleted $COUNT object versions"
done

echo "bucket is now empty: $BUCKET"
