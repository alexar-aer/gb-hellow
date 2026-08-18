unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Grids, ExtCtrls, Menus, Buttons, dglOpenGL;

type
  TVector3 = record
    X, Y, Z: Single;
  end;

  TFace = record
    V1, V2, V3: Integer;
    N1, N2, N3: Integer;
  end;

  TPoint3D = record
    Pos: TVector3;
    ModelPoint: TVector3;
    FaceIndex: Integer;
  end;

  TMeasurement = record
    Point1Index: Integer;
    Point2Index: Integer;
    Distance: Single;
    ScaledDistance: Single;
  end;

  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Exit1: TMenuItem;
    Tools1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Panel2: TPanel;
    StringGrid1: TStringGrid;
    Panel3: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    EditScale: TEdit;
    BtnSetScale: TButton;
    BtnClearPoints: TButton;
    BtnClearMeasurements: TButton;
    Label4: TLabel;
    Label5: TLabel;
    LblPointCount: TLabel;
    LblMeasurementCount: TLabel;
    CbAutoConnect: TCheckBox;
    BtnExport: TButton;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Open1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure BtnSetScaleClick(Sender: TObject);
    procedure BtnClearPointsClick(Sender: TObject);
    procedure BtnClearMeasurementsClick(Sender: TObject);
    procedure CbAutoConnectChange(Sender: TObject);
    procedure BtnExportClick(Sender: TObject);
  private
    FVertices: array of TVector3;
    FNormals: array of TVector3;
    FFaces: array of TFace;
    FModelLoaded: Boolean;
    FModelCenter: TVector3;
    FModelSize: Single;
    
    FCameraPos: TVector3;
    FCameraTarget: TVector3;
    FCameraUp: TVector3;
    FRotationX, FRotationY: Single;
    FZoom: Single;
    
    FLastMouseX, FLastMouseY: Integer;
    FIsRotating: Boolean;
    FIsPanning: Boolean;
    
    FPoints: array of TPoint3D;
    FPointCount: Integer;
    FMeasurements: array of TMeasurement;
    FMeasurementCount: Integer;
    FScaleFactor: Single;
    FReferenceDistance: Single;
    
    FCursorPos: TVector3;
    FCursorOnSurface: Boolean;
    FCurrentFace: Integer;
    
    procedure LoadOBJFile(const FileName: string);
    procedure RenderModel;
    procedure RenderPoints;
    procedure RenderMeasurements;
    procedure RenderCursor;
    procedure SetupCamera;
    procedure SetupLighting;
    procedure ProjectPoint(X, Y: Integer; var Point: TVector3; var OnSurface: Boolean; var FaceIndex: Integer);
    function FindClosestPointOnMesh(const RayOrigin, RayDir: TVector3; var OutPoint: TVector3; var OutFace: Integer): Boolean;
    function CalculateDistance(const P1, P2: TVector3): Single;
    procedure AddMeasurement(P1Index, P2Index: Integer);
    procedure UpdateGrid;
    procedure CalculateBoundingBox;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True;
  
  FModelLoaded := False;
  FPointCount := 0;
  FMeasurementCount := 0;
  FScaleFactor := 1.0;
  FReferenceDistance := 0;
  
  FCameraPos := Vector3Make(0, 0, 5);
  FCameraTarget := Vector3Make(0, 0, 0);
  FCameraUp := Vector3Make(0, 1, 0);
  FRotationX := 0;
  FRotationY := 0;
  FZoom := 5;
  
  SetLength(FPoints, 1000);
  SetLength(FMeasurements, 1000);
  
  StringGrid1.ColCount := 5;
  StringGrid1.RowCount := 2;
  StringGrid1.Cells[0, 0] := 'N';
  StringGrid1.Cells[1, 0] := 'Point1';
  StringGrid1.Cells[2, 0] := 'Point2';
  StringGrid1.Cells[3, 0] := 'Distance';
  StringGrid1.Cells[4, 0] := 'Meters';
  StringGrid1.ColWidths[0] := 40;
  StringGrid1.ColWidths[1] := 60;
  StringGrid1.ColWidths[2] := 60;
  StringGrid1.ColWidths[3] := 100;
  StringGrid1.ColWidths[4] := 100;
  
  LblPointCount.Caption := '0';
  LblMeasurementCount.Caption := '0';
  EditScale.Text := '1.0';
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  if ClientWidth > 0 then
  begin
    glViewport(0, 0, ClientWidth, ClientHeight);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;
    gluPerspective(45, ClientWidth / ClientHeight, 0.1, 1000);
    glMatrixMode(GL_MODELVIEW);
  end;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  wglMakeCurrent(Canvas.Handle, FGLContext);
  
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glClearColor(0.95, 0.95, 0.95, 1);
  
  SetupCamera;
  SetupLighting;
  
  if FModelLoaded then
    RenderModel;
  
  RenderPoints;
  RenderMeasurements;
  RenderCursor;
  
  SwapBuffers(Canvas.Handle);
