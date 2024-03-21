unit dm;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Phys, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait, FireDAC.VCLUI.Login,
  FireDAC.Comp.UI, FireDAC.Phys.ODBCBase, Data.DB, FireDAC.Comp.Client,
  Data.SqlExpr, DataBaseU;

type
  TDataModule1 = class(TDataModule)
    FDManager: TFDManager;
    FDConnection: TFDConnection;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysMSSQLDriverLink: TFDPhysMSSQLDriverLink;
    procedure FDConnectionError(ASender, AInitiator: TObject;
      var AException: Exception);
    procedure FDConnectionAfterConnect(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
      { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule1: TDataModule1;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses Vcl.Dialogs, ConnectionParamU, MTLogger, UtilsRegistry;

{$R *.dfm}



{ TDataModule1 }

procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  CreateDefLogger('DhlTracking.log');
  logger.isActive := (regLoad('OnLog') = 'True');
  logger.Info('Программа запущена');
  TConn.ReadConnectionParam;
  TConn.Connection := FDConnection;
  if TConn.DbConnect() then
    CreateDataBase(FDConnection);
end;

procedure TDataModule1.DataModuleDestroy(Sender: TObject);
begin
//  FDConnection.ExecSQL('delete from DatevTools100.dbo.pAmaExport where Spid = @@SPID');
  logger.Info('Программа остановлена');
  FreeDefLogger;
end;


procedure TDataModule1.FDConnectionAfterConnect(Sender: TObject);
begin

  CreateTmpTable(FDConnection);
end;

procedure TDataModule1.FDConnectionError(ASender, AInitiator: TObject;
  var AException: Exception);
begin
  MessageDlg(AException.Message,  mtError, [mbOK], 0);
end;

end.
