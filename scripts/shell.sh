#!/bin/bash
set -euo pipefail

# Tenta bash, se não houver, cai para sh
SHELL_CMD="bash"
if ! docker exec n8n which bash >/dev/null 2>&1; then
  SHELL_CMD="sh"
fi

echo "🔗 Abrindo shell no container 'n8n' ($SHELL_CMD)..."
docker exec -it n8n $SHELL_CMD
