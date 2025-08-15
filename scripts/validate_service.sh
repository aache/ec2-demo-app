#!/usr/bin/env bash
set -euo pipefail
curl -fsS http://localhost:8080/ > /dev/null
echo "App responded OK"