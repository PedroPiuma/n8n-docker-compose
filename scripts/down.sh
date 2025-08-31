#!/bin/bash
echo "🛑 Derrubando serviços (docker compose down)..."
if command -v docker compose &> /dev/null; then
  docker compose down
else
  docker-compose down
fi

echo "✅ Serviços finalizados."
