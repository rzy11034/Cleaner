unit Clean.Main;

interface

uses
  System.SysUtils,
  Clean.Utils;

type
  TClean = class
  private
    _dirList: TArray_str;
    _fileList: TArray_str;

    /// <summary> 对目录下的所有文件进行扫描并加入 __fileList </summary>
    /// <param name="dir">当前目录 </param>
    procedure __addAllFlie(dir: UString);
    /// <summary> 将 str 字符串加入到数组末尾 </summary>
    procedure __append(var arr: Tarray_str; str: UString);
    /// <summary> 对当前目录下所有目录递归扫描 </summary>
    procedure __scanning(dir: UString);
    /// <summary> 快速排序 </summary>
    procedure __sort(var arr: Tarray_str); overload;
    /// <summary> 文件后缀名匹配 </summary>
    function __fileSuffixMatch(Source: UString): boolean;
    /// <summary> 目录名匹配 </summary>
    function __dirSuffixMatch(Source: UString): boolean;

  public
    constructor Create;
    destructor Destroy; override;
    procedure ExecuteClean;
    /// <summary> 打印待删除列表 </summary>
    procedure Print;
  end;

implementation

{ TClean }

constructor TClean.Create;
begin
  __scanning(GetCurrentDir);
end;

destructor TClean.Destroy;
begin
  inherited Destroy;
end;

procedure TClean.ExecuteClean;
var
  i: integer;
  tempDir: UString;
  tempFlie: UString;
  IsSuccess: boolean;
begin
  for i := Low(_fileList) to High(_fileList) do
  begin
    tempFlie := _fileList[i];
    IsSuccess := DeleteFile(tempFlie);

    if IsSuccess then
      Writeln('Delete ', tempFlie, '  -- OK.')
    else
      Writeln('Delete ', tempFlie, '  -- Failed.');
  end;

  for i := High(_dirList) downto Low(_dirList) do
  begin
    tempDir := _dirList[i];
    IsSuccess := RemoveDir(tempDir);

    if IsSuccess then
      Writeln('Delete ', tempDir, '  -- OK.')
    else
      Writeln('Delete ', tempDir, '  -- Failed.');
  end;
end;

procedure TClean.Print;
var
  i: integer;
begin
  __sort(_dirList);
  __sort(_fileList);

  for i := 0 to Length(_dirList) - 1 do
  begin
    Writeln(_dirList[i]);
  end;

  for i := 0 to Length(_fileList) - 1 do
  begin
    Writeln(_fileList[i]);
  end;
end;

procedure TClean.__addAllFlie(dir: UString);
var
  errFile: integer;
  tempFile: UString;
  searchRec: TSearchRec;
begin
  errFile := FindFirst(dir + PathDelim + '*', faAnyFile, searchRec);
  while errFile = 0 do
  begin
    if (searchRec.Name <> '.') and (searchRec.Name <> '..') and
      ((searchRec.Attr and faDirectory) <> faDirectory) then
    begin
      tempFile := dir + PathDelim + searchRec.Name;
      __append(_fileList, tempFile);

    end;
    errFile := FindNext(searchRec);
  end;

  FindClose(searchRec);
end;

procedure TClean.__append(var arr: Tarray_str; str: UString);
var
  i: integer;
begin
  i := Length(arr);
  SetLength(arr, i + 1);
  arr[High(arr)] := str;
end;

function TClean.__dirSuffixMatch(Source: UString): boolean;
var
  dirName: TArray_str;
  i: integer;
begin
  dirName := [
    '__history',
    '__recovery',
    'win32',
    'win64',
    'release',
    'debug',
    'lib',
    'i386-win32',
    'x86_64-win64',
    'x86_64-linux',
    'backup'];

  for i := 0 to High(dirName) do
  begin
    if LowerCase(Source) = dirName[i] then
      Exit(true);
  end;

  Result := false;
end;

function TClean.__fileSuffixMatch(Source: UString): boolean;
var
  suffixName: TArray_str;
  s, tmp: UString;
  i, j: integer;
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
    i := High(s);
    j := High(Source);
    tmp := '';

    while (Length(s) < Length(Source)) and (i >= Low(s)) do
    begin
      Insert(Source[j], tmp, Low(tmp));
      Dec(i);
      Dec(j);
    end;

    if tmp = s then
    begin
      Result := true;
      Exit;
    end;
  end;

  Result := false;
end;

procedure TClean.__scanning(dir: UString);
var
  searchRec: TSearchRec;
  errDir: integer;
  tempDir: UString;
begin
  errDir := FindFirst(dir + PathDelim + '*', faAnyFile, searchRec);

  while errDir = 0 do
  begin
    tempDir := dir + PathDelim + searchRec.Name;

    if (searchRec.Name <> '.') and (searchRec.Name <> '..') and
      ((searchRec.Attr and faDirectory) = faDirectory) then
    begin
      // 将符合条件的目录加入 _dirList 中
      if __dirSuffixMatch(searchRec.Name) then
      begin
        __addAllFlie(tempDir);
        __append(_dirList, tempDir);
      end;

      __scanning(tempDir);
    end
    else // 对特殊文件进行扫描并加列表
    begin
      if __fileSuffixMatch(LowerCase(searchRec.Name)) then
      begin
        __append(_fileList, tempDir);
      end;
    end;

    errDir := FindNext(searchRec);
  end;

  FindClose(searchRec);
end;

procedure TClean.__sort(var arr: Tarray_str);
  procedure __swap__(var a, b: UString);
  var
    tmp: UString;
  begin
    tmp := a;
    a := b;
    b := tmp;
  end;

  function __partition__(var arr: TArray_str; l, r: integer): integer;
  var
    leftPoint, rightPoint: integer;
    e: UString;
  begin
    __swap__(arr[l], arr[l + (r - l) div 2]);
    e := arr[l];

    leftPoint := l + 1;
    rightPoint := r;
    while true do
    begin
      while (leftPoint <= r) and (arr[leftPoint] < e) do
        Inc(leftPoint);
      while (rightPoint >= l) and (arr[rightPoint] > e) do
        Dec(rightPoint);

      if leftPoint > rightPoint then
        Break;

      __swap__(arr[leftPoint], arr[rightPoint]);
      Inc(leftPoint);
      Dec(rightPoint);
    end;

    __swap__(arr[l], arr[rightPoint]);
    Result := rightPoint;
  end;

  procedure __sort__(var arr: TArray_str; l, r: integer);
  var
    p: integer;
  begin
    if l >= r then
      Exit;

    p := __partition__(arr, l, r);
    __sort__(arr, l, p);
    __sort__(arr, p + 1, r);
  end;

begin
  __sort__(arr, 0, High(arr));
end;

end.
