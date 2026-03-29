# QuickTodo AWS Infrastructure Setup Guide

## Step 1: AWSマネジメントコンソールにログイン
https://console.aws.amazon.com/ にアクセスしてログイン

## Step 2: Route 53でドメイン登録

### 2.1 ドメインの登録
1. Route 53 サービスを開く
2. 「ドメイン」→「登録済みドメイン」→「ドメインを登録」をクリック
3. ドメイン名: `quicktodo.xyz` を入力
4. 「確認」をクリックして利用可能かチェック
5. 連絡先情報を入力：
   - 名: Admin
   - 姓: User
   - 組織名: QuickTodo
   - 住所1: 1-1-1 Shibuya
   - 市区町村: Shibuya-ku
   - 都道府県: Tokyo
   - 国: Japan
   - 郵便番号: 150-0002
   - 電話番号: +81.3123456789
   - メール: admin@quicktodo.xyz
6. プライバシー保護を有効化
7. 期間: 1年間
8. 支払い情報を入力して登録完了（年間$2）

**登録後**: ドメインの承認に数分〜数時間かかります

---

## Step 3: SSL証明書の発行（ACM）

1. **Certificate Manager** (ACM) サービスを開く
2. **リージョンを us-east-1（バージニア北部）に変更** ※重要
3. 「証明書をリクエスト」→「パブリック証明書をリクエスト」
4. ドメイン名: `quicktodo.xyz`
5. 「別の名前をこの証明書に追加」→ `*.quicktodo.xyz`
6. 「DNS検証」を選択
7. 「リクエスト」をクリック

### 3.1 DNS検証の設定
1. 証明書の詳細を開く
2. 「Route 53でレコードを作成」をクリック
3. CNAMEレコードが自動作成される
4. 検証完了まで数分待つ（ステータスが「発行済み」になる）

**証明書ARN**: `arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/XXXXX` をメモ

---

## Step 4: S3バケット作成

1. **S3** サービスを開く（リージョン: ap-northeast-1）
2. 「バケットを作成」
3. バケット名: `quicktodo.xyz`
4. リージョン: アジアパシフィック（東京）ap-northeast-1
5. 「パブリックアクセスをすべてブロック」のチェックを**外す**
6. 「バケットを作成」をクリック

### 4.1 静的ウェブサイトホスティングの有効化
1. バケットを開く → 「プロパティ」タブ
2. 「静的ウェブサイトホスティング」を編集
3. 「有効化」を選択
4. インデックスドキュメント: `index.html`
5. エラードキュメント: `index.html`
6. 「変更を保存」

