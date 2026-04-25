program ProvaAPI;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  System.Win.ComObj,
  Winapi.ActiveX,
  System.JSON,
  controller.tarefas in 'src\Controller\controller.tarefas.pas',
  Factory.Conexao.Contracts in 'src\Factory\Factory.Conexao.Contracts.pas',
  Factory.Conexao in 'src\Factory\Factory.Conexao.pas',
  model.tarefas in 'src\Model\model.tarefas.pas',
  Repository.Tarefas.Contracts in 'src\Repository\Repository.Tarefas.Contracts.pas',
  Repository.Tarefas in 'src\Repository\Repository.Tarefas.pas',
  Routes.Tarefas in 'src\Routes\Routes.Tarefas.pas',
  Security.ApiKey in 'src\Security\Security.ApiKey.pas',
  Service.Tarefas.Contracts in 'src\Service\Service.Tarefas.Contracts.pas',
  Service.Tarefas in 'src\Service\Service.Tarefas.pas',
  uConstantes in 'src\Utils\uConstantes.pas';

var
  Service: ITarefaService;
  Controller: TTarefaController;

begin
  try
    // MIDDLEWARE GLOBAL
    THorse.Use(
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        CoInitialize(nil);
        try
          try
            Next;
          except
            on E: Exception do
            begin
              Res
                .Status(500)
                .Send(TJSONObject.Create
                      .AddPair('error', E.Message)
                      .ToString);
            end;
          end;
        finally
          CoUninitialize;
        end;
      end);

    // INSTÂNCIA SINGLETON
    Service := TTarefaService.Create(TTarefaRepository.Create(TConexaoFactory.Create));
    Controller := TTarefaController.Create(Service);

    // ROTAS
    THorse.Get('/tarefas',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        Controller.Listar(Req, Res, Next);
      end);

    THorse.Post('/tarefas',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        Controller.Inserir(Req, Res, Next);
      end);

    THorse.Put('/tarefas/:id/status',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        Controller.AtualizarStatus(Req, Res, Next);
      end);

    THorse.Delete('/tarefas/:id',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        Controller.Remover(Req, Res, Next);
      end);

    THorse.Get('/tarefas/estatisticas',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        Controller.Estatisticas(Req, Res, Next);
      end);

    THorse.Listen(9000);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
