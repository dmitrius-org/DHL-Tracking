unit Settings_U;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, cxCheckBox,
  Vcl.ExtCtrls, cxGroupBox, Vcl.ComCtrls, dxCore, cxDateUtils, cxTextEdit,
  cxSpinEdit, cxTimeEdit, cxMaskEdit, cxDropDownEdit, cxCalendar, cxLabel,
  Vcl.Menus, System.ImageList, Vcl.ImgList, cxImageList, Vcl.StdCtrls, cxButtons,

  DateUtils ;

type
  TSettings_F = class(TForm)
    cxGroupBox1: TcxGroupBox;
    Panel1: TPanel;
    cxGroupBox2: TcxGroupBox;
    cxGroupBox3: TcxGroupBox;
    cxGroupBox4: TcxGroupBox;
    cbTaskEnabled: TcxCheckBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    edtDate: TcxDateEdit;
    edtTime1: TcxTimeEdit;
    edtTime2: TcxTimeEdit;
    cbTime1Enabled: TcxCheckBox;
    cbTime2Enabled: TcxCheckBox;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    edtServer: TcxTextEdit;
    edtBase: TcxTextEdit;
    edtUser: TcxTextEdit;
    edtPas: TcxTextEdit;
    cbOnTray: TcxCheckBox;
    Panel2: TPanel;
    btnExecute: TcxButton;
    btnSave: TcxButton;
    cxImageList1: TcxImageList;
    Timer: TTimer;
    btnParseStop: TcxButton;
    btnTestConnect: TcxButton;
    btnShippingMethod: TcxButton;
    edtDhlApiKey: TcxTextEdit;
    cxLabel8: TcxLabel;
    cbOnLog: TcxCheckBox;
    procedure btnSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnTestConnectClick(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
    procedure cbTaskEnabledClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure btnParseStopClick(Sender: TObject);
    procedure btnShippingMethodClick(Sender: TObject);
  private
    { Private declarations }

    procedure ConfigSave();
    procedure ConfigLoad();

    /// <summary>
    ///  OnTask - запуск задачи
    ///</summary>
    procedure OnTask(); overload;
    /// <summary>
    ///  OnTask - запуск задачи
    ///  ATask         - имя задачи. Например NextOnDate1
    ///  ATaskEnabled  - наименование параметра регистра в котором проверяем активность задачи. Например Time1Enabled
    ///  ATime         - настроенное время запуска задачи
    ///</summary>
    procedure OnTask(ATask, ATaskEnabled: String; ATime:TTime); overload;
    procedure OnTimer();

    /// <summary>
    ///  SetNextOnDate - Установка следующей даты выполнения
    ///  ATask         - имя задачи. Например NextOnDate1
    ///  ATime         - настроенное время запуска задачи
    ///</summary>
    procedure SetNextOnDate(ATask: String; ATime:TTime);

  public
    { Public declarations }
  end;

var
  Settings_F: TSettings_F;

implementation

{$R *.dfm}

uses UtilsRegistry, ConnectionParamU, DataBaseU, UtilsTask, MTLogger,
  ShippingMethod_U;



procedure TSettings_F.btnExecuteClick(Sender: TObject);
begin
  btnExecute.Enabled := False;
  btnParseStop.Enabled := True;
  isStopParse := True;
  Start(tconn.Connection);
end;

procedure TSettings_F.btnParseStopClick(Sender: TObject);
begin
  btnParseStop.Enabled := False;
  isStopParse := True;
end;

procedure TSettings_F.btnSaveClick(Sender: TObject);
begin
  ConfigSave
end;

procedure TSettings_F.btnShippingMethodClick(Sender: TObject);
begin
  ShippingMethod_F.ShowModal;
end;

procedure TSettings_F.ConfigSave;
begin
  regSave('TaskEnabled', cbTaskEnabled.Checked);

  regSave('DateBegin', edtDate.Text);
  regSave('Time1', edtTime1.Text);
  regSave('Time2', edtTime2.Text);
  regSave('Time1Enabled', cbTime1Enabled.Checked);
  regSave('Time2Enabled', cbTime2Enabled.Checked);

  regSave('Server', edtServer.Text);
  regSave('Base', edtBase.Text);
  regSave('User', edtUser.Text);
  regSave('Password', edtPas.Text);
  regSave('DhlApiKey', edtDhlApiKey.Text);

  regSave('OnTray', cbOnTray.Checked);
  regSave('OnLog', cbOnLog.Checked);

  SetNextOnDate('NextOnDate1', edtTime1.Time);
  SetNextOnDate('NextOnDate2', edtTime2.Time);

  logger.isActive := cbOnLog.Checked;

//  ShowMessage('Vorgang abgeschlossen!');
  MessageDlg('Vorgang abgeschlossen!',  TMsgDlgType.mtInformation, [mbOK], 0);
end;


procedure TSettings_F.FormShow(Sender: TObject);
begin
  ConfigLoad;
  btnParseStop.Enabled := False;
end;

procedure TSettings_F.OnTask;
begin
  if tconn.Connection.Connected  then
  begin
    logger.Info('OnTask begin');   //Time1Enabled
    OnTask('NextOnDate1', 'Time1Enabled', edtTime1.Time);
    OnTask('NextOnDate2', 'Time2Enabled', edtTime2.Time);
  end
  else
    logger.Info('OnTask begin: No Connected!');   //Time1Enabled
  //DefLogger.AddToLog('OnTask end');
end;

procedure TSettings_F.OnTask(ATask, ATaskEnabled: String; ATime: TTime);
var //dateTime: TDateTime;
NextOnDate1:string;
NextOnDate2:string;
begin
  if cbTaskEnabled.Checked then
  begin
    logger.Info(format('Задача %s, %s: %s', [ATask, ATaskEnabled, regLoad(ATask)]));
    if regLoad(ATaskEnabled)='True' then
    begin
      logger.Info(format('%s: %s', [ATask, regLoad(ATask)]));
      NextOnDate1 :=regLoad(ATask);
      if NextOnDate1 <> '' then
      begin
        //dateTime:=StrToDateTime(NextOnDate1);
        if StrToDateTime(NextOnDate1) <= now() then
        begin
          logger.Info('Start');
          Start(tconn.Connection);
          SetNextOnDate(ATask, ATime);
        end;
      end;
    end;
  end;
end;


procedure TSettings_F.SetNextOnDate(ATask: String; ATime:TTime);
var dateTime: TDateTime;
begin
  if regload(ATask) = '' then
  begin
    dateTime := Trunc(edtDate.Date) + Frac(ATime);
  end
  else
  begin
    dateTime := Trunc(Tomorrow()) + Frac(ATime);
  end;

  regsave(ATask, dateTime);
end;

procedure TSettings_F.OnTimer;
begin
    timer.Enabled := regLoad('TaskEnabled') ='True';
    logger.Info(Format('OnTimer: %s', [timer.Enabled.ToString()]));
end;

procedure TSettings_F.TimerTimer(Sender: TObject);
begin
  OnTask;
end;

procedure TSettings_F.btnTestConnectClick(Sender: TObject);
begin
  if ((edtServer.Text='') or (edtBase.Text='') or (edtPas.Text='')) then
  begin
//    showmessage('Füllen Sie alle Felder aus');  //Заполните все поля
    MessageDlg('Füllen Sie alle Felder aus!',  mtWarning, [mbOK], 0);
    exit;
  end;


  if TConn.DbConnect(edtServer.Text, edtUser.Text, edtPas.Text) then
  begin
    MessageDlg('Datenbankverbindung: fertig',  TMsgDlgType.mtInformation, [mbOK], 0);


    CreateDataBase(TConn.Connection);
  end;
end;

procedure TSettings_F.cbTaskEnabledClick(Sender: TObject);
begin
  regSave('TaskEnabled', cbTaskEnabled.Checked);

  OnTimer;
end;

procedure TSettings_F.ConfigLoad;
begin
  cbTaskEnabled.Checked := regLoad('TaskEnabled') = 'True';

  edtDate.text := regLoad('DateBegin');
  edtTime1.text:= regLoad('Time1');
  edtTime2.text := regLoad('Time2');
  cbTime1Enabled.Checked := regLoad('Time1Enabled')='True';
  cbTime2Enabled.Checked := regLoad('Time2Enabled')='True';

  edtServer.Text := regLoad('Server');
  //edtBase.Text := regLoad('Base');
  edtUser.Text := regLoad('User');
  edtPas.Text := regLoad('Password');
  edtDhlApiKey.Text := regLoad('DhlApiKey');

  cbOnTray.Checked := regLoad('OnTray')='True';
  cbOnLog.Checked := regLoad('OnLog')='True';

  OnTimer;
end;

end.
