#!/usr/bin/env bash
set -euo pipefail

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

# Read the exact tag that Build produced (from artifact placed by CodeDeploy)
IMAGE_TAG=$(cat /opt/ec2-demo/deploy/image_tag.txt)

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_URI}

docker pull ${ECR_URI}/ec2-demo-app:${IMAGE_TAG}

docker stop ec2-demo-app || true
docker rm ec2-demo-app || true

docker run -d --name ec2-demo-app -p 8080:8080 \
  ${ECR_URI}/ec2-demo-app:${IMAGE_TAG}