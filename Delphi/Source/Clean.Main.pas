unit Clean.Main;

interface

uses
  System.SysUtils,
  Clean.Utils,
  Clean.KMPAlgorithm;

type
  TClean = class
  private
    __dirList: TArr_str;
    __fileList: TArr_str;

    /// <summary> 对目录下的所有文件进行扫描并加入 __fileList </summary>
    /// <param name="dir">当前目录 </param>
    procedure __addFlie(dir: UString);
    /// <summary> 将 str 字符串加入到数组末尾 </summary>
    procedure __append(var arr: TArr_str; str: UString);
    /// <summary> 对当前目录下所有目录递归扫描，  /// </summary>
    procedure __search(dir: UString);
    // 冒泡排序
    procedure __sort(var arr: TArr_str);
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

procedure TClean.__addFlie(dir: UString);
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
  arr[High(arr)] := str;
end;

constructor TClean.Create;
begin
  __search(GetCurrentDir);
end;

procedure TClean.ExecuteClean;
var
  i: integer;
  tempDir: UString;
  tempFlie: UString;
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

procedure TClean.__search(dir: UString);
var
  searchRec: TSearchRec;
  errDir, i: integer;
  tempDir: UString;
begin
  errDir := FindFirst(dir + PathDelim + '*.*', faAnyFile, searchRec);

  while errDir = 0 do
  begin
    if (searchRec.Name <> '.') and (searchRec.Name <> '..') and
      ((searchRec.Attr and faDirectory) = faDirectory) then
    begin
      tempDir := dir + PathDelim + searchRec.Name;

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
        __addFlie(tempDir);
        __append(__dirList, tempDir);
      end
      else
      begin
        for i := 0 to High(TARR_FILE_EXTENSION) do
        begin
          if KmpSearch(LowerCase(searchRec.Name), TARR_FILE_EXTENSION[i]) <> -1 then
            __append(__fileList, tempDir);
        end;
      end;

      __search(tempDir);
    end;

    errDir := FindNext(searchRec);
  end;

  FindClose(searchRec);
end;

procedure TClean.__sort(var arr: TArr_str);
var
  i, pass: integer;
  temp, s1, s2: UString;
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
