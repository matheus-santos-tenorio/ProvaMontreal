unit uConstantes;

interface

/// <summary>
/// Configuração da API e do banco.
/// Mantenha API_KEY_* e API_PORT alinhados ao cliente VCL (Utils\uConstantes).
/// </summary>
const
  API_KEY_HEADER = 'X-API-KEY';
  API_KEY_VALUE = 'MONTREAL-SEGURA-2026';
  DB_CONNECTION_STRING =
    'Provider=MSOLEDBSQL;Server=localhost;Database=prova;Trusted_Connection=Yes;TrustServerCertificate=True;';
  API_PORT = 9000;

implementation

end.
