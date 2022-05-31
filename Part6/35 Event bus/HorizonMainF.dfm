object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 281
  ClientWidth = 464
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
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 13
  object Panel1: TPanel
    Left = 6
    Top = 6
    Width = 452
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 8
      Top = 6
      Width = 100
      Height = 25
      Caption = 'Send String'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 114
      Top = 6
      Width = 100
      Height = 25
      Caption = 'Send Foo'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 220
      Top = 6
      Width = 100
      Height = 25
      Caption = 'Subscribe Int'
      TabOrder = 2
      OnClick = Button3Click
    end
  end
  object Memo: TMemo
    Left = 6
    Top = 41
    Width = 452
    Height = 234
    Align = alClient
    TabOrder = 1
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 398
    Top = 22
  end
end
