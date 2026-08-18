object Form1: TForm1
  Left = 200
  Top = 150
  Width = 1024
  Height = 768
  Caption = '3D Measure Tool'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 769
    Height = 729
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
  end
  object Splitter1: TSplitter
    Left = 769
    Top = 0
    Width = 5
    Height = 729
    Align = alRight
    Color = clGray
    ParentColor = False
  end
  object Panel2: TPanel
    Left = 774
    Top = 0
    Width = 234
    Height = 729
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 2
    object StringGrid1: TStringGrid
      Left = 0
      Top = 200
      Width = 234
      Height = 529
      Align = alClient
      ColCount = 5
      DefaultColWidth = 40
      DefaultRowHeight = 20
      FixedCols = 0
      RowCount = 2
      FixedRows = 1
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
      TabOrder = 0
    end
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 234
      Height = 200
      Align = alTop
      BevelOuter = bvLowered
      TabOrder = 1
      object Label1: TLabel
        Left = 10
        Top = 15
        Width = 80
        Height = 13
        Caption = 'Reference (meters):'
      end
      object Label2: TLabel
        Left = 10
        Top = 70
        Width = 65
        Height = 13
        Caption = 'Points count:'
      end
      object Label3: TLabel
        Left = 10
        Top = 95
        Width = 90
        Height = 13
        Caption = 'Measurements:'
      end
      object Label4: TLabel
        Left = 10
        Top = 145
        Width = 150
        Height = 13
        Caption = 'Shift+LMB - Pan, Wheel - Zoom'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGrayText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label5: TLabel
        Left = 10
        Top = 165
        Width = 120
        Height = 13
        Caption = 'LMB - Rotate/Add point'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGrayText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object EditScale: TEdit
        Left = 10
        Top = 35
        Width = 100
        Height = 21
        TabOrder = 0
        Text = '1.0'
      end
      object BtnSetScale: TButton
        Left = 120
        Top = 33
        Width = 100
        Height = 25
        Caption = 'Set Scale'
        TabOrder = 1
        OnClick = BtnSetScaleClick
      end
      object BtnClearPoints: TButton
        Left = 10
        Top = 115
        Width = 100
        Height = 25
        Caption = 'Clear All'
        TabOrder = 2
        OnClick = BtnClearPointsClick
      end
      object BtnClearMeasurements: TButton
        Left = 120
        Top = 115
        Width = 100
        Height = 25
        Caption = 'Clear Measures'
        TabOrder = 3
        OnClick = BtnClearMeasurementsClick
      end
      object CbAutoConnect: TCheckBox
        Left = 10
        Top = 55
        Width = 150
        Height = 17
        Caption = 'Auto-connect points'
        Checked = True
        State = cbChecked
        TabOrder = 4
        OnChange = CbAutoConnectChange
      end
      object BtnExport: TButton
        Left = 10
        Top = 145
        Width = 100
        Height = 25
        Caption = 'Export'
        TabOrder = 5
        OnClick = BtnExportClick
      end
      object LblPointCount: TLabel
        Left = 110
        Top = 70
        Width = 6
        Height = 13
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LblMeasurementCount: TLabel
        Left = 110
        Top = 95
        Width = 6
        Height = 13
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 32
    Top = 32
    object File1: TMenuItem
      Caption = 'File'
      object Open1: TMenuItem
        Caption = 'Open OBJ...'
        ShortCut = 16463
        OnClick = Open1Click
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        ShortCut = 32883
        OnClick = Exit1Click
      end
    end
    object Tools1: TMenuItem
      Caption = 'Tools'
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object About1: TMenuItem
        Caption = 'About...'
        OnClick = About1Click
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'OBJ Files|*.obj|All Files|*.*'
    Left = 80
    Top = 32
  end
  object SaveDialog1: TSaveDialog
    Filter = 'Text Files|*.txt|All Files|*.*'
    Left = 128
    Top = 32
  end
end
