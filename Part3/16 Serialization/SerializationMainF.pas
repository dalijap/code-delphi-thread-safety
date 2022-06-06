unit SerializationMainF;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.SyncObjs,
  System.NetEncoding,
  System.JSON,
  Winapi.ActiveX,
  REST.Json,
  Xml.XMLDoc,
  Xml.XMLIntf,
  Xml.XMLSchema,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Memo: TMemo;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
  public
  end;

  {$M+}
  TFoo = class
  private
    FData: string;
  published
    property Data: string read FData write FData;
  end;

  IFoo = interface
    function GetData: string;
    procedure SetData(const Value: string);
    property Data: string read GetData write SetData;
  end;

  {$M+}
  TInterfacedFoo = class(TInterfacedObject, IFoo)
  private
    FData: string;
    function GetData: string;
    procedure SetData(const Value: string);
  published
    property Data: string read GetData write SetData;
  end;

  IValues = interface
    function GetValue1: string;
    function GetValue2: string;
    procedure SetValue1(const Value: string);
    procedure SetValue2(const Value: string);
    property Value1: string read GetValue1 write SetValue1;
    property Value2: string read GetValue2 write SetValue2;
  end;

  TThreadValues = class(TInterfacedObject, IValues)
  private
    FLock: TCriticalSection;
    FValue1: string;
    FValue2: string;
    function GetValue1: string;
    function GetValue2: string;
    procedure SetValue1(const Value: string);
    procedure SetValue2(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Value1: string read GetValue1 write SetValue1;
    property Value2: string read GetValue2 write SetValue2;
  end;

  TValues = class(TInterfacedObject, IValues)
  private
    FValue1: string;
    FValue2: string;
    function GetValue1: string;
    function GetValue2: string;
    procedure SetValue1(const Value: string);
    procedure SetValue2(const Value: string);
  published
    property Value1: string read GetValue1 write SetValue1;
    property Value2: string read GetValue2 write SetValue2;
  end;


  {$M+}
  TBar = class
  private
    FData: string;
    FNumber: Double;
  published
    property Data: string read FData write FData;
    property Number: Double read FNumber write FNumber;
  end;


var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{ TInterfacedFoo }

function TInterfacedFoo.GetData: string;
begin
  Result := FData;
end;

procedure TInterfacedFoo.SetData(const Value: string);
begin
  FData := Value;
end;

{ TThreadValues }

constructor TThreadValues.Create;
begin
  FLock := TCriticalSection.Create;
end;

destructor TThreadValues.Destroy;
begin
  FLock.Free;
  inherited;
end;

function TThreadValues.GetValue1: string;
begin
  FLock.Enter;
  try
    Result := FValue1;
  finally
    FLock.Leave;
  end;
end;

function TThreadValues.GetValue2: string;
begin
  FLock.Enter;
  try
    Result := FValue2;
  finally
    FLock.Leave;
  end;
end;

procedure TThreadValues.SetValue1(const Value: string);
begin
  FLock.Enter;
  try
    FValue1 := Value;
  finally
    FLock.Leave;
  end;
end;

procedure TThreadValues.SetValue2(const Value: string);
begin
  FLock.Enter;
  try
    FValue2 := Value;
  finally
    FLock.Leave;
  end;
end;

{ TValues }

function TValues.GetValue1: string;
begin
  Result := FValue1;
end;

function TValues.GetValue2: string;
begin
  Result := FValue2;
end;

procedure TValues.SetValue1(const Value: string);
begin
  FValue1 := Value;
end;

procedure TValues.SetValue2(const Value: string);
begin
  FValue2 := Value;
end;


// fake serialization function
function Convert(const aData: TObject): string;
begin
  Result := aData.ClassName;
end;

function ConvertJSON(const aData: TObject): string;
begin
  Result := TJson.ObjectToJsonString(aData);
end;

// simplified XML serialization for IFoo
function ConvertFooXML(const aData: IFoo): string;
begin
  Result := '<foo>'#13#10'  <data>' + aData.Data + '</data>'#13#10'</foo>';
end;

// simplified XML serialization for IValues
function ConvertValuesXML(const aData: IValues): string;
begin
  Result := '<obj>'#13#10'  <value1>' + aData.Value1 + '</value1>'#13#10 +
    '  <value2>' + aData.Value2 + '</value2>'#13#10'</obj>';
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  Foo: TFoo;
begin
  Memo.Lines.Clear;
  Foo := TFoo.Create;
  try
    Foo.Data := 'abc';
    TThread.CreateAnonymousThread(
      procedure
      var
        Converted: string;
      begin
        try
          Converted := Convert(Foo);
          TThread.Synchronize(nil,
            procedure
            begin
              Memo.Lines.Add(Converted);
            end);
        finally
          Foo.Free;
        end;
      end).Start;
  except
    Foo.Free;
    raise;
  end;
end;

procedure TMainForm.Button2Click(Sender: TObject);
var
  Foo: IFoo;
begin
  Memo.Lines.Clear;
  Foo := TInterfacedFoo.Create;
  Foo.Data := 'abc';

  TThread.CreateAnonymousThread(
    procedure
    var
      Converted: string;
    begin
      Converted := Convert(TObject(Foo));
      TThread.Synchronize(nil,
        procedure
        begin
          Memo.Lines.Add(Converted);
        end);
    end).Start;
end;

procedure TMainForm.Button3Click(Sender: TObject);
var
  Foo: IFoo;
begin
  Memo.Lines.Clear;
  Foo := TInterfacedFoo.Create;
  Foo.Data := 'abc';

  TThread.CreateAnonymousThread(
    procedure
    var
      JSON: string;
    begin
      JSON := ConvertJSON(TObject(Foo));
      TThread.Synchronize(nil,
        procedure
        begin
          Memo.Lines.Add(JSON);
        end);
    end).Start;

  TThread.CreateAnonymousThread(
    procedure
    var
      XML: string;
    begin
      XML := ConvertFooXML(Foo);
      TThread.Synchronize(nil,
        procedure
        begin
          Memo.Lines.Add(XML);
        end);
    end).Start;

  Memo.Lines.Add(Foo.Data);
end;

procedure TMainForm.Button4Click(Sender: TObject);
var
  Obj: IValues;
begin
  Memo.Lines.Clear;
  // immediate initialization after object is constructed does not have to be protected
  // because at that point Obj instance is accessible only from single thread
  Obj := TThreadValues.Create;
  Obj.Value1 := 'abc';
  Obj.Value2 := '123';

  TThread.CreateAnonymousThread(
    procedure
    var
      XML: string;
    begin
      System.TMonitor.Enter(TObject(Obj));
      try
        XML := ConvertValuesXML(Obj);
      finally
        System.TMonitor.Exit(TObject(Obj));
      end;
      TThread.Synchronize(nil,
        procedure
        begin
          Memo.Lines.Add(XML);
        end);
    end).Start;

  // Changing Sleep value we can influence order of execution
  // and the result of the serialization
  Sleep(13);

  System.TMonitor.Enter(TObject(Obj));
  try
    Obj.Value1 := '000';
    Obj.Value2 := '444';
  finally
    System.TMonitor.Exit(TObject(Obj));
  end;
end;

procedure TMainForm.Button5Click(Sender: TObject);
begin
  Memo.Lines.Clear;

  TThread.CreateAnonymousThread(
    procedure
    var
      Data1: string;
      Result1: string;
    begin
      Data1 := 'First';
      Result1 := TNetEncoding.Base64.Encode(Data1);
      TThread.Synchronize(nil,
        procedure
        begin
          Memo.Lines.Add(Result1);
        end);
    end).Start;

  TThread.CreateAnonymousThread(
    procedure
    var
      Data2: string;
      Result2: string;
    begin
      Data2 := 'Second';
      Result2 := TNetEncoding.Base64.Encode(Data2);
      TThread.Synchronize(nil,
        procedure
        begin
          Memo.Lines.Add(Result2);
        end);
    end).Start;
end;

procedure TMainForm.Button6Click(Sender: TObject);
begin
  Memo.Lines.Clear;
  TThread.CreateAnonymousThread(
    procedure
    var
      Obj: TFoo;
      JSON: string;
    begin
      Obj := TFoo.Create;
      try
        Obj.Data := 'abc';
        JSON := TJson.ObjectToJsonString(Obj);
      finally
        Obj.Free;
      end;

      Obj := nil;
      try
        Obj := TJson.JsonToObject<TFoo>(JSON);
      finally
        Obj.Free;
      end;

      TThread.Synchronize(nil,
        procedure
        begin
          Memo.Lines.Add(JSON);
        end);
    end).Start;
end;

procedure TMainForm.Button7Click(Sender: TObject);
var
  Source: string;
begin
  Source := '<?xml version="1.0"?><doc><num>12.45</num></doc>';
  TThread.CreateAnonymousThread(
    procedure
    var
      Doc: IXMLDocument;
      XML: string;
    begin
      {$IFDEF MSWINDOWS}
      CoInitialize(nil);
      try
      {$ENDIF}
        Doc := TXMLDocument.Create(nil);
        Doc.LoadFromXML(Source);

        Doc.SaveToXML(XML);
      {$IFDEF MSWINDOWS}
      finally
        CoUninitialize;
      end;
      {$ENDIF}
      TThread.Synchronize(nil,
        procedure
        begin
          Memo.Lines.Add(XML);
        end);
    end).Start;
end;

procedure TMainForm.Button8Click(Sender: TObject);
var
  Source: string;
begin
  Source := '<?xml version="1.0"?><doc><num>12.45</num></doc>';
  TThread.CreateAnonymousThread(
    procedure
    var
      Doc: IXMLDocument;
      XML: string;
    begin
      {$IFDEF MSWINDOWS}
      CoInitialize(nil);
      try
      {$ENDIF}

        Doc := TXMLDocument.Create(nil);
        Doc.LoadFromXML(Source);

        Doc.SaveToXML(XML);
      {$IFDEF MSWINDOWS}
      finally
        CoUninitialize;
      end;
      {$ENDIF}
      TThread.Synchronize(nil,
        procedure
        begin
          Memo.Lines.Add(XML);
        end);
    end).Start;
end;

end.
