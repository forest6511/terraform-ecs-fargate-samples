# ワークフローの例

このディレクトリは `.github/workflows/` ではないので、この repo では実行されない。

使うときは、自分の repo にコピーして `.github/workflows/` に置く。
その前に次の 3 つを自分の値に書き換えること。

1. `role-to-assume` — `terraform output github_actions_role_arn` の値
2. `aws-region` — 使うリージョン
3. `TF_STATE_BUCKET` — `bootstrap` で作ったバケット名

ロール側の信頼ポリシーが自分の repo の `sub` クレームと一致していないと、
`Not authorized to perform sts:AssumeRoleWithWebIdentity` で止まる。
自分の値は次で調べる。

```bash
gh api repos/<owner>/<repo>/actions/oidc/customization/sub
```
