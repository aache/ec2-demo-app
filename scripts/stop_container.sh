#!/usr/bin/env bash
set -euo pipefail
cd /opt/ec2-demo
# Try compose first; fall back to plain Docker
if docker compose ls >/dev/null 2>&1; then
  ECR_URI=${ECR_URI:-}
  IMAGE_TAG=${IMAGE_TAG:-}
  docker compose -f docker-compose.yml down || true
else
  docker rm -f ec2-demo-app || true
fi