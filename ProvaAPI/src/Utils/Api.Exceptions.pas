unit Api.Exceptions;

interface

uses
  System.SysUtils;

type
  /// <summary>
  /// Payload ou parametro HTTP invalido  
  /// </summary>
  EValidationException = class(Exception);
  /// <summary>
  /// Recurso solicitado nao existe
  /// </summary>
  ENotFoundException = class(Exception);
  /// <summary>
  /// Regra de negocio impediu a operacao
  /// </summary>
  EBusinessRuleException = class(Exception);
  /// <summary>
  /// Falha ao acessar o banco ou executar comando SQL
  /// </summary>
  ERepositoryException = class(Exception);

implementation

end.
