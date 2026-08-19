///<summary>
/// Модуль uTypes: Определение базовых типов данных для 3D графики.
/// Предназначение: Содержит записи для представления векторов, вершин, граней и материалов.
/// Статистика:
///   - Типы: 6 (TVector3, TVertex, TFace, TMaterial, TPoint3D, TMeasurement)
///   - Константы: 2
///   - Переменные: 0
///   - Функции/Процедуры: 0
///   - Классы: 0
///</summary>
unit uTypes;

interface

type
  /// <summary>Трехмерный вектор или точка</summary>
  TVector3 = record
    X, Y, Z: Single;
  end;

  /// <summary>Вершина модели с нормалью и текстурной координатой</summary>
  TVertex = record
    Pos: TVector3;
    Normal: TVector3;
    Tex: TVector3;
  end;

  /// <summary>Грань (треугольник), ссылающаяся на индексы вершин</summary>
  TFace = record
    v1, v2, v3: Integer;
  end;

  /// <summary>Материал (заглушка для простоты)</summary>
  TMaterial = record
    Name: string;
    Color: TVector3;
  end;

  /// <summary>Точка в 3D пространстве для измерений</summary>
  TPoint3D = record
    Pos: TVector3;
    Label: string;
    Selected: Boolean;
  end;

  /// <summary>Результат измерения между двумя точками</summary>
  TMeasurement = record
    PointA, PointB: TPoint3D;
    Distance: Single;
    ScaleFactor: Single;
    RealDistance: Single;
  end;

const
  DEF_SCALE = 1.0;
  MAX_POINTS = 100;

implementation

end.
