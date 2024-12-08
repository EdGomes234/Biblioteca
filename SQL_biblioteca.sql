CREATE DATABASE Biblioteca
GO

USE Biblioteca
GO

CREATE TABLE Usuarios (
	ID_Usuario INT IDENTITY PRIMARY KEY,
	NomeUsuario VARCHAR(100),
	Turma VARCHAR(100),
	Telefone VARCHAR(11),
	Periodo VARCHAR(20)
)
GO

CREATE TABLE Livros (
	ID_Livro INT IDENTITY PRIMARY KEY,
	Titulo VARCHAR(100),
	Autor VARCHAR(100),
	Editora VARCHAR(100),
	Edicao VARCHAR(100),
	Volume INT,
	Quantidade INT,
	AnoPublicacao INT
)

ALTER TABLE Livros
ADD Imagem NVARCHAR(400)

UPDATE Livros
SET Imagem = 'https://marketplace.canva.com/EAE4oJOnMh0/1/0/1003w/canva-capa-de-livro-de-suspense-O7z4yw4a5k8.jpg'
WHERE ID_Livro = 1;

EXEC sp_rename 'Livros.AnoPublica��o', 'AnoPublicacao', 'COLUMN';

CREATE TABLE Emprestimo (
	ID_Emprestimo INT IDENTITY PRIMARY KEY,
	ID_Usuario INT REFERENCES Usuarios(ID_Usuario),
	ID_Livro INT REFERENCES Livros(ID_Livro),
	DataEmprestimo DATE,
	DataDevolucao DATE,
	[Status] VARCHAR(50)
)
GO

ALTER TABLE Emprestimo
ADD [Status] VARCHAR(50)

USE Biblioteca;
GO

CREATE TABLE frequencia (
	ID_User INT IDENTITY PRIMARY KEY,
	NomeCompleto VARCHAR(120),
	Ident_User VARCHAR(100)
)
GO

DELETE FROM frequencia
WHERE ID_User = 1;

ALTER TABLE frequencia
ADD DataHoraMomento DATETIME DEFAULT GETDATE();

SELECT *
FROM frequencia


INSERT INTO Livros (Titulo, Autor, Editora, Edicao, Volume, Quantidade, AnoPublicacao) VALUES
('Introdu��o � Programa��o', 'Alice Souza', 'TechBooks', '1�', 1, 5, 2022),
('Estruturas de Dados', 'Carlos Silva', 'EducaBook', '2�', 1, 3, 2021),
('Banco de Dados SQL', 'Maria Costa', 'Informatics', '3�', 1, 4, 2020),
('Algoritmos Avan�ados', 'Roberto Lima', 'TechPrint', '1�', 1, 2, 2023),
('JavaScript Essencial', 'Ana Melo', 'DevBooks', '2�', 1, 6, 2019);

CREATE LOGIN appUser1 
WITH PASSWORD = '12345';
GO

CREATE USER appUser1
FOR LOGIN appUser1;
GO

ALTER ROLE db_owner ADD MEMBER appUser1;
GO

SELECT *
FROM Emprestimo

SELECT *
FROM Usuarios

SELECT *
FROM Livros

DELETE FROM Livros
WHERE ID_Livro IN (29);

 

CREATE VIEW vw_Emprestimo_Completo AS
SELECT
	Usuarios.ID_Usuario,
	NomeUsuario, 
	Turma,
	Periodo,
	Telefone,
	Livros.ID_Livro,
	Titulo,
	Autor,
	Editora,
	Edicao,
	Volume,
	AnoPublicacao,
	Emprestimo.ID_Emprestimo,
	DataEmprestimo,
	DataDevolucao,
	Status
FROM Usuarios

INNER JOIN 
	Emprestimo
ON Usuarios.ID_Usuario = Emprestimo.ID_Usuario

INNER JOIN
	Livros
ON Emprestimo.ID_Livro = Livros.ID_Livro

SELECT *
FROM vw_Emprestimo_Completo

DROP VIEW vw_Emprestimo_Completo

