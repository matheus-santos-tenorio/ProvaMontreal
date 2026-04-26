unit Routes.Tarefas;

interface

uses
  Controller.Tarefas;

procedure RegistrarRotasTarefas(const pController: TTarefaController);

implementation

uses
  Horse;

procedure RegistrarRotasTarefas(const pController: TTarefaController);
begin
  THorse.Get('/tarefas/estatisticas',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      pController.Estatisticas(Req, Res, Next);
    end);

  THorse.Get('/tarefas',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      pController.Listar(Req, Res, Next);
    end);

  THorse.Post('/tarefas',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      pController.Inserir(Req, Res, Next);
    end);

  THorse.Put('/tarefas/:id/status',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      pController.AtualizarStatus(Req, Res, Next);
    end);

  THorse.Delete('/tarefas/:id',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      pController.Remover(Req, Res, Next);
    end);
end;

end.
