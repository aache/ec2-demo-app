#!/usr/bin/env bash
set -eu

# Simple health check (adjust path if your app exposes a health endpoint)
# Tries /actuator/health then falls back to root.
if curl -fsS -m 5 http://localhost:8080/actuator/health >/dev/null 2>&1; then
  exit 0
fi

curl -fsS -m 5 http://localhost:8080/ >/dev/null
