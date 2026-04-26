unit ufPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,
  Vcl.Buttons, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Grids,
  Presenter.ApiTarefas, Presenter.ApiTarefas.Contracts, Service.ApiTarefas.Contracts;

type
  TfPrincipal = class(TForm)
    Panel1: TPanel;
    btnListar: TBitBtn;
    btnCadastrar: TBitBtn;
    btnAlterarStatus: TBitBtn;
    btnRemover: TBitBtn;
    btnEstatisticas: TBitBtn;
    Panel2: TPanel;
    pcMenu: TPageControl;
    tsListar: TTabSheet;
    tsCadastrar: TTabSheet;
    tsAlterar: TTabSheet;
    tsRemover: TTabSheet;
    tsEstatisticas: TTabSheet;
    Panel3: TPanel;
    Label1: TLabel;
    Panel4: TPanel;
    Panel5: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    memCadMensagem: TMemo;
    edtCadTitulo: TEdit;
    edtCadDescricao: TEdit;
    cmbCadPrioridade: TComboBox;
    btnCadSalvar: TBitBtn;
    Panel6: TPanel;
    Label6: TLabel;
    edtAltCodigo: TEdit;
    btnAltLimpar: TBitBtn;
    Panel7: TPanel;
    memAltMensagem: TMemo;
    Panel8: TPanel;
    Label7: TLabel;
    edtRemCodigo: TEdit;
    btnRemSalvar: TBitBtn;
    btnRemLimpar: TBitBtn;
    memRemMensagem: TMemo;
    memEstatisticas: TMemo;
    sgListar: TStringGrid;
    rgCadStatus: TRadioGroup;
    btnCadLimpar: TBitBtn;
    btnAltSalvar: TBitBtn;
    rgAltStatus: TRadioGroup;
    Label8: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure btnListarClick(Sender: TObject);
    procedure btnCadastrarClick(Sender: TObject);
    procedure btnAlterarStatusClick(Sender: TObject);
    procedure btnRemoverClick(Sender: TObject);
    procedure btnEstatisticasClick(Sender: TObject);
    procedure btnCadLimparClick(Sender: TObject);
    procedure btnCadSalvarClick(Sender: TObject);
    procedure btnAltSalvarClick(Sender: TObject);
    procedure btnRemSalvarClick(Sender: TObject);
    procedure btnRemLimparClick(Sender: TObject);
    procedure btnAltLimparClick(Sender: TObject);
    destructor Destroy; override;
  private
    FPresenter: ITarefaPresenter;
    FRetorno: TApiResult;
    procedure ListarTarefas;
    procedure ConfigurarGrid;
  public
    { Public declarations }
  end;

var
  fPrincipal: TfPrincipal;  

implementation

uses
  Model.Tarefas, System.Generics.Collections;

{$R *.dfm}

procedure TfPrincipal.btnAlterarStatusClick(Sender: TObject);
begin
  pcMenu.ActivePage := tsAlterar;
end;

procedure TfPrincipal.btnAltLimparClick(Sender: TObject);
begin
  edtAltCodigo.Text := '0';
  rgAltStatus.ItemIndex := 0;
end;

procedure TfPrincipal.btnAltSalvarClick(Sender: TObject);
begin
  FRetorno := FPresenter.AtualizarStatus(StrToIntDef(edtAltCodigo.Text, 0), TTarefa.toStatus(rgAltStatus.ItemIndex + 1));

  memAltMensagem.Text := FRetorno.Message;
  if FRetorno.Success then
    btnAltLimpar.Click;
end;

procedure TfPrincipal.btnCadastrarClick(Sender: TObject);
begin
  pcMenu.ActivePage := tsCadastrar;
end;

procedure TfPrincipal.btnCadLimparClick(Sender: TObject);
begin
  edtCadTitulo.Text := '';
  edtCadDescricao.Text := '';
  cmbCadPrioridade.ItemIndex := 0;
  rgCadStatus.ItemIndex := 0;
end;

procedure TfPrincipal.btnCadSalvarClick(Sender: TObject);
var
  oTarefa: TTarefa;
