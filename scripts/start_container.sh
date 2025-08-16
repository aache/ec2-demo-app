#!/usr/bin/env bash
set -eu

# Hardcoded config (matches your account/region/resources)
REGION="ap-south-1"
S3_BUCKET="ec2-demo-app-bucket-tags"
ECR_URI_ACCOUNT="577805406315.dkr.ecr.ap-south-1.amazonaws.com"
REPO_NAME="ec2-demo-app"
ECR_IMAGE="${ECR_URI_ACCOUNT}/${REPO_NAME}"

mkdir -p /opt/ec2-demo/deploy

# Fetch the exact image tag produced by Build (from S3 latest.txt)
aws s3 cp "s3://${S3_BUCKET}/latest.txt" /opt/ec2-demo/deploy/image_tag.txt --region "${REGION}"
IMAGE_TAG="$(cat /opt/ec2-demo/deploy/image_tag.txt)"

# Login to ECR and pull image
aws ecr get-login-password --region "${REGION}" \
  | docker login --username AWS --password-stdin "${ECR_URI_ACCOUNT}"

docker pull "${ECR_IMAGE}:${IMAGE_TAG}"

# Run via compose if you have docker-compose.yml deployed; otherwise plain docker
if [ -f /opt/ec2-demo/docker-compose.yml ]; then
  ECR_URI="${ECR_URI_ACCOUNT}/${REPO_NAME}" IMAGE_TAG="${IMAGE_TAG}" \
    docker compose -f /opt/ec2-demo/docker-compose.yml up -d
else
  # Start the container exposing port 8080
  docker run -d --name ec2-demo-app -p 8080:8080 "${ECR_IMAGE}:${IMAGE_TAG}"
fi