end;

procedure TForm1.SetupCamera;
begin
  glLoadIdentity;
  gluLookAt(FCameraPos.X, FCameraPos.Y, FCameraPos.Z,
            FCameraTarget.X, FCameraTarget.Y, FCameraTarget.Z,
            FCameraUp.X, FCameraUp.Y, FCameraUp.Z);
  
  glRotatef(FRotationX, 1, 0, 0);
  glRotatef(FRotationY, 0, 1, 0);
end;

procedure TForm1.SetupLighting;
var
  LightPos: array[0..3] of Single;
  Ambient, Diffuse: array[0..3] of Single;
begin
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glEnable(GL_NORMALIZE);
  
  LightPos[0] := 5; LightPos[1] := 5; LightPos[2] := 5; LightPos[3] := 1;
  glLightfv(GL_LIGHT0, GL_POSITION, @LightPos);
  
  Ambient[0] := 0.3; Ambient[1] := 0.3; Ambient[2] := 0.3; Ambient[3] := 1;
  glLightfv(GL_LIGHT0, GL_AMBIENT, @Ambient);
  
  Diffuse[0] := 0.8; Diffuse[1] := 0.8; Diffuse[2] := 0.8; Diffuse[3] := 1;
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @Diffuse);
  
  glEnable(GL_COLOR_MATERIAL);
  glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
end;

procedure TForm1.RenderModel;
var
  i: Integer;
  Face: TFace;
  Normal: TVector3;
begin
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_LIGHTING);
  
  glColor3f(0.8, 0.8, 0.8);
  
  glBegin(GL_TRIANGLES);
  for i := 0 to High(FFaces) do
  begin
    Face := FFaces[i];
    
    if Length(FNormals) > 0 then
    begin
      Normal := FNormals[Face.N1];
      glNormal3f(Normal.X, Normal.Y, Normal.Z);
    end;
    glVertex3f(FVertices[Face.V1].X, FVertices[Face.V1].Y, FVertices[Face.V1].Z);
    
    if Length(FNormals) > 0 then
    begin
      Normal := FNormals[Face.N2];
      glNormal3f(Normal.X, Normal.Y, Normal.Z);
    end;
    glVertex3f(FVertices[Face.V2].X, FVertices[Face.V2].Y, FVertices[Face.V2].Z);
    
    if Length(FNormals) > 0 then
    begin
      Normal := FNormals[Face.N3];
      glNormal3f(Normal.X, Normal.Y, Normal.Z);
    end;
    glVertex3f(FVertices[Face.V3].X, FVertices[Face.V3].Y, FVertices[Face.V3].Z);
  end;
  glEnd;
  
  glDisable(GL_LIGHTING);
  glColor3f(0.5, 0.5, 0.5);
  glBegin(GL_LINES);
  for i := 0 to High(FFaces) do
  begin
    Face := FFaces[i];
    glVertex3f(FVertices[Face.V1].X, FVertices[Face.V1].Y, FVertices[Face.V1].Z);
    glVertex3f(FVertices[Face.V2].X, FVertices[Face.V2].Y, FVertices[Face.V2].Z);
    glVertex3f(FVertices[Face.V2].X, FVertices[Face.V2].Y, FVertices[Face.V2].Z);
    glVertex3f(FVertices[Face.V3].X, FVertices[Face.V3].Y, FVertices[Face.V3].Z);
    glVertex3f(FVertices[Face.V3].X, FVertices[Face.V3].Y, FVertices[Face.V3].Z);
    glVertex3f(FVertices[Face.V1].X, FVertices[Face.V1].Y, FVertices[Face.V1].Z);
  end;
  glEnd;