CREATE PROCEDURE AtualizarStatusEmprestimos
AS
BEGIN
    -- Atualiza para "Atrasado" se a data de devolu��o for passada e o status ainda estiver "Em Aberto"
    UPDATE Emprestimo
    SET [Status] = 'Atrasado'
    WHERE DataDevolucao < GETDATE() AND [Status] = 'Em Aberto';

    -- Atualiza para "Perda" se o empr�stimo j� est� atrasado por mais de 30 dias
    UPDATE Emprestimo
    SET [Status] = 'Perda'
    WHERE DataDevolucao < DATEADD(DAY, -30, GETDATE()) AND [Status] = 'Atrasado';
END;
GO

EXEC AtualizarStatusEmprestimos;

SELECT name 
FROM sys.procedures
WHERE name = 'AtualizarStatusEmprestimos';


-- Trigger para reduzir a quantidade ao registrar um empr�stimo
CREATE TRIGGER AtualizarQuantidadeAoEmprestar
ON Emprestimo
AFTER INSERT
AS
BEGIN
    -- Atualizar a quantidade de livros ap�s um novo empr�stimo ser registrado
    UPDATE Livros
    SET Quantidade = Quantidade - 1
    FROM Livros
    INNER JOIN Inserted ON Livros.ID_Livro = Inserted.ID_Livro
    WHERE Livros.Quantidade > 0; -- Garantir que n�o fique negativo

    -- Lidar com o caso de estoque insuficiente
    IF EXISTS (
        SELECT 1
        FROM Livros
        INNER JOIN Inserted ON Livros.ID_Livro = Inserted.ID_Livro
        WHERE Livros.Quantidade <= 0
    )
    BEGIN
        PRINT 'Aviso: Estoque de algum livro est� esgotado!';
    END
END;
GO


-- Trigger para aumentar a quantidade ao registrar uma devolu��o
CREATE TRIGGER AtualizarQuantidadeAoDevolver
ON Emprestimo
AFTER UPDATE
AS
BEGIN
    -- Atualizar a quantidade de livros quando o status muda para "Devolvido"
    UPDATE Livros
    SET Quantidade = Quantidade + 1
    FROM Livros
    INNER JOIN Inserted ON Livros.ID_Livro = Inserted.ID_Livro
    INNER JOIN Deleted ON Inserted.ID_Emprestimo = Deleted.ID_Emprestimo
    WHERE Inserted.Status = 'Devolvido' 
      AND Deleted.Status != 'Devolvido';
END;
GO

-- o Inserted � usado dentro de triggers para armazenar os dados que foram inseridos, atualizados ou exclu�dos em uma opera��o.
-- o Inserted cont�m os registros novos que est�o sendo adicionados ou atualizados na tabela-alvo.
-- Na trigger AtualizarQuantidadeAoEmprestar, estamos reagindo a uma inser��o na tabela Emprestimo. A tabela l�gica Inserted 
-- cont�m os dados dessa nova linha que est� sendo inserida.

-- Explica��o desse if:
    --IF EXISTS (
    --    SELECT 1
    --    FROM Livros
    --    INNER JOIN Inserted ON Livros.ID_Livro = Inserted.ID_Livro
    --    WHERE Livros.Quantidade <= 0
    --)
    --BEGIN
    --    PRINT 'Aviso: Estoque de algum livro est� esgotado!';
    --END
--Quando tentamos registrar um empr�stimo:
-- O IF EXISTS consulta os livros envolvidos no empr�stimo (atrav�s do JOIN com Inserted).
-- O 'SELECT 1' n�o retorna dados espec�ficos; ele apenas verifica a exist�ncia de uma linha que satisfa�a as condi��es dadas no WHERE.
-- Esse SELECT 1 � eficiente porque o banco de dados para de processar assim que encontra a primeira ocorr�ncia.
-- Esse IF verifica se algum deles tem a Quantidade menor ou igual a zero.
-- Se a condi��o for verdadeira (ou seja, o estoque est� esgotado):
-- O trigger impede a opera��o (dependendo da l�gica definida) ou envia uma mensagem informando que o livro est� esgotado.


ALTER TABLE Emprestimo ADD Processado BIT DEFAULT 0;
-- Criando a coluna Processado para registrar as quantidades de emprestimos que n�o foram considerados.
-- o DEFAULT 0 serve para inserir o n�mero 0 por padr�o at� que seja inserido outro dado.


