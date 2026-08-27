#!/usr/bin/env bash
# 本書で作ったリソースが残っていないかを確認する。
#
# このスクリプトは何も削除しない。一覧を出すだけ。
# 削除を自動化しないのは、同じ AWS アカウントで動かしている
# 別のプロジェクトを巻き込んで壊す事故を避けるため。
set -uo pipefail

echo "=== 時間課金が続くもの（最優先で確認） ==="
echo "-- ECS クラスター"
aws ecs list-clusters --query 'clusterArns' --output text
echo "-- ALB / NLB"
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[].LoadBalancerName' --output text
echo "-- NAT Gateway"
aws ec2 describe-nat-gateways \
  --query 'NatGateways[?State!=`deleted`].NatGatewayId' --output text
echo "-- Elastic IP（付いていても外れていても課金される）"
aws ec2 describe-addresses --query 'Addresses[].PublicIp' --output text

echo
echo "=== 保存量で課金されるもの ==="
echo "-- VPC（デフォルト VPC は除外）"
aws ec2 describe-vpcs --query 'Vpcs[?!IsDefault].VpcId' --output text
echo "-- ロググループ"
aws logs describe-log-groups --query 'logGroups[].logGroupName' --output text
echo "-- シークレット"
aws secretsmanager list-secrets --query 'SecretList[].Name' --output text
echo "-- 名前空間"
aws servicediscovery list-namespaces --query 'Namespaces[].Name' --output text

echo
echo "=== 目視で判断するもの（本書と無関係なものが混ざる） ==="
echo "-- ECR リポジトリ"
aws ecr describe-repositories \
  --query 'repositories[].repositoryName' --output text
echo "-- S3 バケット"
aws s3api list-buckets --query 'Buckets[].Name' --output text

echo
echo "=== タグで絞る（本書の構成にだけ付けたタグ） ==="
echo "   注意: 削除済みの ECS クラスター/サービス/タスク定義は INACTIVE として"
echo "   残り、タグも保持されるためここに出てくる。課金はされない。"
echo "   ACTIVE なものが無いことは上の list-clusters が空であることで判断する。"
aws resourcegroupstaggingapi get-resources \
  --tag-filters "Key=Project,Values=terraform-ecs-fargate-book" \
  --query 'ResourceTagMappingList[].ResourceARN' --output text

echo
echo "=== 課金されないが残るもの ==="
echo "-- タスク定義（INACTIVE でも無期限に残る。課金はされない）"
aws ecs list-task-definitions --status ACTIVE \
  --query 'taskDefinitionArns' --output text