end;

procedure TForm1.RenderPoints;
var
  i: Integer;
  Pt: TPoint3D;
begin
  glDisable(GL_LIGHTING);
  glPointSize(8);
  
  for i := 0 to FPointCount - 1 do
  begin
    Pt := FPoints[i];
    
    if i mod 2 = 0 then
      glColor3f(1, 0, 0)
    else
      glColor3f(0, 0, 1);
    
    glBegin(GL_POINTS);
    glVertex3f(Pt.Pos.X, Pt.Pos.Y, Pt.Pos.Z);
    glEnd;
  end;
end;

procedure TForm1.RenderMeasurements;
var
  i: Integer;
  Meas: TMeasurement;
  P1, P2: TPoint3D;
begin
  glDisable(GL_LIGHTING);
  glColor3f(0, 0.5, 0);
  glLineWidth(2);
  
  for i := 0 to FMeasurementCount - 1 do
  begin
    Meas := FMeasurements[i];
    P1 := FPoints[Meas.Point1Index];
    P2 := FPoints[Meas.Point2Index];
    
    glBegin(GL_LINES);
    glVertex3f(P1.Pos.X, P1.Pos.Y, P1.Pos.Z);
    glVertex3f(P2.Pos.X, P2.Pos.Y, P2.Pos.Z);
    glEnd;
  end;
end;

procedure TForm1.RenderCursor;
var
  angle: Single;
begin
  if FCursorOnSurface and FModelLoaded then
  begin
    glDisable(GL_LIGHTING);
    glColor3f(1, 0.5, 0);
    glPointSize(10);
    
    glBegin(GL_POINTS);
    glVertex3f(FCursorPos.X, FCursorPos.Y, FCursorPos.Z);
    glEnd;
    
    glBegin(GL_LINE_LOOP);
    for angle := 0 to 6.28 step 0.1 do
    begin
      glVertex3f(
        FCursorPos.X + Cos(angle) * 0.05,
        FCursorPos.Y + Sin(angle) * 0.05,
        FCursorPos.Z
      );
    end;
    glEnd;
  end;
end;

procedure TForm1.ProjectPoint(X, Y: Integer; var Point: TVector3; var OnSurface: Boolean; var FaceIndex: Integer);
var
  Viewport: array[0..3] of GLint;
  WinX, WinY, WinZ: Single;
  ObjX, ObjY, ObjZ: Single;
  RayOrigin, RayDir: TVector3;
begin
  OnSurface := False;
  FaceIndex := -1;
  
  glGetIntegerv(GL_VIEWPORT, @Viewport);
  
  WinX := X;
  WinY := Viewport[3] - Y;
  WinZ := 0;
  
  gluUnProject(WinX, WinY, WinZ, 
               ModelViewMatrix, ProjectionMatrix, Viewport,
               ObjX, ObjY, ObjZ);
  RayOrigin := Vector3Make(ObjX, ObjY, ObjZ);
  
  WinZ := 1;
  gluUnProject(WinX, WinY, WinZ,
               ModelViewMatrix, ProjectionMatrix, Viewport,
               ObjX, ObjY, ObjZ);
  RayDir := Vector3Make(ObjX, ObjY, ObjZ);
  RayDir := VectorSubtract(RayDir, RayOrigin);
  RayDir := VectorNormalize(RayDir);
  
  OnSurface := FindClosestPointOnMesh(RayOrigin, RayDir, Point, FaceIndex);
end;

