unit Service.ApiTarefas;

interface

uses
  System.Generics.Collections,
  Model.Tarefas,
  Service.ApiTarefas.Contracts, REST.Client, REST.Types;

type
  TApiTarefasService = class(TInterfacedObject, IApiTarefasService)
  private
    procedure ConfigurarSeguranca(pRequest: TRESTRequest);
    procedure ExecutarRequisicaoBruta(const pResource: string; const pMethod: TRESTRequestMethod;
      out pStatusCode: Integer; out pContent: string; const pBody: string = '');
    function ExtrairCampoErroJson(const pContent: string): string;
    function CriarResultadoPorStatus(const pStatusCode: Integer; const pContent,
      pMensagemSucesso, pPrefixoErro: string): TApiResult;
  public
    function Listar: TObjectList<TTarefa>;
    function Inserir(pTarefa: TTarefa): TApiResult;
    function AtualizarStatus(pId: Integer; pNovoStatus: TStatusTarefa): TApiResult;
    function Remover(pId: Integer): TApiResult;
    function Estatisticas: string;
  end;

implementation

uses
  System.JSON, System.SysUtils, System.DateUtils, uConstantes;

function TApiTarefasService.AtualizarStatus(pId: Integer;
  pNovoStatus: TStatusTarefa): TApiResult;
var
  StatusCode: Integer;
  Content: string;
begin
  try
    ExecutarRequisicaoBruta(Format('tarefas/%d/status', [pId]),
                            rmPUT,
                            StatusCode,
                            Content,
                            Format('{"status":%d}', [Ord(pNovoStatus)]));

    Result := CriarResultadoPorStatus(StatusCode,
                                      Content,
                                      'Tarefa do codigo ' + pId.ToString + ' alterada com sucesso!',
                                      'Erro ao atualizar: ');
  except
    on E: Exception do
    begin
      Result.Success := False;
      Result.Message := 'Excecao: ' + E.Message;
    end;
  end;
end;

function TApiTarefasService.Inserir(pTarefa: TTarefa): TApiResult;
var
  oJSONObject: TJSONObject;
  StatusCode: Integer;
  Content: string;
  Body: string;
begin
  try
    oJSONObject := TJSONObject.Create;
    try
      oJSONObject.AddPair('titulo', pTarefa.Titulo);
      oJSONObject.AddPair('descricao', pTarefa.Descricao);
      oJSONObject.AddPair('prioridade', TJSONNumber.Create(Ord(pTarefa.Prioridade)));
      oJSONObject.AddPair('status', TJSONNumber.Create(Ord(pTarefa.Status)));
      Body := oJSONObject.ToJSON;
    finally
      oJSONObject.Free;
    end;

    ExecutarRequisicaoBruta('tarefas', rmPOST, StatusCode, Content, Body);
    Result := CriarResultadoPorStatus(StatusCode,
                                      Content,
                                      'Tarefa ' + pTarefa.Titulo + ' inserida com sucesso!',
                                      'Erro ao inserir: ');
  except
    on E: Exception do
    begin
      Result.Success := False;
      Result.Message := 'Excecao: ' + E.Message;
    end;
  end;
end;

function TApiTarefasService.Listar: TObjectList<TTarefa>;
var
  StatusCode: Integer;
  Content: string;
  oJsonArray: TJSONArray;
  oItem: TJSONValue;
  oTarefa: TTarefa;
  Msg: string;

  function JsonObterDateTimeCampo(const pItem: TJSONValue; const pNomeCampo: string): TDateTime;
  var
    oJSONObject: TJSONObject;
    oJSONValue: TJSONValue;
    DataJson: string;
  begin
    Result := 0;
    oJSONObject := pItem as TJSONObject;

    if oJSONObject = nil then
      Exit;

    oJSONValue := oJSONObject.Values[pNomeCampo];
    if (oJSONValue = nil) or (oJSONValue is TJSONNull) then
      Exit;

    if oJSONValue is TJSONString then
    begin
      DataJson := TJSONString(oJSONValue).Value;
      if not TryISO8601ToDate(DataJson, Result) then
        Result := 0;
    end;
  end;  
begin
  Result := TObjectList<TTarefa>.Create(True);
  try
    try
      ExecutarRequisicaoBruta('tarefas', rmGET, StatusCode, Content);
    except
      on E: Exception do
        raise Exception.Create('Falha de rede ou servico indisponivel em ' + ApiBaseUrl + '.' + sLineBreak + E.Message);
    end;

    if StatusCode <> 200 then
    begin
      Msg := ExtrairCampoErroJson(Content);
      if Msg <> '' then
        raise Exception.Create(Msg)
      else
        raise Exception.Create(Format('HTTP %d ao listar. Confirme se a API esta em execucao.', [StatusCode]));
    end;

    oJsonArray := TJSONObject.ParseJSONValue(Content) as TJSONArray;
    if oJsonArray = nil then
      raise Exception.Create('Resposta JSON invalida ao listar tarefas.');
    try
      for oItem in oJsonArray do
      begin
        oTarefa := TTarefa.Create;
        try
          oTarefa.Id := oItem.GetValue<Integer>('id');
          oTarefa.Titulo := oItem.GetValue<string>('titulo');
          oTarefa.Descricao := oItem.GetValue<string>('descricao');
          oTarefa.Prioridade := TTarefa.toPrioridade(oItem.GetValue<Integer>('prioridade'));
          oTarefa.Status := TTarefa.toStatus(oItem.GetValue<Integer>('status'));
          oTarefa.DataCriacao := JsonObterDateTimeCampo(oItem, 'dataCriacao');
          oTarefa.DataConclusao := JsonObterDateTimeCampo(oItem, 'dataConclusao');
          Result.Add(oTarefa);
        except
          oTarefa.Free;
          raise;
        end;
      end;
    finally
      oJsonArray.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TApiTarefasService.ConfigurarSeguranca(pRequest: TRESTRequest);
