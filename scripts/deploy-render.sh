#!/bin/bash
# ===========================================
# Script de Deploy Manual para Render
# ===========================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 FlowB2B Deploy Script${NC}"
echo "=================================="

# Verificar se está no diretório correto
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Erro: Execute este script na raiz do projeto${NC}"
    exit 1
fi

# Verificar se tem variáveis de ambiente necessárias
if [ -z "$RENDER_API_KEY" ]; then
    echo -e "${RED}❌ RENDER_API_KEY não definida${NC}"
    echo "Configure com: export RENDER_API_KEY=your_api_key"
    exit 1
fi

# Opções de deploy
echo -e "${YELLOW}Escolha o ambiente de deploy:${NC}"
echo "1) 🧪 Staging"
echo "2) 🚀 Production"
read -p "Digite sua escolha (1 ou 2): " choice

case $choice in
    1)
        SERVICE_ID="$RENDER_STAGING_SERVICE_ID"
        ENV_NAME="staging"
        ;;
    2)
        SERVICE_ID="$RENDER_SERVICE_ID"
        ENV_NAME="production"
        ;;
    *)
        echo -e "${RED}❌ Opção inválida${NC}"
        exit 1
        ;;
esac

if [ -z "$SERVICE_ID" ]; then
    echo -e "${RED}❌ Service ID não definido para $ENV_NAME${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Preparando deploy para $ENV_NAME...${NC}"

# 1. Instalar dependências
echo -e "${BLUE}📦 Instalando dependências...${NC}"
npm ci

# 2. Executar testes
echo -e "${BLUE}🧪 Executando testes...${NC}"
npm run lint

# 3. Build de teste local
echo -e "${BLUE}🏗️ Testando build...${NC}"
npm run build

# 4. Deploy via API do Render
echo -e "${BLUE}🚀 Fazendo deploy...${NC}"
curl -X POST "https://api.render.com/v1/services/$SERVICE_ID/deploys" \
  -H "Authorization: Bearer $RENDER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'

echo -e "${GREEN}✅ Deploy iniciado com sucesso!${NC}"
echo -e "${YELLOW}🔍 Acompanhe o progresso no dashboard do Render${NC}"

# 5. Aguardar conclusão (opcional)
read -p "Aguardar conclusão do deploy? (y/N): " wait_deploy

if [ "$wait_deploy" = "y" ] || [ "$wait_deploy" = "Y" ]; then
    echo -e "${BLUE}⏳ Aguardando conclusão...${NC}"

    for i in {1..30}; do
        sleep 10
        status=$(curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
                "https://api.render.com/v1/services/$SERVICE_ID" | \
                jq -r '.serviceDetails.deploy.status' 2>/dev/null || echo "unknown")

        case $status in
            "live")
                echo -e "${GREEN}✅ Deploy concluído com sucesso!${NC}"
                exit 0
                ;;
            "build_failed"|"update_failed")
                echo -e "${RED}❌ Deploy falhou!${NC}"
                exit 1
                ;;
            *)
                echo -e "${BLUE}⏳ Status: $status (tentativa $i/30)${NC}"
                ;;
        esac
    done

    echo -e "${YELLOW}⚠️ Timeout - verifique manualmente no dashboard${NC}"
fi