function TForm1.FindClosestPointOnMesh(const RayOrigin, RayDir: TVector3; var OutPoint: TVector3; var OutFace: Integer): Boolean;
var
  i: Integer;
  Face: TFace;
  V1, V2, V3: TVector3;
  E1, E2, P, Q, T: TVector3;
  Det, U, V, TDist: Single;
  BestDist: Single;
  InvDet: Single;
begin
  Result := False;
  BestDist := 1e10;
  OutFace := -1;
  
  for i := 0 to High(FFaces) do
  begin
    Face := FFaces[i];
    V1 := FVertices[Face.V1];
    V2 := FVertices[Face.V2];
    V3 := FVertices[Face.V3];
    
    E1 := VectorSubtract(V2, V1);
    E2 := VectorSubtract(V3, V1);
    P := VectorCross(RayDir, E2);
    Det := VectorDot(E1, P);
    
    if Abs(Det) < 0.0001 then Continue;
    
    InvDet := 1 / Det;
    T := VectorSubtract(RayOrigin, V1);
    U := VectorDot(T, P) * InvDet;
    
    if (U < 0) or (U > 1) then Continue;
    
    Q := VectorCross(T, E1);
    V := VectorDot(RayDir, Q) * InvDet;
    
    if (V < 0) or (U + V > 1) then Continue;
    
    TDist := VectorDot(E2, Q) * InvDet;
    
    if (TDist > 0.01) and (TDist < BestDist) then
    begin
      BestDist := TDist;
      OutFace := i;
      Result := True;
      
      OutPoint.X := RayOrigin.X + RayDir.X * TDist;
      OutPoint.Y := RayOrigin.Y + RayDir.Y * TDist;
      OutPoint.Z := RayOrigin.Z + RayDir.Z * TDist;
    end;
  end;
end;

function TForm1.CalculateDistance(const P1, P2: TVector3): Single;
begin
  Result := Sqrt(Sqr(P2.X - P1.X) + Sqr(P2.Y - P1.Y) + Sqr(P2.Z - P1.Z));
end;

procedure TForm1.AddMeasurement(P1Index, P2Index: Integer);
begin
  if FMeasurementCount >= Length(FMeasurements) then
    SetLength(FMeasurements, FMeasurementCount + 100);
  
  FMeasurements[FMeasurementCount].Point1Index := P1Index;
  FMeasurements[FMeasurementCount].Point2Index := P2Index;
  FMeasurements[FMeasurementCount].Distance := 
    CalculateDistance(FPoints[P1Index].Pos, FPoints[P2Index].Pos);
  FMeasurements[FMeasurementCount].ScaledDistance := 
    FMeasurements[FMeasurementCount].Distance * FScaleFactor;
  
  Inc(FMeasurementCount);
  UpdateGrid;
end;

procedure TForm1.UpdateGrid;
var
  i: Integer;
begin
  StringGrid1.RowCount := FMeasurementCount + 1;
  
  for i := 0 to FMeasurementCount - 1 do
  begin
    StringGrid1.Cells[0, i + 1] := IntToStr(i + 1);
    StringGrid1.Cells[1, i + 1] := IntToStr(FMeasurements[i].Point1Index + 1);
    StringGrid1.Cells[2, i + 1] := IntToStr(FMeasurements[i].Point2Index + 1);
    StringGrid1.Cells[3, i + 1] := Format('%.4f', [FMeasurements[i].Distance]);
    StringGrid1.Cells[4, i + 1] := Format('%.4f', [FMeasurements[i].ScaledDistance]);
  end;
  
  LblMeasurementCount.Caption := IntToStr(FMeasurementCount);
end;

procedure TForm1.CalculateBoundingBox;
var
  i: Integer;
  MinX, MinY, MinZ, MaxX, MaxY, MaxZ: Single;
