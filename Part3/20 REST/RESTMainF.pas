unit RESTMainF;

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
  REST.Types,
  REST.Client,
  REST.Authenticator.Basic,
  Data.Bind.Components,
  Data.Bind.ObjectScope;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Memo: TMemo;
    Button2: TButton;
    Client: TRESTClient;
    Request: TRESTRequest;
    Response: TRESTResponse;
    BasicAuth: THTTPBasicAuthenticator;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
  public
    FThread: TThread;
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
      Client: TRESTClient;
      Request: TRESTRequest;
      Response: TRESTResponse;
      Auth: THTTPBasicAuthenticator;
    begin
      Client := TRESTClient.Create(nil);
      try
        Auth := THTTPBasicAuthenticator.Create(Client);
        Request := TRESTRequest.Create(Client);
        Response := TRESTResponse.Create(Client);
        Auth.Username := 'test';
        Auth.Password := 'test';
        Client.Accept := 'application/json';
        Client.BaseURL := 'https://reqres.in/api/';
        Request.Client := Client;
        Request.Resource := 'users';
        Request.Response := Response;
        Request.Execute;
        TThread.Synchronize(nil,
          procedure
          begin
            Memo.Lines.Add(Response.Content);
          end);
      finally
        Client.Free;
      end;
    end).Start;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  Memo.Lines.Clear;
  Request.ExecuteAsync(
    procedure
    begin
      Memo.Lines.Add(Response.Content);
    end, True, True,
    procedure(Error: TObject)
    begin
      Memo.Lines.Add(Exception(Error).Message);
    end);
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  if Assigned(FThread) then
    Exit;

  Memo.Lines.Clear;
  FThread := Request.ExecuteAsync(
    procedure
    begin
      Memo.Lines.Add(Response.Content);
      TThread.ForceQueue(nil,
        procedure
        begin
          FreeAndNil(FThread);
        end);
    end,
    True, False,
    procedure(Error: TObject)
    begin
      Memo.Lines.Add(Exception(Error).Message);
      TThread.ForceQueue(nil,
        procedure
        begin
          FreeAndNil(FThread);
        end);
    end);
end;

end.
