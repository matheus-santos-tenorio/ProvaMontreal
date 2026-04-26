unit uConstantes;

interface

/// <summary>
/// Configuração do cliente REST. API_KEY_* e API_PORT devem coincidir com ProvaAPI\src\Utils\uConstantes.
/// </summary>
const
  API_SCHEME = 'http';
  API_HOST = 'localhost';
  API_PORT = 9000;
  API_KEY_HEADER = 'X-API-KEY';
  API_KEY_VALUE = 'MONTREAL-SEGURA-2026';

/// <summary>URL base da API (http://host:porta), derivada das constantes acima.</summary>
function ApiBaseUrl: string;

implementation

uses
  System.SysUtils;

function ApiBaseUrl: string;
begin
  Result := Format('%s://%s:%d', [API_SCHEME, API_HOST, API_PORT]);
end;

end.
