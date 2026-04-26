program ProvaAPI;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  System.Win.ComObj,
  Winapi.ActiveX,
  System.JSON,
  Controller.Tarefas in 'src\Controller\controller.tarefas.pas',
  Factory.Conexao.Contracts in 'src\Factory\Factory.Conexao.Contracts.pas',
  Factory.Conexao in 'src\Factory\Factory.Conexao.pas',
  Model.Tarefas in 'src\Model\model.tarefas.pas',
  Repository.Tarefas.Contracts in 'src\Repository\Repository.Tarefas.Contracts.pas',
  Repository.Tarefas in 'src\Repository\Repository.Tarefas.pas',
  Routes.Tarefas in 'src\Routes\Routes.Tarefas.pas',
  Security.ApiKey in 'src\Security\Security.ApiKey.pas',
  Service.Tarefas.Contracts in 'src\Service\Service.Tarefas.Contracts.pas',
  Service.Tarefas in 'src\Service\Service.Tarefas.pas',
  Api.Exceptions in 'src\Utils\Api.Exceptions.pas',
  uConstantes in 'src\Utils\uConstantes.pas';

var
  Service: ITarefaService;
  Controller: TTarefaController;

procedure EnviarErroJson(const Res: THorseResponse; const AStatusCode: Integer; const AMessage: string);
var
  ErrorJson: TJSONObject;
begin
  ErrorJson := TJSONObject.Create;
  try
    ErrorJson.AddPair('error', AMessage);
    Res.Status(AStatusCode).Send(ErrorJson.ToString);
  finally
    ErrorJson.Free;
  end;
end;

begin
  try
    THorse.Use(
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        CoInitialize(nil);
        try
          try
            Next;
          except
            on E: EApiUnauthorized do
              EnviarErroJson(Res, 401, 'Acesso nao autorizado');
            on E: EValidationException do
              EnviarErroJson(Res, 400, E.Message);
            on E: ENotFoundException do
              EnviarErroJson(Res, 404, E.Message);
            on E: EBusinessRuleException do
              EnviarErroJson(Res, 422, E.Message);
            on E: ERepositoryException do
              EnviarErroJson(Res, 500, E.Message);
            on E: Exception do
              EnviarErroJson(Res, 500, 'Erro interno inesperado');
          end;
        finally
          CoUninitialize;
        end;
      end);

    RegistrarApiKeyMiddleware;

    Service := TTarefaService.Create(TTarefaRepository.Create(TConexaoFactory.Create));
    Controller := TTarefaController.Create(Service);

    RegistrarRotasTarefas(Controller);

    THorse.Listen(API_PORT);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
