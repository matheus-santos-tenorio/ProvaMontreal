unit Servicer.ApiTarefas.Contracts;

interface

uses
  Model.Tarefas, System.Generics.Collections;

type
  TApiResult = record
    Success: Boolean;
    Message: string;
  end;

  /// <summary>
  /// Interface regras de negócios.
  /// </summary>
  IApiTarefasService = interface['{16D6F188-526B-46CA-9C0F-44229DE46AD2}']
    /// <summary>
    /// Retorna todas as tarefas cadastradas.
    /// </summary>
    function Listar: TObjectList<TTarefa>;
    /// <summary>
    /// Realiza o cadastro de uma nova tarefa.
    /// </summary>
    function Inserir(pTarefa: TTarefa): TApiResult;
    /// <summary>
    /// Atualiza o status de uma tarefa existente.
    /// </summary>
    function AtualizarStatus(pId: Integer; pNovoStatus: TStatusTarefa): TApiResult;
    /// <summary>
    /// Remove uma tarefa pelo identificador.
    /// </summary>
    function Remover(pId: Integer): TApiResult;
    /// <summary>
    /// Retorna o total de tarefas cadastradas.
    /// Retorna a média de prioridade das tarefas pendentes.
    /// Retorna a quantidade de tarefas concluídas nos últimos 7 dias.    ///
    /// </summary>
    function Estatisticas: String;
  end;

implementation

end.
