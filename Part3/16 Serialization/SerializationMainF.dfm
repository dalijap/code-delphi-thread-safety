object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Serialization'
  ClientHeight = 358
  ClientWidth = 703
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
    Width = 691
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 776
    object Button1: TButton
      Left = 0
      Top = 4
      Width = 110
      Height = 25
      Caption = 'Data Handover'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 116
      Top = 4
      Width = 110
      Height = 25
      Caption = 'Data Handover ARC'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 232
      Top = 4
      Width = 110
      Height = 25
      Caption = 'Read-only Data'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 348
      Top = 4
      Width = 80
      Height = 25
      Caption = 'TMonitor'
      TabOrder = 3
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 434
      Top = 4
      Width = 80
      Height = 25
      Caption = 'TNetEncoding'
      TabOrder = 4
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 517
      Top = 4
      Width = 80
      Height = 25
      Caption = 'JSON'
      TabOrder = 5
      OnClick = Button6Click
    end
    object Button7: TButton
      Left = 603
      Top = 4
      Width = 80
      Height = 25
      Caption = 'XML'
      TabOrder = 6
      OnClick = Button7Click
    end
  end
  object Memo: TMemo
    Left = 6
    Top = 41
    Width = 691
    Height = 311
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 776
  end
end
