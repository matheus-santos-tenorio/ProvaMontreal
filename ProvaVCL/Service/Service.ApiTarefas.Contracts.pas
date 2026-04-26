unit Service.ApiTarefas.Contracts;

interface

uses
  Model.Tarefas, System.Generics.Collections;

type
  TApiResult = record
    Success: Boolean;
    Message: string;
  end;

  IApiTarefasService = interface['{16D6F188-526B-46CA-9C0F-44229DE46AD2}']
    function Listar: TObjectList<TTarefa>;
    function Inserir(pTarefa: TTarefa): TApiResult;
    function AtualizarStatus(pId: Integer; pNovoStatus: TStatusTarefa): TApiResult;
    function Remover(pId: Integer): TApiResult;
    function Estatisticas: string;
  end;

implementation

end.
