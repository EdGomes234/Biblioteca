/********************************************************************************
 SCRIPT DE CRIAÇÃO DO BANCO DE DADOS "Biblioteca"
 Autor: [Seu Nome]
 Data: [Data]
 Descrição: Cria estrutura completa do sistema de biblioteca
********************************************************************************/

-- =============================================================================
-- 1. CRIAÇÃO DO BANCO DE DADOS
-- =============================================================================
PRINT 'Criando banco de dados Biblioteca...';

-- Verifica se o banco já existe
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Biblioteca')
BEGIN
    CREATE DATABASE Biblioteca;
    PRINT 'Banco Biblioteca criado com sucesso.';
END
ELSE
BEGIN
    PRINT 'Banco Biblioteca já existe. Usando banco existente...';
END
GO

-- MUDA PARA O BANCO Biblioteca
USE Biblioteca;
GO

-- =============================================================================
-- 2. CRIAÇÃO DAS TABELAS PRINCIPAIS
-- =============================================================================
PRINT 'Criando tabelas...';

-- Tabela de usuários do sistema
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Usuarios')
BEGIN
    CREATE TABLE Usuarios (
        ID_Usuario INT IDENTITY(1,1) PRIMARY KEY,
        NomeUsuario VARCHAR(100),
        Turma VARCHAR(100),
        Telefone VARCHAR(11),
        Periodo VARCHAR(20)
    );
    PRINT 'Tabela Usuarios criada.';
END
ELSE
    PRINT 'Tabela Usuarios já existe.';
GO

-- Tabela de livros do acervo
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Livros')
BEGIN
    CREATE TABLE Livros (
        ID_Livro INT IDENTITY(1,1) PRIMARY KEY,
        Titulo VARCHAR(100),
        Autor VARCHAR(100),
        Editora VARCHAR(100),
        Edicao VARCHAR(100),
        Volume INT,
        Quantidade INT,
        AnoPublicacao INT,
        Imagem NVARCHAR(400) NULL
    );
    PRINT 'Tabela Livros criada.';
END
ELSE
    PRINT 'Tabela Livros já existe.';
GO
 
-- Tabela de registros de empréstimos
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Emprestimo')
BEGIN
    CREATE TABLE Emprestimo (
        ID_Emprestimo INT IDENTITY(1,1) PRIMARY KEY,
        ID_Usuario INT REFERENCES Usuarios(ID_Usuario),
        ID_Livro INT REFERENCES Livros(ID_Livro),
        DataEmprestimo DATE,
        DataDevolucao DATE,
        [Status] VARCHAR(50),
        Processado BIT DEFAULT 0
    );
    PRINT 'Tabela Emprestimo criada.';
END
ELSE
    PRINT 'Tabela Emprestimo já existe.';
GO

-- Tabela de frequência
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'frequencia')
BEGIN
    CREATE TABLE frequencia (
        ID_User INT IDENTITY(1,1) PRIMARY KEY,
        NomeCompleto VARCHAR(120),
        Ident_User VARCHAR(100),
        DataHoraMomento DATETIME DEFAULT GETDATE()
    );
    PRINT 'Tabela frequencia criada.';
END
ELSE
    PRINT 'Tabela frequencia já existe.';
GO

-- =============================================================================
-- 3. INSERÇÃO DE DADOS BÁSICOS (apenas se a tabela estiver vazia)
-- =============================================================================
PRINT 'Verificando dados iniciais...';

IF NOT EXISTS (SELECT TOP 1 * FROM Livros)
BEGIN
    PRINT 'Inserindo dados iniciais...';
    INSERT INTO Livros (Titulo, Autor, Editora, Edicao, Volume, Quantidade, AnoPublicacao, Imagem) 
    VALUES
    ('Introdução à Programação', 'Alice Souza', 'TechBooks', '1ª', 1, 5, 2022, 'https://marketplace.canva.com/EAE4oJOnMh0/1/0/1003w/canva-capa-de-livro-de-suspense-O7z4yw4a5k8.jpg'),
    ('Estruturas de Dados', 'Carlos Silva', 'EducaBook', '2ª', 1, 3, 2021, 'https://marketplace.canva.com/EAE4oJOnMh0/1/0/1003w/canva-capa-de-livro-de-suspense-O7z4yw4a5k8.jpg'),
    ('Banco de Dados SQL', 'Maria Costa', 'Informatics', '3ª', 1, 4, 2020, 'https://marketplace.canva.com/EAE4oJOnMh0/1/0/1003w/canva-capa-de-livro-de-suspense-O7z4yw4a5k8.jpg'),
    ('Algoritmos Avançados', 'Roberto Lima', 'TechPrint', '1ª', 1, 2, 2023, 'https://marketplace.canva.com/EAE4oJOnMh0/1/0/1003w/canva-capa-de-livro-de-suspense-O7z4yw4a5k8.jpg'),
    ('JavaScript Essencial', 'Ana Melo', 'DevBooks', '2ª', 1, 6, 2019, 'https://marketplace.canva.com/EAE4oJOnMh0/1/0/1003w/canva-capa-de-livro-de-suspense-O7z4yw4a5k8.jpg');
    PRINT '5 livros inseridos.';
