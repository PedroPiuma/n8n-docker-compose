#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Diretório de backups
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="n8n_backup_${TIMESTAMP}.tar.gz"

echo -e "${YELLOW}Iniciando atualização do n8n...${NC}"

# Criar diretório de backup se não existir
mkdir -p "$BACKUP_DIR"

# Verificar se o container está rodando
if [ "$(docker compose ps -q n8n)" ]; then
    echo -e "${YELLOW}Fazendo backup dos dados...${NC}"
    
    # Fazer backup do volume de dados
    docker run --rm \
        -v n8n_data:/data \
        -v "$(pwd)/${BACKUP_DIR}:/backup" \
        ubuntu tar czf "/backup/${BACKUP_FILE}" /data 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Backup criado com sucesso: ${BACKUP_DIR}/${BACKUP_FILE}${NC}"
    else
        echo -e "${RED}Erro ao criar backup. Abortando atualização.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}Container n8n não está rodando. Pulando backup.${NC}"
fi

# Baixar nova versão
echo -e "${YELLOW}Baixando nova versão...${NC}"
docker compose pull

# Parar containers
echo -e "${YELLOW}Parando containers...${NC}"
docker compose down

# Iniciar containers
echo -e "${YELLOW}Iniciando containers...${NC}"
docker compose up -d

# Verificar se subiu corretamente
sleep 5
if [ "$(docker compose ps -q n8n)" ]; then
    echo -e "${GREEN}✓ Atualização concluída com sucesso!${NC}"
    echo -e "${GREEN}✓ Backup salvo em: ${BACKUP_DIR}/${BACKUP_FILE}${NC}"
    echo -e "${GREEN}✓ n8n disponível em: https://n8n.local${NC}"
    
    # Limpar backups antigos (manter apenas os 5 mais recentes)
    echo -e "${YELLOW}Limpando backups antigos...${NC}"
    cd "$BACKUP_DIR"
    OLD_BACKUPS=$(ls -t n8n_backup_*.tar.gz 2>/dev/null | tail -n +6)
    if [ -n "$OLD_BACKUPS" ]; then
        echo "$OLD_BACKUPS" | xargs rm
        REMOVED_COUNT=$(echo "$OLD_BACKUPS" | wc -l)
        echo -e "${GREEN}✓ Removidos $REMOVED_COUNT backup(s) antigo(s)${NC}"
    else
        echo -e "${GREEN}✓ Nenhum backup antigo para remover${NC}"
    fi
    cd ..
else
    echo -e "${RED}✗ Erro: Container n8n não está rodando após atualização${NC}"
    echo -e "${YELLOW}Verificando logs...${NC}"
    docker compose logs n8n
    exit 1
fi