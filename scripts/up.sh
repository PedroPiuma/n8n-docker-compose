#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
cd "$PROJECT_DIR"

# Iniciar ngrok e capturar a URL pública para atualizar o WEBHOOK_URL no .env
if command -v ngrok >/dev/null 2>&1; then
  echo "🔌 Abrindo túnel ngrok para https://n8n.local:5678 ..."
  # Se a API do ngrok ainda não responde, iniciamos o processo em background
  if ! curl -sf http://127.0.0.1:4040/api/tunnels >/dev/null 2>&1; then
    # Iniciar ngrok em background sem persistir logs em arquivo
    nohup ngrok http https://n8n.local:5678 --host-header=n8n.local >/dev/null 2>&1 &
    # Aguardar a API subir
    for i in {1..20}; do
      sleep 1
      if curl -sf http://127.0.0.1:4040/api/tunnels >/dev/null 2>&1; then
        break
      fi
    done
  fi
  # Ler a URL pública (prioriza https)
  NGROK_URL="$(curl -s http://127.0.0.1:4040/api/tunnels | sed -n 's/.*"public_url":"\(https:[^"]*\)".*/\1/p' | head -n1 || true)"
  if [ -n "${NGROK_URL:-}" ]; then
    echo "🔗 Ngrok URL detectada: $NGROK_URL"
    ENV_FILE="$PROJECT_DIR/.env"
    # Backup do .env
    if [ -f "$ENV_FILE" ]; then
      mkdir -p "$PROJECT_DIR/backups"
      cp "$ENV_FILE" "$PROJECT_DIR/backups/.env.bak_${TIMESTAMP}"
    fi
    # Atualiza ou adiciona WEBHOOK_URL
    if [ -f "$ENV_FILE" ] && grep -q '^WEBHOOK_URL=' "$ENV_FILE"; then
      sed -i -E "s|^WEBHOOK_URL=.*$|WEBHOOK_URL=$NGROK_URL|g" "$ENV_FILE"
    else
      echo "WEBHOOK_URL=$NGROK_URL" >> "$ENV_FILE"
    fi
    # Export para garantir que o compose enxergue mesmo se usar env interpolado
    export WEBHOOK_URL="$NGROK_URL"
    echo "✅ WEBHOOK_URL atualizado em .env"
  else
    echo "⚠️  Não foi possível obter a URL do ngrok pela API local. Prosseguindo sem atualizar WEBHOOK_URL."
  fi
else
  echo "⚠️  ngrok não encontrado no PATH. Pulando configuração automática do WEBHOOK_URL."
fi

echo "🚀 Subindo serviços (docker compose up -d)..."
docker compose up -d

echo "✅ Serviços em execução. Acesse:"
echo " - Local: https://n8n.local:5678 (via Caddy, se configurado)"
echo " - Local (HTTP direto se exposto): http://localhost:5678"
echo " - Ngrok: ${WEBHOOK_URL:-indisponível}"
