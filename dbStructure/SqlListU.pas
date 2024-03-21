unit SqlListU;
// пример использования:
// Connection.ExecSQL(SqlList['GetOrder'], ['123']);
// содержание файла запросов:
// --SQL CreateDB
// запрос
// go
//
interface

uses System.Classes, Winapi.Windows, System.SysUtils,
  System.Generics.Collections, Vcl.Dialogs;

type
  TSqlList = class(TObjectDictionary<string, TStrings>)
  const
    SCRIPTS_RCNAME = 'SqlList';
  private
    function GetScripts(const AName: string): TStrings;
    procedure FillList;
    function GetItem(const AKey: string): string;
  public
    constructor Create;
  public
    property Sql[const Key: string]: string read GetItem; default;
  end;

var
  SqlList: TSqlList;

implementation

function GetStringResource(const AName: string): string;
var
  LResource: TResourceStream;
begin
  LResource := TResourceStream.Create(hInstance, AName, RT_RCDATA);

  with TStringList.Create do
    try
      LoadFromStream(LResource);
      Result := Text;
    finally
      Free;
      LResource.Free;
    end;
end;

{ TScriptList }

constructor TSqlList.Create;
begin
  inherited Create([doOwnsValues]);
  FillList;
end;

procedure TSqlList.FillList;
var
  LScripts: TStrings;
  I: Integer;
  S, LKey: string;
  LStarted: Boolean;
  LSql: TStrings;
begin
  LScripts := GetScripts(SCRIPTS_RCNAME);
  try
    LStarted := False;
    LSql := nil;
    for I := 0 to LScripts.Count - 1 do
    begin
      S := LScripts[I];

      if LStarted then
      begin
        if S.ToLower = 'go' then
        begin
          LStarted := False;
          Continue;
        end
        else if not S.StartsWith('--') then
          LSql.Add(S);
      end
      else
      begin
        LStarted := S.ToLower.StartsWith('--sql ');
        if LStarted then
        begin
          LKey := S.Substring(6);
          LSql := TStringList.Create;
          Add(LKey, LSql);
        end;
        Continue;
      end;
    end;
  finally
    LScripts.Free;
  end;
end;

function TSqlList.GetItem(const AKey: string): string;
begin
  Result := Items[AKey].Text;
end;

function TSqlList.GetScripts(const AName: string): TStrings;
begin
  Result := TStringList.Create;
  try
    Result.Text := GetStringResource(AName);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

initialization

SqlList := TSqlList.Create;

finalization

FreeAndNil(SqlList);

end.