begin
  oTarefa := TTarefa.Create;
  try
    oTarefa.Titulo := edtCadTitulo.Text;
    oTarefa.Descricao := edtCadDescricao.Text;
    oTarefa.Prioridade := TTarefa.toPrioridade(cmbCadPrioridade.ItemIndex + 1);
    oTarefa.Status := TTarefa.toStatus(rgCadStatus.ItemIndex + 1);

    FRetorno := FPresenter.Inserir(oTarefa);
  finally
    oTarefa.Free;
  end;

  memCadMensagem.Text := FRetorno.Message;
  if FRetorno.Success then
    btnCadLimpar.Click;
end;

destructor TfPrincipal.Destroy;
begin
  FPresenter := nil;
  inherited;
end;

procedure TfPrincipal.btnEstatisticasClick(Sender: TObject);
begin
  pcMenu.ActivePage := tsEstatisticas;
  memEstatisticas.Text := FPresenter.Estatisticas;
end;

procedure TfPrincipal.btnListarClick(Sender: TObject);
begin
  pcMenu.ActivePage := tsListar;
  ListarTarefas;
end;

procedure TfPrincipal.btnRemLimparClick(Sender: TObject);
begin
  edtRemCodigo.Text := '0';
end;

procedure TfPrincipal.btnRemoverClick(Sender: TObject);
begin
  pcMenu.ActivePage := tsRemover;
end;

procedure TfPrincipal.btnRemSalvarClick(Sender: TObject);
begin
  FRetorno := FPresenter.Remover(StrToIntDef(edtRemCodigo.Text, 0));

  memRemMensagem.Text := FRetorno.Message;
  if FRetorno.Success then
    btnRemLimpar.Click;
end;

procedure TfPrincipal.ConfigurarGrid;
begin
  sgListar.ColCount := 7;
  sgListar.RowCount := 2;
  sgListar.FixedRows := 1;

  sgListar.Cells[0, 0] := 'ID';
  sgListar.Cells[1, 0] := 'Titulo';
  sgListar.Cells[2, 0] := 'Descrição';
  sgListar.Cells[3, 0] := 'Prioridade';
  sgListar.Cells[4, 0] := 'Status';
  sgListar.Cells[5, 0] := 'Data de criação';
  sgListar.Cells[6, 0] := 'Data de conclusão';

  sgListar.ColWidths[0] := 45;
  sgListar.ColWidths[1] := 251;
  sgListar.ColWidths[2] := 255;
  sgListar.ColWidths[3] := 95;
  sgListar.ColWidths[4] := 110;
  sgListar.ColWidths[5] := 125;
  sgListar.ColWidths[6] := 125;
end;

procedure TfPrincipal.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to pcMenu.PageCount - 1 do
    pcMenu.Pages[i].TabVisible := False;

  ConfigurarGrid;
  FPresenter := TTarefasPresenter.Create;
  btnListar.Click;
end;


procedure TfPrincipal.ListarTarefas;
var
  I: Integer;
  lTarefas: TObjectList<TTarefa>;
begin
  try
    lTarefas := FPresenter.Listar;
  except
    on E: Exception do
    begin
      ShowMessage('Nao foi possivel carregar a lista de tarefas.' + sLineBreak + sLineBreak + E.Message);
      sgListar.RowCount := 2;
      Exit;
    end;
  end;
  try
    sgListar.RowCount := lTarefas.Count + 1;

    for I := 0 to lTarefas.Count - 1 do
    begin
      sgListar.Cells[0, I + 1] := lTarefas[I].Id.ToString;
      sgListar.Cells[1, I + 1] := lTarefas[I].Titulo;
      sgListar.Cells[2, I + 1] := lTarefas[I].Descricao;
      sgListar.Cells[3, I + 1] := TTarefa.toPrioridade(lTarefas[I].Prioridade);
      sgListar.Cells[4, I + 1] := TTarefa.toStatus(lTarefas[I].Status);
      if lTarefas[I].DataCriacao <> 0 then
        sgListar.Cells[5, I + 1] := FormatDateTime('dd/mm/yyyy hh:nn', lTarefas[I].DataCriacao)
      else
        sgListar.Cells[5, I + 1] := '';
      if lTarefas[I].DataConclusao <> 0 then
        sgListar.Cells[6, I + 1] := FormatDateTime('dd/mm/yyyy hh:nn', lTarefas[I].DataConclusao)
      else
        sgListar.Cells[6, I + 1] := '';
    end;
  finally
    lTarefas.Free;
  end;
end;

end.
