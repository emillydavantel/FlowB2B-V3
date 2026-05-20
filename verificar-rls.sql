-- ===========================================
-- SCRIPT DE VERIFICAÇÃO RLS
-- Execute ANTES e DEPOIS da implementação
-- ===========================================

-- 1. STATUS ATUAL DAS TABELAS
SELECT
    tablename,
    rowsecurity as rls_ativo,
    CASE
        WHEN rowsecurity THEN '✅ PROTEGIDO'
        ELSE '🚨 EXPOSTO'
    END as status_seguranca,
    (SELECT COUNT(*) FROM pg_policies WHERE tablename = pt.tablename) as num_politicas
FROM pg_tables pt
WHERE schemaname = 'public'
    AND tablename NOT LIKE '%backup%'
    AND tablename NOT LIKE 'views_%'
ORDER BY rowsecurity, tablename;

-- 2. TABELAS CRÍTICAS SEM RLS
SELECT
    '🚨 CRÍTICA EXPOSTA: ' || tablename as alerta,
    pg_size_pretty(pg_total_relation_size('public.' || tablename)) as tamanho
FROM pg_tables
WHERE schemaname = 'public'
    AND rowsecurity = false
    AND tablename IN (
        'empresas', 'users', 'produtos', 'fornecedores', 'clientes',
        'pedidos_venda', 'pedidos_compra', 'bling_tokens',
        'fornecedores_produtos', 'movimentacao_estoque'
    );

-- 3. POLÍTICAS CRIADAS
SELECT
    schemaname,
    tablename,
    policyname,
    cmd,
    CASE
        WHEN qual LIKE '%empresaId%' THEN '✅ Multi-tenant'
        WHEN qual LIKE '%empresa_id%' THEN '✅ Multi-tenant'
        ELSE '⚠️ Revisar política'
    END as tipo_politica
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 4. RESUMO GERAL
SELECT
    COUNT(*) as total_tabelas,
    COUNT(*) FILTER (WHERE rowsecurity = true) as protegidas,
    COUNT(*) FILTER (WHERE rowsecurity = false) as expostas,
    ROUND(
        (COUNT(*) FILTER (WHERE rowsecurity = true) * 100.0 / COUNT(*)), 1
    ) || '%' as percentual_protegido
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename NOT LIKE '%backup%'
    AND tablename NOT LIKE 'views_%';

-- 5. TESTE DE AUTENTICAÇÃO (se logado)
SELECT
    CASE
        WHEN auth.jwt() IS NOT NULL THEN
            '✅ JWT Token válido - Empresa: ' || COALESCE((auth.jwt() ->> 'empresaId'), 'NÃO DEFINIDO')
        ELSE
            '❌ Não autenticado'
    END as status_auth;

-- 6. VERIFICAÇÃO DE ACESSO (simular consulta)
-- ATENÇÃO: Esta query só funciona se você estiver autenticado
DO $$
BEGIN
    IF auth.jwt() IS NOT NULL THEN
        RAISE NOTICE 'Testando acesso aos produtos...';
        PERFORM COUNT(*) FROM public.produtos;
        RAISE NOTICE '✅ Acesso aos produtos funcionando';
    ELSE
        RAISE NOTICE '⚠️ Não é possível testar - usuário não autenticado';
    END IF;
EXCEPTION
    WHEN insufficient_privilege THEN
        RAISE NOTICE '🚨 ERRO: Acesso negado aos produtos (RLS funcionando)';
    WHEN OTHERS THEN
        RAISE NOTICE '❌ ERRO: %', SQLERRM;
END
$$;