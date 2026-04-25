program ProvaVCL;

uses
  Vcl.Forms,
  ufPrincipal in 'View\ufPrincipal.pas' {fPrincipal},
  uConstantes in 'Utils\uConstantes.pas',
  uExceptions in 'Utils\uExceptions.pas',
  uLogger in 'Utils\uLogger.pas',
  model.tarefas in 'Model\model.tarefas.pas',
  Servicer.ApiTarefas in 'Servicer\Servicer.ApiTarefas.pas',
  Presenter.ApiTarefas in 'Presenter\Presenter.ApiTarefas.pas',
  Presenter.ApiTarefas.Contracts in 'Presenter\Presenter.ApiTarefas.Contracts.pas',
  Servicer.ApiTarefas.Contracts in 'Servicer\Servicer.ApiTarefas.Contracts.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfPrincipal, fPrincipal);
  Application.Run;
end.
