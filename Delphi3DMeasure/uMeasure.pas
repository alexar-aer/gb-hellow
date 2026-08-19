///<summary>
/// Модуль uMeasure: Логика измерений и управление точками.
/// Предназначение: Добавление точек, расчет расстояний, масштабирование по реперам.
/// Статистика:
///   - Типы: 1 (TMeasurementManager)
///   - Константы: 0
///   - Переменные: 0
///   - Функции/Процедуры: 5 (AddPoint, ClearPoints, GetDistance, SetScale, ExportToTable)
///   - Классы: 1 (TMeasurementManager: 6 методов)
///</summary>
unit uMeasure;

interface

uses
  uTypes, Classes, ComCtrls;

type
  /// <summary>Менеджер измерений для работы с точками и расстояниями</summary>
  TMeasurementManager = class
  private
    FPoints: array of TPoint3D;
    FScaleFactor: Single;
    FReperSet: Boolean;
    FReperDistance: Single;
  public
    constructor Create;
    procedure AddPoint(const Pos: TVector3; const Label: string);
    procedure ClearPoints;
    function GetCount: Integer;
    function GetPoint(Index: Integer): TPoint3D;
    function CalculateDistance(Index1, Index2: Integer): Single;
    procedure SetScale(RealDistance: Single);
    procedure ExportToTable(ListView: TListView);
    property Count: Integer read GetCount;
    property Points[Index: Integer]: TPoint3D read GetPoint;
    property ScaleFactor: Single read FScaleFactor;
  end;

implementation

{ TMeasurementManager }

constructor TMeasurementManager.Create;
begin
  inherited;
  SetLength(FPoints, 0);
  FScaleFactor := DEF_SCALE;
  FReperSet := False;
  FReperDistance := 0;
end;

procedure TMeasurementManager.AddPoint(const Pos: TVector3; const Label: string);
var
  Len: Integer;
begin
  Len := Length(FPoints);
  SetLength(FPoints, Len + 1);
  FPoints[Len].Pos := Pos;
  FPoints[Len].Label := Label;
  FPoints[Len].Selected := False;
end;

procedure TMeasurementManager.ClearPoints;
begin
  SetLength(FPoints, 0);
  FScaleFactor := DEF_SCALE;
  FReperSet := False;
end;

function TMeasurementManager.GetCount: Integer;
begin
  Result := Length(FPoints);
end;

function TMeasurementManager.GetPoint(Index: Integer): TPoint3D;
begin
  if (Index >= 0) and (Index < Length(FPoints)) then
    Result := FPoints[Index]
  else
    Result := TPoint3D(TVector3(0,0,0), '', False);
end;

function TMeasurementManager.CalculateDistance(Index1, Index2: Integer): Single;
var
  D: Single;
begin
  if (Index1 >= 0) and (Index2 >= 0) and 
     (Index1 < Length(FPoints)) and (Index2 < Length(FPoints)) then
  begin
    D := Distance3D(FPoints[Index1].Pos, FPoints[Index2].Pos);
    Result := D * FScaleFactor;
  end
  else
    Result := 0;
end;

procedure TMeasurementManager.SetScale(RealDistance: Single);
var
  CurrentDist: Single;
begin
  if FReperSet and (FReperDistance > EPSILON) then
  begin
    FScaleFactor := RealDistance / FReperDistance;
  end
  else
  begin
    // Если реперы не заданы, используем первое и последнее расстояние
    if Length(FPoints) >= 2 then
    begin
      CurrentDist := Distance3D(FPoints[0].Pos, FPoints[High(FPoints)].Pos);
      if CurrentDist > EPSILON then
        FScaleFactor := RealDistance / CurrentDist;
    end;
  end;
end;

procedure TMeasurementManager.ExportToTable(ListView: TListView);
var
  I: Integer;
  Item: TListItem;
  Dist: Single;
begin
  ListView.Items.Clear;
  
  // Заголовки
  ListView.Columns.Clear;
  ListView.Columns.Add('№', 30);
  ListView.Columns.Add('Точка A', 80);
  ListView.Columns.Add('Точка B', 80);
  ListView.Columns.Add('Расстояние (ед.)', 100);
  ListView.Columns.Add('Расстояние (м)', 100);
  
  for I := 0 to Length(FPoints) - 2 do
  begin
    Item := ListView.Items.Add;
    Item.Caption := IntToStr(I + 1);
    Item.SubItems.Add(FPoints[I].Label);
    Item.SubItems.Add(FPoints[I + 1].Label);
    
    Dist := Distance3D(FPoints[I].Pos, FPoints[I + 1].Pos);
    Item.SubItems.Add(FormatFloat('0.000', Dist));
    Item.SubItems.Add(FormatFloat('0.000', Dist * FScaleFactor));
  end;
end;

end.
