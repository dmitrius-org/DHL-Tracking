unit ShippingMethod_U;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges,
  dxScrollbarAnnotations, Data.DB, cxDBData, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGridLevel, cxClasses, cxGridCustomView,
  cxGrid, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.ExtCtrls, Vcl.Menus,
  Vcl.StdCtrls, cxButtons, System.ImageList, Vcl.ImgList, cxImageList;

type
  TShippingMethod_F = class(TForm)
    FDTable: TFDTable;
    DataSource: TDataSource;
    TableView: TcxGridDBTableView;
    GridLevel: TcxGridLevel;
    Grid: TcxGrid;
    FDTableId: TIntegerField;
    FDTableName: TWideStringField;
    FDTableisActive: TBooleanField;
    TableViewId: TcxGridDBColumn;
    TableViewName: TcxGridDBColumn;
    TableViewisActive: TcxGridDBColumn;
    Panel1: TPanel;
    btnShippingMethod: TcxButton;
    FDQuery: TFDQuery;
    cxImageList1: TcxImageList;
    procedure FormShow(Sender: TObject);
    procedure btnShippingMethodClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ShippingMethod_F: TShippingMethod_F;

implementation

{$R *.dfm}

uses dm;

procedure TShippingMethod_F.btnShippingMethodClick(Sender: TObject);
begin
  if FDTable.Connection.Connected then
  begin
    FDQuery.ExecSQL;

    FDTable.Refresh;
  end;
end;

procedure TShippingMethod_F.FormShow(Sender: TObject);
begin
  if FDTable.Connection.Connected then
    FDTable.Open;
end;

end.
