## 概要
Terraformを用いてAWS環境を構築し、GitHub ActionsによるCI/CDを実装しています。
また、S3 + DynamoDBをbackendとして使用し、tfstateのリモート管理を行っています。

## 前提条件
- Terraformを実行できるIAMロールが作成されていること
- GitHub ActionsからAWSへアクセスするためのOIDC設定が完了していること
- S3バケットおよびDynamoDBテーブルが作成されていること

そのため、本環境を適用する前に `bootstrap` 環境で Terraform を実行し、
S3バケット,DynamoDBテーブル,IAMロールを事前に作成する必要があります。  

## 実行手順

### 1. backend用リソースの作成
```bash
cd bootstrap
terraform init
terraform apply
```

### 2. dev環境の初期化
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### 3. CI/CD
1. GitHub ActionsにPRを出すと、CIが走り、`terraform plan`の結果が出ます。
2. マージすると、CDが走り、AWSリソースが作成されます。

## 補足（セキュリティ設定）
GitHub Actions から AWS へアクセスするための IAM ロールについては、
OIDC の信頼ポリシーにて以下のような条件でアクセスを制限しています。

- 特定の GitHub リポジトリのみ許可
- ブランチ（main）または pull_request のみ許可

例：
- token.actions.githubusercontent.com:sub に対して
  repo:<organization>/<repository>:ref:refs/heads/main
  repo:<organization>/<repository>:pull_request

これにより、不要なリポジトリやブランチからのアクセスを防止しています。
