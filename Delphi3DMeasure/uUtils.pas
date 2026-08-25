///<summary>
/// Модуль uUtils: Утилиты для загрузки и обработки данных.
/// Предназначение: Чтение OBJ файлов, парсинг строк, вспомогательные функции.
/// Статистика:
///   - Типы: 0
///   - Константы: 0
///   - Переменные: 0
///   - Функции/Процедуры: 4 (LoadOBJ, ParseVector, TrimStr, FileExistsEx)
///   - Классы: 0
///</summary>
unit uUtils;

interface

uses
  Classes, SysUtils, uTypes;

/// <summary>Загрузка модели из OBJ файла</summary>
function LoadOBJ(const FileName: string; var Vertices: array of TVertex; var Faces: array of TFace): Boolean;
/// <summary>Парсинг строки в вектор</summary>
function ParseVector(const S: string): TVector3;
/// <summary>Удаление пробелов по краям</summary>
function TrimStr(const S: string): string;
/// <summary>Проверка существования файла</summary>
function FileExistsEx(const FileName: string): Boolean;

implementation

function TrimStr(const S: string): string;
var
  I, J: Integer;
begin
  I := 1;
  J := Length(S);
  while (I <= J) and (S[I] <= ' ') do Inc(I);
  while (J >= I) and (S[J] <= ' ') do Dec(J);
  Result := Copy(S, I, J - I + 1);
end;

function ParseVector(const S: string): TVector3;
var
  Parts: TStringList;
  X, Y, Z: Single;
begin
  Parts := TStringList.Create;
  try
    Parts.Delimiter := ' ';
    Parts.StrictDelimiter := True;
    Parts.DelimitedText := TrimStr(S);
    if Parts.Count >= 3 then
    begin
      X := StrToFloat(Parts[0]);
      Y := StrToFloat(Parts[1]);
      Z := StrToFloat(Parts[2]);
      Result := TVector3(X, Y, Z);
    end
    else
      Result := TVector3(0, 0, 0);
  finally
    Parts.Free;
  end;
end;

function FileExistsEx(const FileName: string): Boolean;
begin
  Result := FileExists(FileName);
end;

function LoadOBJ(const FileName: string; var Vertices: array of TVertex; var Faces: array of TFace): Boolean;
var
  F: TextFile;
  Line, Cmd: string;
  VCount, FCount: Integer;
begin
  Result := False;
  if not FileExists(FileName) then Exit;
  
  AssignFile(F, FileName);
  Reset(F);
  VCount := 0;
  FCount := 0;
  
  try
    while not Eof(F) do
    begin
      ReadLn(F, Line);
      Line := TrimStr(Line);
      if Length(Line) < 2 then Continue;
      
      Cmd := Copy(Line, 1, 1);
      Delete(Line, 1, 1);
      Line := TrimStr(Line);
      
      if Cmd = 'v' then
      begin
        // Парсинг вершин (упрощенно)
        if VCount < Length(Vertices) then
        begin
          Vertices[VCount].Pos := ParseVector(Line);
          Vertices[VCount].Normal := TVector3(0, 1, 0);
          Vertices[VCount].Tex := TVector3(0, 0, 0);
          Inc(VCount);
        end;
      end
      else if Cmd = 'f' then
      begin
        // Парсинг граней (упрощенно)
        if FCount < Length(Faces) then
        begin
          // Здесь нужен полноценный парсер индексов
          Inc(FCount);
        end;
      end;
    end;
    Result := True;
  finally
    CloseFile(F);
  end;
end;

end.
