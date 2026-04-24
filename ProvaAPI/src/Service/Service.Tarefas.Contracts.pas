unit Service.Tarefas.Contracts;

interface

uses
  System.Generics.Collections, Model.Tarefas;

type
  /// <summary>
  /// Interface regras de negócios.
  /// </summary>
  ITarefaService = interface['{E153F2A2-0605-4056-BBD8-456306F5E6A5}']

    /// <summary>
    /// Retorna todas as tarefas cadastradas.
    /// </summary>
    function Listar: TObjectList<TTarefa>;
    /// <summary>
    /// Realiza o cadastro de uma nova tarefa.
    /// </summary>
    procedure Inserir(pTarefa: TTarefa);
    /// <summary>
    /// Atualiza o status de uma tarefa existente.
    /// </summary>
    procedure AtualizarStatus(pId: Integer; pNovoStatus: TStatusTarefa);
    /// <summary>
    /// Remove uma tarefa pelo identificador.
    /// </summary>
    procedure Remover(pId: Integer);
    /// <summary>
    /// Retorna o total de tarefas cadastradas.
    /// </summary>
    function TotalTarefas: Integer;
    /// <summary>
    /// Retorna a média de prioridade das tarefas pendentes.
    /// </summary>
    function MediaPrioridadePendentes: Double;
    /// <summary>
    /// Retorna a quantidade de tarefas concluídas nos últimos 7 dias.
    /// </summary>
    function TarefasConcluidasUltimos7Dias: Integer;
  end;

implementation

end.