begin
  pRequest.Params.AddItem(API_KEY_HEADER, API_KEY_VALUE, pkHTTPHEADER, [poDoNotEncode]);
end;

procedure TApiTarefasService.ExecutarRequisicaoBruta(const pResource: string;
  const pMethod: TRESTRequestMethod; out pStatusCode: Integer; out pContent: string;
  const pBody: string);
var
  oClient: TRESTClient;
  oRequest: TRESTRequest;
  oResponse: TRESTResponse;
begin
  oClient := TRESTClient.Create(ApiBaseUrl);
  oRequest := TRESTRequest.Create(nil);
  oResponse := TRESTResponse.Create(nil);
  try
    oRequest.Client := oClient;
    oRequest.Response := oResponse;
    oRequest.Resource := pResource;
    oRequest.Method := pMethod;
    ConfigurarSeguranca(oRequest);

    if pBody <> '' then
      oRequest.AddBody(pBody, ctAPPLICATION_JSON);

    oRequest.Execute;

    pStatusCode := oResponse.StatusCode;
    pContent := oResponse.Content;
  finally
    oRequest.Free;
    oResponse.Free;
    oClient.Free;
  end;
end;

function TApiTarefasService.ExtrairCampoErroJson(const pContent: string): string;
var
  oJson: TJSONObject;
begin
  Result := '';

  if pContent.Trim.IsEmpty then
    Exit;

  oJson := TJSONObject.ParseJSONValue(pContent) as TJSONObject;

  if oJson = nil then
    Exit;

  try
    if oJson.Get('error') <> nil then
      Result := oJson.GetValue<string>('error');
  finally
    oJson.Free;
  end;
end;

function TApiTarefasService.CriarResultadoPorStatus(const pStatusCode: Integer;
  const pContent, pMensagemSucesso, pPrefixoErro: string): TApiResult;
var
  Detalhe: string;
begin
  Result.Success := pStatusCode in [200, 201];
  if Result.Success then
    Result.Message := pMensagemSucesso
  else
  begin
    Detalhe := ExtrairCampoErroJson(pContent);
    if Detalhe <> '' then
      Result.Message := pPrefixoErro + Detalhe
    else
      Result.Message := pPrefixoErro + pContent;
  end;
end;

function TApiTarefasService.Estatisticas: string;
var
  StatusCode: Integer;
  Content: string;
  oJson: TJSONObject;
  Msg: string;
begin
  Result := '';
  try
    ExecutarRequisicaoBruta('tarefas/estatisticas', rmGET, StatusCode, Content);
  except
    on E: Exception do
    begin
      Result := 'Nao foi possivel obter estatisticas.' + sLineBreak + E.Message;
      Exit;
    end;
  end;

  if StatusCode <> 200 then
  begin
    Msg := ExtrairCampoErroJson(Content);
    if Msg <> '' then
      Result := Msg
    else
      Result := Format('HTTP %d ao consultar estatisticas.', [StatusCode]);
    Exit;
  end;

  oJson := TJSONObject.ParseJSONValue(Content) as TJSONObject;
  if oJson = nil then
  begin
    Result := 'Resposta invalida do servidor (JSON esperado).';
    Exit;
  end;
  try
    try
      Result :=
        'Total de Tarefas: ' + IntToStr(oJson.GetValue<Integer>('totalTarefas')) + sLineBreak +
        'Media de Prioridade Pendentes: ' +
        FormatFloat('0.##', oJson.GetValue<Double>('mediaPrioridadePendentes')) + sLineBreak +
        'Tarefas Concluidas ultimos 7 Dias: ' +
        IntToStr(oJson.GetValue<Integer>('tarefasConcluidasUltimos7Dias'));
    except
      on E: Exception do
        Result := 'Resposta JSON inconsistente nas estatisticas: ' + E.Message;
    end;
  finally
    oJson.Free;
  end;
end;

function TApiTarefasService.Remover(pId: Integer): TApiResult;
var
  StatusCode: Integer;
  Content: string;
begin
  try
    ExecutarRequisicaoBruta(Format('tarefas/%d', [pId]), rmDELETE, StatusCode, Content);
    Result := CriarResultadoPorStatus(StatusCode,
                                      Content,
                                      'Tarefa do codigo ' + pId.ToString + ' foi removida com sucesso!',
                                      'Erro ao remover: ');
  except
    on E: Exception do
    begin
      Result.Success := False;
      Result.Message := 'Excecao: ' + E.Message;
    end;
  end;
end;

end.
