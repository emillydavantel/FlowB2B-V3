-- ===========================================
-- CORREÇÃO RLS: Tabelas restantes
-- Execute após validar que as críticas funcionam
-- ===========================================

BEGIN;

-- Tabelas de relacionamento e detalhes
ALTER TABLE public.fornecedores_produtos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "fornecedores_produtos_empresa_policy" ON public.fornecedores_produtos
    FOR ALL USING (empresa_id = (auth.jwt() ->> 'empresaId')::integer);

ALTER TABLE public.itens_pedido_venda ENABLE ROW LEVEL SECURITY;
CREATE POLICY "itens_pedido_venda_policy" ON public.itens_pedido_venda
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.pedidos_venda pv WHERE pv.id = pedido_venda_id AND pv.empresa_id = (auth.jwt() ->> 'empresaId')::integer)
    );

ALTER TABLE public.itens_pedido_compra ENABLE ROW LEVEL SECURITY;
CREATE POLICY "itens_pedido_compra_policy" ON public.itens_pedido_compra
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.pedidos_compra pc WHERE pc.id = pedido_compra_id AND pc.empresa_id = (auth.jwt() ->> 'empresaId')::integer)
    );

ALTER TABLE public.parcelas_pedido_venda ENABLE ROW LEVEL SECURITY;
CREATE POLICY "parcelas_pedido_venda_policy" ON public.parcelas_pedido_venda
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.pedidos_venda pv WHERE pv.id = pedido_venda_id AND pv.empresa_id = (auth.jwt() ->> 'empresaId')::integer)
    );

ALTER TABLE public.parcelas_pedido_compra ENABLE ROW LEVEL SECURITY;
CREATE POLICY "parcelas_pedido_compra_policy" ON public.parcelas_pedido_compra
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.pedidos_compra pc WHERE pc.id = pedido_compra_id AND pc.empresa_id = (auth.jwt() ->> 'empresaId')::integer)
    );

-- Movimentação de estoque
ALTER TABLE public.movimentacao_estoque ENABLE ROW LEVEL SECURITY;
CREATE POLICY "movimentacao_estoque_empresa_policy" ON public.movimentacao_estoque
    FOR ALL USING (empresa_id = (auth.jwt() ->> 'empresaId')::integer);

-- Notas fiscais
ALTER TABLE public.notas_fiscais ENABLE ROW LEVEL SECURITY;
CREATE POLICY "notas_fiscais_empresa_policy" ON public.notas_fiscais
    FOR ALL USING (empresa_id = (auth.jwt() ->> 'empresaId')::integer);

-- Políticas de compra
ALTER TABLE public.politica_compra ENABLE ROW LEVEL SECURITY;
CREATE POLICY "politica_compra_empresa_policy" ON public.politica_compra
    FOR ALL USING (empresa_id = (auth.jwt() ->> 'empresaId')::integer);

-- Catálogos
ALTER TABLE public.catalogo_itens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "catalogo_itens_empresa_policy" ON public.catalogo_itens
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.catalogo_fornecedor cf WHERE cf.id = catalogo_fornecedor_id AND cf.empresa_id = (auth.jwt() ->> 'empresaId')::integer)
    );

ALTER TABLE public.catalogo_fornecedor ENABLE ROW LEVEL SECURITY;
CREATE POLICY "catalogo_fornecedor_empresa_policy" ON public.catalogo_fornecedor
    FOR ALL USING (empresa_id = (auth.jwt() ->> 'empresaId')::integer);

-- Logs e auditoria
ALTER TABLE public.user_activity_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "user_activity_log_policy" ON public.user_activity_log
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.users u WHERE u.id::text = user_id AND u.empresa_id = (auth.jwt() ->> 'empresaId')::integer)
    );

ALTER TABLE public.sync_errors_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sync_errors_log_empresa_policy" ON public.sync_errors_log
    FOR ALL USING (empresa_id = (auth.jwt() ->> 'empresaId')::integer);

-- Verificar progresso
SELECT
    COUNT(*) as total_tables_with_rls,
    COUNT(*) FILTER (WHERE rowsecurity = true) as tables_rls_enabled
FROM pg_tables
WHERE schemaname = 'public';

COMMIT;