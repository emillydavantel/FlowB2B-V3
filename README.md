# FlowB2B V3 — plataforma B2B de gestão de compras integrada ao ERP Bling

[![Next.js](https://img.shields.io/badge/Next.js-16-black)](https://nextjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-3178c6)](https://www.typescriptlang.org/)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ecf8e)](https://supabase.com/)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](LICENSE)

> **EN:** FlowB2B is a multi-tenant B2B purchasing platform for retailers, suppliers and sales reps, integrated with the Bling ERP (Brazil). Built with Next.js 16, TypeScript and Supabase. Apache 2.0 licensed.

A FlowB2B conecta **lojistas**, **fornecedores** e **representantes** em um único fluxo de compras: catálogos e tabelas de preço dos fornecedores, pedidos de compra gerados manualmente ou de forma automática a partir do consumo, acompanhamento de entregas e notas fiscais, tudo sincronizado com o ERP Bling.

Ela nasceu dentro de uma rede de pet shops, para resolver um problema real: repor estoque sem faltar produto e sem travar dinheiro em mercadoria parada. A versão 3 é a reescrita completa do frontend em Next.js (a versão anterior rodava em Bubble.io), publicada como código aberto.

---

## O que o sistema faz

### Lojista (empresa compradora)
- **Dashboard** com indicadores de compras, estoque e pedidos.
- **Cadastros**: empresas, colaboradores, fornecedores, produtos e representantes.
- **Compras**: catálogos e tabelas de preço dos fornecedores, pedidos de compra (criação manual, geração automática por sugestão de reposição e validação-espelho do pedido), análise de curva de produtos por fornecedor e acompanhamento de atualizações de catálogo.
- **Estoque**: posição por produto, sugestões de reposição e diagnóstico de estoque.
- **Fiscal**: consulta de notas fiscais de entrada e saída sincronizadas do ERP.
- **Suprimentos**: política de compra por fornecedor (prazos, mínimos, condições).
- **Configurações**: conexão e sincronização com o Bling.

### Fornecedor (portal próprio)
- Cadastro e login independentes, catálogo e atualizações de catálogo, tabelas de preço.
- Lojistas atendidos, convites e solicitações de vínculo, representantes.
- Pedidos recebidos, notas fiscais, conferência de estoque e indicações.
- **Landing pages de produtos** com checkout, para vender diretamente aos lojistas.

### Representante (portal próprio)
- Entrada por convite, catálogo dos fornecedores representados, pedidos, conferência de estoque e landing pages.

### Administração (super admin)
- Empresas, usuários (lojistas, fornecedores e representantes), negociações, pedidos, relações entre empresas, auditoria, importação de lojistas e integração Bling por empresa.

### Páginas públicas
- Catálogo público por fornecedor (`/catalogo/[slug]`), landing pages com checkout (`/lp/[slug]`), acompanhamento público de pedido, termos de uso e política de privacidade.

---

## Integrações

- **Bling ERP (API v3)** — OAuth 2.0 por empresa, sincronização inicial e incremental de produtos, pedidos, estoque e notas fiscais, webhook de estoque e controle de limite de requisições.
- **Importação de catálogos** — a partir de planilhas (XLSX) e PDFs de fornecedores, com extração assistida por IA e comparação de diferenças entre versões.
- **E-mail transacional** (Resend) — convites, confirmações, redefinição de senha e notificações de catálogo.
- **WhatsApp** — integração para contato e notificações.

---

## Arquitetura

```
┌────────────────────────────────────────────────────────┐
│                 FlowB2B V3 (Next.js 16)                │
│  App Router · páginas por perfil · API routes (/api)   │
└───────────────┬───────────────────────┬────────────────┘
                │                       │
        ┌───────▼────────┐      ┌───────▼────────┐
        │   Supabase     │      │   Bling API v3 │
        │  PostgreSQL    │      │  (OAuth 2.0)   │
        │  RLS + RPC     │      └────────────────┘
        └────────────────┘
Serviços auxiliares: flowB2BAPI (Node/Express — sincronização com o Bling)
e validacao_ean (Python/FastAPI — validação de EAN e cálculo de sugestão de pedido).
```

- **Multi-tenant por `empresa_id`**: toda leitura e escrita é isolada por empresa, com Row Level Security no banco e filtros obrigatórios na aplicação.
- **Autenticação própria** com JWT em cookie `httpOnly` (sem Supabase Auth), perfis (`admin`, lojista, fornecedor, representante) e guardas de rota por papel.
- **Processamento assíncrono**: fila de jobs de sincronização e rotinas agendadas (`/api/cron`).
- **Observabilidade**: log de atividades e auditoria administrativa.

---

## Stack

| Camada | Tecnologias |
|---|---|
| Frontend | Next.js 16 (App Router), React 19, TypeScript, Tailwind CSS 4, Framer Motion, Recharts, Phosphor Icons |
| Backend | API routes do Next.js, Supabase (PostgreSQL, RLS, funções RPC e Edge Functions) |
| Autenticação | JWT (`jose`) + `bcryptjs`, cookies `httpOnly` |
| Integrações | Bling API v3, Resend, OpenAI, `pdf-parse` / `pdf-lib`, `xlsx` |
| Infra | Render.com, CI/CD com GitHub Actions |

---

## Rodando localmente

Requisitos: Node.js 22 e um projeto Supabase.

```bash
git clone https://github.com/emillydavantel/FlowB2B-V3.git
cd FlowB2B-V3
npm install
cp .env.example .env.local   # preencha as variáveis
npm run dev                  # http://localhost:3000
```

Variáveis principais (veja `.env.example`): URL e chaves do Supabase, credenciais OAuth do Bling, chave do serviço de e-mail e segredo do JWT.

Scripts: `npm run dev`, `npm run build`, `npm run start`, `npm run lint`.

Banco de dados: os guias `SUPABASE_RPC.md`, `GUIA_IMPLEMENTACAO_RLS.md` e a pasta `backup-supabase/` descrevem funções, políticas de segurança e rotinas de backup e restauração.

---

## Deploy

O projeto está preparado para o Render.com (`DEPLOY_GUIDE.md`, `scripts/deploy-render.sh`) com pipeline de CI/CD em GitHub Actions (`.github/workflows`).

---

## Documentação do projeto

| Arquivo | Conteúdo |
|---|---|
| `CLAUDE.md` | Visão geral, regras de multi-tenant, autenticação, tabelas e integrações |
| `ENGINEERING_GUIDELINES.md` | Diretrizes de engenharia e convenções de código |
| `DESIGN.md` | Sistema de design e padrões de interface |
| `PLANO_PEDIDOS_COMPRA.md`, `MAPEAMENTO_API_PEDIDOS_COMPRA.md` | Fluxo de pedidos de compra e mapeamento com a API do Bling |
| `CATALOGO_IMPORT_PLAN.md`, `CATALOGO_PUBLICO_VITRINE.md` | Importação de catálogos e vitrine pública |
| `LANDING_PAGE.md`, `LANDING_FORNECEDOR.md` | Landing pages de produtos e de fornecedores |
| `docs/` | Especificação do super admin, QA do portal do representante, webhook de estoque do Bling |
| `CHANGELOG.md`, `BACKLOG.md` | Histórico de versões e próximos passos |

O desenvolvimento é assistido por IA (Claude Code), com as regras do projeto versionadas em `CLAUDE.md` e `.claude/`.

---

## Segurança e privacidade

Isolamento de dados por empresa (RLS), senhas com hash, sessões em cookie `httpOnly`, segredos fora do repositório, auditoria de ações administrativas e páginas de termos de uso e política de privacidade alinhadas à LGPD.

---

## Licença

Distribuído sob a licença [Apache 2.0](LICENSE).

## Autora

**Emilly Davantel** — desenvolvedora full stack e fundadora da FlowB2B e da WhatsFlow B2B (Davantel Conti Desenvolvimento de Software).
[LinkedIn](https://www.linkedin.com/in/emillydavantel/) · [flowb2b.com.br](https://flowb2b.com.br)
