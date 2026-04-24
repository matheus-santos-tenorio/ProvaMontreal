unit Factory.Conexao;

interface

uses
  FireDAC.Comp.Client, Factory.Conexao.Contracts, Data.DB, Data.Win.ADODB;

type
  /// <summary>
  /// Classe responsável por criar conexões
  /// com o banco SQL Server via FireDAC.
  /// </summary>
  TConexaoFactory = class(TInterfacedObject, IConexaoFactory)
  public

    /// <summary>
    /// Cria e retorna uma conexão ativa com o banco.
    /// </summary>
    function GetConnection: TADOConnection;
  end;

implementation

uses
  System.SysUtils;

{ TConexaoFactory }

function TConexaoFactory.GetConnection: TADOConnection;
var
  oConexao: TADOConnection;
begin
  oConexao := TADOConnection.Create(nil);
  try
    oConexao.ConnectionString := 'Provider=MSOLEDBSQL;' +
                                 'Server=localhost;' +
                                 'Database=prova;' +
                                 'Trusted_Connection=Yes;' +
                                 'TrustServerCertificate=True;';

    oConexao.LoginPrompt := False;
    oConexao.Connected := True;

    Result := oConexao;
  except
    oConexao.Free;
    Result := nil;
    raise Exception.Create('Erro ao conectar com o banco de dados.');
  end;
end;

end.
