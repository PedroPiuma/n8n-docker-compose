# Projeto n8n Local

Este projeto configura e executa uma instância local do [n8n](https://n8n.io/), uma ferramenta de automação de fluxo de trabalho. Ele utiliza Docker Compose para gerenciar os serviços necessários, incluindo o n8n e o servidor proxy reverso Caddy.

## Pré-requisitos

- [Docker](https://www.docker.com/) instalado
- [Docker Compose](https://docs.docker.com/compose/) instalado

## Estrutura do Projeto

- `docker-compose.yml`: Arquivo de configuração do Docker Compose para gerenciar os serviços.
- `Caddyfile`: Configuração do servidor proxy reverso Caddy.
- `certs/`: Diretório contendo os certificados SSL para o domínio `n8n.local`.
- `.env`: Arquivo de variáveis de ambiente (não deve ser compartilhado publicamente).

## Configuração

1. Certifique-se de que o domínio `n8n.local` está configurado no seu arquivo `/etc/hosts`:
   ```
   127.0.0.1 n8n.local
   ```

2. Coloque os certificados SSL no diretório `certs/` com os nomes:
   - `n8n.local.pem`: Certificado público
   - `n8n.local-key.pem`: Chave privada

3. Configure as variáveis de ambiente no arquivo `.env` conforme necessário.

## Gerando os Certificados SSL

Para criar os certificados SSL necessários para o domínio `n8n.local`, você pode usar a ferramenta [mkcert](https://github.com/FiloSottile/mkcert):

1. Instale o `mkcert` seguindo as instruções no repositório oficial.
2. Execute os seguintes comandos para gerar os certificados:

```bash
mkcert -install
mkcert -key-file certs/n8n.local-key.pem -cert-file certs/n8n.local.pem n8n.local
```

Certifique-se de que o diretório `certs/` existe antes de executar o comando.

## Como Executar

1. Inicie os serviços com o Docker Compose:
   ```bash
   docker compose up -d
   ```

2. Acesse o n8n no navegador em: [https://n8n.local](https://n8n.local)

## Expondo o n8n Publicamente

Para expor o n8n publicamente, você pode usar o [ngrok](https://ngrok.com/):

```bash
ngrok http https://n8n.local:5678 --host-header=n8n.local
```

## Parar os Serviços

Para parar os serviços, execute:

```bash
docker compose down
```

## Notas

- Certifique-se de que os certificados SSL são válidos para evitar problemas de conexão.
- Este projeto é apenas para uso local e não deve ser usado em produção sem ajustes adicionais.