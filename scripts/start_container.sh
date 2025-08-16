#!/bin/bash
set -eu

APP_NAME="ec2-demo-app"
APP_PORT=8080
IMAGE_REPO="577805406315.dkr.ecr.ap-south-1.amazonaws.com/ec2-demo-app"

# Ensure IMAGE_TAG is set from CodeDeploy/appspec
if [ -z "${IMAGE_TAG:-}" ]; then
  echo "[error] IMAGE_TAG not provided. Exiting."
  exit 1
fi

echo "[docker] using image: ${IMAGE_REPO}:${IMAGE_TAG}"

# ---- Step 1: Remove any container already exposing port 8080 ----
if docker ps --filter publish=$APP_PORT -q | grep -q .; then
  echo "[docker] removing containers that publish :${APP_PORT}"
  docker ps --filter publish=$APP_PORT -q | xargs -r docker rm -f
fi

# ---- Step 2: Remove old container by name ----
echo "[docker] removing old container named $APP_NAME (if any)"
docker rm -f "$APP_NAME" 2>/dev/null || true

# ---- Step 3: Detect non-docker process on 8080 ----
if ss -ltn '( sport = :'$APP_PORT' )' | grep -q LISTEN; then
  echo "[error] A non-Docker process is listening on :$APP_PORT"
  echo "Stop it or change ports before deploying."
  exit 1
fi

# ---- Step 4: Pull and run new image ----
echo "[docker] pulling latest image"
docker pull "${IMAGE_REPO}:${IMAGE_TAG}"

echo "[docker] starting container $APP_NAME on :$APP_PORT"
docker run -d \
  --name "$APP_NAME" \
  --restart unless-stopped \
  -p ${APP_PORT}:8080 \
  "${IMAGE_REPO}:${IMAGE_TAG}"

echo "[success] container $APP_NAME started successfully"
