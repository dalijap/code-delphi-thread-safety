unit NetClientMainF;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  System.Threading,
  System.Types,
  NX.Log,
  System.Net.FileClient,
  System.Net.URLClient,
  System.Net.HttpClient,
  System.Net.HttpClientComponent;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    Memo: TMemo;
    HttpClient: TNetHTTPClient;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure HTTPRequestRequestCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
    procedure HTTPRequestSendData(const Sender: TObject; AContentLength, AWriteCount: Int64; var AAbort: Boolean);
    procedure HTTPRequestReceiveData(const Sender: TObject; AContentLength, AReadCount: Int64; var AAbort: Boolean);
    procedure HTTPRequestRequestError(const Sender: TObject; const AError: string);
    procedure HTTPRequestRequestException(const Sender: TObject; const AError: Exception);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.Button1Click(Sender: TObject);
begin
  Memo.Lines.Clear;

  TThread.CreateAnonymousThread(
    procedure
    var
      Client: THTTPClient;
      Response: IHTTPResponse;
    begin
      Client := THTTPClient.Create;
      try
        Client.OnReceiveData := HTTPRequestReceiveData;
        Client.OnSendData := HTTPRequestSendData;
        Response := Client.Get('http://httpbin.org/get');
        NxLog.D('HTTP Request Completed');
      finally
        Client.Free;
      end;
      TThread.Queue(nil,
        procedure
        begin
          Memo.Lines.Add(Response.ContentAsString);
        end);
    end).Start;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  Memo.Lines.Clear;

  TThread.CreateAnonymousThread(
    procedure
    var
      Client: TNetHTTPClient;
      Response: IHTTPResponse;
    begin
      Client := TNetHTTPClient.Create(nil);
      try
        Client.OnReceiveData := HTTPRequestReceiveData;
        Client.OnSendData := HTTPRequestSendData;
        Client.OnRequestCompleted := HTTPRequestRequestCompleted;
        Client.Asynchronous := False;
        Client.SynchronizeEvents := False;
        Response := Client.Get('http://httpbin.org/get');
      finally
        Client.Free;
      end;
      TThread.Queue(nil,
        procedure
        begin
          Memo.Lines.Add(Response.ContentAsString);
        end);
    end).Start;
end;

procedure TMainForm.Button3Click(Sender: TObject);
var
  Client: TNetHTTPClient;
begin
  Memo.Lines.Clear;

  Client := TNetHTTPClient.Create(nil);
  Client.Asynchronous := True;
  Client.OnRequestCompleted := HTTPRequestRequestCompleted;
  Client.OnRequestError := HTTPRequestRequestError;
  Client.OnRequestException := HTTPRequestRequestException;
  Client.Get('http://httpbin.org/get');
end;

procedure TMainForm.HTTPRequestReceiveData(const Sender: TObject; AContentLength, AReadCount: Int64; var AAbort: Boolean);
begin
  NxLog.D('HTTP Receive Data');
  TThread.Queue(nil,
    procedure
    begin
      Memo.Lines.Add(Format('Received: %d of %d', [AReadCount, AContentLength]));
    end);
end;

procedure TMainForm.HTTPRequestRequestCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
begin
  NxLog.D('HTTP Request Completed');
  TThread.Synchronize(nil,
    procedure
    begin
      Memo.Lines.Add(AResponse.ContentAsString);
      Sender.Free;
    end);
end;

procedure TMainForm.HTTPRequestRequestError(const Sender: TObject; const AError: string);
begin
  NxLog.D('HTTP Request Error');
end;

procedure TMainForm.HTTPRequestRequestException(const Sender: TObject; const AError: Exception);
begin
  NxLog.D('HTTP Request Exception');
end;

procedure TMainForm.HTTPRequestSendData(const Sender: TObject; AContentLength, AWriteCount: Int64; var AAbort: Boolean);
begin
  NxLog.D('HTTP Send Data');
  TThread.Queue(nil,
    procedure
    begin
      Memo.Lines.Add('Sent: ' + AWriteCount.ToString + ' of ' + AContentLength.ToString);
    end);
end;

initialization

  NxLog.SetThreadInfo(TNxLogThread.LogThreadID);

end.

