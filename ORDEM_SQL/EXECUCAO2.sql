/********************************************************************************
 SCRIPT: TABELAS DE ASSUNTOS PARA BANCO "Biblioteca"
 Descrição: Cria tabelas de categorização de livros por assunto
 Pré-requisito: Banco "Biblioteca" deve existir
********************************************************************************/

PRINT 'Configurando tabelas de assuntos...';

-- Verifica se o banco existe
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Biblioteca')
BEGIN
    PRINT 'ERRO: Banco Biblioteca não encontrado!';
    PRINT 'Execute primeiro: SQL_biblioteca.sql';
    RETURN;
END

USE Biblioteca;
GO

-- =============================================================================
-- 1. VERIFICAÇÃO DA TABELA Livros (para foreign key)
-- =============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Livros')
BEGIN
    PRINT 'ERRO: Tabela Livros não encontrada!';
    PRINT 'Certifique-se de que SQL_biblioteca.sql foi executado.';
    RETURN;
END

-- =============================================================================
-- 2. CRIAÇÃO DA TABELA Assuntos
-- =============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Assuntos')
BEGIN
    CREATE TABLE Assuntos (
        AssuntoID INT IDENTITY(1,1) PRIMARY KEY,
        Assunto_Nome NVARCHAR(255) NOT NULL
    );
    PRINT 'Tabela Assuntos criada.';
END
ELSE
BEGIN
    PRINT 'Tabela Assuntos já existe.';
END
GO

-- =============================================================================
-- 3. CRIAÇÃO DA TABELA LivroAssunto
-- =============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LivroAssunto')
BEGIN
    CREATE TABLE LivroAssunto (
        ID_Livro INT NOT NULL,
        AssuntoID INT NOT NULL,
        PRIMARY KEY (ID_Livro, AssuntoID),
        FOREIGN KEY (ID_Livro) REFERENCES Livros(ID_Livro) ON DELETE CASCADE,
        FOREIGN KEY (AssuntoID) REFERENCES Assuntos(AssuntoID) ON DELETE CASCADE
    );
    PRINT 'Tabela LivroAssunto criada.';
END
ELSE
BEGIN
    PRINT 'Tabela LivroAssunto já existe.';
END
GO

-- =============================================================================
-- 4. INSERÇÃO DE ASSUNTOS (apenas se tabela estiver vazia)
-- =============================================================================
PRINT 'Verificando dados de assuntos...';

IF NOT EXISTS (SELECT TOP 1 * FROM Assuntos)
BEGIN
    PRINT 'Inserindo categorias de assuntos...';
    
    INSERT INTO Assuntos (Assunto_Nome) VALUES 
    -- Educativo
    ('Matemática'), ('Português'), ('Ciências'), ('História'), ('Geografia'),
    ('Filosofia'), ('Educação Física'), ('Arte'), ('Tecnologia'),
    
    -- Ficção
    ('Fantasia'), ('Ficção científica'), ('Suspense'), ('Terror'), ('Romance'),
    ('Distopia'), ('Viagem no tempo'), ('Super-heróis'), ('Mistério policial'),
    
    -- Biografias
    ('Líderes políticos'), ('Artistas e músicos'), ('Cientistas e inventores'),
    ('Atletas'), ('Filantropos'), ('Escritores e poetas'),
    
    -- Autoajuda
    ('Desenvolvimento pessoal'), ('Carreira e negócios'), ('Relacionamentos'),
    ('Saúde mental'), ('Espiritualidade'), ('Motivação');
    
    -- Continua com outras categorias...
    INSERT INTO Assuntos (Assunto_Nome) VALUES
    ('História antiga'), ('Idade Média'), ('História moderna'),
    ('História contemporânea'), ('Guerras mundiais'), ('História cultural'),
    ('Física'), ('Biologia'), ('Química'), ('Astronomia'),
    ('Tecnologia e inovação'), ('Meio ambiente'),
    ('Contos de fadas'), ('Histórias com animais'), ('Aventuras mágicas'),
    ('Alta fantasia'), ('Fantasia urbana'), ('Fantasia sombria'),
    ('Romance histórico'), ('Romance contemporâneo'), ('Romance de época'),
    ('Thriller psicológico'), ('Suspense policial'), ('Suspense jurídico'),
    ('Terror psicológico'), ('Horror cósmico'), ('Terror sobrenatural'),
    ('Aventuras marítimas'), ('Aventuras arqueológicas'), ('Sobrevivência na natureza'),
    ('Coming of age'), ('Aventura escolar'), ('Ficção de superação'),
    ('Comédia absurda'), ('Paródias'), ('Comédia romântica'),
    ('Histórias de superação'), ('Bastidores de eventos esportivos'), ('Biografias de atletas'),
    ('Programação para iniciantes'), ('Inteligência artificial'), ('Blockchain'),
    ('True crime'), ('Ficção de detetive'), ('Histórias de mafiosos'),
    ('Economia'), ('Educação Financeira'), ('Finanças'), ('Sustentabilidade');
    
    PRINT CAST(@@ROWCOUNT AS VARCHAR) + ' assuntos inseridos.';
END
ELSE
BEGIN
    DECLARE @TotalAssuntos INT;
    SELECT @TotalAssuntos = COUNT(*) FROM Assuntos;
    PRINT 'Tabela Assuntos já contém ' + CAST(@TotalAssuntos AS VARCHAR) + ' registros.';
END
GO

-- =============================================================================
-- 5. RELATÓRIO FINAL
-- =============================================================================
PRINT '==============================================';
PRINT 'TABELAS DE ASSUNTOS CONFIGURADAS!';
PRINT '==============================================';
PRINT 'Tabelas disponíveis:';
PRINT '  - Assuntos (categorização)';
PRINT '  - LivroAssunto (relação N:N)';
PRINT '';
PRINT 'Para associar livros a assuntos:';
PRINT 'INSERT INTO LivroAssunto (ID_Livro, AssuntoID) VALUES (1, 1);';
PRINT '==============================================';