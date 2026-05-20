-- ===========================================
-- CORREÇÃO CRÍTICA: RLS para tabelas principais
-- Execute durante horário de baixo tráfego
-- ===========================================

-- IMPORTANTE: Teste primeiro em development!

BEGIN;

-- 1. EMPRESAS - Só pode ver a própria empresa
ALTER TABLE public.empresas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "empresas_own_company" ON public.empresas
    FOR ALL USING (
        id = (auth.jwt() ->> 'empresaId')::integer
    );

-- 2. USERS - Só pode ver usuários da própria empresa
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_company" ON public.users
    FOR ALL USING (
        empresa_id = (auth.jwt() ->> 'empresaId')::integer
    );

-- 3. PRODUTOS - Isolamento por empresa_id
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "produtos_empresa_policy" ON public.produtos
    FOR ALL USING (
        empresa_id = (auth.jwt() ->> 'empresaId')::integer
    );

-- 4. FORNECEDORES - Isolamento por empresa_id
ALTER TABLE public.fornecedores ENABLE ROW LEVEL SECURITY;
CREATE POLICY "fornecedores_empresa_policy" ON public.fornecedores
    FOR ALL USING (
        empresa_id = (auth.jwt() ->> 'empresaId')::integer
    );

-- 5. CLIENTES - Isolamento por empresa_id
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "clientes_empresa_policy" ON public.clientes
    FOR ALL USING (
        empresa_id = (auth.jwt() ->> 'empresaId')::integer
    );

-- 6. PEDIDOS DE VENDA - Crítico para faturamento
ALTER TABLE public.pedidos_venda ENABLE ROW LEVEL SECURITY;
CREATE POLICY "pedidos_venda_empresa_policy" ON public.pedidos_venda
    FOR ALL USING (
        empresa_id = (auth.jwt() ->> 'empresaId')::integer
    );

-- 7. PEDIDOS DE COMPRA - Crítico para compras
ALTER TABLE public.pedidos_compra ENABLE ROW LEVEL SECURITY;
CREATE POLICY "pedidos_compra_empresa_policy" ON public.pedidos_compra
    FOR ALL USING (
        empresa_id = (auth.jwt() ->> 'empresaId')::integer
    );

-- 8. BLING TOKENS - Extremamente sensível
ALTER TABLE public.bling_tokens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "bling_tokens_empresa_policy" ON public.bling_tokens
    FOR ALL USING (
        empresa_id = (auth.jwt() ->> 'empresaId')::integer
    );

-- Verificar se foi aplicado
SELECT
    tablename,
    rowsecurity,
    (SELECT COUNT(*) FROM pg_policies WHERE tablename = pt.tablename) as policies_count
FROM pg_tables pt
WHERE schemaname = 'public'
    AND tablename IN ('empresas', 'users', 'produtos', 'fornecedores', 'clientes', 'pedidos_venda', 'pedidos_compra', 'bling_tokens')
ORDER BY tablename;

COMMIT;