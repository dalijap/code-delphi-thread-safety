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
      Caption = 'REST Thread'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 114
      Top = 6
      Width = 100
      Height = 25
      Caption = 'REST Async Auto'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 220
      Top = 6
      Width = 100
      Height = 25
      Caption = 'Rest Async'
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
  object Client: TRESTClient
    Authenticator = BasicAuth
    BaseURL = 'https://reqres.in/api'
    ContentType = 'application/json'
    Params = <>
    Left = 32
    Top = 88
  end
  object Request: TRESTRequest
    Client = Client
    Params = <>
    Resource = 'users'
    Response = Response
    Left = 32
    Top = 160
  end
  object Response: TRESTResponse
    Left = 32
    Top = 224
  end
  object BasicAuth: THTTPBasicAuthenticator
    Username = 'test'
    Password = 'test'
    Left = 136
    Top = 88
  end
end
