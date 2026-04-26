unit Repository.Tarefas.Contracts;

interface

uses
  System.Generics.Collections,
  Model.Tarefas;

type
  /// <summary>
  /// Interface responsavel por definir o contrato de persistência e consulta das tarefas.
  /// </summary>
  ITarefaRepository = interface ['{3F4ECABC-7573-4082-AE44-B805E3D0E818}']
    /// <summary>
    /// Retorna todas as tarefas cadastradas.
    /// </summary>
    function Listar: TObjectList<TTarefa>;
    /// <summary>
    /// Insere uma nova tarefa no banco de dados.
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
    /// Retorna o número total de tarefas.
    /// </summary>
    function TotalTarefas: Integer;
    /// <summary>
    /// Retorna a média de prioridade
    /// das tarefas pendentes.
    /// </summary>
    function MediaPrioridadePendentes: Double;
    /// <summary>
    /// Retorna a quantidade de tarefas
    /// concluídas nos últimos 7 dias.
    /// </summary>
    function TarefasConcluidasUltimos7Dias: Integer;
  end;

implementation


end.
