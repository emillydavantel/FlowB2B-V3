-- Script para anonimizar dados sensíveis no ambiente de desenvolvimento

-- Anonimizar senhas dos usuários
UPDATE users SET
    password_hash = '$2b$10$example.hash.for.development.password123',
    email = CASE
        WHEN email LIKE '%@gmail.com' THEN 'dev' || id || '@example.com'
        WHEN email LIKE '%@hotmail.com' THEN 'dev' || id || '@example.com'
        ELSE 'dev' || id || '@example.com'
    END
WHERE id > 0;

-- Anonimizar dados da empresa (manter estrutura, dados fictícios)
UPDATE empresas SET
    razao_social = 'EMPRESA DESENVOLVIMENTO LTDA',
    nome_fantasia = 'Dev Company',
    cnpj = '12345678000199',
    inscricao_estadual = '123456789',
    inscricao_municipal = '987654321',
    authtoken = NULL,
    refreshtoken = NULL,
    endereco_dado = jsonb_build_object(
        'logradouro', 'Rua do Desenvolvimento, 123',
        'cidade', 'Dev City',
        'uf', 'SP',
        'cep', '01234-567'
    )
WHERE id > 0;

-- Anonimizar dados dos fornecedores
UPDATE fornecedores SET
    cnpj = '98765432000100',
    cpf = NULL,
    telefone = '(11) 99999-9999',
    celular = '(11) 99999-9999',
    email = 'fornecedor' || id || '@example.com',
    endereco = jsonb_build_object(
        'logradouro', 'Rua do Fornecedor, ' || id,
        'cidade', 'Fornecedores City',
        'uf', 'SP',
        'cep', '01234-567'
    )
WHERE id > 0;

-- Limpar tokens do Bling
UPDATE bling_tokens SET
    access_token = 'dev_access_token',
    refresh_token = 'dev_refresh_token'
WHERE id > 0;

-- Anonimizar dados dos clientes
UPDATE clientes SET
    cnpj = '11111111000111',
    cpf = NULL,
    telefone = '(11) 88888-8888',
    celular = '(11) 88888-8888',
    email = 'cliente' || id || '@example.com'
WHERE id > 0;

COMMIT;