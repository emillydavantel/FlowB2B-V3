#!/bin/bash

# Script para restaurar backup no novo projeto de desenvolvimento
# Uso: ./restore-script.sh [ACCESS_TOKEN] [NEW_PROJECT_REF]

set -e

ACCESS_TOKEN=$1
NEW_PROJECT_REF=$2

if [ -z "$ACCESS_TOKEN" ] || [ -z "$NEW_PROJECT_REF" ]; then
    echo "❌ Erro: Parâmetros não fornecidos"
    echo "Uso: ./restore-script.sh [ACCESS_TOKEN] [NEW_PROJECT_REF]"
    echo ""
    echo "Para obter NEW_PROJECT_REF:"
    echo "1. Acesse https://supabase.com/dashboard"
    echo "2. Crie um novo projeto"
    echo "3. Copie o Project Reference ID (ex: abcd1234efgh)"
    exit 1
fi

echo "🚀 Iniciando restauração no projeto de desenvolvimento..."

# Configurar token
export SUPABASE_ACCESS_TOKEN=$ACCESS_TOKEN

# Conectar ao novo projeto
echo "📡 Conectando ao novo projeto: $NEW_PROJECT_REF"
supabase link --project-ref $NEW_PROJECT_REF

# Aplicar estrutura
echo "🏗️ Aplicando estrutura do banco..."
supabase db push

# Aplicar schema personalizado se existir
if [ -f "schema.sql" ]; then
    echo "📋 Aplicando schema customizado..."
    supabase db reset --linked
    supabase db push
fi

# Aguardar estabilização
echo "⏳ Aguardando estabilização do banco..."
sleep 10

# Importar dados essenciais
echo "📊 Importando dados..."

if [ -f "data-empresas.sql" ]; then
    echo "🏢 Importando empresas..."
    supabase db push --include-seeds
fi

if [ -f "data-users.sql" ]; then
    echo "👥 Importando usuários..."
    supabase db push --include-seeds
fi

if [ -f "data-fornecedores.sql" ]; then
    echo "🏪 Importando fornecedores..."
    supabase db push --include-seeds
fi

if [ -f "data-produtos.sql" ]; then
    echo "🏷️ Importando produtos..."
    supabase db push --include-seeds
fi

# Aplicar anonimização
echo "🔒 Aplicando anonimização de dados..."
supabase db push --include-all

echo ""
echo "✅ Restauração concluída!"
echo ""
echo "🎯 Novo projeto configurado:"
echo "   Project Ref: $NEW_PROJECT_REF"
echo "   URL: https://$NEW_PROJECT_REF.supabase.co"
echo ""
echo "📝 Próximo passo: Atualizar .env.local com as novas credenciais"