USE Biblioteca

CREATE TABLE Assuntos (
    AssuntoID INT IDENTITY(1,1) PRIMARY KEY,
    Assunto_Nome NVARCHAR(255) NOT NULL
);
GO

--Cria��o da Tabela de rela��o entre livros e assuntos
CREATE TABLE LivroAssunto (
    ID_Livro INT NOT NULL,
    AssuntoID INT NOT NULL,
    PRIMARY KEY (ID_Livro, AssuntoID),
    FOREIGN KEY (ID_Livro) REFERENCES Livros(ID_Livro) ON DELETE CASCADE,
    FOREIGN KEY (AssuntoID) REFERENCES Assuntos(AssuntoID) ON DELETE CASCADE
);
GO

SELECT *
FROM Assuntos

--Inser��o de Dados

-- Inser��o dos Assuntos
INSERT INTO Assuntos (Assunto_Nome)
VALUES 

-- Educativo
('Matem�tica'),
('Portugu�s'),
('Ci�ncias'),
('Hist�ria'),
('Geografia'),
('Filosofia'),
('Educa��o F�sica'),
('Arte'),
('Tecnologia'),

-- Fic��o
('Fantasia'),
('Fic��o cient�fica'),
('Suspense'),
('Terror'),
('Romance'),
('Distopia'),
('Viagem no tempo'),
('Super-her�is'),
('Mist�rio policial'),

-- Biografias
('L�deres pol�ticos'),
('Artistas e m�sicos'),
('Cientistas e inventores'),
('Atletas'),
('Filantropos'),
('Escritores e poetas'),

-- Autoajuda
('Desenvolvimento pessoal'),
('Carreira e neg�cios'),
('Relacionamentos'),
('Sa�de mental'),
('Espiritualidade'),
('Motiva��o'),

-- Hist�ria
('Hist�ria antiga'),
('Idade M�dia'),
('Hist�ria moderna'),
('Hist�ria contempor�nea'),
('Guerras mundiais'),
('Hist�ria cultural'),

-- Cient�fico
('F�sica'),
('Biologia'),
('Qu�mica'),
('Astronomia'),
('Tecnologia e inova��o'),
('Meio ambiente'),

-- Infantil
('Contos de fadas'),
('Hist�rias com animais'),
('Aventuras m�gicas'),
('Hist�rias educativas'),
('Hist�rias para dormir'),
('Hist�rias em quadrinhos'),

-- Fantasia
('Alta fantasia'),
('Fantasia urbana'),
('Fantasia sombria'),
('Fantasia hist�rica'),
('Fantasia juvenil'),
('Fantasia mitol�gica'),

-- Romance
('Romance hist�rico'),
('Romance contempor�neo'),
('Romance de �poca'),
('Romance sobrenatural'),
('Romance LGBTQIA+'),
('Romance adolescente'),

-- Suspense
('Thriller psicol�gico'),
('Suspense policial'),
('Suspense jur�dico'),
('Suspense tecnol�gico'),
('Suspense de espionagem'),
('Suspense m�dico'),

-- Terror
('Terror psicol�gico'),
('Horror c�smico'),
('Terror sobrenatural'),
('Terror gore'),
('Terror de sobreviv�ncia'),
('Terror de lendas urbanas'),

-- Aventura
('Aventuras mar�timas'),
('Aventuras arqueol�gicas'),
('Sobreviv�ncia na natureza'),
('Explora��o espacial'),
('Aventuras urbanas'),
('Aventuras em reinos desconhecidos'),

-- Hist�ria Alternativa
('E se hist�ricos'),
('Fic��o de realidades paralelas'),
('Eventos divergentes'),
('Hist�ria com tecnologia moderna'),
('Hist�ria com magia integrada'),

-- Juvenil (YA)
('Coming of age'),
('Aventura escolar'),
('Fic��o de supera��o'),
('Romance adolescente'),
('Fantasia juvenil'),
('Mist�rio e investiga��o juvenil'),

-- Humor
('Com�dia absurda'),
('Par�dias'),
('Com�dia rom�ntica'),
('Com�dia do cotidiano'),
('Humor negro'),
('Humor sat�rico'),

-- Esportes
('Hist�rias de supera��o'),
('Bastidores de eventos esportivos'),
('Biografias de atletas'),
('A evolu��o de esportes'),
('Esportes radicais'),
('Fic��o esportiva'),

-- Tecnologia
('Programa��o para iniciantes'),
('Intelig�ncia artificial'),
('Blockchain'),
('Hist�ria da tecnologia'),
('�tica na tecnologia'),
('Futuro da inova��o'),

-- Criminal
('True crime'),
('Fic��o de detetive'),
('Hist�rias de mafiosos'),
('Mist�rios n�o resolvidos'),
('Casos famosos'),
('Crimes cibern�ticos');
GO

INSERT INTO Assuntos (Assunto_Nome)
VALUES

('Economia'),
('Educa��o Financeira'),
('Finan�as'),
('Sustentabilidade')