# API Horse + cliente VCL

Projeto de **serviço REST em Delphi (Horse)** com **SQL Server** e **aplicação VCL** que consome apenas a API.

## Requisitos

- Delphi (RAD Studio) com suporte a **Horse** (submódulo ou pasta `ProvaAPI/modules/horse`).
- **SQL Server** acessível pela máquina em que a API roda.

## Banco de dados

1. Execute o script [`prova_base_tabela.sql`](prova_base_tabela.sql) no SQL Server (cria o banco `prova` e a tabela `tarefas`, se ainda não existirem).
2. Ajuste a *connection string* em `ProvaAPI/src/Utils/uConstantes.pas` (`DB_CONNECTION_STRING`) se servidor, instância ou autenticação forem diferentes.

## Configuração da API (`ProvaAPI`)

| Constante | Descrição |
|-----------|-----------|
| `API_PORT` | Porta HTTP (padrão `9000`). |
| `API_KEY_HEADER` / `API_KEY_VALUE` | Cabeçalho `X-API-KEY` esperado em todas as requisições. |

**Ordem de execução:** subir o SQL Server, compilar e executar `ProvaAPI.dpr` e, em seguida, o cliente VCL.

### Endpoints (todos exigem o cabeçalho `X-API-KEY`)

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/tarefas` | Lista todas as tarefas. |
| POST | `/tarefas` | Corpo JSON: `titulo`, `descricao`, `prioridade` (inteiro). Campo opcional `status` (0..2); se omitido, usa Pendente. Se `status` for Concluída, grava `DATA_CONCLUSAO`. |
| PUT | `/tarefas/:id/status` | Corpo JSON: `status` (**número**: 0 = Pendente, 1 = Em andamento, 2 = Concluída). |
| DELETE | `/tarefas/:id` | Remove por `id`. |
| GET | `/tarefas/estatisticas` | Total de tarefas, média de prioridade das pendentes e concluídas nos últimos 7 dias. |

Respostas de erro seguem o formato `{"error":"mensagem"}`, com HTTP 400, 401, 404, 422 ou 500, conforme o caso.

### Tabela `TAREFAS` (SQL Server)

| Coluna | Tipo | Observação |
|--------|------|------------|
| `ID` | INT IDENTITY PK | Identificador. |
| `TITULO` | NVARCHAR(200) | Obrigatório. |
| `DESCRICAO` | NVARCHAR(1000) | Obrigatório. |
| `PRIORIDADE` | INT | 0..4 — ver comentários em `prova_base_tabela.sql`. |
| `STATUS` | INT | 0..2 — ver comentários em `prova_base_tabela.sql`. |
| `DATA_CRIACAO` | DATETIME2 | Preenchida na inserção. |
| `DATA_CONCLUSAO` | DATETIME2 NULL | Preenchida ao concluir; base do filtro “últimos 7 dias”. |

### Modelo em memória (Delphi)

Classe `TTarefa` em `model.tarefas.pas`: propriedades espelham as colunas; enums `TPrioridadeTarefa` e `TStatusTarefa` mapeiam os inteiros do banco e do JSON.

### Camadas da API

- **Routes** — registram *endpoints* Horse.
- **Controller** — HTTP/JSON.
- **Service** — validações de negócio.
- **Repository** — ADO + SQL; estatísticas com consultas agregadas no SQL Server.
- **Factory** — `TConexaoFactory` cria `TADOConnection` por operação.

## Cliente VCL (`ProvaVCL`)

- URL da API no VCL: função `ApiBaseUrl` em `ProvaVCL/Utils/uConstantes.pas` (derivada de `API_SCHEME`, `API_HOST`, `API_PORT`; deve coincidir com `API_PORT` da ProvaAPI).
- A mesma `API_KEY_VALUE` deve coincidir com a da API.
- Chamadas via `TRESTClient` / `TRESTRequest` (`ProvaVCL/Service/Service.ApiTarefas.pas`).
