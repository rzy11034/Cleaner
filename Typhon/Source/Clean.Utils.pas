unit Clean.Utils;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils;

type
  UChar = UnicodeChar;
  UString = UnicodeString;

  TArr_int = array of integer;
  TArr_str = array of UString;

procedure DrawLineProgramEnd;

resourcestring
  END_OF_PROGRAM_EN = 'Press any key to continue...';

implementation

procedure DrawLineProgramEnd;
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