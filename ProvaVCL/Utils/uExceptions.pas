unit uExceptions;

interface

uses
  System.SysUtils;

type
  EPresenterException = class(Exception)
  public
    constructor Create(const psMensagem: string; poInnerException: Exception);
  end;

  ECarregamentoParaleloException = class(EPresenterException);
  ESQLGenerationException = class(EPresenterException);
  EProjetosTotalDivisoesException = class(EPresenterException);

implementation

{ EPresenterException }

constructor EPresenterException.Create(const psMensagem: string; poInnerException: Exception);
begin
  inherited Create(psMensagem + ': ' + poInnerException.Message);
end;

end.