# 第4章 動かないときに読む

第 3 章の最小構成に、第 4 章で扱う調査用の設定を足したものです。

## 第 3 章からの差分

- `iam.tf` — タスクロール（`aws_iam_role.task`）と、
  ECS Exec 用のポリシー（`ssmmessages` の 4 アクション）を追加
- `ecs.tf` — タスク定義に `task_role_arn`、
  サービスに `enable_execute_command = var.enable_exec` を追加
- `variables.tf` — `enable_exec`（既定 `false`）を追加

`terraform plan` で 25 個のリソースが作られます（第 3 章の 23 個 + 2 個）。

## 使い方

```bash
terraform init
terraform apply

# 調査したいときだけ ECS Exec を有効にする
terraform apply -var enable_exec=true
```

## 撤収

```bash
terraform destroy
```

ALB とパブリック IPv4 アドレスは、タスクが起動していなくても課金されます。
調査を中断するときも destroy してください。
