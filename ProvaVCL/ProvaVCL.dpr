program ProvaVCL;

uses
  Vcl.Forms,
  ufPrincipal in 'View\ufPrincipal.pas' {fPrincipal},
  uConstantes in 'Utils\uConstantes.pas',
  Model.Tarefas in 'Model\model.tarefas.pas',
  Service.ApiTarefas in 'Service\Service.ApiTarefas.pas',
  Presenter.ApiTarefas in 'Presenter\Presenter.ApiTarefas.pas',
  Presenter.ApiTarefas.Contracts in 'Presenter\Presenter.ApiTarefas.Contracts.pas',
  Service.ApiTarefas.Contracts in 'Service\Service.ApiTarefas.Contracts.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfPrincipal, fPrincipal);
  Application.Run;
end.
