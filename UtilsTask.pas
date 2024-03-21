unit UtilsTask;

interface


uses  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
      Vcl.Controls, System.Classes, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
      Vcl.StdCtrls, ShellApi,  System.JSON,
      Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Error ,

      System.Net.HttpClient, System.Net.URLClient,
      System.Net.HttpClientComponent
      ;

type

   TTask=class(TThread)
   private
     FbtnExecute: tControl;

    var FConnection: TFDConnection;
    function ParseDhlShipments():boolean;
    procedure SetConnection(const Value: TFDConnection);
    property Connection: TFDConnection read FConnection write SetConnection;


    property btnExecute: tControl read FbtnExecute write FbtnExecute;

    /// <summary>
    ///  GetDHLData - ��������� ������ � dhl �� trackingNumber ����������� ��������: ...
    ///  ��������� ��������� 250 ������� � ���� � ������������ �������� 1 ����� � ������� .
    ///</summary>
    function GetDHLData(ShipmentNumber: string): string;

    /// <summary>
    ///  ShipmentsUpdate - ���������� ������� ������� �� ������� ����� �������� ������
    ///</summary>
    procedure ShipmentsUpdate();

    /// <summary>
    ///  ShipmentsInsert - ���������� � ���� ������ �� �������
    ///</summary>
    procedure ShipmentsInsert(AShipments: string);

    /// <summary>
    ///  TaskLogInsert - ���������� ����������/������ � ���������� ������.
    ///  ��� ���������� ������
    ///</summary>
    procedure TaskLogInsert(mType, mText: string);

    procedure TaskLogRefresh;
    procedure TaskLogShowingRefresh;
    procedure TaskLogButtonEnabled;

   protected
   public
     procedure Execute; override;
   end;

  function Start(AConnection: TFDConnection):boolean;


  var isStopParse: Boolean = False;

implementation

uses SqlListU, UtilsRegistry, dm, TaskLog_U, Settings_U, MainForm, MTLogger;

function Start(AConnection: TFDConnection): boolean;
  var ThreadBegin:TTask;
begin
  ThreadBegin:=TTask.Create(True);
  ThreadBegin.FreeOnTerminate := true; // ��������� ������ ���� ������������ ����� ����������
  ThreadBegin.Priority:=tThreadPriority.tpNormal; // ���������� ��������� ������

  ThreadBegin.Connection := AConnection;

  ThreadBegin.Resume; // ��������������� ������ ������ ������
end;


{ TTask }

procedure TTask.Execute;
var i: integer;
    Task: TTask;
begin
  inherited;
  isStopParse := False;
  ShipmentsUpdate;
  ParseDhlShipments;
end;

procedure TTask.TaskLogRefresh;
begin
  try
//    if Form1.tsLog.Showing then
    begin   
      TaskLog_F.LogQuery.Active:=false;
      TaskLog_F.LogQuery.Active:=true;
    end
  finally

  end;
end;

procedure TTask.TaskLogShowingRefresh;
begin
  try
    if Form1.tsLog.Showing then
    begin
      TaskLog_F.LogQuery.Active:=false;
      TaskLog_F.LogQuery.Active:=true;
    end
  finally

  end;
end;

function TTask.GetDHLData(ShipmentNumber: string): string;
var client: THTTPClient;
 // headers: TNetHeaders;
  response: IHTTPResponse;
  JSonValue:TJSonValue;
  s: TJSonValue;
  URI: TURI;

  StatusCode : string;
begin
  Result := '';

  URI:= TURI.Create('https://api-eu.dhl.com/track/shipments');
  URI.AddParameter('trackingNumber', ShipmentNumber);
  URI.AddParameter('language', 'DE');
  logger.Info(URI.ToString);
  client := THTTPClient.Create;
  try
    response := client.Get(URI.ToString, nil, [
       TNameValuePair.Create('Accept', 'application/json'),
       TNameValuePair.Create('DHL-API-Key', regLoad('DhlApiKey'))]);

    //DefLogger.AddToLog(response.ContentAsString);
    logger.Info('Status: ' + response.StatusCode.ToString + ' and reason: ' + response.StatusText);

    if response.StatusCode = 200 then
      StatusCode :='Ok'
    else
      StatusCode :='Error';
    TaskLogInsert(StatusCode, ShipmentNumber + ' Status: ' + response.StatusCode.ToString + ' and reason: ' + response.StatusText);

    if response.StatusCode = 429 then Terminate;  // �������� ����� ��������

    if response.StatusCode = 200 then
    begin
      JSonValue := TJSONObject.ParseJSONValue(response.ContentAsString);
      s := JSonValue.GetValue<TJSonValue>('shipments[0]');
      //DefLogger.AddToLog(s.ToJSON);
    end;

    Result := s.ToJSON;

  except
    on E: Exception do logger.Info(E.Message);
  end;

  freeandnil(client);
