program DhlTracking;

{$R *.dres}

uses
  Vcl.Forms,
  SqlListU in 'dbStructure\SqlListU.pas',
  MTLogger in 'logger\MTLogger.pas',
  MTUtils in 'logger\MTUtils.pas',
  TimeIntervals in 'logger\TimeIntervals.pas',
  dm in 'dm.pas' {DataModule1: TDataModule},
  MainForm in 'MainForm.pas' {Form1},
  Settings_U in 'Settings_U.pas' {Settings_F},
  UtilsRegistry in 'UtilsRegistry.pas',
  ConnectionParamU in 'ConnectionParamU.pas',
  DataBaseU in 'dbStructure\DataBaseU.pas',
  UtilsTask in 'UtilsTask.pas',
  TaskLog_U in 'TaskLog_U.pas' {TaskLog_F},
  ShippingMethod_U in 'ShippingMethod_U.pas' {ShippingMethod_F};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TTaskLog_F, TaskLog_F);
  Application.CreateForm(TShippingMethod_F, ShippingMethod_F);
  Application.CreateForm(TSettings_F, Settings_F);
  Application.Run;
end.
