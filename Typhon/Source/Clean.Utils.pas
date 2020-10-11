unit Clean.Utils;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils;

type
  UChar = UnicodeChar;
  UString = UnicodeString;

  TArray_int = array of integer;
  TArray_str = array of UString;

procedure DrawLine;

implementation

procedure DrawLine;
var
  i: integer;
begin
  for i := 0 to 70 do
  begin
    Write('=');
  end;
  Writeln;
end;

end.