END
ELSE
    PRINT 'Tabela Livros já contém dados.';
GO

-- =============================================================================
-- 4. USUÁRIO DO BANCO (verifica se já existe)
-- =============================================================================
PRINT 'Verificando usuário appUser1...';

-- Tenta adicionar o usuário à role (se já existir)
BEGIN TRY
    ALTER ROLE db_owner ADD MEMBER appUser1;
    PRINT 'Usuário appUser1 já existe e foi adicionado à role db_owner.';
END TRY
BEGIN CATCH
    PRINT 'Usuário appUser1 não encontrado ou já está na role.';
END CATCH
GO

-- =============================================================================
-- 5. CRIAÇÃO DA VIEW (com GO antes para ser primeiro no batch)
-- =============================================================================
PRINT 'Criando/Atualizando view vw_Emprestimo_Completo...';
GO

IF OBJECT_ID('vw_Emprestimo_Completo', 'V') IS NOT NULL
    DROP VIEW vw_Emprestimo_Completo;
GO

CREATE VIEW vw_Emprestimo_Completo AS
SELECT
    U.ID_Usuario,
    U.NomeUsuario, 
    U.Turma,
    U.Periodo,
    U.Telefone,
    L.ID_Livro,
    L.Titulo,
    L.Autor,
    L.Editora,
    L.Edicao,
    L.Volume,
    L.AnoPublicacao,
    L.Imagem,
    E.ID_Emprestimo,
    E.DataEmprestimo,
    E.DataDevolucao,
    E.Status
FROM Usuarios U
INNER JOIN Emprestimo E ON U.ID_Usuario = E.ID_Usuario
INNER JOIN Livros L ON E.ID_Livro = L.ID_Livro;
GO

PRINT 'View vw_Emprestimo_Completo criada.';
GO

-- =============================================================================
-- 6. STORED PROCEDURES (cada um em batch separado com GO)
-- =============================================================================
PRINT 'Criando procedure AtualizarStatusEmprestimos...';
GO

IF OBJECT_ID('AtualizarStatusEmprestimos', 'P') IS NOT NULL
    DROP PROCEDURE AtualizarStatusEmprestimos;
GO

CREATE PROCEDURE AtualizarStatusEmprestimos
AS
BEGIN
    UPDATE Emprestimo
    SET [Status] = 'Atrasado'
    WHERE DataDevolucao < GETDATE() AND [Status] = 'Em Aberto';

    UPDATE Emprestimo
    SET [Status] = 'Perda'
    WHERE DataDevolucao < DATEADD(DAY, -30, GETDATE()) AND [Status] = 'Atrasado';
END;
GO

PRINT 'Procedure AtualizarStatusEmprestimos criada.';
GO

-- Procedure AjustarQuantidadeLivros
PRINT 'Criando procedure AjustarQuantidadeLivros...';
GO

IF OBJECT_ID('AjustarQuantidadeLivros', 'P') IS NOT NULL
    DROP PROCEDURE AjustarQuantidadeLivros;
GO

CREATE PROCEDURE AjustarQuantidadeLivros
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ID_Livro INT, @Quantidade INT;

    DECLARE livro_cursor CURSOR FOR
    SELECT ID_Livro FROM Livros;

    OPEN livro_cursor;
    FETCH NEXT FROM livro_cursor INTO @ID_Livro;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Quantidade = (SELECT Quantidade FROM Livros WHERE ID_Livro = @ID_Livro);
        
        SET @Quantidade = @Quantidade - (
            SELECT COUNT(*) 
            FROM Emprestimo
            WHERE ID_Livro = @ID_Livro
            AND Status IN ('Em Aberto', 'Atrasado', 'Perda')
            AND Processado = 0
        );

        IF @Quantidade < 0
            SET @Quantidade = 0;

        UPDATE Livros
        SET Quantidade = @Quantidade
        WHERE ID_Livro = @ID_Livro;

        UPDATE Emprestimo
        SET Processado = 1
        WHERE ID_Livro = @ID_Livro AND Processado = 0;

        FETCH NEXT FROM livro_cursor INTO @ID_Livro;
    END

    CLOSE livro_cursor;
    DEALLOCATE livro_cursor;
