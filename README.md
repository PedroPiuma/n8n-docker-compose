# Projeto n8n Local

Este projeto configura e executa uma instância local do [n8n](https://n8n.io/), uma ferramenta de automação de fluxo de trabalho. Ele utiliza Docker Compose para gerenciar os serviços necessários, incluindo o n8n e o servidor proxy reverso Caddy.

## Pré-requisitos

- [Docker](https://www.docker.com/) instalado
- [Docker Compose](https://docs.docker.com/compose/) instalado
- Opcional: [ngrok](https://ngrok.com/) para expor o n8n publicamente

## Estrutura do Projeto

- `n8n`: CLI para facilitar comandos (up, down, shell, update, restore)
- `docker-compose.yml`: Arquivo de configuração do Docker Compose para gerenciar os serviços.
- `Caddyfile`: Configuração do servidor proxy reverso Caddy.
- `certs/`: Diretório contendo os certificados SSL para o domínio `n8n.local`.
- `.env`: Arquivo de variáveis de ambiente (não deve ser compartilhado publicamente).
- `.env.example`: Arquivo de exemplo para configuração das variáveis de ambiente.
- `scripts/`: Diretório contendo scripts utilitários:
  - `up.sh`: Sobe os serviços. Se o ngrok existir, inicia um túnel e atualiza `WEBHOOK_URL` no `.env` automaticamente.
  - `down.sh`: Derruba os serviços e encerra apenas túneis do ngrok que apontem para `https://n8n.local:5678`.
  - `shell.sh`: Abre um shell dentro do container `n8n` (bash/sh).
  - `update.sh`: Atualiza o n8n com backup automático.
  - `restore_backup.sh`: Restaura um backup existente.
- `backups/`: Diretório onde são armazenados os backups automáticos.

## Configuração

1. **Configure o domínio local**: Adicione o domínio `n8n.local` ao seu arquivo `/etc/hosts`:
   ```bash
   # Edite o arquivo /etc/hosts (requer sudo)
   sudo nano /etc/hosts
   
   # Adicione esta linha ao final do arquivo:
   127.0.0.1 n8n.local
   ```
   
   Importante: Necessário para acessar `https://n8n.local` localmente.

2. Coloque os certificados SSL no diretório `certs/` com os nomes:
   - `n8n.local.pem`: Certificado público
   - `n8n.local-key.pem`: Chave privada

3. Configure as variáveis de ambiente no arquivo `.env` conforme necessário:
   ```bash
   cp .env.example .env
   # Ajuste DOCKER_NETWORK_NAME/EXTERNAL e demais variáveis conforme necessário
   ```

## CLI (recomendado)

- Subir serviços: `n8n up`
  - Se o ngrok estiver instalado, será aberto um túnel automaticamente e `WEBHOOK_URL` será atualizado no `.env`.
- Parar serviços: `n8n down`
  - Encerra apenas túneis do ngrok que apontem para `https://n8n.local:5678`.
- Abrir shell no container: `n8n shell`
- Atualizar com backup: `n8n update`
- Restaurar backup: `n8n restore`

Importante (primeira execução):
- Execute a partir do diretório do projeto usando `./n8n` (ex.: `./n8n up`). O comando global `n8n` ainda não existe.
- Durante essa primeira execução, a CLI tentará criar um symlink em `/usr/local/bin/n8n` para disponibilizar o comando global (pode solicitar `sudo`).
- Se o symlink não puder ser criado, continue utilizando `./n8n ...` nas próximas execuções.

## Como Executar (alternativa manual)

1. Inicie os serviços com o Docker Compose:
   ```bash
   docker compose up -d
   ```
2. Acesse o n8n no navegador em: `https://n8n.local:5678`

## Expondo o n8n Publicamente

Opções:
- Automático (recomendado): `n8n up` (se o `ngrok` estiver instalado, cria um túnel e preenche `WEBHOOK_URL` no `.env`).
- Manual:
  ```bash
  ngrok http https://n8n.local:5678 --host-header=n8n.local
  ```

## Atualizando o n8n

Recomendado (CLI):
```bash
n8n update
```
Alternativa direta ao script:
```bash
./scripts/update.sh
```

## Restaurando Backups

Recomendado (CLI):
```bash
n8n restore
```
Alternativa direta ao script:
```bash
./scripts/restore_backup.sh
```

## Parar os Serviços

Recomendado (CLI):
```bash
n8n down
```
Alternativa manual:
```bash
docker compose down
```

## Notas

- Certifique-se de que os certificados SSL são válidos localmente para evitar avisos do navegador.
- `WEBHOOK_URL` é atualizado automaticamente pelo `n8n up` quando o ngrok está presente; caso não esteja, permanece inalterado.
- Os backups ficam em `backups/` e são gerenciados pelo `update.sh` (mantém os 5 mais recentes).
- Para usar rede Docker externa, garanta que ela existe antes de subir os serviços.