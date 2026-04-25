unit Servicer.ApiTarefas;

interface

uses
  System.Generics.Collections,
  model.tarefas,
  Servicer.ApiTarefas.Contracts;

type
  TApiTarefasService = class(TInterfacedObject, IApiTarefasService)
  public
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

uses
 System.JSON, System.SysUtils, REST.Client, REST.Types;

function TApiTarefasService.AtualizarStatus(pId: Integer;
  pNovoStatus: TStatusTarefa): TApiResult;
var
  oClient: TRESTClient;
  oRequest: TRESTRequest;
  oResponse: TRESTResponse;
  oJSONObject: TJSONObject;
begin
  oClient := TRESTClient.Create('http://localhost:9000');
  oRequest := TRESTRequest.Create(nil);
  oResponse := TRESTResponse.Create(nil);
  try
    try
      oRequest.Client := oClient;
      oRequest.Response := oResponse;

      oRequest.Resource := Format('tarefas/%d/status', [pId]);
      oRequest.Method := rmPUT;

      oRequest.AddBody(Format('{"status":"%d"}', [Ord(pNovoStatus)]), ctAPPLICATION_JSON);

      oRequest.Execute;

      if oResponse.StatusCode in [200, 201] then
      begin
        Result.Success := True;
        Result.Message := 'Tarefa do código ' + pId.ToString + ' alterada com sucesso!'
      end
      else
      begin
        Result.Success := False;
        Result.Message := 'Erro ao atualizar: ' + oResponse.Content;
      end;

    except
      on E: Exception do
      begin
        Result.Success := False;

        if Trim(oResponse.Content) <> '' then
          Result.Message := 'Exceção: ' + oResponse.Content
        else
          Result.Message := 'Exceção: ' + E.Message;
      end;
    end;
  finally
    oRequest.Free;
    oResponse.Free;
    oClient.Free;
  end;
end;

function TApiTarefasService.Inserir(pTarefa: TTarefa): TApiResult;
var
  oClient: TRESTClient;
  oRequest: TRESTRequest;
  oResponse: TRESTResponse;
  oJSONObject: TJSONObject;
begin
  Result.Success := False;
  Result.Message := '';

  oClient := TRESTClient.Create('http://localhost:9000');
  oRequest := TRESTRequest.Create(nil);
  oResponse := TRESTResponse.Create(nil);
  try
    try
      oRequest.Client := oClient;
      oRequest.Response := oResponse;

      oRequest.Resource := 'tarefas';
      oRequest.Method := rmPOST;


      oJSONObject := TJSONObject.Create;
      try
        oJSONObject.AddPair('titulo', pTarefa.Titulo);
        oJSONObject.AddPair('descricao', pTarefa.Descricao);
        oJSONObject.AddPair('prioridade', TJSONNumber.Create(Ord(pTarefa.Prioridade)));
        oJSONObject.AddPair('status', TJSONNumber.Create(Ord(pTarefa.Status)));

        oRequest.AddBody(oJSONObject.ToJSON, ctAPPLICATION_JSON);

      finally
        oJSONObject.Free;
      end;

      oRequest.Execute;

      if oResponse.StatusCode in [200, 201] then
      begin
        Result.Success := True;
        Result.Message := 'Tarefa ' + pTarefa.Titulo + ' inserida com sucesso!'
      end
      else
      begin
        Result.Success := False;
        Result.Message := 'Erro ao inserir: ' + oResponse.Content;
      end;

    except
      on E: Exception do
      begin
        Result.Success := False;

        if Trim(oResponse.Content) <> '' then
          Result.Message := 'Exceção: ' + oResponse.Content
        else
          Result.Message := 'Exceção: ' + E.Message;
      end;
    end;
  finally
    oClient.Free;
    oRequest.Free;
    oResponse.Free;
  end;
end;

function TApiTarefasService.Listar: TObjectList<TTarefa>;
var
  oClient: TRESTClient;
  oRequest: TRESTRequest;
  oResponse: TRESTResponse;
  oJsonArray: TJSONArray;
  oItem: TJSONValue;
  oTarefa: TTarefa;
