unit MTLogger;

interface

uses
  Windows, SysUtils, Classes, SyncObjs, MTUtils;

type
  TLoggerThread = class(TThread)
  private
    FLogFileName: string;
    Event: TEvent;
    CritSect: TCriticalSection; // Для защиты списка строк
    LogStrings: TStringList;
    FisActive: Boolean;

    procedure SetisActive(const Value: Boolean);
  protected
    procedure Execute; override;
  public
    constructor Create(LogFileName: string);
    destructor Destroy; override;
    property isActive: Boolean read FisActive write SetisActive;
    /// <summary>
    ///  Info - Запись лога
    ///</summary>
    procedure Info(const Msg: string);
  end;

var
  logger: TLoggerThread;
  AllowMessageBoxIfError: Boolean = False; 

procedure CreateDefLogger(DefLogFileName: string);
procedure FreeDefLogger;

// Записывает заданную строку текста в указанный файл
procedure WriteStringToTextFile(AFileName: string; Msg: string);

implementation

procedure CreateDefLogger(DefLogFileName: string);
begin
  if logger = nil then
  begin
    logger := TLoggerThread.Create(DefLogFileName);
  end;
end;

procedure FreeDefLogger;
begin
  FreeAndNil(logger);
end;

procedure WriteStringToTextFile(AFileName: string; Msg: string);
var
  AFile: TextFile;
begin
  try
    // Открываем файл при каждом добавлении строки! При большом объеме записи
    // в лог файл это очень нерационально!
    AssignFile(AFile, AFileName);
    if FileExists(AFileName) then
      Append(AFile)
    else
      Rewrite(AFile);
    Writeln(AFile, Msg);
    CloseFile(AFile);
  except
    on E: Exception do
    begin
      // Внимание! В реальном приложении выдача пользователю сообщения об ошибке
      // записи в лог-файл недопустима!
      if AllowMessageBoxIfError then
        ThreadShowMessageFmt('Ошибка при записи в файл [%s] строки "%s": %s', [AFileName, Msg, E.Message]);
    end;
  end;
end;

{ TLoggerThread }

procedure TLoggerThread.Info(const Msg: string);
begin
  if not FisActive then Exit();

  CritSect.Enter;
  try
    LogStrings.Add(Format('%s Info [P:%d T:%d] - %s', [FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz', Now), GetCurrentProcessId, GetCurrentThreadId, Msg]));
  finally
    CritSect.Leave;
  end;
  Event.SetEvent;
end;

procedure TLoggerThread.SetisActive(const Value: Boolean);
begin
  FisActive := Value;
end;

constructor TLoggerThread.Create(LogFileName: string);
const
  STATE_NONSIGNALED = FALSE;
  AUTO_RESET  = FALSE;
begin
  inherited Create(False);

  // Создаём объект "Event" в состоянии "nonsignaled" и просим, чтобы
  // он автоматически переходил в состояние "nonsignaled" после WaitFor
  Event := TEvent.Create(nil, AUTO_RESET, STATE_NONSIGNALED, '', False);

  // Создаём список строк LogStrings
  LogStrings := TStringList.Create;

  // Создаём критическую секцию для защиты списка строк от одновременного
  // доступа из нескольких потоков
  CritSect := TCriticalSection.Create;

  FLogFileName := LogFileName;
end;

destructor TLoggerThread.Destroy;
begin
  // Очень важно, чтобы вызов Terminate был раньше вызова SetEvent!
  Terminate;      // 1. Выставляем флаг Terminated
  Event.SetEvent; // 2. Переводим Event в состояние SIGNALED
  inherited;      // 3. Дожидаемся выхода из метода Execute
  Event.Free;     // 4. Уничтожаем объект Event
  CritSect.Free;
  LogStrings.Free;
end;

procedure TLoggerThread.Execute;
var
  TmpList: TStringList;
begin
  while True do
  begin
    // Завершаем работу потока в том случае, если пользователь выходит из программы,
    // а поток успел скинуть в лог-файл все сообщения из списка LogStrings
    if Terminated and (LogStrings.Count = 0) then Exit;

    // Ожидаем переключения объекта Event в состояние signaled, но не более 2х секунд
    // При вызове метода TLoggerThread.AddToLog выполняется вызов Event.SetEvent,
    // однако лучше перестраховаться и не делать ожидание бесконечным
    Event.WaitFor(2000);

    // Проверяем свойство Count без критической секции (это безопасно)
    if LogStrings.Count > 0 then
    begin
      TmpList := TStringList.Create;
      try
        // 1. Входим в критическую секцию
        CritSect.Enter;
        try
          // 2. Копируем все строки из LogStrings в TmpList
          TmpList.Assign(LogStrings);
          // 3. Очищаем список LogStrings
          LogStrings.Clear;
        finally
          // 4. Выходим из критической секции
          CritSect.Leave;
        end;

        // Список TmpList является локальным, поэтому его не нужно защищать
        // критической секцией.

        // 5. За одно действие записываем все строки из списка TmpList в лог-файл
        WriteStringToTextFile(FLogFileName, Trim(TmpList.Text));
      finally
        TmpList.Free;
      end;
    end;
  end;
end;

end.
