object DataModule1: TDataModule1
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 279
  Width = 744
  object FDManager: TFDManager
    DriverDefFileAutoLoad = False
    ConnectionDefFileAutoLoad = False
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <>
    Active = True
    Left = 72
    Top = 32
  end
  object FDConnection: TFDConnection
    ConnectionName = 'connect'
    Params.Strings = (
      'DriverID=MSSQL')
    LoginPrompt = False
    OnError = FDConnectionError
    AfterConnect = FDConnectionAfterConnect
    Left = 72
    Top = 96
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 344
    Top = 32
  end
  object FDPhysMSSQLDriverLink: TFDPhysMSSQLDriverLink
    DriverID = 'MSSQL'
    ODBCDriver = 'ODBC Driver 17 for SQL Server'
    ODBCAdvanced = 'ODBC Driver 17 for SQL Server'
    Left = 344
    Top = 104
  end
end
