unit uLogger;

interface

uses
  System.SysUtils, System.Classes, System.IniFiles, uConstantes;

type
  /// <summary>
  /// Níveis de logging disponíveis
  /// </summary>
  /// <remarks>
  /// 0 = Nenhum log
  /// 1 = Apenas INFO
  /// 2 = INFO e WARNING
  /// 3 = INFO, WARNING e ERROR
  /// </remarks>
  TLogLevel = (llInfo, llWarning, llError);

  /// <summary>
  /// Interface para sistema de logging
  /// </summary>
  ILogger = interface['{AAF238FF-9B1A-4675-8BE4-A96D338A0C3C}']
    /// <summary>Registra mensagem de nível INFO</summary>
    procedure LogInfo(psMensagem: string);
    /// <summary>Registra mensagem de nível WARNING</summary>
    procedure LogWarning(psMensagem: string);
    /// <summary>Registra mensagem de nível ERROR</summary>
    procedure LogError(psMensagem: string);
  end;

  /// <summary>
  /// Implementação de logger que escreve em arquivo
  /// </summary>
  /// <remarks>
  /// O arquivo é criado no diretório atual/Logger com nome datado.
  /// O nível de logging é lido do config.ini (NivelLogger).
  /// </remarks>
  TFileLogger = class(TInterfacedObject, ILogger)
  private
    class var FInstance: ILogger;

    FLogFile: string;
    FNivelLogger: Integer;
    procedure EscreverNoArquivo(psNivel, psMensagem: string);
  public
    /// <summary>Retorna a instância única do logger (Singleton)</summary>
    class function GetInstance: ILogger; static;

    /// <summary>Cria o logger e inicializa configurações</summary>
    constructor Create;
    /// <summary>Registra mensagem de nível INFO</summary>
    procedure LogInfo(psMensagem: string);
    /// <summary>Registra mensagem de nível WARNING</summary>
    procedure LogWarning(psMensagem: string);
    /// <summary>Registra mensagem de nível ERROR</summary>
    procedure LogError(psMensagem: string);
  end;

implementation

{ TFileLogger }

constructor TFileLogger.Create;
var
  LogDir: string;
  ConfigFile: string;
  Ini: TIniFile;
begin
  inherited Create;
  FLogFile := STRING_VAZIA;
  FNivelLogger := LOG_NIVEL_NENHUM;

  // Lê o nível do config.ini primeiro
  ConfigFile := GetCurrentDir + '\config.ini';
  if FileExists(ConfigFile) then
  begin
    Ini := TIniFile.Create(ConfigFile);
    try
      FNivelLogger := Ini.ReadInteger('Logger', 'NivelLogger', LOG_NIVEL_NENHUM);
    finally
      Ini.Free;
    end;
  end;

  // Se nível for 0, não cria arquivo de log
  if FNivelLogger = LOG_NIVEL_NENHUM then
    Exit;

  LogDir := GetCurrentDir + '\Logger\';
  if not DirectoryExists(LogDir) then
    ForceDirectories(LogDir);
  FLogFile := LogDir + FormatDateTime('yyyy-mm-dd-hh-nn-ss', Now) + '-app.log';
end;

procedure TFileLogger.EscreverNoArquivo(psNivel, psMensagem: string);
var
  ArquivoLog: TextFile;
  EntradaLog: string;
begin
  if FLogFile = STRING_VAZIA then
    Exit;

  EntradaLog := Format('[%s] %s: %s', [DateTimeToStr(Now), psNivel, psMensagem]);
  AssignFile(ArquivoLog, FLogFile);
  if FileExists(FLogFile) then
    Append(ArquivoLog)
  else
    Rewrite(ArquivoLog);
  try
    Writeln(ArquivoLog, EntradaLog);
  finally
    CloseFile(ArquivoLog);
  end;
end;

procedure TFileLogger.LogInfo(psMensagem: string);
begin
  if FNivelLogger >= LOG_NIVEL_INFO then
    EscreverNoArquivo('INFO', psMensagem);
end;

procedure TFileLogger.LogWarning(psMensagem: string);
begin
  if FNivelLogger >= LOG_NIVEL_WARNING then
    EscreverNoArquivo('WARNING', psMensagem);
end;

procedure TFileLogger.LogError(psMensagem: string);
begin
  if FNivelLogger >= LOG_NIVEL_ERROR then
    EscreverNoArquivo('ERROR', psMensagem);
end;

class function TFileLogger.GetInstance: ILogger;
begin
  if not Assigned(FInstance) then
    FInstance := TFileLogger.Create;

  Result := FInstance;
end;

end.