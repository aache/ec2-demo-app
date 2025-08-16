#!/usr/bin/env bash
set -eu

LOG="/var/log/ec2-demo-start.log"
exec > >(tee -a "$LOG") 2>&1
echo "== $(date) Starting start_container.sh abcd =="

# ---- Static config (edit if you rename things) ----
REGION="ap-south-1"
ACCOUNT_ID="577805406315"
REPO_NAME="ec2-demo-app"
S3_BUCKET="ec2-demo-app-bucket-tags"
APP_NAME="ec2-demo-app"
APP_PORT_HOST=8080       # host port to bind
APP_PORT_CONTAINER=8080  # container port your Spring Boot listens on

ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
ECR_IMAGE="${ECR_REGISTRY}/${REPO_NAME}"

# ---- Pre-req checks ----
command -v docker >/dev/null 2>&1 || { echo "[error] docker not found"; exit 1; }
systemctl is-active --quiet docker || { echo "[info] starting docker"; systemctl start docker || true; }
command -v aws >/dev/null 2>&1 || { echo "[error] aws cli not found"; exit 1; }

echo "[whoami] $(aws sts get-caller-identity --query Arn --output text || echo 'sts failed')"

# ---- Get immutable tag from S3 ----
mkdir -p /opt/ec2-demo/deploy
echo "[pull] s3://${S3_BUCKET}/latest.txt -> /opt/ec2-demo/deploy/image_tag.txt"
aws s3 cp "s3://${S3_BUCKET}/latest.txt" "/opt/ec2-demo/deploy/image_tag.txt" --region "${REGION}"
IMAGE_TAG="$(tr -d '\r\n' < /opt/ec2-demo/deploy/image_tag.txt)"
[ -n "${IMAGE_TAG}" ] || { echo "[error] image tag empty"; exit 1; }
echo "[tag] ${IMAGE_TAG}"

# ---- ECR login ----
echo "[ecr] login to ${ECR_REGISTRY}"
aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "${ECR_REGISTRY}"
echo "[ecr] login ok"

# ---- Pull image ----
echo "[docker] pulling ${ECR_IMAGE}:${IMAGE_TAG}"
docker pull "${ECR_IMAGE}:${IMAGE_TAG}"

# ---- Free port if in use by any container ----
if docker ps --format '{{.ID}} {{.Ports}}' | grep -q ":${APP_PORT_HOST}->"; then
  echo "[docker] removing containers that publish :${APP_PORT_HOST}"
  docker ps --filter "publish=${APP_PORT_HOST}" -q | xargs -r docker rm -f
fi

# ---- Remove old container by name (if exists) ----
echo "[docker] removing old container named ${APP_NAME} (if any)"
docker rm -f "${APP_NAME}" 2>/dev/null || true

# ---- If a NON-docker process holds the port, kill it (last resort) ----
# Try ss first, fall back to lsof if available.
PID=""
if ss -ltnp 2>/dev/null | awk '{print $4,$6}' | grep -qE ":${APP_PORT_HOST}\s"; then
  PID="$(ss -ltnp 2>/dev/null | awk -v p=":${APP_PORT_HOST}" '$4 ~ p {print $6}' | sed -n 's/.*pid=\([0-9]\+\).*/\1/p' | head -n1 || true)"
fi
if [ -z "${PID}" ] && command -v lsof >/dev/null 2>&1; then
  PID="$(lsof -iTCP:${APP_PORT_HOST} -sTCP:LISTEN -t 2>/dev/null | head -n1 || true)"
fi
if [ -n "${PID}" ]; then
  echo "[warn] non-docker process PID ${PID} is listening on :${APP_PORT_HOST} – killing it"
  kill -TERM "${PID}" || true
  sleep 2
  if ss -ltn "( sport = :${APP_PORT_HOST} )" | grep -q LISTEN; then
    echo "[warn] PID ${PID} still holding port, sending KILL"
    kill -KILL "${PID}" || true
    sleep 1
  fi
  if ss -ltn "( sport = :${APP_PORT_HOST} )" | grep -q LISTEN; then
    echo "[error] port :${APP_PORT_HOST} still busy after kill attempts"; exit 1
  fi
fi

# ---- Start container ----
echo "[docker] starting ${APP_NAME} on :${APP_PORT_HOST} -> :${APP_PORT_CONTAINER}"
docker run -d \
  --name "${APP_NAME}" \
  --restart unless-stopped \
  -p ${APP_PORT_HOST}:${APP_PORT_CONTAINER} \
  "${ECR_IMAGE}:${IMAGE_TAG}"

echo "[docker] container started:"
docker ps --filter "name=${APP_NAME}"

echo "== $(date) start_container.sh completed =="
