#!/bin/bash

# Script para gerenciar o Redis do n8n
# Uso: ./redis-manager.sh [comando] [opções]

# Carregar variáveis do .env
if [ -f ".env" ]; then
    set -o allexport
    source .env
    set +o allexport
fi

# Configurações Redis
REDIS_CONTAINER="n8n_redis"
REDIS_AUTH="${REDIS_PASSWORD:-default}"
REDIS_HOST="127.0.0.1"
REDIS_PORT="${REDIS_EXPOSE_PORT:-6379}"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para mostrar ajuda
show_help() {
    echo -e "${BLUE}=== Gerenciador Redis para n8n ===${NC}"
    echo ""
    echo "Uso: $0 [comando] [opções]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  list                    - Listar todas as chaves"
    echo "  count                   - Contar total de chaves"
    echo "  search <padrão>        - Buscar chaves por padrão"
    echo "  delete <chave>         - Deletar uma chave específica"
    echo "  delete-pattern <padrão> - Deletar chaves por padrão"
    echo "  delete-scrapped        - Deletar todas as chaves Scrapped_Sites_*"
    echo "  delete-waha            - Deletar todas as chaves waha*"
    echo "  delete-evolution       - Deletar chaves evolution*"
    echo "  clear                  - Limpar todo o Redis (FLUSHALL)"
    echo "  monitor                - Monitorar comandos em tempo real"
    echo "  info                   - Mostrar informações do Redis"
    echo "  memory                 - Mostrar uso de memória"
    echo "  shell                  - Abrir shell interativo do Redis"
    echo "  config                 - Mostrar configurações atuais"
    echo "  help                   - Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 list"
    echo "  $0 search 'Scrapped_Sites'"
    echo "  $0 delete 'minha_chave'"
    echo "  $0 delete-pattern 'waha*'"
    echo "  $0 delete-scrapped"
    echo ""
}



# Função para listar chaves
list_keys() {
    echo -e "${YELLOW}Listando todas as chaves do Redis...${NC}"
    docker exec $REDIS_CONTAINER redis-cli -h $REDIS_HOST -p $REDIS_PORT --no-auth-warning -a $REDIS_AUTH KEYS '*'
}

# Função para contar chaves
count_keys() {
    echo -e "${YELLOW}Contando total de chaves...${NC}"
    local count=$(docker exec $REDIS_CONTAINER redis-cli -h $REDIS_HOST -p $REDIS_PORT --no-auth-warning -a $REDIS_AUTH DBSIZE)
    echo -e "${GREEN}Total de chaves: $count${NC}"
}

# Função para buscar chaves por padrão
search_keys() {
    local pattern="$1"
    if [ -z "$pattern" ]; then
        echo -e "${RED}Erro: Padrão de busca não especificado${NC}"
        echo "Uso: $0 search <padrão>"
        exit 1
    fi
    
    echo -e "${YELLOW}Buscando chaves com padrão: $pattern${NC}"
    docker exec $REDIS_CONTAINER redis-cli -h $REDIS_HOST -p $REDIS_PORT --no-auth-warning -a $REDIS_AUTH KEYS "$pattern"
}

# Função para deletar uma chave específica
delete_key() {
    local key="$1"
    if [ -z "$key" ]; then
        echo -e "${RED}Erro: Chave não especificada${NC}"
        echo "Uso: $0 delete <chave>"
        exit 1
    fi
    
    echo -e "${YELLOW}Deletando chave: $key${NC}"
    local result=$(docker exec $REDIS_CONTAINER redis-cli -h $REDIS_HOST -p $REDIS_PORT --no-auth-warning -a $REDIS_AUTH DEL "$key")
    if [ "$result" = "1" ]; then
        echo -e "${GREEN}Chave '$key' deletada com sucesso${NC}"
    else
        echo -e "${RED}Chave '$key' não encontrada ou não pôde ser deletada${NC}"
    fi
}

# Função para deletar chaves por padrão
delete_pattern() {
    local pattern="$1"
    if [ -z "$pattern" ]; then
        echo -e "${RED}Erro: Padrão não especificado${NC}"
        echo "Uso: $0 delete-pattern <padrão>"
        exit 1
    fi
    
    echo -e "${YELLOW}Deletando chaves com padrão: $pattern${NC}"
    local keys=$(docker exec $REDIS_CONTAINER redis-cli -h $REDIS_HOST -p $REDIS_PORT --no-auth-warning -a $REDIS_AUTH KEYS "$pattern")
    if [ -z "$keys" ]; then
        echo -e "${YELLOW}Nenhuma chave encontrada com o padrão: $pattern${NC}"
        return
    fi
    
    local count=0
    for key in $keys; do
        local result=$(docker exec $REDIS_CONTAINER redis-cli -h $REDIS_HOST -p $REDIS_PORT --no-auth-warning -a $REDIS_AUTH DEL "$key")
        if [ "$result" = "1" ]; then
            count=$((count + 1))
            echo -e "${GREEN}Deletada: $key${NC}"
        fi
    done
    
    echo -e "${GREEN}Total de chaves deletadas: $count${NC}"
}