begin
  if Length(FVertices) = 0 then Exit;
  
  MinX := FVertices[0].X; MaxX := MinX;
  MinY := FVertices[0].Y; MaxY := MinY;
  MinZ := FVertices[0].Z; MaxZ := MinZ;
  
  for i := 1 to High(FVertices) do
  begin
    if FVertices[i].X < MinX then MinX := FVertices[i].X;
    if FVertices[i].X > MaxX then MaxX := FVertices[i].X;
    if FVertices[i].Y < MinY then MinY := FVertices[i].Y;
    if FVertices[i].Y > MaxY then MaxY := FVertices[i].Y;
    if FVertices[i].Z < MinZ then MinZ := FVertices[i].Z;
    if FVertices[i].Z > MaxZ then MaxZ := FVertices[i].Z;
  end;
  
  FModelCenter.X := (MinX + MaxX) / 2;
  FModelCenter.Y := (MinY + MaxY) / 2;
  FModelCenter.Z := (MinZ + MaxZ) / 2;
  
  FModelSize := Max(MaxX - MinX, Max(MaxY - MinY, MaxZ - MinZ));
  
  FCameraTarget := FModelCenter;
  FCameraPos := Vector3Make(FModelCenter.X, FModelCenter.Y, FModelCenter.Z + FModelSize * 2);
  FZoom := FModelSize * 2;
end;

