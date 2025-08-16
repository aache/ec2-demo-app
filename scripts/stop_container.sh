#!/usr/bin/env bash
set -eu

# Stop and remove the old container if present
docker stop ec2-demo-app 2>/dev/null || true
docker rm   ec2-demo-app 2>/dev/null || true

# Optional: prune dangling images to save disk
docker image prune -f 2>/dev/null || true
