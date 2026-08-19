object MainForm: TMainForm
  Left = 200
  Top = 150
  Width = 1024
  Height = 768
  Caption = '3D Measure - Измерение 3D моделей'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 769
    Height = 714
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
  end
  object ListView1: TListView
    Left = 769
    Top = 0
    Width = 239
    Height = 714
    Align = alRight
    Columns = <>
    TabOrder = 1
    ViewStyle = vsReport
  end
  object MainMenu1: TMainMenu
    Left = 48
    Top = 48
    object FileMenu: TMenuItem
      Caption = '&Файл'
      object LoadMenuItem: TMenuItem
        Caption = '&Загрузить модель...'
        OnClick = LoadMenuItemClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object ExitMenuItem: TMenuItem
        Caption = 'В&ыход'
        OnClick = ExitMenuItemClick
      end
    end
    object ToolsMenu: TMenuItem
      Caption = '&Инструменты'
      object AddPointMenuItem: TMenuItem
        Caption = '&Добавить точку'
      end
      object ClearMenuItem: TMenuItem
        Caption = '&Очистить все'
        OnClick = ClearMenuItemClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object ExportMenuItem: TMenuItem
        Caption = '&Экспорт данных...'
        OnClick = ExportMenuItemClick
      end
    end
    object HelpMenu: TMenuItem
      Caption = '&Справка'
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'OBJ файлы|*.obj|Все файлы|*.*'
    Left = 96
    Top = 48
  end
  object SaveDialog1: TSaveDialog
    Filter = 'TXT файлы|*.txt|CSV файлы|*.csv|Все файлы|*.*'
    Left = 144
    Top = 48
  end
end
