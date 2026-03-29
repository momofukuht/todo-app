#!/bin/bash
set -e

# 設定
DOMAIN="quicktodo.xyz"
REGION="ap-northeast-1"
GLOBAL_REGION="us-east-1"
STACK_NAME="todo-app"

# プロファイル設定（SSO用）
export AWS_PROFILE=${AWS_PROFILE:-default}

# 色の設定
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}QuickTodo AWS Infrastructure Setup${NC}"
echo "=================================="
echo "Domain: $DOMAIN"
echo "Region: $REGION"
echo ""

# 1. Route 53ドメイン登録
echo -e "${YELLOW}[1/8] Route 53: ドメイン登録${NC}"
echo "注意: Route 53ドメイン登録はus-east-1リージョンで実行します"
aws route53domains register-domain \
    --domain-name $DOMAIN \
    --duration-in-years 1 \
    --admin-contact file://contact.json \
    --registrant-contact file://contact.json \
    --tech-contact file://contact.json \
    --privacy-protect-admin-contact \
    --privacy-protect-registrant-contact \
    --privacy-protect-tech-contact \
    --auto-renew \
    --region $GLOBAL_REGION || echo "ドメイン登録スキップ（既に登録済みの可能性）"

# 2. ACM SSL証明書の作成
echo -e "${YELLOW}[2/8] ACM: SSL証明書発行${NC}"
CERT_ARN=$(aws acm request-certificate \
    --domain-name $DOMAIN \
    --subject-alternative-names "*.$DOMAIN" \
    --validation-method DNS \
    --region us-east-1 \
    --output text \
    --query 'CertificateArn')

echo "Certificate ARN: $CERT_ARN"

# 証明書検証用DNSレコードを取得
sleep 5
aws acm describe-certificate \
    --certificate-arn $CERT_ARN \
    --region us-east-1 \
    --output json > cert-details.json

echo "証明書の検証が必要です。マネジメントコンソールで確認してください。"

# 3. S3バケット作成
echo -e "${YELLOW}[3/8] S3: バケット作成${NC}"
aws s3 mb s3://$DOMAIN --region $REGION || echo "バケットは既に存在します"

# 静的ウェブサイトホスティング有効化
aws s3 website s3://$DOMAIN --index-document index.html --error-document index.html

# バケットポリシー設定
cat > bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$DOMAIN/*"
        }
    ]
}
EOF

aws s3api put-bucket-policy --bucket $DOMAIN --policy file://bucket-policy.json

# 4. CloudFrontディストリビューション作成
echo -e "${YELLOW}[4/8] CloudFront: ディストリビューション作成${NC}"
echo "注意: SSL証明書の検証が完了してから実行してください"
echo "証明書ARN: $CERT_ARN"

cat > cloudfront-config.json << EOF
{
    "CallerReference": "$(date +%s)",
    "Aliases": {
        "Quantity": 1,
        "Items": ["$DOMAIN"]
    },
    "Origins": {
        "Quantity": 1,
        "Items": [
            {
                "Id": "S3Origin",
                "DomainName": "$DOMAIN.s3.$REGION.amazonaws.com",
                "S3OriginConfig": {
                    "OriginAccessIdentity": ""
                }
            }
        ]
    },
    "DefaultCacheBehavior": {
        "TargetOriginId": "S3Origin",
        "ViewerProtocolPolicy": "redirect-to-https",
        "AllowedMethods": {
            "Quantity": 2,
            "Items": ["GET", "HEAD"],
            "CachedMethods": {
                "Quantity": 2,
                "Items": ["GET", "HEAD"]
            }
        },
        "ForwardedValues": {
            "QueryString": false,
            "Cookies": {"Forward": "none"}
        },
        "MinTTL": 0,
        "DefaultTTL": 86400,
        "MaxTTL": 31536000,
        "Compress": true
    },
    "Comment": "QuickTodo frontend distribution",
    "Enabled": true,
    "PriceClass": "PriceClass_200"
}
EOF

# 証明書検証後に実行
# aws cloudfront create-distribution --distribution-config file://cloudfront-config.json

echo -e "${GREEN}フロントエンド設定完了${NC}"

# 5. RDSデータベース作成
echo -e "${YELLOW}[5/8] RDS: MySQLデータベース作成${NC}"
aws rds create-db-instance \
    --db-instance-identifier todo-db \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --engine-version 8.0 \
    --allocated-storage 20 \
    --master-username admin \
    --master-user-password 'TodoApp2025!' \
    --db-name todo_db \
    --vpc-security-group-ids $(aws ec2 describe-security-groups --filters Name=group-name,Values=default --query 'SecurityGroups[0].GroupId' --output text) \
    --publicly-accessible \
    --region $REGION || echo "DBは既に存在します"

echo "RDSエンドポイントを待機中..."
aws rds wait db-instance-available --db-instance-identifier todo-db --region $REGION

RDS_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier todo-db \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text \
    --region $REGION)

echo "RDS Endpoint: $RDS_ENDPOINT"

# 6. Systems Manager Parameter StoreにDB情報保存
echo -e "${YELLOW}[6/8] Systems Manager: パラメータ保存${NC}"
aws ssm put-parameter \
    --name "/todo-app/db-host" \
    --value "$RDS_ENDPOINT" \
    --type SecureString \
    --overwrite \
    --region $REGION

aws ssm put-parameter \
    --name "/todo-app/db-name" \
    --value "todo_db" \
    --type SecureString \
    --overwrite \
    --region $REGION

aws ssm put-parameter \
    --name "/todo-app/db-user" \
    --value "admin" \
    --type SecureString \
    --overwrite \
    --region $REGION

aws ssm put-parameter \
    --name "/todo-app/db-password" \
    --value "TodoApp2025!" \
    --type SecureString \
    --overwrite \
    --region $REGION

# 7. Lambda実行ロール作成
echo -e "${YELLOW}[7/8] IAM: Lambda実行ロール作成${NC}"

cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

aws iam create-role \
    --role-name todo-lambda-role \
    --assume-role-policy-document file://trust-policy.json || echo "ロールは既に存在します"

# ポリシーアタッチ
aws iam attach-role-policy \
    --role-name todo-lambda-role \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole

aws iam attach-role-policy \
    --role-name todo-lambda-role \
    --policy-arn arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess

# 8. API Gateway作成
echo -e "${YELLOW}[8/8] API Gateway: REST API作成${NC}"
API_ID=$(aws apigateway create-rest-api \
    --name todo-api \
    --region $REGION \
    --query 'id' \
    --output text)

echo "API ID: $API_ID"

# ルートリソース取得
ROOT_RESOURCE_ID=$(aws apigateway get-resources \
    --rest-api-id $API_ID \
    --region $REGION \
    --query 'items[0].id' \
    --output text)

# /todos リソース作成
TODOS_RESOURCE_ID=$(aws apigateway create-resource \
    --rest-api-id $API_ID \
    --parent-id $ROOT_RESOURCE_ID \
    --path-part todos \
    --region $REGION \
    --query 'id' \
    --output text)

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}インフラ構造が完了しました！${NC}"
echo -e "${GREEN}==================================${NC}"
echo ""
echo "次のステップ:"
echo "1. ACM証明書の検証を確認（マネジメントコンソール）"
echo "2. CloudFrontディストリビューションを作成（コメントアウトを解除）"
echo "3. Route 53でCloudFrontにAレコードを設定"
echo "4. Lambda関数をデプロイ"
echo ""
echo "証明書ARN: $CERT_ARN"
echo "API ID: $API_ID"
