#!/usr/bin/env bash
# scripts/start_container.sh
set -eu

LOG="/var/log/ec2-demo-start.log"
exec > >(tee -a "$LOG") 2>&1
echo "== $(date) Starting start_container.sh =="

# ---- Static config (update if you rename things) ----
REGION="ap-south-1"
ACCOUNT_ID="577805406315"
REPO_NAME="ec2-demo-app"
S3_BUCKET="ec2-demo-app-bucket-tags"
ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
ECR_IMAGE="${ECR_REGISTRY}/${REPO_NAME}"

# ---- Pre-req checks ----
echo "[check] docker installed?"
if ! command -v docker >/dev/null 2>&1; then
  echo "[error] docker not found. Did before_install.sh run?"; exit 1
fi
systemctl is-active --quiet docker || { echo "[info] starting docker"; systemctl start docker || true; }

echo "[check] aws cli installed?"
command -v aws >/dev/null 2>&1 || { echo "[error] aws cli not found"; exit 1; }

# Helpful for IAM debugging
echo "[whoami] $(aws sts get-caller-identity --query Arn --output text || echo 'sts failed')"

# ---- Get immutable tag from S3 ----
mkdir -p /opt/ec2-demo/deploy
echo "[pull] S3 s3://${S3_BUCKET}/latest.txt -> /opt/ec2-demo/deploy/image_tag.txt"
if ! aws s3 cp "s3://${S3_BUCKET}/latest.txt" /opt/ec2-demo/deploy/image_tag.txt --region "${REGION}"; then
  echo "[error] failed to read latest.txt from S3 bucket ${S3_BUCKET} in ${REGION}. Check EC2 instance role s3:GetObject."; exit 1
fi
IMAGE_TAG="$(cat /opt/ec2-demo/deploy/image_tag.txt | tr -d '\r\n' || true)"
if [ -z "${IMAGE_TAG:-}" ]; then
  echo "[error] image tag file empty"; exit 1
fi
echo "[tag] ${IMAGE_TAG}"

# ---- ECR login (retry) ----
echo "[ecr] logging in to ${ECR_REGISTRY}"
for i in 1 2 3; do
  if aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "${ECR_REGISTRY}"; then
    echo "[ecr] login ok"; break
  fi
  echo "[ecr] login failed (attempt $i), retrying in 3s..."; sleep 3
  if [ "$i" -eq 3 ]; then echo "[error] ECR login failed"; exit 1; fi
done

# ---- Pull image (retry) ----
for i in 1 2 3; do
  echo "[docker] pulling ${ECR_IMAGE}:${IMAGE_TAG}"
  if docker pull "${ECR_IMAGE}:${IMAGE_TAG}"; then
    break
  fi
  echo "[docker] pull failed (attempt $i), retrying in 3s..."; sleep 3
  if [ "$i" -eq 3 ]; then echo "[error] docker pull failed"; exit 1; fi
done

# ---- Stop/remove any previous container ----
echo "[docker] stopping old container if exists"
docker stop ec2-demo-app 2>/dev/null || true
docker rm   ec2-demo-app 2>/dev/null || true

# ---- Run container ----
echo "[docker] starting ec2-demo-app"
docker run -d --name ec2-demo-app -p 8080:8080 "${ECR_IMAGE}:${IMAGE_TAG}"

# Optional prune (free space)
docker image prune -f 2>/dev/null || true

echo "== $(date) start_container.sh completed =="