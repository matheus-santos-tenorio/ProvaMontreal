unit Service.Tarefas;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Model.Tarefas,
  Service.Tarefas.Contracts,
  Repository.Tarefas.Contracts;

type
  /// <summary>
  /// Classe regras de negócios.
  /// </summary>
  TTarefaService = class(TInterfacedObject, ITarefaService)
  private
    FRepository: ITarefaRepository;

  public
    /// <summary>
    /// Construtor responsável por receber o repositório de tarefas.
    /// </summary>
    constructor Create(pRepository: ITarefaRepository);
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

{ TTarefaService }

constructor TTarefaService.Create(pRepository: ITarefaRepository);
begin
  inherited Create;
  FRepository := pRepository;
end;

function TTarefaService.Listar: TObjectList<TTarefa>;
begin
  Result := FRepository.Listar;
end;

procedure TTarefaService.Inserir(pTarefa: TTarefa);
begin
  if Trim(pTarefa.Titulo).IsEmpty then
    raise Exception.Create('O título da tarefa é obrigatório.');

  if Trim(pTarefa.Descricao).IsEmpty then
    raise Exception.Create('A descrição da tarefa é obrigatória.');

  pTarefa.DataCriacao := Now;
  pTarefa.Status := stPendente;

  FRepository.Inserir(pTarefa);
end;

procedure TTarefaService.AtualizarStatus(pId: Integer; pNovoStatus: TStatusTarefa);
begin
  if pId <= 0 then
    raise Exception.Create('Id da tarefa inválido.');

  FRepository.AtualizarStatus(pId, pNovoStatus);
end;

procedure TTarefaService.Remover(pId: Integer);
begin
  if pId <= 0 then
    raise Exception.Create('Id da tarefa inválido.');

  FRepository.Remover(pId);
end;

function TTarefaService.TotalTarefas: Integer;
begin
  Result := FRepository.TotalTarefas;
end;

function TTarefaService.MediaPrioridadePendentes: Double;
begin
  Result := FRepository.MediaPrioridadePendentes;
end;

function TTarefaService.TarefasConcluidasUltimos7Dias: Integer;
begin
  Result := FRepository.TarefasConcluidasUltimos7Dias;
end;

end.
