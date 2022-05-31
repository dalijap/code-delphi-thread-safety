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
  OnCreate = FormCreate
  OnDestroy = FormDestroy
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
      Left = 0
      Top = 4
      Width = 75
      Height = 25
      Caption = 'Start Task'
      TabOrder = 0
      OnClick = Button1Click
    end
    object CancelBtn: TButton
      Left = 243
      Top = 4
      Width = 75
      Height = 25
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = CancelBtnClick
    end
    object Button2: TButton
      Left = 81
      Top = 4
      Width = 75
      Height = 25
      Caption = 'Start Thread'
      TabOrder = 2
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 162
      Top = 4
      Width = 75
      Height = 25
      Caption = 'Start Foo'
      TabOrder = 3
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
end
