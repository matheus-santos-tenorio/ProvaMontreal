unit Model.Tarefas;

interface

uses
  System.SysUtils;

type
  /// <summary>
  /// Status persistido: 1=Pendente, 2=Em andamento, 3=Concluida (enum com valor inicial 1).
  /// </summary>
  TStatusTarefa = (stPendente = 1, stEmAndamento, stConcluida);

  /// <summary>
  /// Prioridade persistida: 1=Baixa .. 5=Critica.
  /// </summary>
  TPrioridadeTarefa = (ptBaixa = 1, ptMedia, ptAlta, ptUrgente, ptCritica);

  /// <summary>
  /// Modelo de dominio da tarefa (alinhado a tabela TAREFAS na API).
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

    class function toPrioridade(const pPrioridade: Integer): TPrioridadeTarefa; static;
    class function toStatus(const pStatus: Integer): TStatusTarefa; static;
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

end.
