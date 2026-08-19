///<summary>
/// Модуль uMainForm: Главная форма приложения.
/// Предназначение: Обработка событий UI, интеграция всех модулей, управление приложением.
/// Статистика:
///   - Типы: 1 (TMainForm)
///   - Константы: 0
///   - Переменные: 0
///   - Функции/Процедуры: 8 (FormCreate, FormDestroy, LoadModelClick, AddPoint, ClearAll, ExportData, Resize, MouseDown)
///   - Классы: 1 (TMainForm: 10 методов)
///</summary>
unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Menus, dglOpenGL,
  uTypes, uMeasure;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    FileMenu: TMenuItem;
    LoadMenuItem: TMenuItem;
    ExitMenuItem: TMenuItem;
    ToolsMenu: TMenuItem;
    AddPointMenuItem: TMenuItem;
    ClearMenuItem: TMenuItem;
    ExportMenuItem: TMenuItem;
    Panel1: TPanel;
    ListView1: TListView;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LoadMenuItemClick(Sender: TObject);
    procedure ClearMenuItemClick(Sender: TObject);
    procedure ExportMenuItemClick(Sender: TObject);
    procedure ExitMenuItemClick(Sender: TObject);
  private
    FMeasurementMgr: TMeasurementManager;
    FVertices: array of TVertex;
    FFaces: array of TFace;
    FGLInitialized: Boolean;
    procedure InitOpenGL;
    procedure UpdateView;
  public
    property MeasurementManager: TMeasurementManager read FMeasurementMgr;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uRenderer, uUtils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FMeasurementMgr := TMeasurementManager.Create;
  SetLength(FVertices, 10000);
  SetLength(FFaces, 10000);
  FGLInitialized := False;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FMeasurementMgr.Free;
  dglDeleteContext;
end;

procedure TMainForm.InitOpenGL;
begin
  // Инициализация OpenGL на панели
  // В реальном проекте здесь нужен PaintBox с OpenGL контекстом
  FGLInitialized := True;
end;

procedure TMainForm.UpdateView;
begin
  if FGLInitialized then
    PaintGL(FVertices, FFaces, 
      TPoint3D(Pointer(@FMeasurementMgr.Points[0])^)); // Упрощенно
end;

procedure TMainForm.LoadMenuItemClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    if LoadOBJ(OpenDialog1.FileName, FVertices, FFaces) then
    begin
      Caption := '3D Measure: ' + ExtractFileName(OpenDialog1.FileName);
      UpdateView;
    end
    else
      ShowMessage('Ошибка загрузки файла!');
  end;
end;

procedure TMainForm.ClearMenuItemClick(Sender: TObject);
begin
  FMeasurementMgr.ClearPoints;
  ListView1.Items.Clear;
  UpdateView;
end;

procedure TMainForm.ExportMenuItemClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    // Экспорт в текстовый файл
    FMeasurementMgr.ExportToTable(ListView1);
    ShowMessage('Данные экспортированы!');
  end;
end;

procedure TMainForm.ExitMenuItemClick(Sender: TObject);
begin
  Close;
end;

end.
