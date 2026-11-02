# 🚀 n8n + WAHA Local com Docker Compose

Ambiente local para automação com **[n8n](https://n8n.io/)**, integração WhatsApp via **[WAHA](https://waha.devlike.pro/)**, cache em **Redis** e persistência em **PostgreSQL**, gerenciado de forma simples via **Makefile**.

---

## ✨ Serviços Inclusos

- 🎯 **n8n** (`n8nio/n8n:latest`): Automação de fluxos e webhooks.
- 📱 **WAHA** (`devlikeapro/waha:latest`): WhatsApp HTTP API.
- 🗄️ **Redis** (`redis:alpine`): Cache e mensageria.
- 🐘 **PostgreSQL** (`postgres:18-alpine`): Banco do n8n e sessões do WAHA.
- 🛠️ **Makefile**: Atalhos essenciais para o Docker Compose.

---

## 📁 Estrutura

```text
.
├── docker/
│   └── docker-compose.yml   # Definição dos serviços
├── workflows/               # Exportações locais do n8n (fora do Git)
├── .env                     # Configuração local (fora do Git)
├── .env.example             # Modelo do .env
└── Makefile                 # Atalhos do Docker Compose
```

Rode os comandos com `make` na raiz do projeto. Um `docker compose` executado dentro de `docker/` não lê o `.env` da raiz.

Os arquivos `workflows/*.json` ficam fora do Git porque exportações do n8n podem conter mensagens reais fixadas nos nós.

---

## 🚀 Início Rápido

### 1. Iniciar os Serviços

```bash
make up
```

Após subir, os serviços estarão disponíveis em:

| Serviço | URL | Portas / Credenciais Padrão |
|---|---|---|
| **n8n** | [http://localhost:5678](http://localhost:5678) | Porta `5678` |
| **WAHA Dashboard** | [http://localhost:3008/dashboard](http://localhost:3008/dashboard) | Porta `3008` \| Login: `admin` / `admin123` |
| **WAHA Swagger** | [http://localhost:3008](http://localhost:3008) | Porta `3008` \| Login: `admin` / `admin123` |
| **PostgreSQL** | `localhost:5433` | Porta `5433` \| Banco `n8n` \| `postgres` / `postgres` (`default` / `default` com o `.env.example`) |
| **Redis** | `localhost:6379` | Porta `6379` \| Senha: `default` |

> [!NOTE]
> As portas externas padrão do WAHA (`3008`) e PostgreSQL (`5433`) evitam conflito com portas comumente ocupadas em máquinas locais (`3000` e `5432`). Caso deseje customizar, crie um arquivo `.env` baseado no `.env.example`.

---

## 🎮 Comandos Disponíveis (`make`)

| Comando | Descrição |
|---|---|
| `make up` | Inicia todos os serviços em segundo plano |
| `make down` | Para todos os containers |
| `make restart` | Reinicia todos os containers |
| `make ps` | Mostra o status dos containers |
| `make logs` | Acompanha os logs (`make logs` ou específico: `make logs service=n8n`) |
| `make shell` | Abre o shell no container do n8n |
| `make update` | Baixa a imagem mais recente de um serviço e recria só o container dele (`make update service=waha`) |
| `make redis-cli` | Conecta ao `redis-cli` interativo autenticado |

---

## ⚙️ Variáveis de Ambiente (`.env`)

Todas as variáveis possuem valores padrão no `docker/docker-compose.yml`. O arquivo `.env` é opcional, fica na raiz do projeto e serve para customizações:

```bash
# Portas no Host
N8N_PORT=5678
WAHA_PORT=3008
POSTGRES_PORT=5433
REDIS_PORT=6379

# n8n
N8N_WEBHOOK_URL=http://localhost:5678/
TZ=America/Sao_Paulo

# WAHA
WAHA_DASHBOARD_USERNAME=admin
WAHA_DASHBOARD_PASSWORD=admin123
WAHA_API_KEY=admin

# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=n8n

# Redis
REDIS_PASSWORD=default
```

## 🌊 Carga de eventos do WhatsApp

Ao reconectar, o WhatsApp reenvia ao WAHA tudo o que chegou com a sessão parada, e cada mensagem vira um POST para o n8n. Para conter essa rajada:

- **Assine um evento só:** `message.any` já inclui o que `message` entrega. Assinar os dois duplica as chamadas.
- **Configure o webhook na sessão:** um `WHATSAPP_HOOK_URL` global soma com o webhook da sessão.
- **Use poucas tentativas:** configure `retries` baixo na sessão, porque cada POST pendente ocupa memória no WAHA.
- **Desligue "Save execution progress"** nas configurações do workflow. Essa opção grava no banco a cada nó e sobrescreve `EXECUTIONS_DATA_SAVE_ON_PROGRESS`.

O Event Monitor do Dashboard mostra todos os eventos da sessão, inclusive os que não vão para o webhook, como `message.ack.group`.