END;
GO

PRINT 'Procedure AjustarQuantidadeLivros criada.';
GO

-- =============================================================================
-- 7. TRIGGERS (cada um em batch separado)
-- =============================================================================
PRINT 'Criando trigger AtualizarQuantidadeAoEmprestar...';
GO

IF OBJECT_ID('AtualizarQuantidadeAoEmprestar', 'TR') IS NOT NULL
    DROP TRIGGER AtualizarQuantidadeAoEmprestar;
GO

CREATE TRIGGER AtualizarQuantidadeAoEmprestar
ON Emprestimo
AFTER INSERT
AS
BEGIN
    UPDATE L
    SET Quantidade = Quantidade - 1
    FROM Livros L
    INNER JOIN Inserted I ON L.ID_Livro = I.ID_Livro
    WHERE L.Quantidade > 0;

    IF EXISTS (
        SELECT 1
        FROM Livros L
        INNER JOIN Inserted I ON L.ID_Livro = I.ID_Livro
        WHERE L.Quantidade <= 0
    )
    BEGIN
        PRINT 'Aviso: Estoque de algum livro está esgotado!';
    END
END;
GO

PRINT 'Trigger AtualizarQuantidadeAoEmprestar criado.';
GO

-- Segundo trigger
PRINT 'Criando trigger AtualizarQuantidadeAoDevolver...';
GO

IF OBJECT_ID('AtualizarQuantidadeAoDevolver', 'TR') IS NOT NULL
    DROP TRIGGER AtualizarQuantidadeAoDevolver;
GO

CREATE TRIGGER AtualizarQuantidadeAoDevolver
ON Emprestimo
AFTER UPDATE
AS
BEGIN
    UPDATE L
    SET Quantidade = Quantidade + 1
    FROM Livros L
    INNER JOIN Inserted I ON L.ID_Livro = I.ID_Livro
    INNER JOIN Deleted D ON I.ID_Emprestimo = D.ID_Emprestimo
    WHERE I.Status = 'Devolvido' AND D.Status != 'Devolvido';
END;
GO

PRINT 'Trigger AtualizarQuantidadeAoDevolver criado.';
GO

-- =============================================================================
-- 8. CONSTRAINTS
-- =============================================================================
PRINT 'Adicionando constraint de quantidade positiva...';

IF NOT EXISTS (
    SELECT * FROM sys.check_constraints 
    WHERE name = 'CK_Quantidade_Positive'
)
BEGIN
    ALTER TABLE Livros
    ADD CONSTRAINT CK_Quantidade_Positive
    CHECK (Quantidade >= 0);
    PRINT 'Constraint CK_Quantidade_Positive criada.';
END
ELSE
    PRINT 'Constraint CK_Quantidade_Positive já existe.';
GO

-- =============================================================================
-- 9. RELATÓRIO FINAL
-- =============================================================================
PRINT '==============================================';
PRINT 'BANCO DE DADOS "Biblioteca" CONFIGURADO!';
PRINT '==============================================';
PRINT 'Tabelas verificadas/criadas:';
PRINT '  - Usuarios';
PRINT '  - Livros';
PRINT '  - Emprestimo';
PRINT '  - frequencia';
PRINT '';
PRINT 'Objetos de programação criados:';
PRINT '  - View: vw_Emprestimo_Completo';
PRINT '  - Procedures: AtualizarStatusEmprestimos, AjustarQuantidadeLivros';
PRINT '  - Triggers: AtualizarQuantidadeAoEmprestar, AtualizarQuantidadeAoDevolver';
PRINT '  - Constraint: CK_Quantidade_Positive';
PRINT '';
PRINT 'Usuário: appUser1 mantido (se existia)';
PRINT '==============================================';
PRINT '';
PRINT 'PRÓXIMOS PASSOS:';
PRINT '1. Execute SQL_biblioteca_assunto.sql para tabelas de assuntos';
PRINT '2. Execute SQL_biblioteca_senai.sql para banco secundário';
PRINT '3. Execute SQL_user_biblioteca_senai.sql para usuários do segundo banco';
PRINT '==============================================';
