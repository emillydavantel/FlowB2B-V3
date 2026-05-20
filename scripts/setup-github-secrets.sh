#!/bin/bash
# ===========================================
# Script para Configurar Secrets do GitHub
# ===========================================

echo "🔧 Configuração de Secrets do GitHub"
echo "======================================"
echo ""
echo "Este script irá ajudar você a configurar os secrets necessários no GitHub."
echo ""
echo "📋 SECRETS NECESSÁRIOS:"
echo ""
echo "🏗️ Build & Deploy:"
echo "  • RENDER_API_KEY           - Chave da API do Render"
echo "  • RENDER_SERVICE_ID        - ID do serviço de produção"
echo "  • RENDER_STAGING_SERVICE_ID - ID do serviço de staging"
echo ""
echo "🗄️ Supabase (Produção):"
echo "  • SUPABASE_URL"
echo "  • SUPABASE_ANON_KEY"
echo "  • SUPABASE_SERVICE_ROLE_KEY"
echo ""
echo "🧪 Supabase (Staging):"
echo "  • STAGING_SUPABASE_URL"
echo "  • STAGING_SUPABASE_ANON_KEY"
echo "  • STAGING_SUPABASE_SERVICE_ROLE_KEY"
echo ""
echo "🔐 Auth:"
echo "  • JWT_SECRET"
echo "  • STAGING_JWT_SECRET"
echo ""

# Verificar se gh CLI está instalado
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI não encontrado!"
    echo "📥 Instale com: curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg"
    echo "    echo 'deb [signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main' | sudo tee /etc/apt/sources.list.d/github-cli.list"
    echo "    sudo apt update && sudo apt install gh"
    exit 1
fi

# Verificar se está autenticado
if ! gh auth status &> /dev/null; then
    echo "🔑 Fazendo login no GitHub..."
    gh auth login
fi

echo ""
echo "🚀 CONFIGURAÇÃO AUTOMÁTICA"
echo ""

# Função para adicionar secret
add_secret() {
    local key=$1
    local description=$2

    echo "🔐 Configurando: $key"
    echo "   Descrição: $description"
    read -s -p "   Digite o valor: " value
    echo ""

    if [ -n "$value" ]; then
        gh secret set "$key" --body "$value"
        echo "   ✅ Secret '$key' configurado com sucesso!"
    else
        echo "   ⚠️ Secret '$key' pulado (valor vazio)"
    fi
    echo ""
}

# Configurar secrets
echo "📝 Vamos configurar os secrets um por um..."
echo ""

add_secret "RENDER_API_KEY" "Chave da API do Render (encontre em Account Settings > API Keys)"
add_secret "RENDER_SERVICE_ID" "ID do serviço de produção no Render"
add_secret "RENDER_STAGING_SERVICE_ID" "ID do serviço de staging no Render"

add_secret "SUPABASE_URL" "URL do projeto Supabase (produção)"
add_secret "SUPABASE_ANON_KEY" "Chave anon do Supabase (produção)"
add_secret "SUPABASE_SERVICE_ROLE_KEY" "Chave service_role do Supabase (produção)"

add_secret "STAGING_SUPABASE_URL" "URL do projeto Supabase (staging)"
add_secret "STAGING_SUPABASE_ANON_KEY" "Chave anon do Supabase (staging)"
add_secret "STAGING_SUPABASE_SERVICE_ROLE_KEY" "Chave service_role do Supabase (staging)"

add_secret "JWT_SECRET" "Chave secreta para JWT (produção) - gere com: openssl rand -base64 32"
add_secret "STAGING_JWT_SECRET" "Chave secreta para JWT (staging) - gere com: openssl rand -base64 32"

echo "🎉 Configuração concluída!"
echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo "  1. Verifique os secrets no GitHub: Settings > Secrets and variables > Actions"
echo "  2. Configure os serviços no Render.com"
echo "  3. Faça um push para testar o deploy automático"
echo ""
echo "🔍 Verificar secrets configurados:"
echo "   gh secret list"
echo ""