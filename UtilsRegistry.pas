unit UtilsRegistry;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
      Vcl.Controls, System.Classes, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
      Vcl.StdCtrls, ShellApi, Registry;


    /// <summary>
    /// RegSave - сохранение данных в реестр
    ///</summary>
    Procedure RegSave(KeyName: string; Value: variant);
    /// <summary>
    /// RegLoad - получение данны из реестра
    ///</summary>
    function  RegLoad(KeyName: string): String;


implementation


Procedure RegSave(KeyName: string; Value: variant);
  var reg : TRegistry;
begin
  reg:=TRegistry.Create;
  reg.RootKey:=HKEY_CURRENT_USER;
  reg.OpenKey('Software\Dhl tracking', True);
  reg.WriteString(KeyName, Value);
  reg.Free;
end;


function RegLoad(KeyName: string): String;
var reg : TRegistry;
s   : string;
begin
  try
    reg:=TRegistry.Create;
    reg.RootKey:=HKEY_CURRENT_USER;
    reg.OpenKey('Software\Dhl tracking', false);
    Result := reg.ReadString(KeyName);
    reg.CloseKey;
    reg.Free;
  except
    //
  end;
end;




end.
