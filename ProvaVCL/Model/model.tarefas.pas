unit Model.Tarefas;

interface

uses
  System.SysUtils;

type
  TStatusTarefa = (stPendente = 1, stEmAndamento, stConcluida);
  TPrioridadeTarefa = (ptBaixa = 1, ptMedia, ptAlta, ptUrgente, ptCritica);

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

    class function toPrioridade(const pPrioridade: Integer): TPrioridadeTarefa; overload; static;
    class function toPrioridade(const pPrioridade: TPrioridadeTarefa): string; overload; static;
    class function toStatus(const pStatus: Integer): TStatusTarefa; overload; static;
    class function toStatus(const pStatus: TStatusTarefa): string; overload; static;
  end;

implementation

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

class function TTarefa.toPrioridade(const pPrioridade: Integer): TPrioridadeTarefa;
begin
  case pPrioridade of
    1: Result := ptBaixa;
    2: Result := ptMedia;
    3: Result := ptAlta;
    4: Result := ptUrgente;
    5: Result := ptCritica;
  else
    raise Exception.Create('Prioridade invalida');
  end;
end;

class function TTarefa.toPrioridade(const pPrioridade: TPrioridadeTarefa): string;
begin
  case pPrioridade of
    ptBaixa:   Result := 'Baixa';
    ptMedia:   Result := 'Media';
    ptAlta:    Result := 'Alta';
    ptUrgente: Result := 'Urgente';
    ptCritica: Result := 'Critica';
  end;
end;

class function TTarefa.toStatus(const pStatus: Integer): TStatusTarefa;
begin
  case pStatus of
    1: Result := stPendente;
    2: Result := stEmAndamento;
    3: Result := stConcluida;
  else
    raise Exception.Create('Status invalido');
  end;
end;

class function TTarefa.toStatus(const pStatus: TStatusTarefa): string;
begin
  case pStatus of
    stPendente:    Result := 'Pendente';
    stEmAndamento: Result := 'Em Andamento';
    stConcluida:   Result := 'Concluida';
  end;
end;

end.
