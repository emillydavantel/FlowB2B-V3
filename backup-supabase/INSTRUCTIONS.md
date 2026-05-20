# 🚀 Guia Completo: Criação do Ambiente de Desenvolvimento

## 📋 Processo Completo

### Etapa 1: Obter Access Token do Supabase ✅
- [x] Acesse https://supabase.com/dashboard
- [x] Vá em Account Settings > Access tokens
- [x] Gere um novo token com nome "FlowB2B Development Copy"
- [x] Copie o token (será usado nos próximos passos)

### Etapa 2: Fazer Backup do Banco Atual
```bash
# Execute no terminal:
cd backup-supabase
chmod +x backup-script.sh
./backup-script.sh [SEU_ACCESS_TOKEN]
```

### Etapa 3: Criar Novo Projeto para Desenvolvimento
1. Acesse https://supabase.com/dashboard
2. Clique em "New Project"
3. Escolha sua organização
4. Nome: "FlowB2B Development"
5. Database Password: crie uma senha forte
6. Region: mesma do projeto original (para melhor performance)
7. Clique "Create new project"
8. Aguarde 2-3 minutos para o projeto ficar pronto
9. **Copie o Project Reference ID** (ex: abcd1234efgh)

### Etapa 4: Restaurar Dados no Novo Projeto
```bash
# Execute no terminal:
chmod +x restore-script.sh
./restore-script.sh [SEU_ACCESS_TOKEN] [NEW_PROJECT_REF]
```

### Etapa 5: Configurar Variáveis de Ambiente
Atualize o arquivo `.env.local` com as credenciais do novo projeto:

```env
# DESENVOLVIMENTO - Novo projeto Supabase
NEXT_PUBLIC_SUPABASE_URL=https://[NEW_PROJECT_REF].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=[nova_anon_key]
SUPABASE_SERVICE_ROLE_KEY=[nova_service_key]

# JWT (manter o mesmo ou gerar novo)
JWT_SECRET=development_jwt_secret_123

# Bling (usar sandbox/test se disponível)
BLING_CLIENT_ID=2abf4c9c9645a7a08016d39c71f0b5d458b799d9
BLING_CLIENT_SECRET=[test_client_secret]
BLING_REDIRECT_URI=http://localhost:3000/api/auth/bling/callback

# APIs (apontar para dev/staging se disponível)
FLOWB2BAPI_URL=https://flowb2bapi-dev.onrender.com
VALIDACAO_EAN_URL=https://validacao-ean-dev.onrender.com
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### Etapa 6: Obter Credenciais do Novo Projeto
1. No dashboard do novo projeto, vá em "Settings" → "API"
2. Copie:
   - **Project URL** (para NEXT_PUBLIC_SUPABASE_URL)
   - **anon public** (para NEXT_PUBLIC_SUPABASE_ANON_KEY)
   - **service_role** (para SUPABASE_SERVICE_ROLE_KEY)

### Etapa 7: Testar Ambiente de Desenvolvimento
```bash
# Parar o servidor atual
# Ctrl+C no terminal do npm run dev

# Iniciar novamente com novas variáveis
npm run dev
```

## 🔒 Segurança

### Dados Anonimizados Automaticamente:
- ✅ Senhas de usuários → hash padrão
- ✅ Emails → dev[id]@example.com
- ✅ CNPJs → valores fictícios
- ✅ Telefones → números genéricos
- ✅ Tokens Bling → removidos
- ✅ Dados de endereço → ficticios

### Usuários de Teste Criados:
- **admin@example.com** / senha: `dev123456`
- **lojista@example.com** / senha: `dev123456`
- **fornecedor@example.com** / senha: `dev123456`

## 🎯 Resultado Final

Após completar todas as etapas, você terá:

1. **✅ Banco de desenvolvimento** - Cópia completa com dados anonimizados
2. **✅ Ambiente isolado** - Mudanças não afetam produção
3. **✅ Dados consistentes** - Estrutura idêntica ao produção
4. **✅ Desenvolvimento seguro** - Sem riscos de exposure de dados reais

## 📞 Suporte

Se encontrar algum erro durante o processo, verifique:
1. Access token ainda válido
2. Novo projeto totalmente inicializado (verde no dashboard)
3. Permissões corretas no projeto
4. Connection string correto