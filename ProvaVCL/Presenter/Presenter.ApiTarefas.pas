unit Presenter.ApiTarefas;

interface

uses
  System.Generics.Collections,
  Model.Tarefas,
  Servicer.ApiTarefas,
  Presenter.ApiTarefas.Contracts, Servicer.ApiTarefas.Contracts;

type
  TTarefasPresenter = class(TInterfacedObject, ITarefaPresenter)
  private
    FService: TApiTarefasService;
  public
    constructor Create;
    destructor Destroy; override;

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

function TTarefasPresenter.AtualizarStatus(pId: Integer;
  pNovoStatus: TStatusTarefa): TApiResult;
begin
  Result := FService.AtualizarStatus(pId, pNovoStatus);
end;

constructor TTarefasPresenter.Create;
begin
  FService := TApiTarefasService.Create;
end;

destructor TTarefasPresenter.Destroy;
begin
  FService.Free;
  inherited;
end;

function TTarefasPresenter.Inserir(pTarefa: TTarefa): TApiResult;
begin
  Result := FService.Inserir(pTarefa);
end;

function TTarefasPresenter.Listar: TObjectList<TTarefa>;
begin
  Result := FService.Listar;
end;

function TTarefasPresenter.Estatisticas: String;
begin
  Result := FService.Estatisticas;
end;

function TTarefasPresenter.Remover(pId: Integer): TApiResult;
begin
  Result := FService.Remover(pId);
end;

end.
