object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 338
  ClientWidth = 538
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
    Width = 526
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 903
    object Button1: TButton
      Left = 0
      Top = 4
      Width = 100
      Height = 25
      Caption = 'Thread GET 1'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 106
      Top = 4
      Width = 100
      Height = 25
      Caption = 'Thread GET 2'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 212
      Top = 4
      Width = 130
      Height = 25
      Caption = 'Asynchronous GET'
      TabOrder = 2
      OnClick = Button3Click
    end
  end
  object Memo: TMemo
    Left = 6
    Top = 41
    Width = 526
    Height = 291
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 903
    ExplicitHeight = 234
  end
  object HTTPClient: TNetHTTPClient
    Asynchronous = True
    SynchronizeEvents = False
    UserAgent = 'Embarcadero URI Client/1.0'
    OnRequestCompleted = HTTPRequestRequestCompleted
    OnRequestError = HTTPRequestRequestError
    OnRequestException = HTTPRequestRequestException
    OnSendData = HTTPRequestSendData
    OnReceiveData = HTTPRequestReceiveData
    Left = 36
    Top = 72
  end
end
