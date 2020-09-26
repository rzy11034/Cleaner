unit Clean.Utils;

interface

type
  UChar = char;
  UString = string;

  TArray_str = TArray<UString>;
  TArray_int = TArray<integer>;

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
