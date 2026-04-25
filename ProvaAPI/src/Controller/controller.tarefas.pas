unit Controller.Tarefas;

interface

uses
  Horse,
  System.JSON,
  Service.Tarefas.Contracts;

type
  /// <summary>
  /// Controller responsável pelo gerenciamento
  /// das rotas relacionadas à entidade Tarefa.
  /// </summary>
  TTarefaController = class
  private
    FService: ITarefaService;

  public
    /// <summary>
    /// Construtor responsável por receber
    /// o service de tarefas.
    /// </summary>
    constructor Create(AService: ITarefaService);

    /// <summary>
    /// Endpoint responsável por listar tarefas.
    /// </summary>
    procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    /// <summary>
    /// Endpoint responsável por inserir tarefa.
    /// </summary>
    procedure Inserir(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    /// <summary>
    /// Endpoint responsável por atualizar status.
    /// </summary>
    procedure AtualizarStatus(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    /// <summary>
    /// Endpoint responsável por remover tarefa.
    /// </summary>
    procedure Remover(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    /// <summary>
    /// Endpoint responsável por retornar estatísticas.
    /// </summary>
    procedure Estatisticas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

uses
  Model.Tarefas, System.Generics.Collections, System.Classes, System.SysUtils;

procedure TTarefaController.AtualizarStatus(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  Body: TJSONObject;
  Id, Status: Integer;
begin
  Body := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;

  if Body = nil then
  begin
    Res.Status(400).Send('JSON inválido');
    Exit;
  end;

  try
    Id := StrToIntDef(Req.Params['id'], 0);
    Status := Body.GetValue<Integer>('status');

    FService.AtualizarStatus(Id, TTarefa.toStatus(Status));

    Res
      .Status(200)
      .Send(TJSONObject.Create
            .AddPair('success', TJSONBool.Create(True))
            .AddPair('message', 'Status atualizado')
            .ToString);

  finally
    Body.Free;
  end;
end;

constructor TTarefaController.Create(AService: ITarefaService);
begin
  inherited Create;
  FService := AService;
end;

procedure TTarefaController.Estatisticas(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJSONObject: TJSONObject;
begin
  oJSONObject := TJSONObject.Create;
  oJSONObject.AddPair('totalTarefas', TJSONNumber.Create(FService.TotalTarefas));
  oJSONObject.AddPair('mediaPrioridadePendentes', TJSONNumber.Create(FService.MediaPrioridadePendentes));
  oJSONObject.AddPair('tarefasConcluidasUltimos7Dias', TJSONNumber.Create(FService.TarefasConcluidasUltimos7Dias));

  Res
    .Status(200)
    .Send(oJSONObject.ToString);
end;

procedure TTarefaController.Inserir(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
var
  Body: TJSONObject;
  Tarefa: TTarefa;
begin
  Body := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;

  if Body = nil then
  begin
    Res.Status(400).Send('JSON inválido');
    Exit;
  end;

  Tarefa := TTarefa.Create;
  try
    Tarefa.Titulo := Body.GetValue<string>('titulo');
    Tarefa.Descricao := Body.GetValue<string>('descricao');
    Tarefa.Prioridade := TTarefa.toPrioridade(Body.GetValue<Integer>('prioridade'));

    FService.Inserir(Tarefa);

    Res
      .Status(201)
      .Send(TJSONObject.Create
            .AddPair('success', TJSONBool.Create(True))
            .AddPair('message', 'Tarefa criada')
            .ToString);

  finally
    Body.Free;
  end;
end;

procedure TTarefaController.Listar(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
var
  oListaTarefas: TObjectList<TTarefa>;
  oTarefa: TTarefa;
  oJSONArray: TJSONArray;
  oJSONObject: TJSONObject;
begin
  oListaTarefas := FService.Listar;
  oJSONArray := TJSONArray.Create;

  try
    for oTarefa in oListaTarefas do
    begin
      oJSONObject := TJSONObject.Create;

      oJSONObject.AddPair('id', TJSONNumber.Create(oTarefa.Id));
      oJSONObject.AddPair('titulo', oTarefa.Titulo);
      oJSONObject.AddPair('descricao', oTarefa.Descricao);
      oJSONObject.AddPair('prioridade', TJSONNumber.Create(Integer(oTarefa.Prioridade)));
      oJSONObject.AddPair('status', TJSONNumber.Create(Integer(oTarefa.Status)));

      oJSONArray.AddElement(oJSONObject);
    end;

    Res
      .Status(200)
      .Send(oJSONArray.ToString);

  finally
    oListaTarefas.Free;
  end;
end;

procedure TTarefaController.Remover(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
var
  Id: Integer;
begin
  Id := StrToIntDef(Req.Params['id'], 0);

  FService.Remover(Id);

  Res
    .Status(200)
    .Send(
      TJSONObject.Create
        .AddPair('success', TJSONBool.Create(True))
        .AddPair('message', 'Tarefa removida')
        .ToString
    );
end;

end.
