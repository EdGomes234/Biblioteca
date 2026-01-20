/********************************************************************************
 SCRIPT: CONFIGURAÇÃO DE USUÁRIOS PARA "Biblioteca_Senai"
 Descrição: Cria/Configura usuário appUser com permissões
 Pré-requisito: Banco "Biblioteca_Senai" deve existir
********************************************************************************/

PRINT 'Configurando usuários para banco Biblioteca_Senai...';

-- Verifica se o banco existe
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Biblioteca_Senai')
BEGIN
    PRINT 'ERRO: Banco Biblioteca_Senai não encontrado!';
    PRINT 'Execute primeiro: SQL_biblioteca_senai.sql';
    RETURN;
END

USE Biblioteca_Senai;
GO

-- =============================================================================
-- 1. CRIAÇÃO DO LOGIN (nível servidor)
-- =============================================================================
PRINT 'Verificando/criando login appUser...';

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'appUser')
BEGIN
    CREATE LOGIN appUser WITH PASSWORD = '1234@';
    PRINT 'Login appUser criado no servidor.';
END
ELSE
BEGIN
    PRINT 'Login appUser já existe no servidor.';
END
GO

-- =============================================================================
-- 2. CRIAÇÃO DO USUÁRIO (nível banco)
-- =============================================================================
PRINT 'Verificando/criando usuário appUser no banco...';

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'appUser')
BEGIN
    CREATE USER appUser FOR LOGIN appUser;
    PRINT 'Usuário appUser criado no banco.';
END
ELSE
BEGIN
    PRINT 'Usuário appUser já existe no banco.';
END
GO

-- =============================================================================
-- 3. ATRIBUIÇÃO DE PERMISSÕES (ROLES)
-- =============================================================================
PRINT 'Atribuindo permissões ao usuário appUser...';

BEGIN TRY
    ALTER ROLE db_owner ADD MEMBER appUser;
    PRINT '  - Adicionado à role: db_owner';
END TRY
BEGIN CATCH
    PRINT '  - Já está na role db_owner ou erro: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    ALTER ROLE db_datareader ADD MEMBER appUser;
    PRINT '  - Adicionado à role: db_datareader';
END TRY
BEGIN CATCH
    PRINT '  - Já está na role db_datareader';
END CATCH

BEGIN TRY
    ALTER ROLE db_datawriter ADD MEMBER appUser;
    PRINT '  - Adicionado à role: db_datawriter';
END TRY
BEGIN CATCH
    PRINT '  - Já está na role db_datawriter';
END CATCH

-- =============================================================================
-- 4. VERIFICAÇÃO FINAL (apenas para informação)
-- =============================================================================
PRINT '';
PRINT 'Verificação final de permissões:';

SELECT 
    dp.name AS Database_Role,
    mp.name AS Member
FROM 
    sys.database_role_members drm
    INNER JOIN sys.database_principals dp ON drm.role_principal_id = dp.principal_id
    INNER JOIN sys.database_principals mp ON drm.member_principal_id = mp.principal_id
WHERE 
    mp.name = 'appUser';
GO

PRINT '==============================================';
PRINT 'USUÁRIO appUser CONFIGURADO COM SUCESSO!';
PRINT '==============================================';
PRINT 'Login: appUser';
PRINT 'Senha: 1234@';
PRINT 'Permissões: db_owner, db_datareader, db_datawriter';
PRINT '==============================================';