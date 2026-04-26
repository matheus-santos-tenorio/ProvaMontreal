unit Security.ApiKey;

interface

uses
  System.SysUtils;

type
  EApiUnauthorized = class(Exception);

procedure RegistrarApiKeyMiddleware;

implementation

uses
  Horse,
  uConstantes;

procedure ValidarApiKey(pReq: THorseRequest; pRes: THorseResponse; Next: TProc);
var
  ApiKey: string;
begin
  ApiKey := pReq.Headers[API_KEY_HEADER];

  if ApiKey <> API_KEY_VALUE then
    raise EApiUnauthorized.Create('Acesso nao autorizado');

  Next;
end;

procedure RegistrarApiKeyMiddleware;
begin
  THorse.Use(ValidarApiKey);
end;

end.
