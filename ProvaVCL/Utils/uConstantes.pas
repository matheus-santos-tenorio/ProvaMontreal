unit uConstantes;

interface

/// <summary>
/// Constantes globais do projeto
/// </summary>

/// <summary>Valor máximo do progressbar (100%)</summary>
const PROGRESS_BAR_MAX = 100;
/// <summary>Valor mínimo permitido para validações</summary>
const NUMERO_ZERO = 0;
/// <summary>Valor padrão para timeout em milissegundos</summary>
const TIMEOUT_DEFAULT = 0;
/// <summary>Posição inicial do progressbar</summary>
const PROGRESS_BAR_POSICAO_INICIAL = 0;
/// <summary>Valor de string vazia</summary>
const STRING_VAZIA = '';
/// <summary>Valor máximo para Random (geração de dados de teste)</summary>
const RANDOM_MAX = 1000;
/// <summary>Nível de logger desabilitado</summary>
const LOG_NIVEL_NENHUM = 0;
/// <summary>Nível de logger para informações</summary>
const LOG_NIVEL_INFO = 1;
/// <summary>Nível de logger para avisos</summary>
const LOG_NIVEL_WARNING = 2;
/// <summary>Nível de logger para erros</summary>
const LOG_NIVEL_ERROR = 3;

/// <summary>Mensagem para valor mínimo inválido</summary>
const MSG_VALOR_MINIMO_INVALIDO = 'Informe um valor superior a 0';
/// <summary>Mensagem para thread já inicializada</summary>
const MSG_THREAD_INICIADA = 'Já existe uma thread inicializada';
/// <summary>Mensagem para divisor zero</summary>
const MSG_DIVISOR_ZERO = 'Divisor zero detectado: não é possível dividir por zero';

implementation

end.