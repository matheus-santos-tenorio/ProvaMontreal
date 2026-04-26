unit Factory.Conexao.Contracts;

interface

uses
  Data.DB, Data.Win.ADODB;

type
  /// <summary>
  /// Interface responsavel por definir o contrato de criação de conexão com banco de dados.
  /// </summary>
  IConexaoFactory = interface ['{9CB2B92A-B7CA-43FB-B5B6-4EC3D325A288}']
    /// <summary>
    /// Retorna uma conexão ativa com o banco de dados.
    /// </summary>
    function GetConnection: TADOConnection;
  end;

implementation

end.