-- Para corrigir a quantidade sem duplica��es ou inconist�ncias, fazemos os seguintes passos: 
-- Passo 1:
UPDATE Emprestimo
SET Processado = 0
-- Esse update acima coloca valor 0 em todas as linhas existentes da coluna processado

-- Passo 2:
UPDATE Livros
SET Quantidade = CASE
    WHEN Titulo = 'Introdu��o � Programa��o' THEN 5
    WHEN Titulo = 'Estruturas de Dados' THEN 3
    WHEN Titulo = 'Banco de Dados SQL' THEN 4
    WHEN Titulo = 'Algoritmos Avan�ados' THEN 2
    WHEN Titulo = 'JavaScript Essencial' THEN 6
    ELSE Quantidade
END
WHERE Titulo IN ('Introdu��o � Programa��o', 'Estruturas de Dados', 'Banco de Dados SQL', 'Algoritmos Avan�ados', 'JavaScript Essencial');
-- Esse update acima reinicia a quantidade para o seu valor inicial, assim, testamos a procedure pra ver se ela corrigiu os valores.

--UPDATE Emprestimo
--SET Processado = 0
--WHERE ID_Livro = 4 AND Status IN ('Em Aberto', 'Atrasado', 'Perda');
-- Esse update acima s� zerava a coluna Processado do ID_Livro = 4, pois era a linha que estava dando mais erro.

--ALTER TABLE Livros
--DROP CONSTRAINT CK_Quantidade_Positive;
-- Guardando c�digo para apagar restri��o caso seja necess�rio

ALTER TABLE Livros
ADD CONSTRAINT CK_Quantidade_Positive
CHECK (Quantidade >= 0);
-- C�digo para cria��o da restri��o que impede valores negativos na coluna Quantidade da tabela Livros.

-- Passo 3:
-- Procedure para corrigir a coluna Quantidade baseada nos emprestimos j� existentes:
ALTER PROCEDURE AjustarQuantidadeLivros
AS
BEGIN
    SET NOCOUNT ON;

    -- Atualiza a quantidade de livros para cada livro na tabela Livros
    DECLARE @ID_Livro INT, @Quantidade INT;

    -- Para cada livro, ajustamos a quantidade de acordo com os empr�stimos e devolu��es
    DECLARE livro_cursor CURSOR FOR
    SELECT ID_Livro
    FROM Livros;

    OPEN livro_cursor;
    FETCH NEXT FROM livro_cursor INTO @ID_Livro;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Inicializa a quantidade do livro
        SET @Quantidade = (SELECT Quantidade FROM Livros WHERE ID_Livro = @ID_Livro);

        -- Subtrai 1 para cada empr�stimo em aberto, atrasado ou em perda
        SET @Quantidade = @Quantidade - (
            SELECT COUNT(*) 
            FROM Emprestimo
            WHERE ID_Livro = @ID_Livro
            AND Status IN ('Em Aberto', 'Atrasado', 'Perda')
            AND Processado = 0
        );

        -- Atualiza a quantidade no estoque, sem ultrapassar a quantidade inicial
        IF @Quantidade < 0
        BEGIN
            SET @Quantidade = 0; -- N�o pode ter quantidade negativa
        END

        UPDATE Livros
        SET Quantidade = @Quantidade
        WHERE ID_Livro = @ID_Livro;

        -- Marca os empr�stimos como processados para n�o fazer a mesma atualiza��o de novo
        UPDATE Emprestimo
        SET Processado = 1
        WHERE ID_Livro = @ID_Livro
        AND Processado = 0;

        FETCH NEXT FROM livro_cursor INTO @ID_Livro;
    END

    CLOSE livro_cursor;
    DEALLOCATE livro_cursor;
END;
GO


-- Passo 4: Final
EXEC AjustarQuantidadeLivros;
-- Depois � s� verificar se os valores das quantidades fazem sentido em rela��o ao Status.

SELECT *
FROM Emprestimo

SELECT *
FROM Livros

SELECT *
FROM Usuarios

SELECT Quantidade
FROM Livros
WHERE ID_Livro = 4;

--DELETE FROM Emprestimo
--WHERE ID_Emprestimo = 10;



