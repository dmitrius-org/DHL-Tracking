unit TaskLog_U;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, cxImageComboBox, System.ImageList,
  Vcl.ImgList, cxImageList, Vcl.Menus, dxDateTimeWheelPicker, cxCalendar,
  cxTextEdit;

type
  TTaskLog_F = class(TForm)
    logGridDBTableView1: TcxGridDBTableView;
    logGridLevel: TcxGridLevel;
    logGrid: TcxGrid;
    LogDataSource: TDataSource;
    LogQuery: TFDQuery;
    _InDate: TcxGridDBColumn;
    _MessageType: TcxGridDBColumn;
    _MessageText: TcxGridDBColumn;
    cxImageList1: TcxImageList;
    PopupMenu: TPopupMenu;
    Refresh1: TMenuItem;
    LogQueryInDate: TSQLTimeStampField;
    LogQueryMessageType: TWideStringField;
    LogQueryMessageText: TWideStringField;
    procedure FormShow(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure PopupMenuPopup(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TaskLog_F: TTaskLog_F;

implementation

{$R *.dfm}

uses dm;

procedure TTaskLog_F.FormShow(Sender: TObject);
begin
  if LogQuery.Connection.Connected then
    LogQuery.Active:=true;
end;

procedure TTaskLog_F.PopupMenuPopup(Sender: TObject);
begin
  Refresh1.Enabled:= LogQuery.Connection.Connected;
end;

procedure TTaskLog_F.Refresh1Click(Sender: TObject);
begin
   LogQuery.Active:=false;
   LogQuery.Active:=true;
end;

end.
