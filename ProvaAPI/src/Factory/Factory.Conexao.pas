unit Factory.Conexao;

interface

uses
  Factory.Conexao.Contracts, Data.Win.ADODB;

type
  /// <summary>
  /// Factory de conexoes com SQL Server.
  /// </summary>
  TConexaoFactory = class(TInterfacedObject, IConexaoFactory)
  public

    /// <summary>
    /// Cria e retorna uma conexao ativa com o banco.
    /// </summary>
    function GetConnection: TADOConnection;
  end;

implementation

uses
  System.SysUtils, uConstantes, Api.Exceptions;

{ TConexaoFactory }

function TConexaoFactory.GetConnection: TADOConnection;
var
  oConexao: TADOConnection;
begin
  oConexao := TADOConnection.Create(nil);
  try
    oConexao.ConnectionString := DB_CONNECTION_STRING;

    oConexao.LoginPrompt := False;
    oConexao.Connected := True;

    Result := oConexao;
  except
    oConexao.Free;
    Result := nil;
    raise ERepositoryException.Create('Erro ao conectar com o banco de dados.');
  end;
end;

end.
