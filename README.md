# API Horse + cliente VCL
Projeto de **servico REST em Delphi (Horse)** com **SQL Server** e **aplicacao VCL** que consome apenas a API.

## Requisitos
- Delphi (RAD Studio) com suporte a **Horse** (submodulo/pasta `ProvaAPI/modules/horse` conforme seu projeto).
- **SQL Server** acessivel pela maquina onde a API roda.
- Driver **MSOLEDBSQL** (OLE DB) para a connection string ADO usada na API.

## Banco de dados
1. Execute o script [`prova_base_tabela.sql`](prova_base_tabela.sql) no SQL Server (cria o banco `prova` e a tabela `tarefas` se ainda nao existirem).
2. Ajuste a connection string em `ProvaAPI/src/Utils/uConstantes.pas` (`DB_CONNECTION_STRING`) se servidor, instancia ou autenticacao forem diferentes.

## Configuracao da API (`ProvaAPI`)
| Constante | Descricao |
|-----------|-----------|
| `API_PORT` | Porta HTTP (padrao `9000`). |
| `API_KEY_HEADER` / `API_KEY_VALUE` | Header `X-API-KEY` esperado em todas as requisicoes. |

**Ordem de execucao:** subir o SQL Server, compilar e executar `ProvaAPI.dpr`, depois o cliente VCL.

### Endpoints (todas exigem header `X-API-KEY`)
| Metodo | Rota | Descricao |
|--------|------|------------|
| GET | `/tarefas` | Lista todas as tarefas. |
| POST | `/tarefas` | Corpo JSON: `titulo`, `descricao`, `prioridade` (inteiro). Campo opcional `status` (0..2); se omitido, usa Pendente. Se `status` for Concluida, grava `DATA_CONCLUSAO`. |
| PUT | `/tarefas/:id/status` | Corpo JSON: `status` (**numero** 0=Pendente, 1=Em andamento, 2=Concluida). |
| DELETE | `/tarefas/:id` | Remove por id. |
| GET | `/tarefas/estatisticas` | Total de tarefas, media de prioridade das pendentes, concluidas nos ultimos 7 dias. |

Respostas de erro seguem o formato `{"error":"mensagem"}` com HTTP 400/401/404/422/500 conforme o caso.

### Tabela `TAREFAS` (SQL Server)
| Coluna | Tipo | Observacao |
|--------|------|------------|
| `ID` | INT IDENTITY PK | Identificador. |
| `TITULO` | NVARCHAR(200) | Obrigatorio. |
| `DESCRICAO` | NVARCHAR(1000) | Obrigatorio. |
| `PRIORIDADE` | INT | 0..4 — ver comentarios em `prova_base_tabela.sql`. |
| `STATUS` | INT | 0..2 — ver comentarios em `prova_base_tabela.sql`. |
| `DATA_CRIACAO` | DATETIME2 | Preenchida na insercao. |
| `DATA_CONCLUSAO` | DATETIME2 NULL | Preenchida ao concluir; base do filtro "ultimos 7 dias". |

### Modelo em memoria (Delphi)
Classe `TTarefa` em `model.tarefas.pas`: propriedades espelham as colunas; enums `TPrioridadeTarefa` e `TStatusTarefa` mapeiam os inteiros do banco e do JSON.

### Camadas da API
- **Routes** — registram endpoints Horse.
- **Controller** — HTTP/JSON.
- **Service** — validacoes de negocio.
- **Repository** — ADO + SQL; estatisticas com consultas agregadas no SQL Server.
- **Factory** — `TConexaoFactory` cria `TADOConnection` por operacao.

## Cliente VCL (`ProvaVCL`)
- URL da API no VCL: função `ApiBaseUrl` em `ProvaVCL/Utils/uConstantes.pas` (derivada de `API_SCHEME`, `API_HOST`, `API_PORT`; deve bater com `API_PORT` da ProvaAPI).
- A mesma `API_KEY_VALUE` deve coincidir com a da API.
- Chamadas via `TRESTClient` / `TRESTRequest` (`ProvaVCL/Service/Service.ApiTarefas.pas`).
