# Backup e Criação de Ambiente de Desenvolvimento

## Processo Automatizado

Este diretório contém os arquivos de backup e scripts para criar o ambiente de desenvolvimento.

### Arquivos que serão gerados:

1. **schema.sql** - Estrutura das tabelas
2. **data-empresas.sql** - Dados da tabela empresas
3. **data-users.sql** - Dados da tabela users
4. **data-produtos.sql** - Dados da tabela produtos
5. **data-fornecedores.sql** - Dados da tabela fornecedores
6. **data-todas-tabelas.sql** - Backup completo

### Processo:

1. Export da estrutura do banco (schema)
2. Export dos dados essenciais (empresas, users, produtos, fornecedores)
3. Criar novo projeto Supabase para desenvolvimento
4. Importar estrutura e dados
5. Configurar variáveis de ambiente

### Segurança:

- Dados sensíveis serão anonimizados
- Senhas serão resetadas para valores padrão
- Tokens serão removidos