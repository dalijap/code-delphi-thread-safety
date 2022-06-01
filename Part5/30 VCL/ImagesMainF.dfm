object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 501
  ClientWidth = 751
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Padding.Left = 6
  Padding.Top = 6
  Padding.Right = 6
  Padding.Bottom = 6
  TextHeight = 13
  object Panel1: TPanel
    Left = 6
    Top = 6
    Width = 739
    Height = 45
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 8
      Top = 8
      Width = 200
      Height = 25
      Caption = 'Generate Jpeg thumbnails'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 214
      Top = 8
      Width = 220
      Height = 25
      Caption = 'Generate image thumbnails - Synchronize'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 440
      Top = 8
      Width = 220
      Height = 25
      Caption = 'Generate image thumbnails - Queue'
      TabOrder = 2
      OnClick = Button3Click
    end
  end
  object ListView1: TListView
    Left = 6
    Top = 51
    Width = 739
    Height = 444
    Align = alClient
    Columns = <>
    LargeImages = ThnList
    TabOrder = 1
    ExplicitTop = 258
    ExplicitHeight = 237
  end
  object ThnList: TImageList
    Height = 100
    Width = 150
    Left = 678
    Top = 22
  end
end
