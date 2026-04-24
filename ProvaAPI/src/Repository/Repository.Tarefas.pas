unit Repository.Tarefas;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Model.Tarefas,
  Repository.Tarefas.Contracts,
  Factory.Conexao.Contracts;

type
  /// <summary>
  /// Implementação das operações de persistência
  /// </summary>
  TTarefaRepository = class(TInterfacedObject, ITarefaRepository)
  private
    FConexaoFactory: IConexaoFactory;

  public
    /// <summary>
    /// Construtor responsável por receber a factory de conexão com o banco.
    /// </summary>
    constructor Create(AConexaoFactory: IConexaoFactory);
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
    /// Retorna a média de prioridade das tarefas pendentes.
    /// </summary>
    function MediaPrioridadePendentes: Double;
    /// <summary>
    /// Retorna a quantidade de tarefas concluídas nos últimos 7 dias.
    /// </summary>
    function TarefasConcluidasUltimos7Dias: Integer;
  end;

implementation

uses
  Data.DB, Data.Win.ADODB;

{ TTarefaRepository }

constructor TTarefaRepository.Create(AConexaoFactory: IConexaoFactory);
begin
  inherited Create;
  FConexaoFactory := AConexaoFactory;
end;

function TTarefaRepository.Listar: TObjectList<TTarefa>;
var
  oListaTarefas: TObjectList<TTarefa>;
  oQuery: TADOQuery;
  oConexao: TADOConnection;
  oTarefa: TTarefa;
begin
  oListaTarefas := TObjectList<TTarefa>.Create;
  oConexao := FConexaoFactory.GetConnection;
  oQuery := TADOQuery.Create(nil);

  try
    try
      oQuery.Connection := oConexao;
      oQuery.SQL.Text := 'SELECT ID, TITULO, DESCRICAO, PRIORIDADE, STATUS, DATA_CRIACAO, DATA_CONCLUSAO ' +
                         'FROM TAREFAS ' +
                         'ORDER BY ID';

      oQuery.Open;

      while not oQuery.Eof do
      begin
        oTarefa := TTarefa.Create;

        try
          oTarefa.Id := oQuery.FieldByName('ID').AsInteger;
          oTarefa.Titulo := oQuery.FieldByName('TITULO').AsString;
          oTarefa.Descricao := oQuery.FieldByName('DESCRICAO').AsString;
          oTarefa.Prioridade := TPrioridadeTarefa(oQuery.FieldByName('PRIORIDADE').AsInteger);
          oTarefa.Status := TStatusTarefa(oQuery.FieldByName('STATUS').AsInteger);
          oTarefa.DataCriacao := oQuery.FieldByName('DATA_CRIACAO').AsDateTime;

          if not oQuery.FieldByName('DATA_CONCLUSAO').IsNull then
            oTarefa.DataConclusao := oQuery.FieldByName('DATA_CONCLUSAO').AsDateTime;

          oListaTarefas.Add(oTarefa);

        except
          oTarefa.Free;
          raise;
        end;

        oQuery.Next;
      end;

      Result := oListaTarefas;

    except
      oListaTarefas.Free;
      raise Exception.Create('Erro ao listar tarefas.');
    end;

  finally
    oQuery.Free;
    oConexao.Free;
  end;
end;

procedure TTarefaRepository.Inserir(pTarefa: TTarefa);
var
  oQuery: TADOQuery;
  oConexao: TADOConnection;
begin
  oConexao := FConexaoFactory.GetConnection;
  oQuery := TADOQuery.Create(nil);

  try
    try
      oQuery.Connection := oConexao;
      oQuery.SQL.Text := 'INSERT INTO TAREFAS (TITULO, DESCRICAO, PRIORIDADE, STATUS, DATA_CRIACAO) ' +
                         'VALUES (:pTITULO, :pDESCRICAO, :pPRIORIDADE, :pSTATUS, :pDATA_CRIACAO)';

      oQuery.Parameters.ParamByName('pTITULO').Value := pTarefa.Titulo;
      oQuery.Parameters.ParamByName('pDESCRICAO').Value := pTarefa.Descricao;
      oQuery.Parameters.ParamByName('pPRIORIDADE').Value := Integer(pTarefa.Prioridade);
      oQuery.Parameters.ParamByName('pSTATUS').Value := Integer(pTarefa.Status);
      oQuery.Parameters.ParamByName('pDATA_CRIACAO').Value := pTarefa.DataCriacao;

      oQuery.ExecSQL;

    except
      raise Exception.Create('Erro ao inserir tarefa.');
    end;
  finally
    oQuery.Free;
    oConexao.Free;
  end;
end;

procedure TTarefaRepository.AtualizarStatus(pId: Integer; pNovoStatus: TStatusTarefa);
var
  oQuery: TADOQuery;
  oConexao: TADOConnection;
