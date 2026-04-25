unit Presenter.ApiTarefas.Contracts;

interface

uses
  System.Generics.Collections, Model.Tarefas, Servicer.ApiTarefas.Contracts;

type

  /// <summary>
  /// Interface regras de negócios.
  /// </summary>
  ITarefaPresenter = interface['{C5BB5945-3E82-418B-8AE7-66265519B66C}']
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
