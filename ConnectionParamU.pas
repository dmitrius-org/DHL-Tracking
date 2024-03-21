unit ConnectionParamU;

interface
uses  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
      Vcl.Controls, System.Classes, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
      Vcl.StdCtrls, ShellApi,

      Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Error,

      Registry;



Type

  TConn = Class
  private
    class var FPassword: string;
    class var FBase: string;
    class var FUser: string;
    class var FServer: string;
    class var FExportPfad: string;
    class var FIsReadParam: boolean;
    class var FConnection: TFDConnection;

    class procedure SetBase(const Value: string); static;
    class procedure SetPassword(const Value: string); static;
    class procedure SetServer(const Value: string); static;
    class procedure SetUser(const Value: string); static;
    class procedure SetExportPfad(const Value: string); static;
    class procedure SetIsReadParam(const Value: boolean); static;
    class procedure SetConnection(const Value: TFDConnection); static;
  public
    class property Server: string read FServer write SetServer;
    class property Base: string read FBase write SetBase;
    class property User: string read FUser write SetUser;
    class property Password: string read FPassword write SetPassword;
    class property ExportPfad: string read FExportPfad write SetExportPfad;
    class property IsReadParam: boolean read FIsReadParam write SetIsReadParam;



    class property Connection: TFDConnection read FConnection write SetConnection;

    class procedure ReadConnectionParam(); static;
//    class procedure SetConnectionParam(server, base, user, password: string); static;

    class function DbConnect():boolean;  Overload; static;
    class function DbConnect(server, user, password: string):boolean; Overload; static;
  end;


implementation



{ TConnectionParam }

uses UtilsRegistry;


class procedure TConn.SetBase(const Value: string);
begin
  FBase := Value;
end;

class procedure TConn.SetConnection(const Value: TFDConnection);
begin
  FConnection := Value;
end;

//class procedure TConnectionParam.SetConnectionParam(server, base, user,
//  password: string);
//  var reg : TRegistry;
//begin
//  reg:=TRegistry.Create;
//  reg.RootKey:=HKEY_CURRENT_USER;
//  reg.OpenKey('Software\DatevTools', True);
//  reg.WriteString('server', server);
//  reg.WriteString('base', base);
//  reg.WriteString('user', user);
//  reg.WriteString('password', password);
//  reg.Free;
//
//  IsReadParam:=True;
//end;

class procedure TConn.SetExportPfad(const Value: string);
begin
  FExportPfad := Value;
end;

class procedure TConn.SetIsReadParam(const Value: boolean);
begin
  FIsReadParam := Value;
end;

class procedure TConn.SetPassword(const Value: string);
begin
  FPassword := Value;
end;

class procedure TConn.SetServer(const Value: string);
begin
  FServer := Value;
end;

class procedure TConn.SetUser(const Value: string);
begin
  FUser := Value;
end;

{ TConnectionParam }

class function TConn.DbConnect(server, user, password: string): boolean;
begin
  try

    FConnection.Params.Clear;
    FConnection.Params.Add('Server='+server);
//    FConnection.Params.Add('Database='+base);
    FConnection.Params.Add('User_name='+user);
    FConnection.Params.Add('Password='+password);
    FConnection.Params.Add('MARS=yes');
    FConnection.Params.Add('OSAuthent=No');
    FConnection.Params.Add('DriverID=MSSQL');


    FConnection.Connected := True;
    Result := FConnection.Connected;
  except
    on E: EAbort do
      ; // user pressed Cancel button in Login dialog
    on E: EFDDBEngineException do
      case E.Kind of
        ekUserPwdInvalid: showmessage('User name or password are incorrect') ; // имя пользователя или пароль неверны
        ekUserPwdExpired: showmessage('User password is expired') ; // срок действия пароля пользователя истек
        ekServerGone: showmessage('DBMS is not accessible due to some reason') ;     // СУБД недоступна по какой-то причине
      else // other issues
        showmessage(e.Message)
      end;
  end;
end;
//
class function TConn.DbConnect: boolean;
begin

  if ((Server='') or (User='') or (Password='')) then
  begin
    exit(false);
  end;

  result := DbConnect(Server, User, Password);
end;

class procedure TConn.ReadConnectionParam;
begin

  Server     :=regLoad('Server');
  Base       :=regLoad('Base');
  User       :=regLoad('User');
  Password   :=regLoad('Password');

  IsReadParam:=True;
end;

end.
