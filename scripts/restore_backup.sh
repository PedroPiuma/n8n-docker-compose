#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Diretório de backups
BACKUP_DIR="./backups"

echo -e "${YELLOW}Script de Restauração do n8n${NC}"
echo -e "${YELLOW}================================${NC}"

# Verificar se o diretório de backups existe
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}✗ Diretório de backups não encontrado: $BACKUP_DIR${NC}"
    exit 1
fi

# Listar backups disponíveis
echo -e "${BLUE}Backups disponíveis:${NC}"
BACKUPS=($(ls -t "$BACKUP_DIR"/n8n_backup_*.tar.gz 2>/dev/null))

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo -e "${RED}✗ Nenhum backup encontrado em $BACKUP_DIR${NC}"
    exit 1
fi

# Mostrar lista numerada de backups
for i in "${!BACKUPS[@]}"; do
    BACKUP_FILE=$(basename "${BACKUPS[$i]}")
    # Extrair timestamp do nome do arquivo
    TIMESTAMP=$(echo "$BACKUP_FILE" | sed 's/n8n_backup_\(.*\)\.tar\.gz/\1/')
    # Formatar timestamp para exibição
    DATE_PART=$(echo "$TIMESTAMP" | cut -d'_' -f1)
    TIME_PART=$(echo "$TIMESTAMP" | cut -d'_' -f2)
    FORMATTED_DATE="${DATE_PART:0:4}-${DATE_PART:4:2}-${DATE_PART:6:2}"
    FORMATTED_TIME="${TIME_PART:0:2}:${TIME_PART:2:2}:${TIME_PART:4:2}"
    
    echo -e "${GREEN}[$((i+1))]${NC} $BACKUP_FILE (${FORMATTED_DATE} ${FORMATTED_TIME})"
done

echo

# Solicitar escolha do usuário
while true; do
    echo -e "${YELLOW}Selecione o backup para restaurar (1-${#BACKUPS[@]}) ou 'q' para sair:${NC}"
    read -p "Sua escolha: " choice
    
    if [ "$choice" = "q" ] || [ "$choice" = "Q" ]; then
        echo -e "${YELLOW}Operação cancelada pelo usuário.${NC}"
        exit 0
    fi
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#BACKUPS[@]}" ]; then
        SELECTED_BACKUP="${BACKUPS[$((choice-1))]}"
        break
    else
        echo -e "${RED}Opção inválida. Tente novamente.${NC}"
    fi
done

echo
echo -e "${YELLOW}Backup selecionado: $(basename "$SELECTED_BACKUP")${NC}"

# Confirmação de segurança
echo -e "${RED}⚠️  ATENÇÃO: Esta operação irá substituir todos os dados atuais do n8n!${NC}"
echo -e "${RED}⚠️  Todos os workflows, credenciais e configurações atuais serão perdidos!${NC}"
echo
while true; do
    echo -e "${YELLOW}Tem certeza que deseja continuar? (sim/não):${NC}"
    read -p "Sua resposta: " confirm
    
    case "$confirm" in
        sim|SIM|s|S)
            break
            ;;
        não|nao|NAO|NÃO|n|N)
            echo -e "${YELLOW}Operação cancelada pelo usuário.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Resposta inválida. Digite 'sim' ou 'não'.${NC}"
            ;;
    esac
done

echo
echo -e "${YELLOW}Iniciando restauração...${NC}"

# Parar containers se estiverem rodando
if [ "$(docker compose ps -q n8n)" ]; then
    echo -e "${YELLOW}Parando containers...${NC}"
    docker compose down
fi

# Restaurar backup
echo -e "${YELLOW}Restaurando dados do backup...${NC}"
docker run --rm \
    -v n8n_data:/data \
    -v "$(pwd)/${BACKUP_DIR}:/backup" \
    ubuntu bash -c "rm -rf /data/* && tar xzf /backup/$(basename "$SELECTED_BACKUP") -C / --strip-components=1" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Dados restaurados com sucesso!${NC}"
else
    echo -e "${RED}✗ Erro ao restaurar dados do backup${NC}"
    exit 1
fi

# Iniciar containers
echo -e "${YELLOW}Iniciando containers...${NC}"
docker compose up -d

# Verificar se subiu corretamente
sleep 5
if [ "$(docker compose ps -q n8n)" ]; then
    echo -e "${GREEN}✓ Restauração concluída com sucesso!${NC}"
    echo -e "${GREEN}✓ Backup restaurado: $(basename "$SELECTED_BACKUP")${NC}"
    echo -e "${GREEN}✓ n8n disponível em: https://n8n.local${NC}"
else
    echo -e "${RED}✗ Erro: Container n8n não está rodando após restauração${NC}"
    echo -e "${YELLOW}Verificando logs...${NC}"
    docker compose logs n8n
    exit 1
fi
