-- Criacao do banco e da tabela TAREFAS (SQL Server)
-- PRIORIDADE: 0 Baixa, 1 Media, 2 Alta, 3 Urgente, 4 Critica
-- STATUS: 0 Pendente, 1 Em andamento, 2 Concluida
-- DATA_CONCLUSAO: preenchida pela API ao concluir tarefa; usada nas estatisticas (ultimos 7 dias)

IF DB_ID(N'prova') IS NULL
  CREATE DATABASE prova;
GO

USE prova;
GO

IF OBJECT_ID(N'dbo.tarefas', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.tarefas (
    ID              INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TAREFAS PRIMARY KEY,
    TITULO          NVARCHAR(200)   NOT NULL,
    DESCRICAO       NVARCHAR(1000)  NOT NULL,
    PRIORIDADE      INT             NOT NULL,
    STATUS          INT             NOT NULL,
    DATA_CRIACAO    DATETIME2       NOT NULL CONSTRAINT DF_TAREFAS_DATA_CRIACAO DEFAULT SYSDATETIME(),
    DATA_CONCLUSAO  DATETIME2       NULL
  );
END
GO
