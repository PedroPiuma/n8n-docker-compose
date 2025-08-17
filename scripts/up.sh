#!/bin/bash
echo "🚀 Subindo serviços (docker compose up -d)..."
if command -v docker compose &> /dev/null; then
  docker compose up -d
else
  docker-compose up -d
fi

# Ler .env
set -o allexport
source .env
set +o allexport

echo "✅ Serviços em execução. Acesse:"
echo " - Local: http://${N8N_HOST}:${N8N_EXPOSE_PORT}"
