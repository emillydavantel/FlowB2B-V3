# 🛡️ Guia de Implementação RLS (Row Level Security)

## ⚠️ **IMPORTANTE: Risco de Quebrar o Sistema**

RLS pode **BLOQUEAR ACESSO** se mal configurado. Siga este guia **exatamente** para evitar problemas.

---

## 📅 **Cronograma de Implementação**

### **🔥 HOJE - Tabelas Críticas (15 min)**
- Empresas, Users, Produtos, Fornecedores
- Pedidos de Venda/Compra, Bling Tokens

### **📅 Amanhã - Validação (30 min)**
- Testar todas as funcionalidades
- Verificar se usuários conseguem acessar

### **📅 Esta Semana - Restantes**
- Implementar tabelas secundárias
- Logs e auditoria

---

## 🚀 **PASSO 1: Preparação (OBRIGATÓRIO)**

### **1.1 Fazer Backup**
```sql
-- No Supabase Dashboard → Settings → Database → Backups
-- OU via CLI:
supabase db dump --data-only -f backup-pre-rls.sql
```

### **1.2 Identificar Horário de Baixo Tráfego**
- Madrugada ou domingo de manhã
- Avisar equipe sobre manutenção

### **1.3 Preparar Rollback**
```sql
-- EM CASO DE EMERGÊNCIA - DESABILITAR RLS
ALTER TABLE public.empresas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
-- ... repetir para todas
```

---

## 🔧 **PASSO 2: Testar no Development**

```bash
# 1. Testar no schema development primeiro
psql -h db.asahknimbggpzpoebmej.supabase.co -U postgres -f fix-rls-critical.sql

# 2. Verificar se ainda consegue fazer login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@dev.flowb2b.com","password":"dev123456"}'

# 3. Verificar se queries funcionam
curl -H "Authorization: Bearer [TOKEN]" \
  http://localhost:3000/api/produtos
```

---

## 🎯 **PASSO 3: Implementar em Produção**

### **3.1 Executar Script Crítico**

```sql
-- CUIDADO: Execute DURANTE horário de baixo tráfego
-- Monitore logs de erro em tempo real
\i fix-rls-critical.sql
```

### **3.2 Teste Imediato**

```bash
# 1. Testar login de usuários reais
# 2. Verificar se dashboard carrega
# 3. Testar criação/edição de pedidos
# 4. Verificar relatórios
```

### **3.3 Monitoramento**

```sql
-- Verificar se RLS está ativo
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('empresas', 'users', 'produtos')
  AND rowsecurity = true;

-- Verificar logs de erro
SELECT *
FROM pg_stat_statements
WHERE query LIKE '%permission denied%'
ORDER BY last_exec_time DESC;
```

---

## 🚨 **PROBLEMAS COMUNS E SOLUÇÕES**

### **Erro: "permission denied for table"**
```sql
-- SOLUÇÃO: Verificar se user está autenticado
SELECT auth.uid(), auth.jwt();

-- Se NULL, problema na autenticação JWT
```

### **Erro: "relation does not exist"**
```sql
-- SOLUÇÃO: Verificar se service_role bypassa RLS
SET role service_role;
SELECT * FROM produtos; -- Deve funcionar
```

### **Frontend quebrou após RLS**
```sql
-- SOLUÇÃO TEMPORÁRIA: Desabilitar RLS da tabela específica
ALTER TABLE public.produtos DISABLE ROW LEVEL SECURITY;

-- Debuggar e reabilitar depois
```

---

## 📊 **PASSO 4: Validação Completa**

### **Checklist de Validação**

- [ ] **Login funciona** para todos os tipos de usuário
- [ ] **Dashboard carrega** sem erros
- [ ] **Pedidos de venda** aparecem corretamente
- [ ] **Produtos** filtrados por empresa
- [ ] **Fornecedores** isolados por empresa
- [ ] **Relatórios** mostram apenas dados da empresa
- [ ] **API endpoints** funcionam
- [ ] **Sincronização Bling** não quebrou

### **Teste de Isolamento**
```sql
-- Usuário da empresa 1 NÃO deve ver dados da empresa 2
-- Fazer login com empresas diferentes e verificar
```

---

## 🔧 **PASSO 5: Implementar Restantes**

Apenas **APÓS** validar que críticas funcionam:

```sql
-- Executar segundo script
\i fix-rls-remaining.sql
```

---

## 📱 **Monitoramento Contínuo**

### **Dashboard de Segurança**
```sql
-- Criar view para monitorar RLS
CREATE VIEW security_status AS
SELECT
    tablename,
    rowsecurity as rls_enabled,
    (SELECT COUNT(*) FROM pg_policies WHERE tablename = pt.tablename) as policies_count
FROM pg_tables pt
WHERE schemaname = 'public'
ORDER BY rls_enabled, tablename;
```

### **Alertas**
- Monitor de tentativas de acesso negadas
- Log de queries que falharam por RLS
- Verificação semanal de tabelas sem RLS

---

## 🎯 **Resultado Final**

Após implementação completa:

- ✅ **0 tabelas** expostas publicamente
- ✅ **Isolamento total** entre empresas
- ✅ **Dados sensíveis** protegidos
- ✅ **Conformidade** com LGPD/GDPR
- ✅ **Sistema funcionando** normalmente

---

## 🆘 **Contatos de Emergência**

Em caso de problemas críticos:

1. **Rollback imediato**: Desabilitar RLS
2. **Logs**: Verificar /var/log/postgresql/
3. **Suporte**: Contatar supabase.com/support
4. **Restore**: Usar backup pré-RLS

**⚠️ NUNCA implemente RLS sexta-feira à noite!**