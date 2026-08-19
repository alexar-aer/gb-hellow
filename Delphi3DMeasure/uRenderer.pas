///<summary>
/// Модуль uRenderer: Рендеринг 3D сцены с использованием OpenGL.
/// Предназначение: Инициализация OpenGL, отрисовка модели, курсора и измерений.
/// Статистика:
///   - Типы: 1 (TSceneManager)
///   - Константы: 0
///   - Переменные: 0
///   - Функции/Процедуры: 6 (InitGL, ResizeGL, PaintGL, DrawModel, DrawCursor, DrawMeasurements)
///   - Классы: 1 (TSceneManager: 3 метода)
///</summary>
unit uRenderer;

interface

uses
  Windows, dglOpenGL, uTypes, Classes;

type
  /// <summary>Менеджер сцены для управления состоянием OpenGL</summary>
  TSceneManager = class
  private
    FLightPos: TVector3;
    FCameraPos: TVector3;
  public
    procedure Init;
    procedure SetLight(const Pos: TVector3);
    procedure SetCamera(const Pos: TVector3);
  end;

/// <summary>Инициализация OpenGL контекста</summary>
function InitGL(DC: HDC): Boolean;
/// <summary>Обработка изменения размера окна</summary>
procedure ResizeGL(Width, Height: Integer);
/// <summary>Отрисовка сцены</summary>
procedure PaintGL(Vertices: array of TVertex; Faces: array of TFace; Points: array of TPoint3D);
/// <summary>Отрисовка модели</summary>
procedure DrawModel(Vertices: array of TVertex; Faces: array of TFace);
/// <summary>Отрисовка 3D курсора</summary>
procedure DrawCursor(const Pos: TVector3);
/// <summary>Отрисовка линий измерений</summary>
procedure DrawMeasurements(Points: array of TPoint3D);

implementation

var
  SceneManager: TSceneManager;

function InitGL(DC: HDC): Boolean;
var
  PixelFormat: Integer;
  PFD: TPixelFormatDescriptor;
begin
  Result := False;
  
  FillChar(PFD, SizeOf(PFD), 0);
  PFD.nSize := SizeOf(PFD);
  PFD.nVersion := 1;
  PFD.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  PFD.iPixelType := PFD_TYPE_RGBA;
  PFD.cColorBits := 24;
  PFD.cDepthBits := 32;
  PFD.iLayerType := PFD_MAIN_PLANE;
  
  PixelFormat := ChoosePixelFormat(DC, @PFD);
  if PixelFormat = 0 then Exit;
  
  if not SetPixelFormat(DC, PixelFormat, @PFD) then Exit;
  
  if not dglCreateContext(DC) then Exit;
  if not dglMakeCurrent(DC) then Exit;
  
  SceneManager := TSceneManager.Create;
  SceneManager.Init;
  
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glEnable(GL_COLOR_MATERIAL);
  glShadeModel(GL_SMOOTH);
  
  Result := True;
end;

procedure ResizeGL(Width, Height: Integer);
begin
  if Height = 0 then Height := 1;
  glViewport(0, 0, Width, Height);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(45.0, Width / Height, 0.1, 1000.0);
  glMatrixMode(GL_MODELVIEW);
end;

procedure PaintGL(Vertices: array of TVertex; Faces: array of TFace; Points: array of TPoint3D);
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;
  
  SceneManager.SetCamera(TVector3(0, 0, 5));
  gluLookAt(0, 0, 5, 0, 0, 0, 0, 1, 0);
  
  DrawModel(Vertices, Faces);
  DrawMeasurements(Points);
  
  // Отрисовка курсора в последней точке
  if Length(Points) > 0 then
    DrawCursor(Points[High(Points)].Pos);
end;

procedure DrawModel(Vertices: array of TVertex; Faces: array of TFace);
var
  I: Integer;
begin
  glPushMatrix;
  glColor3f(0.8, 0.8, 0.8);
  
  glBegin(GL_TRIANGLES);
  for I := 0 to High(Faces) do
  begin
    // Упрощенная отрисовка без нормалей
    glVertex3f(Vertices[Faces[I].v1].Pos.X, Vertices[Faces[I].v1].Pos.Y, Vertices[Faces[I].v1].Pos.Z);
    glVertex3f(Vertices[Faces[I].v2].Pos.X, Vertices[Faces[I].v2].Pos.Y, Vertices[Faces[I].v2].Pos.Z);
    glVertex3f(Vertices[Faces[I].v3].Pos.X, Vertices[Faces[I].v3].Pos.Y, Vertices[Faces[I].v3].Pos.Z);
  end;
  glEnd;
  
  glPopMatrix;
end;

procedure DrawCursor(const Pos: TVector3);
begin
  glPushMatrix;
  glTranslatef(Pos.X, Pos.Y, Pos.Z);
  glColor3f(1, 0, 0);
  glutWireSphere(0.05, 8, 8); // Требуется GLUT или своя реализация
  glPopMatrix;
end;

procedure DrawMeasurements(Points: array of TPoint3D);
var
  I: Integer;
begin
  if Length(Points) < 2 then Exit;
  
  glLineWidth(2.0);
  glBegin(GL_LINES);
  glColor3f(0, 1, 0);
  
  for I := 0 to High(Points) - 1 do
  begin
    glVertex3f(Points[I].Pos.X, Points[I].Pos.Y, Points[I].Pos.Z);
    glVertex3f(Points[I + 1].Pos.X, Points[I + 1].Pos.Y, Points[I + 1].Pos.Z);
  end;
  glEnd;
end;

{ TSceneManager }

procedure TSceneManager.Init;
begin
  FLightPos := TVector3(5, 5, 5);
  FCameraPos := TVector3(0, 0, 5);
end;

procedure TSceneManager.SetLight(const Pos: TVector3);
var
  LightPos: array[0..3] of Single;
begin
  FLightPos := Pos;
  LightPos[0] := Pos.X;
  LightPos[1] := Pos.Y;
  LightPos[2] := Pos.Z;
  LightPos[3] := 1.0;
  glLightfv(GL_LIGHT0, GL_POSITION, @LightPos[0]);
end;

procedure TSceneManager.SetCamera(const Pos: TVector3);
begin
  FCameraPos := Pos;
end;

initialization
finalization
  if Assigned(SceneManager) then
    SceneManager.Free;

end.
