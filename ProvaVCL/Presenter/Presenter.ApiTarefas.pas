unit Presenter.ApiTarefas;

interface

uses
  System.Generics.Collections,
  Model.Tarefas,
  Service.ApiTarefas,
  Presenter.ApiTarefas.Contracts, Service.ApiTarefas.Contracts;

type
  TTarefasPresenter = class(TInterfacedObject, ITarefaPresenter)
  private
    FService: IApiTarefasService;
  public
    constructor Create(const pService: IApiTarefasService = nil);
    function Listar: TObjectList<TTarefa>;
    function Inserir(pTarefa: TTarefa): TApiResult;
    function AtualizarStatus(pId: Integer; pNovoStatus: TStatusTarefa): TApiResult;
    function Remover(pId: Integer): TApiResult;
    function Estatisticas: string;
  end;

implementation

function TTarefasPresenter.AtualizarStatus(pId: Integer;
  pNovoStatus: TStatusTarefa): TApiResult;
begin
  Result := FService.AtualizarStatus(pId, pNovoStatus);
end;

constructor TTarefasPresenter.Create(const pService: IApiTarefasService);
begin
  if Assigned(pService) then
    FService := pService
  else
    FService := TApiTarefasService.Create;
end;

function TTarefasPresenter.Inserir(pTarefa: TTarefa): TApiResult;
begin
  Result := FService.Inserir(pTarefa);
end;

function TTarefasPresenter.Listar: TObjectList<TTarefa>;
begin
  Result := FService.Listar;
end;

function TTarefasPresenter.Estatisticas: string;
begin
  Result := FService.Estatisticas;
end;

function TTarefasPresenter.Remover(pId: Integer): TApiResult;
begin
  Result := FService.Remover(pId);
end;

end.
