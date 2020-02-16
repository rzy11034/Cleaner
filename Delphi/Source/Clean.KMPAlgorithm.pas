unit Clean.KMPAlgorithm;

interface

uses
  System.SysUtils,
  Clean.Utils;

  /// <summary> KMP算法  </summary>
  /// <param name="SourceStr">源字符串</param>
  /// <param name="matchStr">待匹配字符串</param>
  /// <returns> 如果匹配返回匹配位置的下标，否则返回 -1 </returns>
function KmpSearch(const SourceStr, matchStr: UString): integer;

implementation

function KmpNext(const str: UString): TArr_int;
var
  Next: TArr_int;
  j, i: integer;
begin
  // 创建一个 next 数组保存部分匹配值
  SetLength(Next, str.Length);
  Next[0] := 0; // 如果字符串是长度为 1, 部分匹配值就是 0

  j := 0;
  for i := 1 to str.Length - 1 do
  begin
    // 当 dest.charAt(i) <> dest.charAt(j) ，我们需要从 next[j-1] 获取新的 j
    // 直到我们发现有 dest.charAt(i) = dest.charAt(j) 成立才退出
    // 这是 kmp 算法的核心点
    while (j > 0) and (str.Chars[i] <> str.Chars[j]) do
      j := Next[j - 1];

    //当 str.Chars[i] = str.Chars[j] 满足时，部分匹配值就 +1
    if str.Chars[i] = str.Chars[j] then
      Inc(j);

    Next[i] := j;
  end;

  Result := Next;
end;

function KmpSearch(const SourceStr, matchStr: UString): integer;
var
  Next: TArr_int;
  j, i: integer;
begin
  Next := KmpNext(matchStr);

  // 遍历
  j := 0;
  for i := 0 to SourceStr.Length - 1 do
  begin

    //需要处理 SourceStr.Chars[i] <> matchStr.Chars[j], 去调整 j 的大小
    //KMP算法核心点, 可以验证...
    while (j > 0) and (SourceStr.Chars[i] <> matchStr.Chars[j]) do
      j := Next[j - 1];

    if SourceStr.Chars[i] = matchStr.Chars[j] then
      Inc(j);

    if j = matchStr.Length then //找到了 // j = 3 i
    begin
      Result := i - j + 1;
      Exit;
    end;
  end;

  Result := -1;
end;

end.
