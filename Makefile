# ==============================================================================
# n8n Docker Compose - Makefile
# ==============================================================================

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Carrega variáveis do .env caso exista
-include .env

N8N_PORT ?= 5678
WAHA_PORT ?= 3008
POSTGRES_PORT ?= 5433
REDIS_PORT ?= 6379

# O compose fica em docker/, mas o .env fica na raiz do projeto
COMPOSE := docker compose --project-directory . -f docker/docker-compose.yml

.PHONY: help up down restart ps logs shell update redis-cli

help:
	@echo "Comandos disponíveis:"
	@echo "  make up         - Inicia os serviços em segundo plano e exibe as URLs"
	@echo "  make down       - Para os serviços"
	@echo "  make restart    - Reinicia os serviços"
	@echo "  make ps         - Mostra o status dos containers"
	@echo "  make logs       - Acompanha os logs (ou: make logs service=n8n)"
	@echo "  make shell      - Abre o shell no container do n8n"
	@echo "  make update     - Atualiza um serviço (make update service=waha)"
	@echo "  make redis-cli  - Conecta ao redis-cli interativo"

up:
	$(COMPOSE) up -d
	@echo ""
	@echo "Serviços disponíveis:"
	@echo "  • n8n:            http://localhost:$(or $(N8N_PORT),5678)"
	@echo "  • WAHA Dashboard: http://localhost:$(or $(WAHA_PORT),3008)/dashboard"
	@echo "  • WAHA Swagger:   http://localhost:$(or $(WAHA_PORT),3008)"
	@echo "  • PostgreSQL:     localhost:$(or $(POSTGRES_PORT),5433)"
	@echo "  • Redis:          localhost:$(or $(REDIS_PORT),6379)"

down:
	$(COMPOSE) down

restart:
	$(COMPOSE) restart

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f $(service)

shell:
	$(COMPOSE) exec -it n8n sh

update:
	@test -n "$(service)" || { echo "Informe o serviço: make update service=waha"; exit 1; }
	$(COMPOSE) pull $(service)
	$(COMPOSE) up -d --no-deps $(service)

redis-cli:
	$(COMPOSE) exec -it redis redis-cli -a "$${REDIS_PASSWORD:-default}"
