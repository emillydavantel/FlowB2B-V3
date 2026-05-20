# 🚀 Guia de Deploy - FlowB2B CI/CD

## 📋 Visão Geral

Sistema completo de CI/CD com **GitHub Actions + Render** configurado para deploy automático do FlowB2B.

### 🌟 Funcionalidades

- ✅ **Deploy automático** em push para `main` (produção)
- ✅ **Deploy de staging** em pull requests
- ✅ **Testes automáticos** (lint, build, security)
- ✅ **Health checks** integrados
- ✅ **Rollback automático** em caso de falha
- ✅ **Notificações** de status

---

## 🔧 Setup Inicial (Fazer Uma Vez)

### **1. Configurar Render.com**

#### **1.1 Criar Serviços**

1. Acesse [render.com](https://render.com)
2. Conecte seu repositório GitHub
3. Crie 2 serviços:

**Produção:**
```
Nome: flowb2b-production
Branch: main
Build Command: npm ci && npm run build
Start Command: npm start
```

**Staging:**
```
Nome: flowb2b-staging  
Branch: develop (ou staging)
Build Command: npm ci && npm run build
Start Command: npm start
```

#### **1.2 Anotar Service IDs**

- Acesse cada serviço → Settings → copie o **Service ID**
- Exemplo: `srv-abc123def456`

#### **1.3 Gerar API Key**

- Account Settings → API Keys → Generate New Key
- Anote a chave (você só verá uma vez)

---

### **2. Configurar GitHub Secrets**

#### **Método Automático (Recomendado):**

```bash
# Execute o script de configuração
./scripts/setup-github-secrets.sh
```

#### **Método Manual:**

1. Vá para: `Settings > Secrets and variables > Actions`
2. Adicione os secrets:

| Secret | Valor | Descrição |
|--------|-------|-----------|
| `RENDER_API_KEY` | `rnd_xxx` | Chave da API do Render |
| `RENDER_SERVICE_ID` | `srv-xxx` | ID do serviço de produção |
| `RENDER_STAGING_SERVICE_ID` | `srv-xxx` | ID do serviço de staging |
| `SUPABASE_URL` | `https://xxx.supabase.co` | URL Supabase produção |
| `SUPABASE_ANON_KEY` | `eyJxxx` | Chave anon produção |
| `SUPABASE_SERVICE_ROLE_KEY` | `eyJxxx` | Chave service produção |
| `JWT_SECRET` | `xxx` | Chave JWT produção |
| `STAGING_SUPABASE_URL` | `https://xxx.supabase.co` | URL Supabase staging |
| `STAGING_SUPABASE_ANON_KEY` | `eyJxxx` | Chave anon staging |
| `STAGING_SUPABASE_SERVICE_ROLE_KEY` | `eyJxxx` | Chave service staging |
| `STAGING_JWT_SECRET` | `xxx` | Chave JWT staging |

---

### **3. Configurar Variáveis no Render**

Para cada serviço no Render, configure as **Environment Variables**:

**Produção:**
```
NODE_ENV=production
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJxxx
SUPABASE_SERVICE_ROLE_KEY=eyJxxx
JWT_SECRET=xxx
BLING_CLIENT_ID=2abf4c9c9645a7a08016d39c71f0b5d458b799d9
BLING_REDIRECT_URI=https://flowb2b-v2.onrender.com/api/auth/bling/callback
NEXT_PUBLIC_APP_URL=https://flowb2b-v2.onrender.com
```

**Staging:**
```
NODE_ENV=staging
NEXT_PUBLIC_SUPABASE_URL=https://staging-xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJxxx
SUPABASE_SERVICE_ROLE_KEY=eyJxxx
JWT_SECRET=xxx-staging
BLING_CLIENT_ID=2abf4c9c9645a7a08016d39c71f0b5d458b799d9
BLING_REDIRECT_URI=https://flowb2b-staging.onrender.com/api/auth/bling/callback
NEXT_PUBLIC_APP_URL=https://flowb2b-staging.onrender.com
```

---

## 🔄 Fluxo de Deploy

### **Deploy Automático**

1. **Pull Request** → Deploy automático para **Staging**
2. **Merge para main** → Deploy automático para **Produção**

### **Deploy Manual**

```bash
# Deploy para staging
./scripts/deploy-render.sh
# Escolha opção 1

# Deploy para produção
./scripts/deploy-render.sh
# Escolha opção 2
```

---

## 🧪 Workflows Configurados

### **1. Deploy (`deploy.yml`)**

**Triggers:**
- Push para `main` → Deploy produção
- Pull request → Deploy staging

**Steps:**
- ✅ Testes de qualidade (lint)
- ✅ Build de teste
- ✅ Deploy para Render
- ✅ Verificação de saúde

### **2. Security (`security.yml`)**

**Triggers:**
- Push/PR para branches principais
- Cron semanal (domingo 2h)

**Verificações:**
- 🛡️ Audit de dependências
- 🔍 Scan de secrets
- 🧪 Verificação RLS
- 📦 Review de dependencies

---

## 🔍 Monitoramento

### **Health Checks**

- **URL:** `/api/health`
- **Frequência:** A cada 5 minutos
- **Timeout:** 30 segundos

### **Logs de Deploy**

```bash
# Ver logs do GitHub Actions
gh run list
gh run view [RUN_ID]

# Ver logs do Render
# Dashboard > Service > Logs
```

---

## 🚨 Troubleshooting

### **Deploy Falha**

1. **Verificar secrets do GitHub:**
   ```bash
   gh secret list
   ```

2. **Verificar logs:**
   - GitHub: Actions tab
   - Render: Dashboard > Logs

3. **Teste local:**
   ```bash
   npm ci
   npm run build
   npm start
   ```

### **Health Check Falha**

1. **Verificar banco:**
   ```bash
   curl https://your-app.onrender.com/api/health
   ```

2. **Verificar variáveis:**
   - Render Dashboard > Environment

### **Build Falha**

1. **Verificar Node.js version:**
   - Deve ser 22.15.0

2. **Verificar dependências:**
   ```bash
   npm audit
   npm ci
   ```

---

## 📊 Status Dashboard

### **URLs de Monitoramento**

- 🔴 **Produção:** https://flowb2b-v2.onrender.com/api/health
- 🟡 **Staging:** https://flowb2b-staging.onrender.com/api/health

### **Métricas Esperadas**

```json
{
  "status": "healthy",
  "database": { "status": "connected", "responseTime": "< 100ms" },
  "services": { "supabase": "connected", "nextjs": "running" }
}
```

---

## 🔄 Atualizações

### **Adicionar Nova Variável**

1. Adicione no GitHub Secrets
2. Configure no Render Dashboard
3. Reinicie o serviço

### **Novo Ambiente**

1. Crie serviço no Render
2. Configure secrets específicos
3. Atualize workflow conforme necessário

---

## 📞 Suporte

### **Comandos Úteis**

```bash
# Verificar status do deploy
gh run list --limit 5

# Fazer deploy manual
./scripts/deploy-render.sh

# Verificar secrets
gh secret list

# Ver logs locais
npm run dev
```

### **Links Importantes**

- [Render Dashboard](https://dashboard.render.com)
- [GitHub Actions](https://github.com/emillydavantell/flowb2b/actions)
- [Supabase Dashboard](https://supabase.com/dashboard)

---

## ✅ Checklist Pós-Setup

- [ ] GitHub Secrets configurados
- [ ] Render services criados
- [ ] Environment variables configuradas
- [ ] Health check funcionando
- [ ] Deploy automático testado
- [ ] URLs de produção/staging acessíveis
- [ ] Notificações funcionando

**🎉 Parabéns! CI/CD está configurado e funcionando!**