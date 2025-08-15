#!/usr/bin/env bash
set -euo pipefail
cd /opt/ec2-demo

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
IMAGE_REPO="ec2-demo-app"
IMAGE_TAG=$(cat /opt/ec2-demo/image_tag.txt 2>/dev/null || echo "latest")

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_URI}

export ECR_URI IMAGE_TAG
# Pull & start via compose
docker pull ${ECR_URI}/${IMAGE_REPO}:${IMAGE_TAG}
docker pull ${ECR_URI}/${IMAGE_REPO}:latest || true

# Compose will use ECR_URI + IMAGE_TAG from env and external /opt/ec2-demo/.env for application props
docker compose -f docker-compose.yml up -d