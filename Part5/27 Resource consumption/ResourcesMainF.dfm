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
    Height = 43
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 8
      Top = 6
      Width = 200
      Height = 25
      Caption = 'Threads - excessive consumption'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 214
      Top = 6
      Width = 120
      Height = 25
      Caption = 'Single thread'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 340
      Top = 6
      Width = 120
      Height = 25
      Caption = 'Tasks'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 466
      Top = 6
      Width = 200
      Height = 25
      Caption = 'Tasks with dedicated thread pool'
      TabOrder = 3
      OnClick = Button4Click
    end
  end
  object Memo: TMemo
    Left = 6
    Top = 49
    Width = 739
    Height = 446
    Align = alClient
    TabOrder = 1
    ExplicitTop = 89
    ExplicitHeight = 403
  end
end
