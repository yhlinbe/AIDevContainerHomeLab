#!/usr/bin/env sh
set -e

# 指定位於 .devcontainer/ 目錄下的 Compose 檔
COMPOSE_FILE=".devcontainer/docker-compose.dev.yml"

echo "=== [Host Init] Checking infrastructure background services ==="

if [ -f "$COMPOSE_FILE" ]; then
    echo "🚀 Starting $COMPOSE_FILE ..."
    docker compose -f "$COMPOSE_FILE" up -d
else
    echo "⚠️ Warning: $COMPOSE_FILE not found."
fi