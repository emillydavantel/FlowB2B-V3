#!/bin/bash

# Script para backup do banco FlowB2B Supabase
# Uso: ./backup-script.sh [ACCESS_TOKEN]

set -e

ACCESS_TOKEN=$1

if [ -z "$ACCESS_TOKEN" ]; then
    echo "❌ Erro: Access Token não fornecido"
    echo "Uso: ./backup-script.sh [ACCESS_TOKEN]"
    exit 1
fi

echo "🚀 Iniciando backup do banco FlowB2B..."

# Configurar token
export SUPABASE_ACCESS_TOKEN=$ACCESS_TOKEN

# Conectar ao projeto atual
echo "📡 Conectando ao projeto FlowB2B..."
supabase link --project-ref asahknimbggpzpoebmej

# Fazer dump da estrutura
echo "📋 Exportando estrutura do banco..."
supabase db dump --schema-only -f schema.sql

# Fazer dump das tabelas principais
echo "📊 Exportando dados das tabelas..."

# Empresas (essencial)
supabase db dump --data-only --table empresas -f data-empresas.sql

# Users (com senhas anonimizadas)
echo "👥 Exportando usuários (dados anonimizados)..."
supabase db dump --data-only --table users -f data-users.sql

# Produtos (amostra)
echo "🏷️ Exportando produtos..."
supabase db dump --data-only --table produtos -f data-produtos.sql

# Fornecedores
echo "🏪 Exportando fornecedores..."
supabase db dump --data-only --table fornecedores -f data-fornecedores.sql

# Fornecedores_produtos (relação)
echo "🔗 Exportando relação fornecedor-produto..."
supabase db dump --data-only --table fornecedores_produtos -f data-fornecedores-produtos.sql

echo "✅ Backup concluído!"
echo ""
echo "📁 Arquivos gerados:"
echo "   - schema.sql (estrutura)"
echo "   - data-empresas.sql"
echo "   - data-users.sql"
echo "   - data-produtos.sql"
echo "   - data-fornecedores.sql"
echo "   - data-fornecedores-produtos.sql"
echo ""
echo "🎯 Próximo passo: Criar novo projeto Supabase para desenvolvimento"