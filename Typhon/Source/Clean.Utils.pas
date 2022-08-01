unit Clean.Utils;

{$mode objfpc}{$H+}
{$ModeSwitch unicodestrings}

interface

uses
  Classes,
  SysUtils;

type
  UChar = unicodechar;
  UString = unicodestring;

  TArray_int = array of integer;
  TArray_str = array of UString;

const
  BEEP = #7;

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
