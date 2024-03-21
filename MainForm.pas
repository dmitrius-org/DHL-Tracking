unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.AppEvnts,
  System.ImageList, Vcl.ImgList, cxImageList, cxGraphics, Vcl.ComCtrls,


  Settings_U, TaskLog_U;

type
  TForm1 = class(TForm)
    ApplicationEvents: TApplicationEvents;
    TrayIcon: TTrayIcon;
    cxImageList1: TcxImageList;
    MainPage: TPageControl;
    tsLog: TTabSheet;
    tsSettings: TTabSheet;
    procedure TrayIconClick(Sender: TObject);
    procedure ApplicationEventsMinimize(Sender: TObject);
    procedure tsSettingsShow(Sender: TObject);
    procedure tsLogShow(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }

    procedure TaskLogFormLoad();
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

//  SettingForm: TSettings_F;
//  TaskLogForm: TTaskLog_F;
implementation

{$R *.dfm}

uses UtilsRegistry;


procedure TForm1.ApplicationEventsMinimize(Sender: TObject);
begin
  if regLoad('OnTray')='True' then
  begin
    TrayIcon.Visible := True;
    Application.ShowMainForm:=False;
    ShowWindow(Handle, SW_HIDE);
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  tsLog.Visible:=False;
    tsLog.Visible:=true;
end;

procedure TForm1.TaskLogFormLoad;
begin
  // форма Лога выполнения задачи
  if Assigned(TaskLog_F) then
  begin
//    TTaskLog_F := TTaskLog_F.Create(Self);
    TaskLog_F.BorderStyle := bsNone;
    TaskLog_F.Parent := tsLog;
    TaskLog_F.Align := alClient;
    TaskLog_F.Show;
  end;
end;

procedure TForm1.TrayIconClick(Sender: TObject);
begin
  TrayIcon.Visible := False;
  Show();
  WindowState := wsNormal;
  Application.BringToFront();
end;

procedure TForm1.tsLogShow(Sender: TObject);
begin
  TaskLogFormLoad();
end;

procedure TForm1.tsSettingsShow(Sender: TObject);
begin
  // форма настройки
//  if not Assigned(SettingForm) then
//  begin
//    SettingForm := TSettings_F.Create(Self);
//    SettingForm.BorderStyle := bsNone;
//    SettingForm.Parent := tsSettings;
//    SettingForm.Align := alClient;
//    SettingForm.Show;
//  end;

  if Assigned(Settings_F) then
  begin
//    Settings_F := TSettings_F.Create(Self);
    Settings_F.BorderStyle := bsNone;
    Settings_F.Parent := tsSettings;
    Settings_F.Align := alClient;
    Settings_F.Show;
  end;
end;

end.