begin
  oConexao := FConexaoFactory.GetConnection;
  oQuery := TADOQuery.Create(nil);

  try  
    try
      oQuery.Connection := oConexao;
      oQuery.SQL.Text := 'UPDATE TAREFAS SET ' +
                         '  STATUS = :pSTATUS, ' +
                         '  DATA_CONCLUSAO = :pDATA_CONCLUSAO ' +
                         'WHERE ID = :pID';

      oQuery.Parameters.ParamByName('pID').Value := pId;
      oQuery.Parameters.ParamByName('pSTATUS').Value := Integer(pNovoStatus);

      if pNovoStatus = stConcluida then
        oQuery.Parameters.ParamByName('pDATA_CONCLUSAO').Value := Now
      else
        oQuery.Parameters.ParamByName('pDATA_CONCLUSAO').Value;

      oQuery.ExecSQL;

    except
      raise Exception.Create('Erro ao atualizar status da tarefa.');
    end;
    
  finally
    oQuery.Free;
    oConexao.Free;
  end;
end;

procedure TTarefaRepository.Remover(pId: Integer);
var
  oQuery: TADOQuery;
  oConexao: TADOConnection;
begin
  oConexao := FConexaoFactory.GetConnection;
  oQuery := TADOQuery.Create(nil);

  try
    try
      oQuery.Connection := oConexao;
      oQuery.SQL.Text := 'DELETE FROM TAREFAS WHERE ID = :pID';

      oQuery.Parameters.ParamByName('pID').Value := pId;

      oQuery.ExecSQL;

    except
      raise Exception.Create('Erro ao remover tarefa.');
    end;
  finally
    oQuery.Free;
    oConexao.Free;
  end;
end;

function TTarefaRepository.TotalTarefas: Integer;
var
  oQuery: TADOQuery;
  oConexao: TADOConnection;
  nTotalTarefas: Integer;
begin
  nTotalTarefas := 0;
  oConexao := FConexaoFactory.GetConnection;
  oQuery := TADOQuery.Create(nil);

  try
    try
      oQuery.Connection := oConexao;
      oQuery.SQL.Text := 'SELECT COUNT(*) AS TOTAL FROM TAREFAS';

      oQuery.Open;

      nTotalTarefas := oQuery.FieldByName('TOTAL').AsInteger;

      Result := nTotalTarefas;

    except
      raise Exception.Create('Erro ao consultar total de tarefas.');
    end;
  finally
    oQuery.Free;
    oConexao.Free;
  end;
end;

function TTarefaRepository.MediaPrioridadePendentes: Double;
var
  oQuery: TADOQuery;
  oConexao: TADOConnection;
  nMedia: Double;
begin
  nMedia := 0;
  oConexao := FConexaoFactory.GetConnection;
  oQuery := TADOQuery.Create(nil);

  try
    try
      oQuery.Connection := oConexao;
      oQuery.SQL.Text := 'SELECT AVG(CAST(PRIORIDADE AS FLOAT)) AS MEDIA ' +
                         'FROM TAREFAS ' +
                         'WHERE STATUS = :pSTATUS';

      oQuery.Parameters.ParamByName('pSTATUS').Value := Integer(stPendente);

      oQuery.Open;

      if not oQuery.FieldByName('MEDIA').IsNull then
        nMedia := oQuery.FieldByName('MEDIA').AsFloat;

      Result := nMedia;

    except
      raise Exception.Create('Erro ao consultar média de prioridade.');
    end;
    
  finally
    oQuery.Free;
    oConexao.Free;
  end;
end;

function TTarefaRepository.TarefasConcluidasUltimos7Dias: Integer;
var
  oQuery: TADOQuery;
  oConexao: TADOConnection;
  nQuantidade: Integer;
begin
  nQuantidade := 0;
  oConexao := FConexaoFactory.GetConnection;
  oQuery := TADOQuery.Create(nil);

  try
    try
      oQuery.Connection := oConexao;
      oQuery.SQL.Text := 'SELECT COUNT(*) AS TOTAL ' +
                         'FROM TAREFAS ' +
                         'WHERE STATUS = :pSTATUS ' +
                         'AND DATA_CONCLUSAO >= DATEADD(DAY, -7, GETDATE())';

      oQuery.Parameters.ParamByName('pSTATUS').Value := Integer(stConcluida);

      oQuery.Open;

      nQuantidade := oQuery.FieldByName('TOTAL').AsInteger;

      Result := nQuantidade;

    except
      raise Exception.Create('Erro ao consultar tarefas concluídas.');
    end;
  finally
    oQuery.Free;
    oConexao.Free;
  end;
end;

end.
