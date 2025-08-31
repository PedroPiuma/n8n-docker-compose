# 🚀 Projeto n8n Local com Docker Compose

Este projeto configura e executa uma instância local completa do [n8n](https://n8n.io/) com todos os serviços necessários para automação de fluxos de trabalho, incluindo WhatsApp Business API (WAHA), Redis e PostgreSQL.

## ✨ **Funcionalidades Principais**

- 🎯 **n8n**: Plataforma de automação de workflows
- 📱 **WAHA**: Integração com WhatsApp Business API
- 🗄️ **Redis**: Cache e sessões
- 🐘 **PostgreSQL**: Banco de dados robusto

- 🛠️ **CLI**: Interface de linha de comando para gerenciamento

## 📋 **Pré-requisitos**

- [Docker](https://www.docker.com/) (versão 20.10+)
- [Docker Compose](https://docs.docker.com/compose/) (versão 2.0+)


## 🏗️ **Arquitetura do Projeto**

```
n8n-docker-compose/
├── 📁 scripts/           # Scripts de gerenciamento
├── 📁 backups/           # Backups automáticos
├── 📁 docs/             # Documentação adicional
├── 🐳 docker-compose.yml # Configuração dos serviços
├── 🔧 n8n               # CLI principal
└── 📖 README.md         # Esta documentação
```

## 🚀 **Início Rápido**

### **1. Configuração Inicial**

```bash
# Clone o repositório
git clone <seu-repositorio>
cd n8n-docker-compose

# Configure as variáveis de ambiente
cp .env.example .env
# Edite o arquivo .env com suas configurações
# Nota: DOCKER_NETWORK_NAME e DOCKER_NETWORK_EXTERNAL são opcionais
```

### **2. Primeira Execução**

```bash
# Torne o CLI executável
chmod +x n8n

# Suba todos os serviços
./n8n up

# Acesse o n8n
# Local: http://localhost:5678
# WAHA Dashboard: http://localhost:3000
```

## 🎮 **CLI - Interface de Linha de Comando**

O projeto inclui um CLI poderoso para gerenciar todos os aspectos do ambiente.

### **Comandos Disponíveis**

| Comando | Descrição | Exemplo |
|---------|-----------|---------|
| `up` | Subir todos os serviços | `n8n up` |
| `down` | Parar todos os serviços | `n8n down` |
| `shell` | Shell no container n8n | `n8n shell` |
| `update` | Atualizar n8n com backup | `n8n update` |
| `restore` | Restaurar backup | `n8n restore` |
| `redis` | Gerenciar Redis | `n8n redis list` |

### **Uso do CLI**

```bash
# Ver ajuda completa
n8n

# Subir serviços
n8n up

# Ver status dos serviços
docker compose ps

# Acessar shell do n8n
n8n shell

# Atualizar com backup automático
n8n update
```

## 🗄️ **Gerenciamento do Redis**

O comando `redis` oferece funcionalidades avançadas para gerenciar o cache e sessões.

### **Comandos Redis Disponíveis**

```bash
# Informações básicas
n8n redis count          # Contar total de chaves
n8n redis list           # Listar todas as chaves
n8n redis config         # Ver configurações

# Busca e filtros
n8n redis search 'padrão'           # Buscar chaves por padrão
n8n redis search 'Scrapped_Sites'   # Buscar chaves de sites raspados

# Deleção seletiva
n8n redis delete-scrapped           # Deletar chaves Scrapped_Sites_*
n8n redis delete-waha               # Deletar chaves waha*
n8n redis delete-evolution          # Deletar chaves evolution*
n8n redis delete 'chave_específica' # Deletar chave específica

# Operações de sistema
n8n redis clear                     # Limpar todo o Redis
n8n redis info                      # Informações do sistema
n8n redis memory                    # Uso de memória
n8n redis monitor                   # Monitorar comandos em tempo real
n8n redis shell                     # Shell interativo do Redis
```

### **Exemplos Práticos do Redis**

```bash
# Ver quantas chaves existem
n8n redis count

# Listar todas as chaves
n8n redis list

# Buscar chaves relacionadas ao WhatsApp
n8n redis search 'waha*'

# Limpar dados de sites raspados
n8n redis delete-scrapped

# Monitorar atividade em tempo real
n8n redis monitor
```

## 🔧 **Serviços e Configurações**

### **n8n**
- **Porta**: Configurável via `N8N_EXPOSE_PORT`
- **Timezone**: America/Sao_Paulo
- **Log Level**: Debug
- **Webhooks**: Suporte completo

### **WAHA (WhatsApp Business API)**
- **Porta**: Configurável via `WAHA_EXPOSE_PORT`
- **Engine**: GOWS (Go WhatsApp)
- **Storage**: PostgreSQL + Redis
- **Dashboard**: Interface web em `/dashboard`
- **API**: Documentação Swagger em `/swagger`

### **Redis**
- **Porta**: Configurável via `REDIS_EXPOSE_PORT`
- **Autenticação**: Configurável via `REDIS_PASSWORD`
- **Persistência**: Volume Docker persistente

### **PostgreSQL**
- **Porta**: Configurável via `POSTGRES_EXPOSE_PORT`
- **Database**: `waha`
- **Usuário/Password**: Configuráveis via `.env`

## 📁 **Estrutura de Arquivos**

### **Scripts de Gerenciamento**
- `scripts/up.sh` - Subir serviços
- `scripts/down.sh` - Parar serviços
- `scripts/shell.sh` - Shell no container
- `scripts/update.sh` - Atualização com backup
- `scripts/restore_backup.sh` - Restauração de backup
- `scripts/redis-manager.sh` - Gerenciamento do Redis

### **Backups**
- **Localização**: `./backups/`
- **Formato**: `n8n_backup_YYYYMMDD_HHMMSS.tar.gz`
- **Retenção**: 5 backups mais recentes
- **Automático**: Durante atualizações



## 🌐 **Configuração de Rede**



### **Rede Docker (Opcional)**
- **Nome**: Configurável via `DOCKER_NETWORK_NAME`
- **Tipo**: Externa (opcional, se não existir será criada automaticamente)
- **Uso**: Para conectar com outros serviços Docker na mesma rede

### **Portas Externas**
- **n8n**: `N8N_EXPOSE_PORT` → 5678
- **WAHA**: `WAHA_EXPOSE_PORT` → 3000
- **Redis**: `REDIS_EXPOSE_PORT` → 6379
- **PostgreSQL**: `POSTGRES_EXPOSE_PORT` → 5432

## 🔒 **Segurança e Autenticação**

### **WAHA Dashboard**
- **Usuário**: Configurável via `WAHA_DASHBOARD_USERNAME`
- **Senha**: Configurável via `WAHA_DASHBOARD_PASSWORD`

### **WAHA Swagger**
- **Usuário**: Configurável via `WHATSAPP_SWAGGER_USERNAME`
- **Senha**: Configurável via `WHATSAPP_SWAGGER_PASSWORD`

### **Redis**
- **Senha**: Configurável via `REDIS_PASSWORD`
- **Acesso**: Apenas localhost

## 📊 **Monitoramento e Logs**

### **Verificar Status**
```bash
# Status dos containers
docker compose ps

# Logs em tempo real
docker compose logs -f

# Logs específicos
docker compose logs n8n
docker compose logs waha
docker compose logs redis
```

### **Métricas do Sistema**
```bash
# Informações do Redis
n8n redis info
n8n redis memory

# Monitorar comandos Redis
n8n redis monitor
```

## 🚨 **Solução de Problemas**

### **Problemas Comuns**

#### **Container não inicia**
```bash
# Verificar logs
docker compose logs <nome-do-container>

# Verificar status
docker compose ps

# Reiniciar serviços
n8n down && n8n up
```

#### **Erro de conectividade**
```bash
# Verificar rede Docker
docker network ls

# Verificar portas
netstat -tlnp | grep :5678
```

#### **Problemas de Redis**
```bash
# Verificar status do Redis
n8n redis info

# Testar conectividade
n8n redis shell

# Limpar cache se necessário
n8n redis clear
```

### **Logs de Debug**
```bash
# n8n logs detalhados
docker compose logs n8n --tail=100

# WAHA logs
docker compose logs waha --tail=100

# Redis logs
docker compose logs redis --tail=100
```

## 🔄 **Atualizações e Manutenção**

### **Atualização Automática**
```bash
# Atualizar com backup automático
n8n update

# Verificar versões
docker compose images
```

### **Backup Manual**
```bash
# Criar backup manual
docker run --rm \
  -v n8n_data:/data \
  -v $(pwd)/backups:/backup \
  ubuntu tar czf "/backup/n8n_backup_manual_$(date +%Y%m%d_%H%M%S).tar.gz" /data
```

### **Restauração**
```bash
# Listar backups disponíveis
n8n restore

# Restaurar backup específico
./scripts/restore_backup.sh
```

## 🌍 **Exposição Pública (Opcional)**

### **Configuração Manual**
- Configure seu domínio público
- Atualize `N8N_WEBHOOK_URL` no `.env`