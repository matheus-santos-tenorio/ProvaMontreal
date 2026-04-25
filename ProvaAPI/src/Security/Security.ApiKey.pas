unit Security.ApiKey;

interface

procedure RegistrarApiKeyMiddleware;

implementation

uses
  Horse,
  System.JSON,
  System.SysUtils;

procedure ValidarApiKey(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  ApiKey: string;
begin
  ApiKey := Req.Headers['X-API-KEY'];

  if ApiKey <> 'MONTREAL-SEGURA-2026' then
    raise Exception.Create('Acesso não autorizado');

  Next;
end;

procedure RegistrarApiKeyMiddleware;
begin
  THorse.Use(ValidarApiKey);
end;

end.
