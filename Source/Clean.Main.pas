unit Clean.Main;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  Tarr_str = array of string;

  TClean = class
  private
    __dirList: Tarr_str;
    __fileList: Tarr_str;
    procedure __addFlie(dir: string);
    procedure __append(var a: Tarr_str; str: string);
    procedure __search(dir: string);
    procedure __sort(var arr: Tarr_str);
  public
    constructor Create;
    destructor Destroy; override;
    procedure StartClean;
    procedure Print;
  end;

implementation

procedure TClean.__addFlie(dir: string);
var
  errFile: integer;
  tempFile: string;
  searchRecFile: TSearchRec;
begin
  errFile := FindFirst(dir + PathDelim + '*.*', faAnyFile, searchRecFile);
  while errFile = 0 do
  begin
    if (searchRecFile.Name <> '.') and (searchRecFile.Name <> '..') and
      ((searchRecFile.Attr and faDirectory) <> faDirectory) then
    begin
      tempFile := dir + PathDelim + searchRecFile.Name;
      __append(__fileList, tempFile);

    end;
    errFile := FindNext(searchRecFile);
  end;

  FindClose(searchRecFile);
end;

procedure TClean.__append(var a: Tarr_str; str: string);
var
  i: integer;
begin
  i := Length(a);
  SetLength(a, i + 1);
  a[High(a)] := str;
end;

constructor TClean.Create;
begin
  __search(GetCurrentDir);
end;

procedure TClean.StartClean;
var
  i: integer;
  tempDir: string;
  tempFlie: string;
  IsSuccess: boolean;
begin

  for i := low(__fileList) to High(__fileList) do
  begin
    tempFlie := __fileList[i];
    IsSuccess := DeleteFile(tempFlie);

    if IsSuccess then
      Writeln('Delete ', tempFlie, '  -- OK.')
    else
      Writeln('Delete ', tempFlie, '  -- Failed.');
  end;

  for i := High(__dirList) downto low(__dirList) do
  begin
    tempDir := __dirList[i];
    IsSuccess := RemoveDir(tempDir);

    if IsSuccess then
      Writeln('Delete ', tempDir, '  -- OK.')
    else
      Writeln('Delete ', tempDir, '  -- Failed.');
  end;
end;

destructor TClean.Destroy;
begin
  inherited Destroy;
end;

procedure TClean.Print;
var
  i: integer;
begin
  __sort(__dirList);
  __sort(__fileList);

  for i := 0 to Length(__dirList) - 1 do
  begin
    Writeln(__dirList[i]);
  end;

  for i := 0 to Length(__fileList) - 1 do
  begin
    Writeln(__fileList[i]);
  end;
end;

procedure TClean.__search(dir: string);
var
  searchRecDir: TSearchRec;
  errDir: integer;
  tempDir: string;
begin
  errDir := FindFirst(dir + PathDelim + '*.*', faAnyFile, searchRecDir);

  while errDir = 0 do
  begin
    if (searchRecDir.Name <> '.') and (searchRecDir.Name <> '..') and
      ((searchRecDir.Attr and faDirectory) = faDirectory) then
    begin
      tempDir := dir + PathDelim + searchRecDir.Name;

      if (LowerCase(searchRecDir.Name) = '__history') or
        (LowerCase(searchRecDir.Name) = '__recovery') or
        (LowerCase(searchRecDir.Name) = 'win32') or
        (LowerCase(searchRecDir.Name) = 'win64') or
        (LowerCase(searchRecDir.Name) = 'release') or
        (LowerCase(searchRecDir.Name) = 'debug') or
        (LowerCase(searchRecDir.Name) = 'lib') or
        (LowerCase(searchRecDir.Name) = 'i386-win32') or
        (LowerCase(searchRecDir.Name) = 'x86_64-win64') or
        (LowerCase(searchRecDir.Name) = 'backup') then
      begin
        __addFlie(tempDir);
        __append(__dirList, tempDir);
      end;
      __search(tempDir);
    end;

    errDir := FindNext(searchRecDir);
  end;

  FindClose(searchRecDir);
end;

procedure TClean.__sort(var arr: Tarr_str);
var
  i, pass: integer;
  temp, s1, s2: string;
  sorted: boolean;
begin
  sorted := False;
  pass := 1;

  while not sorted do
  begin
    sorted := True;
    Inc(pass);

    for i := 0 to Length(arr) - pass do
    begin
      s1 := arr[i];
      s2 := arr[i + 1];

      if (s1 > s2) then
      begin
        temp := arr[i + 1];
        arr[i + 1] := arr[i];
        arr[i] := temp;
        sorted := False;
      end;
    end;
  end;
end;

end.

























