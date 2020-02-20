unit Clean.Main;

interface

uses
  System.SysUtils,
  Clean.Utils;

type
  TClean = class
  private
    __dirList: TArr_str;
    __fileList: TArr_str;

    /// <summary> 对目录下的所有文件进行扫描并加入 __fileList </summary>
    /// <param name="dir">当前目录 </param>
    procedure __addAllFlie(dir: UString);
    /// <summary> 将 str 字符串加入到数组末尾 </summary>
    procedure __append(var arr: TArr_str; str: UString);
    /// <summary> 对当前目录下所有目录递归扫描，  /// </summary>
    procedure __scanning(dir: UString);
    /// <summary> 快速排序 </summary>
    procedure __sort(var arr: TArr_str);
    /// <summary> 后缀名匹配 </summary>
    function __suffixMatch(str: UString): boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ExecuteClean;
    /// <summary> 打印待删除列表 </summary>
    procedure Print;
  end;

const
  TARR_FILE_EXTENSION: TArr_str = [
    '.local',
    '.identcache',
    '.projdata',
    '.tvsconfig'];

implementation

procedure TClean.__addAllFlie(dir: UString);
var
  errFile: integer;
  tempFile: UString;
  searchRec: TSearchRec;
begin
  errFile := FindFirst(dir + PathDelim + '*.*', faAnyFile, searchRec);
  while errFile = 0 do
  begin
    if (searchRec.Name <> '.') and (searchRec.Name <> '..') and
      ((searchRec.Attr and faDirectory) <> faDirectory) then
    begin
      tempFile := dir + PathDelim + searchRec.Name;
      __append(__fileList, tempFile);

    end;
    errFile := FindNext(searchRec);
  end;

  FindClose(searchRec);
end;

procedure TClean.__append(var arr: TArr_str; str: UString);
var
  i: integer;
begin
  i := Length(arr);
  SetLength(arr, i + 1);
  arr[high(arr)] := str;
end;

constructor TClean.Create;
begin
  __scanning(GetCurrentDir);
end;

procedure TClean.ExecuteClean;
var
  i: integer;
  tempDir: UString;
  tempFlie: UString;
  IsSuccess: boolean;
begin
  for i := low(__fileList) to high(__fileList) do
  begin
    tempFlie := __fileList[i];
    IsSuccess := DeleteFile(tempFlie);

    if IsSuccess then
      Writeln('Delete ', tempFlie, '  -- OK.')
    else
      Writeln('Delete ', tempFlie, '  -- Failed.');
  end;

  for i := high(__dirList) downto low(__dirList) do
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

procedure TClean.__scanning(dir: UString);
var
  searchRec: TSearchRec;
  errDir: integer;
  tempDir: UString;
begin
  errDir := FindFirst(dir + PathDelim + '*.*', faAnyFile, searchRec);

  while errDir = 0 do
  begin
    tempDir := dir + PathDelim + searchRec.Name;

    if (searchRec.Name <> '.') and (searchRec.Name <> '..') and
      ((searchRec.Attr and faDirectory) = faDirectory) then
    begin
      // 将符合条件的目录加入 __dirList 中
      if (LowerCase(searchRec.Name) = '__history') or
        (LowerCase(searchRec.Name) = '__recovery') or
        (LowerCase(searchRec.Name) = 'win32') or
        (LowerCase(searchRec.Name) = 'win64') or
        (LowerCase(searchRec.Name) = 'release') or
        (LowerCase(searchRec.Name) = 'debug') or
        (LowerCase(searchRec.Name) = 'lib') or
        (LowerCase(searchRec.Name) = 'i386-win32') or
        (LowerCase(searchRec.Name) = 'x86_64-win64') or
        (LowerCase(searchRec.Name) = 'backup') then
      begin
        __addAllFlie(tempDir);
        __append(__dirList, tempDir);
      end;

      __scanning(tempDir);
    end
    else // 对特殊文件进行扫描并加列表
    begin
      if __suffixMatch(LowerCase(searchRec.Name)) then
      begin
        __append(__fileList, tempDir);
      end;
    end;

    errDir := FindNext(searchRec);
  end;

  FindClose(searchRec);
end;

procedure TClean.__sort(var arr: TArr_str);
  procedure __swap(var a, b: UString);
  var
    tmp: UString;
  begin
    tmp := a;
    a := b;
    b := tmp;
  end;

  function __partition(var arr: TArr_str; l, r: integer): integer;
  var
    leftPoint, rightPoint: integer;
    e: UString;
  begin
    __swap(arr[l], arr[l + (r - l) div 2]);
    e := arr[l];

    leftPoint := l + 1;
    rightPoint := r;
    while True do
    begin
      while (leftPoint <= r) and (arr[leftPoint] < e) do
        Inc(leftPoint);
      while (rightPoint >= l) and (arr[rightPoint] > e) do
        Dec(rightPoint);

      if leftPoint > rightPoint then
        Break;

      __swap(arr[leftPoint], arr[rightPoint]);
      Inc(leftPoint);
      Dec(rightPoint);
    end;

    __swap(arr[l], arr[rightPoint]);
    Result := rightPoint;
  end;

  procedure __sort(var arr: TArr_str; l, r: integer);
  var
    p: integer;
  begin
    if l >= r then
      Exit;

    p := __partition(arr, l, r);
    __sort(arr, l, p);
    __sort(arr, p + 1, r);
  end;

begin
  __sort(arr, 0, high(arr));
end;

function TClean.__suffixMatch(str: UString): boolean;
var
  suffixName: TArr_str;
  s: UString;
  i, j: integer;
  flag: boolean;
begin
  suffixName := [
    '.~dsk',
    '.dsk',
    '.local',
    '.identcache',
    '.projdata',
    '.tvsconfig'];

  for s in suffixName do
  begin
    i := high(s);
    j := high(str);
    flag := False;

    if (Length(s) < Length(str)) and (s[i] = str[j]) then
    begin
      flag := True;
      Dec(i);
      Dec(j);
    end
    else
      flag := False;

    if flag = True then
      Break;
  end;

  Result := flag;
end;

end.