procedure TForm1.LoadOBJFile(const FileName: string);
var
  SL: TStringList;
  i, j: Integer;
  Line: string;
  Parts: array of string;
  V: TVector3;
  Face: TFace;
  Indices: array[0..2] of Integer;
  VertexCount, FaceCount, NormalCount: Integer;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(FileName);
    
    SetLength(FVertices, 0);
    SetLength(FNormals, 0);
    SetLength(FFaces, 0);
    
    VertexCount := 0;
    FaceCount := 0;
    NormalCount := 0;
    
    for i := 0 to SL.Count - 1 do
    begin
      Line := Trim(SL[i]);
      if Copy(Line, 1, 1) = '#' then Continue;
      if Line = '' then Continue;
      
      Parts := nil;
      SplitString(Line, [' ', #9], Parts);
      
      if Parts[0] = 'v' then
      begin
        if Length(FVertices) <= VertexCount then
          SetLength(FVertices, VertexCount + 1000);
        
        V.X := StrToFloatDef(Parts[1], 0);
        V.Y := StrToFloatDef(Parts[2], 0);
        V.Z := StrToFloatDef(Parts[3], 0);
        FVertices[VertexCount] := V;
        Inc(VertexCount);
      end
      else if Parts[0] = 'vn' then
      begin
        if Length(FNormals) <= NormalCount then
          SetLength(FNormals, NormalCount + 1000);
        
        V.X := StrToFloatDef(Parts[1], 0);
        V.Y := StrToFloatDef(Parts[2], 0);
        V.Z := StrToFloatDef(Parts[3], 0);
        FNormals[NormalCount] := V;
        Inc(NormalCount);
      end
      else if Parts[0] = 'f' then
      begin
        if Length(FFaces) <= FaceCount then
          SetLength(FFaces, FaceCount + 1000);
        
        for j := 0 to 2 do
        begin
          if Pos('/', Parts[j + 1]) > 0 then
          begin
            Indices[j] := StrToIntDef(Copy(Parts[j + 1], 1, Pos('/', Parts[j + 1]) - 1), 1) - 1;
          end
          else
          begin
            Indices[j] := StrToIntDef(Parts[j + 1], 1) - 1;
          end;
        end;
        
        Face.V1 := Indices[0];
        Face.V2 := Indices[1];
        Face.V3 := Indices[2];
        Face.N1 := Indices[0];
        Face.N2 := Indices[1];
        Face.N3 := Indices[2];
        FFaces[FaceCount] := Face;
        Inc(FaceCount);
      end;
    end;
    
    SetLength(FVertices, VertexCount);
    SetLength(FNormals, NormalCount);
    SetLength(FFaces, FaceCount);
    
    FModelLoaded := True;
    CalculateBoundingBox;
    
    Caption := '3D Measure Tool - ' + ExtractFileName(FileName);
    
  finally
    SL.Free;
  end;
end;

procedure SplitString(const S: string; const Delims: TSysCharSet; var Parts: array of string);
var
  i, Start, Count: Integer;
  Temp: TStringList;
begin
  Temp := TStringList.Create;
  try
    Start := 1;
    Count := 0;
    for i := 1 to Length(S) do
    begin
      if S[i] in Delims then
      begin
        if i > Start then
        begin
          Temp.Add(Copy(S, Start, i - Start));
          Inc(Count);
        end;
        Start := i + 1;
      end;
    end;
    if Start <= Length(S) then
    begin
      Temp.Add(Copy(S, Start, Length(S) - Start + 1));
      Inc(Count);
    end;
    
    SetLength(Parts, Count);
    for i := 0 to Count - 1 do
      Parts[i] := Temp[i];
  finally
    Temp.Free;
  end;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if FIsRotating then
  begin
    FRotationY := FRotationY + (X - FLastMouseX) * 0.5;
    FRotationX := FRotationX + (Y - FLastMouseY) * 0.5;
  end;
  
  if FIsPanning then
  begin
    FCameraTarget.X := FCameraTarget.X + (X - FLastMouseX) * 0.01;
    FCameraTarget.Y := FCameraTarget.Y - (Y - FLastMouseY) * 0.01;
  end;
  
  FLastMouseX := X;
  FLastMouseY := Y;
  
  if FModelLoaded then
  begin
    ProjectPoint(X, Y, FCursorPos, FCursorOnSurface, FCurrentFace);
    Invalidate;
  end;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FLastMouseX := X;
  FLastMouseY := Y;
  
  if Button = mbLeft then
  begin
    if ssShift in Shift then
      FIsPanning := True
    else
    begin
      FIsRotating := True;
      
      if FCursorOnSurface and (FPointCount < Length(FPoints)) then
      begin
        FPoints[FPointCount].Pos := FCursorPos;
        FPoints[FPointCount].ModelPoint := FCursorPos;
        FPoints[FPointCount].FaceIndex := FCurrentFace;
        Inc(FPointCount);
        LblPointCount.Caption := IntToStr(FPointCount);
        
        if CbAutoConnect.Checked and (FPointCount >= 2) then
        begin
          AddMeasurement(FPointCount - 2, FPointCount - 1);
        end;
        
        Invalidate;
      end;
    end;
  end
  else if Button = mbRight then
  begin
    FIsRotating := True;
  end;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FIsRotating := False;
  FIsPanning := False;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: Close;
    VK_ADD, VK_UP: FZoom := FZoom * 0.9;
    VK_SUBTRACT, VK_DOWN: FZoom := FZoom * 1.1;
  end;
end;

procedure TForm1.Open1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    LoadOBJFile(OpenDialog1.FileName);
    Invalidate;
  end;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.About1Click(Sender: TObject);
begin
  MessageBox(Handle, 
    '3D Measure Tool v1.0'#13#10 +
    'Instrument for 3D model measurement'#13#10 +
    'Created for OBJ files'#13#10 +
    'Delphi 7 + OpenGL',
    'About', MB_OK or MB_ICONINFORMATION);
end;

procedure TForm1.BtnSetScaleClick(Sender: TObject);
var
  i: Integer;
begin
  if FMeasurementCount < 1 then
  begin
    MessageBox(Handle, 'First create at least one measurement between reference points!', 
      'Warning', MB_OK or MB_ICONWARNING);
    Exit;
  end;
  
  try
    FReferenceDistance := StrToFloat(EditScale.Text);
    if FReferenceDistance <= 0 then
    begin
      MessageBox(Handle, 'Scale must be positive!', 
        'Error', MB_OK or MB_ICONERROR);
      Exit;
    end;
    
    FScaleFactor := FReferenceDistance / FMeasurements[0].Distance;
    
    for i := 0 to FMeasurementCount - 1 do
    begin
      FMeasurements[i].ScaledDistance := FMeasurements[i].Distance * FScaleFactor;
    end;
    
    UpdateGrid;
    MessageBox(Handle, 'Scale set! All measurements recalculated.', 
      'Success', MB_OK or MB_ICONINFORMATION);
  except
    MessageBox(Handle, 'Invalid number format!', 'Error', MB_OK or MB_ICONERROR);
  end;
end;

procedure TForm1.BtnClearPointsClick(Sender: TObject);
begin
  if MessageBox(Handle, 'Delete all points and measurements?', 'Confirm', 
     MB_YESNO or MB_ICONQUESTION) = ID_YES then
  begin
    FPointCount := 0;
    FMeasurementCount := 0;
    LblPointCount.Caption := '0';
    LblMeasurementCount.Caption := '0';
    UpdateGrid;
    Invalidate;
  end;
end;

procedure TForm1.BtnClearMeasurementsClick(Sender: TObject);
begin
  FMeasurementCount := 0;
  UpdateGrid;
  Invalidate;
end;

procedure TForm1.CbAutoConnectChange(Sender: TObject);
begin
end;

procedure TForm1.BtnExportClick(Sender: TObject);
var
  SL: TStringList;
  i: Integer;
begin
  if SaveDialog1.Execute then
  begin
    SL := TStringList.Create;
    try
      SL.Add('3D Measurement Report');
      SL.Add('=====================');
      SL.Add('Date: ' + DateTimeToStr(Now));
      SL.Add('Scale Factor: ' + FloatToStr(FScaleFactor));
      SL.Add('');
      SL.Add('Points:');
      for i := 0 to FPointCount - 1 do
      begin
        SL.Add(Format('Point %d: X=%.4f Y=%.4f Z=%.4f', 
          [i + 1, FPoints[i].Pos.X, FPoints[i].Pos.Y, FPoints[i].Pos.Z]));
      end;
      SL.Add('');
      SL.Add('Measurements:');
      SL.Add('No.| Point1 | Point2 | Distance(units) | Distance(meters)');
      for i := 0 to FMeasurementCount - 1 do
      begin
        SL.Add(Format('%3d | %6d | %6d | %15.4f | %16.4f',
          [i + 1, 
           FMeasurements[i].Point1Index + 1,
           FMeasurements[i].Point2Index + 1,
           FMeasurements[i].Distance,
           FMeasurements[i].ScaledDistance]));
      end;
      
      SL.SaveToFile(SaveDialog1.FileName);
      MessageBox(Handle, 'Data exported successfully!', 'Success', MB_OK or MB_ICONINFORMATION);
    finally
      SL.Free;
    end;
  end;
end;

function Vector3Make(X, Y, Z: Single): TVector3;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;

function VectorAdd(const V1, V2: TVector3): TVector3;
begin
  Result.X := V1.X + V2.X;
  Result.Y := V1.Y + V2.Y;
  Result.Z := V1.Z + V2.Z;
end;

function VectorSubtract(const V1, V2: TVector3): TVector3;
begin
  Result.X := V1.X - V2.X;
  Result.Y := V1.Y - V2.Y;
  Result.Z := V1.Z - V2.Z;
end;

function VectorMultiply(const V: TVector3; S: Single): TVector3;
begin
  Result.X := V.X * S;
  Result.Y := V.Y * S;
  Result.Z := V.Z * S;
end;

function VectorDot(const V1, V2: TVector3): Single;
begin
  Result := V1.X * V2.X + V1.Y * V2.Y + V1.Z * V2.Z;
end;

function VectorCross(const V1, V2: TVector3): TVector3;
begin
  Result.X := V1.Y * V2.Z - V1.Z * V2.Y;
  Result.Y := V1.Z * V2.X - V1.X * V2.Z;
  Result.Z := V1.X * V2.Y - V1.Y * V2.X;
end;

function VectorLength(const V: TVector3): Single;
begin
  Result := Sqrt(Sqr(V.X) + Sqr(V.Y) + Sqr(V.Z));
end;

function VectorNormalize(const V: TVector3): TVector3;
var
  Len: Single;
begin
  Len := VectorLength(V);
  if Len > 0 then
  begin
    Result.X := V.X / Len;
    Result.Y := V.Y / Len;
    Result.Z := V.Z / Len;
  end
  else
    Result := V;
end;

end.