end;

function TTask.ParseDhlShipments: boolean;
  var Query: TFDQuery;
      data: string;
begin
  if FConnection.Connected then
  begin
//    try
      try
        Query:= TFDQuery.Create(nil);
        Query.Connection :=FConnection;
        Query.Open('select distinct s.number ' +
                   '  from [tShipments] s with (nolock index=pk1) ' +
                   ' inner join [eazybusiness].[dbo].[tVersand] as v with (nolock) ' +
                   '         on v.[cIdentCode] = s.number COLLATE Latin1_General_CI_AS ' +
                   ' inner join tShippingMethod as sm with (nolock) ' +
                   '         on sm.id       = v.kVersandArt    ' +
                   '        and sm.isActive = 1                ' +
                   ' where isnull(s.status, '''') <> ''delivered''');

        Query.First;
        if Query.RecordCount > 0 then
        begin
          while not Query.Eof do begin

            logger.Info('StopParse: ' + isStopParse.ToString());

            if isStopParse then
            begin
              TaskLogInsert('Stop', 'Parsing�abbrechen');
              Terminate;
              Exit();
            end;

            if Terminated then Exit();

            data := GetDHLData(Query.FieldByName('number').Value);

            if data <> '' then
            begin
              ShipmentsInsert(data);
//
              Synchronize(TaskLogShowingRefresh);   //ShipmentInsert
            end;

            Query.Next;
            Sleep(1000);
          end;
        end;

      finally
        freeandnil(Query);
        isStopParse := False;
        Synchronize(TaskLogButtonEnabled);
        Synchronize(TaskLogRefresh);
      end;
//    except
//      // on Exception do ...
//    end;
  end;
end;

procedure TTask.TaskLogButtonEnabled;
begin
  Settings_F.btnExecute.Enabled := True;
  Settings_F.btnParseStop.Enabled := False;
end;

procedure TTask.TaskLogInsert(mType, mText: string);
var QueryLog: TFDQuery;
begin
  try
    QueryLog:= TFDQuery.Create(nil);
    QueryLog.Connection :=FConnection;
    QueryLog.SQL.Text:='INSERT INTO tTaskLog ([MessageType], [MessageText]) VALUES (:MessageType, :MessageText)';
    QueryLog.ParamByName('MessageType').Value:=mType;
    QueryLog.ParamByName('MessageText').Value:=mText;
    QueryLog.ExecSQL();
  finally
    freeandnil(QueryLog);
  end;
end;

procedure TTask.SetConnection(const Value: TFDConnection);
begin
  FConnection := Value;
end;

procedure TTask.ShipmentsInsert(AShipments: string);
  var Query: TFDQuery;
begin
  if FConnection.Connected then
  begin
//    try
      try
        Query:= TFDQuery.Create(nil);
        Query.Connection :=FConnection;
        Query.SQL.Text:= SqlList['ShipmentInsert'];
        Query.ParamByName('J').asString:=AShipments;
        Query.Prepare;
        Query.ExecSQL;
      finally
        freeandnil(Query);
      end;
//    except
//      // on Exception do ...
//    end;
  end;
end;

procedure TTask.ShipmentsUpdate();
  var Query: TFDQuery;
begin
  if FConnection.Connected then
  begin
//    try
      try
        Query:= TFDQuery.Create(nil);
        Query.Connection :=FConnection;
        Query.SQL.Text:= SqlList['ShipmentsUpdate'];
        Query.ParamByName('BeginDate').Value:=regLoad('DateBegin');
        Query.Prepare;
        //showmessage(regLoad('DateBegin'));
        //showmessage(Query.SQL.Text);
        Query.ExecSQL;

      finally
        freeandnil(Query);
      end;
//    except
//      // on Exception do ...
//    end;
  end;
end;

end.