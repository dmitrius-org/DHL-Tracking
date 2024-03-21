unit DataBaseU;

interface

Uses FireDAC.Comp.Client;

    procedure CreateTmpTable(ADConnection: TFDConnection);
    /// <summary>
    ///  CreateDataBase - Создание бд и объектов
    /// </summary>
    procedure CreateDataBase(ADConnection: TFDConnection);

implementation

uses SqlListU;

procedure CreateTmpTable(ADConnection: TFDConnection);
//var Query: TFDQuery;
begin
//  Query:= TFDQuery.Create(nil) ;
//  Query.Connection :=ADConnection;
//  Query.ExecSQL(SqlList['TmpTable']);
//  Query.Free;
end;


procedure CreateDataBase(ADConnection: TFDConnection);  var Query: TFDQuery;
begin
  if ADConnection.Connected  then
  begin
    ADConnection.ExecSQL(SqlList['CreateDB']);

    ADConnection.ExecSQL(SqlList['useDB']);

    ADConnection.ExecSQL(SqlList['CreateDBSructure']);
  end;
end;

end.
