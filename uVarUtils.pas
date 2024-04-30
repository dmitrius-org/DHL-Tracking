unit uVarUtils;

interface

uses
   System.SysUtils, System.Variants;

  function IsEmptyOrNull(const Value: Variant): Boolean;

  function VarToInt(vVar : Variant) : Integer;
  function VarToIntDef(vVar : Variant; Default : Integer) : Integer;
  function VarToDouble(vVar : Variant) : Double;
  function VarToDoubleDef(vVar : Variant ; Default : Double) : Double;
//  function VarToFloat(const V: Variant; const ADefault: Extended): Extended;
//  function VarToFloatDef(const V: Variant; const ADefault: Extended; const lFormatSettings: TFormatSettings): Extended;
  function VarToBool(vVar : Variant) : Boolean;
  function VarToBoolDef(vVar : Variant; Default : Boolean) : Boolean;
  function VarToDateTimeDef(vVar : Variant ; Default : TDateTime) : TDateTime;

implementation

function IsEmptyOrNull(const Value: Variant): Boolean;
begin
  Result := VarIsClear(Value) or VarIsEmpty(Value) or VarIsNull(Value) or (VarCompareValue(Value, Unassigned) = vrEqual);

  if (not Result) and VarIsStr(Value) then
     Result := Value = '';
end;

function VarToIntDef(vVar : Variant; Default : Integer) : Integer;
begin
  if VarType(vVar) in [varEmpty or varNull] then
    Result := Default
  else
    try
      Result := vVar;
    except
      Result := Default;
    end;
end;

function VarToInt(vVar : Variant) : Integer;
begin
  Result := VarToIntDef(vVar, 0);
end;

function VarToDoubleDef(vVar : Variant ; Default : Double) : Double;
begin
  if VarType(vVar) in [varEmpty or varNull] then
    Result := Default
  else
    try
      Result := vVar
    except
      Result := Default;
    end;
end;

function VarToDouble(vVar : Variant) : Double;
begin
  Result := VarToDoubleDef(vVar, 0.0);
end;

//function VarToFloatDef(const vVar: Variant; const Default: Extended; const AFormatSettings: TFormatSettings): Extended;
//begin
//  if VarType(vVar) in [varEmpty or varNull] then
//    Result := Default
//  else
//    try
//      Result := StrToFloatDef(vVar, Default, AFormatSettings);
//    except
//      Result := Default;
//    end;
//end;

//function VarToFloat(const vVar: Variant; const Default: Extended): Extended;
//begin
//  Result := VarToFloatDef(vVar, Default, FormatSettings);
//end;

function VarToBoolDef(vVar: Variant; Default: Boolean) : Boolean;
begin
  if VarType(vVar) in [varEmpty or varNull] then
    Result := Default
  else
    try
      Result := StrToBoolDef(vVar, Default);
    except
      Result := Default;
    end;
end;
//
function VarToBool(vVar : Variant) : Boolean;
begin
   //Result := VarToBoolDef(vVar, System.Default, FormatSettings);
   Result := VarToBoolDef(vVar, False);
end;

function VarToDateTimeDef(vVar : Variant ; Default : TDateTime) : TDateTime;
begin
  if VarType(vVar) in [varEmpty or varNull] then
    Result := Default
  else
    try
      Result := VarToDateTime(vVar);
    except
      Result := Default;
    end;
end;

end.
