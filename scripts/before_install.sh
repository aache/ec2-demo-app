#!/usr/bin/env bash
set -eu

# Ensure base dirs
mkdir -p /opt/ec2-demo/deploy /opt/ec2-demo/scripts
chown -R ec2-user:ec2-user /opt/ec2-demo

# Install Docker if missing (Amazon Linux 2)
if ! command -v docker >/dev/null 2>&1; then
  yum update -y || true
  amazon-linux-extras enable docker || true
  yum install -y docker
  systemctl enable docker
  systemctl start docker
  usermod -aG docker ec2-user || true
fi

# Optional: install jq (used sometimes to read metadata)
command -v jq >/dev/null 2>&1 || yum install -y jq

# Optional: install docker compose v2 CLI if you plan to use it
if ! docker compose version >/dev/null 2>&1; then
  curl -L "https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose || true
  chmod +x /usr/local/bin/docker-compose || true
fi