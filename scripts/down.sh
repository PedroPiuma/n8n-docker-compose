#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "🛑 Derrubando serviços (docker compose down)..."
docker compose down

echo "🔌 Verificando e encerrando túneis ngrok do n8n (se houver)..."
NGROK_API="http://127.0.0.1:4040/api/tunnels"
TARGET_ADDR_REGEX='^https://n8n\.local:5678$'

# Tenta encerrar via API local do ngrok (preferindo XML para parsing simples)
if curl -sf -H 'Accept: application/xml' "$NGROK_API" >/dev/null 2>&1; then
  XML_RESPONSE="$(curl -s -H 'Accept: application/xml' "$NGROK_API")"
  # Extrair nomes de túneis cujo <Addr> corresponda ao destino do n8n
  MAP_TUNNELS=$(echo "$XML_RESPONSE" | awk '
    /<Tunnels>/ {inT=1; name=""; addr=""; next}
    inT && /<Name>/ {gsub(/.*<Name>/,""); gsub(/<.*/,""); name=$0}
    inT && /<Addr>/ {gsub(/.*<Addr>/,""); gsub(/<.*/,""); addr=$0}
    /<\/Tunnels>/ { if (inT) { printf "%s\t%s\n", name, addr } inT=0; name=""; addr="" }
  ')
  REMOVED=0
  if [ -n "${MAP_TUNNELS}" ]; then
    while IFS=$'\t' read -r TNAME TADDR; do
      if [[ "$TADDR" =~ $TARGET_ADDR_REGEX ]]; then
        curl -s -X DELETE "http://127.0.0.1:4040/api/tunnels/$TNAME" >/dev/null 2>&1 \
          && echo "🛑 ngrok túnel removido: $TNAME -> $TADDR" \
          && REMOVED=$((REMOVED+1))
      fi
    done <<< "$MAP_TUNNELS"
  fi
  if [ "$REMOVED" -eq 0 ]; then
    echo "ℹ️  Nenhum túnel ngrok apontando para https://n8n.local:5678 foi encontrado."
  fi
else
  echo "ℹ️  API do ngrok não está acessível em 127.0.0.1:4040."
  echo "↪️  Tentando encerrar apenas processos do ngrok ligados ao n8n.local:5678..."
  # Fallback: matar somente processos do ngrok que tenham a linha de comando para n8n.local:5678
  if pgrep -f 'ngrok .*https://n8n\.local:5678' >/dev/null 2>&1; then
    pkill -f 'ngrok .*https://n8n\.local:5678' >/dev/null 2>&1 || true
    echo "🛑 Processo ngrok (n8n.local:5678) encerrado."
  else
    echo "ℹ️  Nenhum processo ngrok específico do n8n encontrado."
  fi
fi

echo "✅ Serviços finalizados."
