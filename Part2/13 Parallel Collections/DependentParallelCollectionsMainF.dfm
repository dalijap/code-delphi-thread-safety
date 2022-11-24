object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 398
  ClientWidth = 619
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
    Width = 607
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 0
      Top = 4
      Width = 90
      Height = 25
      Caption = 'Single Thread'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 96
      Top = 4
      Width = 100
      Height = 25
      Caption = 'Parallel For Lock'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 202
      Top = 4
      Width = 120
      Height = 25
      Caption = 'Parallel For Lock 2'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 328
      Top = 4
      Width = 120
      Height = 25
      Caption = 'Parallel For Lock Free'
      TabOrder = 3
      OnClick = Button4Click
    end
  end
  object Memo: TMemo
    Left = 6
    Top = 41
    Width = 607
    Height = 351
    Align = alClient
    TabOrder = 1
  end
end