### 4.2 バケットポリシーの設定
1. 「アクセス許可」タブ → 「バケットポリシー」
2. 「編集」→以下のポリシーを貼り付け：

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::quicktodo.xyz/*"
        }
    ]
}
```

3. 「変更を保存」

---

## Step 5: CloudFrontディストリビューション作成

1. **CloudFront** サービスを開く
2. 「ディストリビューションを作成」
3. オリジンドメイン: S3バケットを選択
   - `quicktodo.xyz.s3.ap-northeast-1.amazonaws.com`
   - **注意**: ドロップダウンから選択せず、正確に入力すること
4. オリジンアクセス: パブリック
5. 「ビューワープロトコルポリシー」: 「HTTPとHTTPSをリダイレクト」
6. 「代替ドメイン名 (CNAME)」: `quicktodo.xyz`
7. 「カスタムSSL証明書」: 手順3で作成した証明書を選択
8. 「デフォルトルートオブジェクト」: `index.html`
9. 「ディストリビューションを作成」をクリック

**作成後**: デプロイ完了まで15〜20分かかります

---

## Step 6: Route 53でDNSレコード設定

1. **Route 53** → 「ホストゾーン」を開く
2. `quicktodo.xyz` のゾーンを選択
3. 「レコードを作成」
4. レコード名: （空白＝ルートドメイン）
5. レコードタイプ: A
6. 「エイリアス」を有効化
7. トラフィックのルーティング先: CloudFrontディストリビューションを選択
8. 「レコードを作成」

---

## Step 7: RDSデータベース作成

1. **RDS** サービスを開く（リージョン: ap-northeast-1）
2. 「データベースを作成」
3. エンジンのタイプ: MySQL
4. テンプレート: 無料利用枠
5. データベース識別子: `todo-db`
6. マスターユーザー名: `admin`
7. マスターパスワード: `TodoApp2025!`（強力なパスワードに変更推奨）
8. インスタンス設定: db.t3.micro
9. ストレージ: 20 GB
10. VPC: デフォルトVPC
11. パブリックアクセス: はい（開発用）
12. VPCセキュリティグループ: 新規作成
    - 名前: `todo-db-sg`
    - インバウンドルール: MySQL/Aurora (3306) を 0.0.0.0/0 から許可
13. 「データベースを作成」をクリック

**作成後**: エンドポイントをメモ（例: `todo-db.XXXX.ap-northeast-1.rds.amazonaws.com`）

---

## Step 8: Systems Manager Parameter Store

1. **Systems Manager** サービスを開く（リージョン: ap-northeast-1）
2. 「パラメータストア」→「パラメータの作成」

作成するパラメータ:

| 名前 | タイプ | 値 |
|------|--------|-----|
| `/todo-app/db-host` | SecureString | RDSエンドポイント |
| `/todo-app/db-name` | SecureString | todo_db |
| `/todo-app/db-user` | SecureString | admin |
| `/todo-app/db-password` | SecureString | パスワード |

---

## Step 9: IAMロール作成（Lambda用）

1. **IAM** サービスを開く
2. 「ロール」→「ロールを作成」
3. 信頼されたエンティティタイプ: AWSサービス
4. 使用ケース: Lambda
5. 「次へ」
6. アクセス許可ポリシーに以下を追加：
   - AWSLambdaVPCAccessExecutionRole
   - AmazonSSMReadOnlyAccess
   - CloudWatchLogsFullAccess
7. ロール名: `todo-lambda-role`
8. 「ロールを作成」

---

## Step 10: API Gateway作成

1. **API Gateway** サービスを開く（リージョン: ap-northeast-1）
2. 「APIを作成」→「REST API」
3. 新しいAPI: `todo-api`
4. 「APIを作成」

### 10.1 リソース作成
1. 「リソースを作成」→ `/todos`
2. 「メソッドを作成」→
   - GET: Lambda統合
   - POST: Lambda統合
3. `/todos/{id}` リソースを作成
   - GET: Lambda統合
   - PUT: Lambda統合
   - DELETE: Lambda統合

### 10.2 CORS設定
各メソッドの「メソッドレスポンス」で：
- Access-Control-Allow-Origin: `*`
- Access-Control-Allow-Methods: `GET,POST,PUT,DELETE`
- Access-Control-Allow-Headers: `Content-Type`

### 10.3 APIをデプロイ
1. 「アクション」→「APIをデプロイ」
2. 新しいステージ: `prod`
3. 「デプロイ」

**APIエンドポイントURL**: `https://XXXX.execute-api.ap-northeast-1.amazonaws.com/prod`

---

## 次のステップ

上記の手順が完了したら、アプリケーションコードの修正（Laravel + Vue）を行います。

### 確認事項
- [ ] Route 53ドメイン登録完了
- [ ] ACM証明書発行＆検証完了
- [ ] S3バケット作成＆静的ホスティング有効化
- [ ] CloudFrontディストリビューション作成＆デプロイ完了
- [ ] Route 53 DNSレコード設定完了
- [ ] RDSデータベース作成完了
- [ ] Parameter Storeにパラメータ保存完了
- [ ] Lambda IAMロール作成完了
- [ ] API Gateway作成＆デプロイ完了

**すべて完了したら、アプリ改修フェーズに進みます。**