begin
  Result := TObjectList<TTarefa>.Create(True);

  oClient := TRESTClient.Create('http://localhost:9000');
  oRequest := TRESTRequest.Create(nil);
  oResponse := TRESTResponse.Create(nil);
  try
    oRequest.Client := oClient;
    oRequest.Response := oResponse;

    oRequest.Resource := 'tarefas';
    oRequest.Method := rmGET;

    oRequest.Execute;

    if oResponse.StatusCode <> 200 then
      Exit;

    oJsonArray := TJSONObject.ParseJSONValue(oResponse.Content) as TJSONArray;
    try
      for oItem in oJsonArray do
      begin
        oTarefa := TTarefa.Create;
        oTarefa.Id := oItem.GetValue<Integer>('id');
        oTarefa.titulo := oItem.GetValue<string>('titulo');
        oTarefa.descricao := oItem.GetValue<string>('descricao');
        oTarefa.prioridade := TTarefa.toPrioridade(oItem.GetValue<Integer>('prioridade'));
        oTarefa.status := TTarefa.toStatus(oItem.GetValue<Integer>('status'));

        Result.Add(oTarefa);
      end;
    finally
      oJsonArray.Free;
    end;

  finally
    oRequest.Free;
    oResponse.Free;
    oClient.Free;
  end;
end;

function TApiTarefasService.Estatisticas: String;
var
  oClient: TRESTClient;
  oRequest: TRESTRequest;
  oResponse: TRESTResponse;
  oJson: TJSONObject;
begin
  Result := '';

  oClient := TRESTClient.Create('http://localhost:9000');
  oRequest := TRESTRequest.Create(nil);
  oResponse := TRESTResponse.Create(nil);
  try
    oRequest.Client := oClient;
    oRequest.Response := oResponse;

    oRequest.Resource := 'tarefas/estatisticas';
    oRequest.Method := rmGET;

    oRequest.Execute;

    if oResponse.StatusCode <> 200 then
      Exit;

    oJson:= TJSONObject.ParseJSONValue(oResponse.Content) as TJSONObject;
    try
      Result := 'Total de Tarefas: ' + oJson.GetValue<string>('totalTarefas') + sLineBreak +
                'Média de Prioridade Pendentes: ' + oJson.GetValue<string>('mediaPrioridadePendentes') + sLineBreak +
                'Tarefas Concluídas Últimos 7 Dias: ' + oJson.GetValue<string>('tarefasConcluidasUltimos7Dias');
    finally
      oJson.Free;
    end;

  finally
    oRequest.Free;
    oResponse.Free;
    oClient.Free;
  end;
end;

function TApiTarefasService.Remover(pId: Integer): TApiResult;
var
  oClient: TRESTClient;
  oRequest: TRESTRequest;
  oResponse: TRESTResponse;
begin
  oClient := TRESTClient.Create('http://localhost:9000');
  oRequest := TRESTRequest.Create(nil);
  oResponse := TRESTResponse.Create(nil);
  try
    try
      oRequest.Client := oClient;
      oRequest.Response := oResponse;

      oRequest.Resource := Format('tarefas/%d', [pId]);
      oRequest.Method := rmDELETE;

      oRequest.Execute;

      if oResponse.StatusCode in [200, 201] then
      begin
        Result.Success := True;
        Result.Message := 'Tarefa do código ' + pId.ToString + ' foi removida com sucesso!'
      end
      else
      begin
        Result.Success := False;
        Result.Message := 'Erro ao remover: ' + oResponse.Content;
      end;
    except
      on E: Exception do
      begin
        Result.Success := False;

        if Trim(oResponse.Content) <> '' then
          Result.Message := 'Exceção: ' + oResponse.Content
        else
          Result.Message := 'Exceção: ' + E.Message;
      end;
    end;
  finally
    oRequest.Free;
    oResponse.Free;
    oClient.Free;
  end;
end;

end.
