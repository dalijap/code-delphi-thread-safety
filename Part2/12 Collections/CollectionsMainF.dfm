object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 366
  ClientWidth = 506
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
    Width = 494
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 799
    object Button1: TButton
      Left = 8
      Top = 6
      Width = 80
      Height = 25
      Caption = 'Unsafe Array'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 94
      Top = 6
      Width = 80
      Height = 25
      Caption = 'Safe Array'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 180
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Safe List'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 261
      Top = 6
      Width = 80
      Height = 25
      Caption = 'List Wrapper'
      TabOrder = 3
      OnClick = Button4Click
    end
  end
  object Memo: TMemo
    Left = 6
    Top = 41
    Width = 494
    Height = 319
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 799
    ExplicitHeight = 309
  end
end
