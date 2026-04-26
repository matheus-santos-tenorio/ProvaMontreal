unit Controller.Tarefas;

interface

uses
  Horse,
  System.JSON,
  Service.Tarefas.Contracts;

type
  /// <summary>
  /// Controller responsavel pelo gerenciamento
  /// </summary>
  TTarefaController = class
  private
    FService: ITarefaService;
    procedure EnviarRespostaSucesso(const pRes: THorseResponse; const pStatusCode: Integer; const pMessage: string);
    procedure EnviarRespostaJson(const pRes: THorseResponse; const pStatusCode: Integer; const pJson: TJSONValue);

  public
    /// <summary>
    /// Construtor responsavel por receber
    /// o service de tarefas.
    /// </summary>
    constructor Create(pService: ITarefaService);

    /// <summary>
    /// Endpoint responsavel por listar tarefas.
    /// </summary>
    procedure Listar(pReq: THorseRequest; pRes: THorseResponse; pNext: TProc);

    /// <summary>
    /// Endpoint responsavel por inserir tarefa.
    /// </summary>
    procedure Inserir(pReq: THorseRequest; pRes: THorseResponse; pNext: TProc);

    /// <summary>
    /// Endpoint responsavel por atualizar status.
    /// </summary>
    procedure AtualizarStatus(pReq: THorseRequest; pRes: THorseResponse; pNext: TProc);

    /// <summary>
    /// Endpoint responsavel por remover tarefa.
    /// </summary>
    procedure Remover(pReq: THorseRequest; pRes: THorseResponse; pNext: TProc);

    /// <summary>
    /// Endpoint responsavel por retornar estatisticas.
    /// </summary>
    procedure Estatisticas(pReq: THorseRequest; pRes: THorseResponse; pNext: TProc);
  end;

implementation

uses
  Model.Tarefas, System.Generics.Collections, System.Classes, System.SysUtils,
  System.DateUtils, Api.Exceptions;

procedure TTarefaController.AtualizarStatus(pReq: THorseRequest;
  pRes: THorseResponse; pNext: TProc);
var
  oBody: TJSONObject;
  Id, Status: Integer;
begin
  oBody := TJSONObject.ParseJSONValue(pReq.Body) as TJSONObject;

  if oBody = nil then
    raise EValidationException.Create('JSON invalido.');

  try
    Id := StrToIntDef(pReq.Params['id'], 0);
    try
      Status := oBody.GetValue<Integer>('status');
    except
      on E: Exception do
        raise EValidationException.Create('Campo "status" invalido ou tipo incorreto');
    end;

    FService.AtualizarStatus(Id, TTarefa.toStatus(Status));
    EnviarRespostaSucesso(pRes, 200, 'Status atualizado');

  finally
    oBody.Free;
  end;
end;

constructor TTarefaController.Create(pService: ITarefaService);
begin
  inherited Create;
  FService := pService;
end;

procedure TTarefaController.EnviarRespostaJson(const pRes: THorseResponse;
  const pStatusCode: Integer; const pJson: TJSONValue);
begin
  try
    pRes.Status(pStatusCode).Send(pJson.ToString);
  finally
    pJson.Free;
  end;
end;

procedure TTarefaController.EnviarRespostaSucesso(const pRes: THorseResponse;
  const pStatusCode: Integer; const pMessage: string);
var
  oResponseJson: TJSONObject;
begin
  oResponseJson := TJSONObject.Create;
  oResponseJson.AddPair('success', TJSONBool.Create(True));
  oResponseJson.AddPair('message', pMessage);
  EnviarRespostaJson(pRes, pStatusCode, oResponseJson);
end;

procedure TTarefaController.Estatisticas(pReq: THorseRequest;
  pRes: THorseResponse; pNext: TProc);
var
  oJSONObject: TJSONObject;
begin
  oJSONObject := TJSONObject.Create;
  oJSONObject.AddPair('totalTarefas', TJSONNumber.Create(FService.TotalTarefas));
  oJSONObject.AddPair('mediaPrioridadePendentes', TJSONNumber.Create(FService.MediaPrioridadePendentes));
  oJSONObject.AddPair('tarefasConcluidasUltimos7Dias', TJSONNumber.Create(FService.TarefasConcluidasUltimos7Dias));
  EnviarRespostaJson(pRes, 200, oJSONObject);
end;

procedure TTarefaController.Inserir(pReq: THorseRequest; pRes: THorseResponse;
  pNext: TProc);
var
  oBody: TJSONObject;
  oTarefa: TTarefa;
  oStatus: TJSONValue;
  N: Integer;
begin
  oBody := TJSONObject.ParseJSONValue(pReq.Body) as TJSONObject;

  if oBody = nil then
    raise EValidationException.Create('JSON invalido.');

  oTarefa := TTarefa.Create;
  try
    try
      oTarefa.Titulo := oBody.GetValue<string>('titulo');
      oTarefa.Descricao := oBody.GetValue<string>('descricao');
      oTarefa.Prioridade := TTarefa.toPrioridade(oBody.GetValue<Integer>('prioridade'));
      oStatus := oBody.Values['status'];
      if (oStatus <> nil) and not (oStatus is TJSONNull) then
      begin
        if oStatus is TJSONNumber then
          oTarefa.Status := TTarefa.toStatus(TJSONNumber(oStatus).AsInt)
        else if oStatus is TJSONString then
        begin
          if not TryStrToInt(Trim(TJSONString(oStatus).Value), N) then
            raise EValidationException.Create('Campo "status" deve ser um numero.');
          oTarefa.Status := TTarefa.toStatus(N);
        end
        else
          raise EValidationException.Create('Campo "status" com tipo invalido.');
      end
      else
        oTarefa.Status := stPendente;
    except
      on E: EValidationException do
        raise;
      on E: Exception do
        raise EValidationException.Create('Payload invalido para inserção da tarefa.');
    end;

    FService.Inserir(oTarefa);
    EnviarRespostaSucesso(pRes, 201, 'Tarefa criada');

  finally
    oTarefa.Free;
    oBody.Free;
  end;
end;

procedure TTarefaController.Listar(pReq: THorseRequest; pRes: THorseResponse;
  pNext: TProc);
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
      oJSONObject.AddPair('dataCriacao', DateToISO8601(oTarefa.DataCriacao, False));
      if oTarefa.DataConclusao <> 0 then
        oJSONObject.AddPair('dataConclusao', DateToISO8601(oTarefa.DataConclusao, False))
      else
        oJSONObject.AddPair('dataConclusao', TJSONNull.Create);

      oJSONArray.AddElement(oJSONObject);
    end;

    pRes.Status(200).Send(oJSONArray.ToString);

  finally
    oJSONArray.Free;
    oListaTarefas.Free;
  end;
end;

procedure TTarefaController.Remover(pReq: THorseRequest; pRes: THorseResponse;
  pNext: TProc);
var
  Id: Integer;
begin
  Id := StrToIntDef(pReq.Params['id'], 0);

  FService.Remover(Id);
  EnviarRespostaSucesso(pRes, 200, 'Tarefa removida');
end;

end.
