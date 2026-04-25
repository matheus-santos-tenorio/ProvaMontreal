unit Model.Tarefas;

interface

uses
  System.SysUtils;

type
  /// <summary>
  /// Enum para o status da tarefa
  /// </summary>
  TStatusTarefa = (stPendente, stEmAndamento, stConcluida);

  /// <summary>
  /// Enum para as prioridades
  /// </summary>
  TPrioridadeTarefa = (ptBaixa, ptMedia, ptAlta, ptUrgente, ptCritica);

  /// <summary>
  /// Implementação da API Tarefa
  /// </summary>
  TTarefa = class
  private
    FId: Integer;
    FTitulo: string;
    FDescricao: string;
    FPrioridade: TPrioridadeTarefa;
    FStatus: TStatusTarefa;
    FDataCriacao: TDateTime;
    FDataConclusao: TDateTime;

  public
    constructor Create;

    property Id: Integer read FId write FId;
    property Titulo: string read FTitulo write FTitulo;
    property Descricao: string read FDescricao write FDescricao;
    property Prioridade: TPrioridadeTarefa read FPrioridade write FPrioridade;
    property Status: TStatusTarefa read FStatus write FStatus;
    property DataCriacao: TDateTime read FDataCriacao write FDataCriacao;
    property DataConclusao: TDateTime read FDataConclusao write FDataConclusao;

    class function toPrioridade(pPrioridadeTarefa: Integer): TPrioridadeTarefa; overload; static;
    class function toPrioridade(pPrioridadeTarefa: TPrioridadeTarefa): String; overload; static;
    class function toStatus(pStatusTarefa: Integer): TStatusTarefa; overload; static;
    class function toStatus(pStatusTarefa: TStatusTarefa): String; overload; static;
  end;

implementation

{ TTask }

constructor TTarefa.Create;
begin
  inherited Create;

  FId := 0;
  FTitulo := '';
  FDescricao := '';
  FPrioridade := ptBaixa;
  FStatus := stPendente;
  FDataCriacao := Now;
  FDataConclusao := 0;
end;

class function TTarefa.toPrioridade(
  pPrioridadeTarefa: Integer): TPrioridadeTarefa;
begin
  case pPrioridadeTarefa of
    0: Result := ptBaixa;
    1: Result := ptMedia;
    2: Result := ptAlta;
    3: Result := ptUrgente;
    4: Result := ptCritica;
  else
    raise Exception.Create('Prioridade inválida');
  end;
end;

class function TTarefa.toPrioridade(
  pPrioridadeTarefa: TPrioridadeTarefa): String;
begin
  case pPrioridadeTarefa of
    ptBaixa:   Result := 'Baixa';
    ptMedia:   Result := 'Media';
    ptAlta:    Result := 'Alta';
    ptUrgente: Result := 'Urgente';
    ptCritica: Result := 'Critica';
  else
    raise Exception.Create('Prioridade inválida');
  end;
end;

class function TTarefa.toStatus(pStatusTarefa: Integer): TStatusTarefa;
begin
  case pStatusTarefa of
    0: Result := stPendente;
    1: Result := stEmAndamento;
    2: Result := stConcluida;
  else
    raise Exception.Create('Status inválido');
  end;
end;

class function TTarefa.toStatus(pStatusTarefa: TStatusTarefa): String;
begin
  case pStatusTarefa of
    stPendente: Result := 'Pendente';
    stEmAndamento: Result := 'Em Andamento';
    stConcluida: Result := 'Concluida';
  else
    raise Exception.Create('Status inválido');
  end;
end;

end.