# Função para deletar chaves Scrapped_Sites
delete_scrapped() {
    echo -e "${YELLOW}Deletando todas as chaves Scrapped_Sites_*...${NC}"
    delete_pattern "Scrapped_Sites_*"
}

# Função para deletar chaves waha
delete_waha() {
    echo -e "${YELLOW}Deletando todas as chaves waha*...${NC}"
    delete_pattern "waha*"
}

# Função para deletar chaves evolution
delete_evolution() {
    echo -e "${YELLOW}Deletando todas as chaves evolution*...${NC}"
    delete_pattern "evolution*"
}

# Função para limpar todo o Redis
clear_redis() {
    echo -e "${RED}⚠️  ATENÇÃO: Esta operação irá DELETAR TODOS os dados do Redis! ⚠️${NC}"
    echo -e "${YELLOW}Tem certeza que deseja continuar? (y/N)${NC}"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Limpando todo o Redis...${NC}"
        docker exec $REDIS_CONTAINER redis-cli -h $REDIS_HOST -p $REDIS_PORT --no-auth-warning -a $REDIS_AUTH FLUSHALL
        echo -e "${GREEN}Redis limpo com sucesso!${NC}"
    else
        echo -e "${YELLOW}Operação cancelada${NC}"
    fi
}

# Função para monitorar Redis
monitor_redis() {
    echo -e "${YELLOW}Monitorando comandos Redis em tempo real...${NC}"
    echo -e "${YELLOW}Pressione Ctrl+C para parar${NC}"
    docker exec -it $REDIS_CONTAINER redis-cli -h $REDIS_HOST -p $REDIS_PORT --no-auth-warning -a $REDIS_AUTH MONITOR
}

# Função para mostrar informações do Redis
show_info() {
    echo -e "${YELLOW}Informações do Redis:${NC}"
    docker exec $REDIS_CONTAINER redis-cli -h $REDIS_HOST -p $REDIS_PORT --no-auth-warning -a $REDIS_AUTH INFO
}

# Função para mostrar uso de memória
show_memory() {
    echo -e "${YELLOW}Uso de memória do Redis:${NC}"
    docker exec $REDIS_CONTAINER redis-cli -h $REDIS_HOST -p $REDIS_PORT --no-auth-warning -a $REDIS_AUTH INFO memory
}

# Função para abrir shell interativo
open_shell() {
    echo -e "${YELLOW}Abrindo shell interativo do Redis...${NC}"
    echo -e "${BLUE}Use 'exit' para sair${NC}"
    docker exec -it $REDIS_CONTAINER redis-cli -h $REDIS_HOST -p $REDIS_PORT --no-auth-warning -a $REDIS_AUTH
}

# Verificar se o container está rodando
check_container() {
    if ! docker ps | grep -q $REDIS_CONTAINER; then
        echo -e "${RED}Erro: Container $REDIS_CONTAINER não está rodando${NC}"
        echo "Execute: docker-compose up -d"
        exit 1
    fi
}

# Função para mostrar configurações atuais
show_config() {
    echo -e "${BLUE}=== Configurações Redis ===${NC}"
    echo "Container: $REDIS_CONTAINER"
    echo "Host: $REDIS_HOST"
    echo "Porta: $REDIS_PORT"
    echo "Autenticação: $REDIS_AUTH"
    echo ""
}

# Função principal
main() {
    local command="$1"
    
    # Verificar se o container está rodando
    check_container
    
    # Mostrar configurações se não for comando de ajuda
    if [[ "$command" != "help" && "$command" != "--help" && "$command" != "-h" && "$command" != "" ]]; then
        show_config
    fi
    
    case "$command" in
        "list")
            list_keys
            ;;
        "count")
            count_keys
            ;;
        "search")
            search_keys "$2"
            ;;
        "delete")
            delete_key "$2"
            ;;
        "delete-pattern")
            delete_pattern "$2"
            ;;
        "delete-scrapped")
            delete_scrapped
            ;;
        "delete-waha")
            delete_waha
            ;;
        "delete-evolution")
            delete_evolution
            ;;
        "clear")
            clear_redis
            ;;
        "monitor")
            monitor_redis
            ;;
        "info")
            show_info
            ;;
        "memory")
            show_memory
            ;;
        "shell")
            open_shell
            ;;
        "config")
            show_config
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            echo -e "${RED}Comando desconhecido: $command${NC}"
            echo "Use '$0 help' para ver os comandos disponíveis"
            exit 1
            ;;
    esac
}

# Executar função principal
main "$@"
