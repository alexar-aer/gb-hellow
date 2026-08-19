///<summary>
/// Модуль uMath: Математические функции для 3D вычислений.
/// Предназначение: Реализация векторной алгебры, нормализации, скалярного произведения и преобразований.
/// Статистика:
///   - Типы: 0
///   - Константы: 1 (EPSILON)
///   - Переменные: 0
///   - Функции/Процедуры: 8 (VectorAdd, VectorSub, VectorMul, VectorDot, VectorCross, VectorLength, VectorNormalize, Distance3D)
///   - Классы: 0
///</summary>
unit uMath;

interface

uses
  uTypes;

const
  EPSILON = 0.00001;

/// <summary>Сложение векторов</summary>
function VectorAdd(const A, B: TVector3): TVector3;
/// <summary>Вычитание векторов</summary>
function VectorSub(const A, B: TVector3): TVector3;
/// <summary>Умножение вектора на скаляр</summary>
function VectorMul(const V: TVector3; S: Single): TVector3;
/// <summary>Скалярное произведение</summary>
function VectorDot(const A, B: TVector3): Single;
/// <summary>Векторное произведение</summary>
function VectorCross(const A, B: TVector3): TVector3;
/// <summary>Длина вектора</summary>
function VectorLength(const V: TVector3): Single;
/// <summary>Нормализация вектора</summary>
function VectorNormalize(const V: TVector3): TVector3;
/// <summary>Расстояние между двумя точками</summary>
function Distance3D(const A, B: TVector3): Single;

implementation

function VectorAdd(const A, B: TVector3): TVector3;
begin
  Result.X := A.X + B.X;
  Result.Y := A.Y + B.Y;
  Result.Z := A.Z + B.Z;
end;

function VectorSub(const A, B: TVector3): TVector3;
begin
  Result.X := A.X - B.X;
  Result.Y := A.Y - B.Y;
  Result.Z := A.Z - B.Z;
end;

function VectorMul(const V: TVector3; S: Single): TVector3;
begin
  Result.X := V.X * S;
  Result.Y := V.Y * S;
  Result.Z := V.Z * S;
end;

function VectorDot(const A, B: TVector3): Single;
begin
  Result := A.X * B.X + A.Y * B.Y + A.Z * B.Z;
end;

function VectorCross(const A, B: TVector3): TVector3;
begin
  Result.X := A.Y * B.Z - A.Z * B.Y;
  Result.Y := A.Z * B.X - A.X * B.Z;
  Result.Z := A.X * B.Y - A.Y * B.X;
end;

function VectorLength(const V: TVector3): Single;
begin
  Result := Sqrt(VectorDot(V, V));
end;

function VectorNormalize(const V: TVector3): TVector3;
var
  Len: Single;
begin
  Len := VectorLength(V);
  if Len > EPSILON then
    Result := VectorMul(V, 1.0 / Len)
  else
    Result := V;
end;

function Distance3D(const A, B: TVector3): Single;
var
  Diff: TVector3;
begin
  Diff := VectorSub(B, A);
  Result := VectorLength(Diff);
end;

end.
