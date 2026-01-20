/********************************************************************************
 SCRIPT: BANCO DE DADOS "Biblioteca_Senai"
 Descrição: Cria banco secundário para controle de frequência
 Nota: Banco independente do principal "Biblioteca"
********************************************************************************/

-- =============================================================================
-- 1. CRIAÇÃO DO BANCO DE DADOS
-- =============================================================================
PRINT 'Criando banco de dados Biblioteca_Senai...';

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Biblioteca_Senai')
BEGIN
    CREATE DATABASE Biblioteca_Senai;
    PRINT 'Banco Biblioteca_Senai criado com sucesso.';
END
ELSE
BEGIN
    PRINT 'Banco Biblioteca_Senai já existe. Usando banco existente...';
END
GO

-- =============================================================================
-- 2. CONFIGURAÇÃO DO BANCO
-- =============================================================================
USE Biblioteca_Senai;
GO

PRINT 'Configurando tabela frequencia...';

-- =============================================================================
-- 3. CRIAÇÃO DA TABELA DE FREQUÊNCIA (corrigida)
-- =============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'frequencia')
BEGIN
    -- Cria tabela completa de uma vez
    CREATE TABLE frequencia (
        ID_User INT IDENTITY(1,1) PRIMARY KEY,
        NomeCompleto VARCHAR(120),
        Ident_User VARCHAR(100),
        DataHoraMomento DATETIME DEFAULT GETDATE()
    );
    PRINT 'Tabela frequencia criada com estrutura completa.';
END
ELSE
BEGIN
    PRINT 'Tabela frequencia já existe. Verificando estrutura...';
    
    -- Adiciona colunas faltantes se necessário
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('frequencia') AND name = 'DataHoraMomento')
    BEGIN
        ALTER TABLE frequencia ADD DataHoraMomento DATETIME DEFAULT GETDATE();
        PRINT 'Coluna DataHoraMomento adicionada.';
    END
END
GO

-- =============================================================================
-- 4. LIMPEZA DE DADOS DE TESTE (APENAS SE NECESSÁRIO)
-- =============================================================================
PRINT 'Limpando dados de teste (ID_User = 1)...';

-- Apenas deleta se existir (evita erro)
IF EXISTS (SELECT * FROM frequencia WHERE ID_User = 1)
BEGIN
    DELETE FROM frequencia WHERE ID_User = 1;
    PRINT 'Registro de teste removido.';
END
ELSE
BEGIN
    PRINT 'Nenhum registro com ID_User = 1 encontrado.';
END
GO

-- =============================================================================
-- 5. VERIFICAÇÃO FINAL
-- =============================================================================
PRINT 'Verificação final da tabela:';

-- Apenas mostra estrutura, não interrompe execução
SELECT 
    'Estrutura da tabela frequencia:' AS Informacao,
    COUNT(*) AS Total_Registros
FROM frequencia;
GO

PRINT '==============================================';
PRINT 'BANCO "Biblioteca_Senai" CONFIGURADO!';
PRINT '==============================================';
PRINT 'Próximos passos:';
PRINT '1. Execute SQL_user_biblioteca_senai.sql para usuários';
PRINT '2. A tabela frequencia está pronta para uso';
PRINT '==============================================';