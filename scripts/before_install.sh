#!/usr/bin/env bash
set -euo pipefail

# Install Docker & compose plugin if missing (Amazon Linux 2023/2)
if ! command -v docker >/dev/null 2>&1; then
  yum update -y || true
  amazon-linux-extras enable docker || true
  yum install -y docker
  systemctl enable docker
  systemctl start docker
  usermod -aG docker ec2-user || true
fi

if ! docker compose version >/dev/null 2>&1; then
  # Compose v2 plugin is usually in docker package on AL2023; fallback to binary install if needed
  curl -L https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose || true
fi

mkdir -p /opt/ec2-demo
chown -R ec2-user:ec2-user /opt/ec2-demo

# Optional: render /opt/ec2-demo/.env from SSM Parameter Store path /ec2-demo/<env>/*
# Example (uncomment & set ENV_NAME tag on instance):
# ENV_NAME=$(curl -s http://169.254.169.254/latest/meta-data/tags/instance/Environment || echo dev)
# aws ssm get-parameters-by-path --path "/ec2-demo/${ENV_NAME}/" --with-decryption --query 'Parameters[].{Name:Name,Value:Value}' --output text |
#   awk '{gsub(".*/","",$1); printf "%s=%s\n",$1,$2}' > /opt/ec2-demo/.env
