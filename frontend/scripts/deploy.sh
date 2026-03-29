#!/bin/bash

# QuickTodo Frontend Deploy Script
set -e

DOMAIN="quicktodo.xyz"
REGION="ap-northeast-1"
DISTRIBUTION_ID=""  # CloudFront Distribution ID (後で設定)

echo "=========================================="
echo "QuickTodo Frontend Deployment"
echo "=========================================="
echo "Domain: $DOMAIN"
echo "Region: $REGION"
echo ""

# 1. ビルド
echo "[1/3] Building application..."
cd "$(dirname "$0")/.."
yarn install
yarn build

# 2. S3にデプロイ
echo "[2/3] Deploying to S3..."
aws s3 sync dist/ s3://$DOMAIN --delete --region $REGION

# 3. CloudFrontキャッシュ無効化
echo "[3/3] Invalidating CloudFront cache..."
if [ -n "$DISTRIBUTION_ID" ]; then
    aws cloudfront create-invalidation \
        --distribution-id $DISTRIBUTION_ID \
        --paths "/*" \
        --region us-east-1
    echo "Cache invalidation created"
else
    echo "WARNING: CloudFront Distribution ID not set"
    echo "Please manually invalidate cache from AWS Console"
fi

echo ""
echo "=========================================="
echo "Deployment complete!"
echo "=========================================="
echo "Website: https://$DOMAIN"
echo ""
