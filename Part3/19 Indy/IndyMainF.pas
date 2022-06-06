unit IndyMainF;

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
  IdBaseComponent,
  IdComponent,
  IdTCPConnection,
  IdTCPClient,
  IdHTTP;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Memo: TMemo;
    Button2: TButton;
    HTTP: TIdHTTP;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure HTTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure HTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
  private
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.Button1Click(Sender: TObject);
var
  Response: string;
begin
  Memo.Lines.Clear;
  Response := HTTP.Get('http://httpbin.org/get');
  Memo.Lines.Add(Response);
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  Memo.Lines.Clear;
  TThread.CreateAnonymousThread(
    procedure
    var
      Client: TIdHTTP;
      Response: string;
    begin
      Client := TIdHTTP.Create(nil);
      try
        Client.OnWorkBegin := HTTPWorkBegin;
        Client.OnWork := HTTPWork;
        Client.OnWorkEnd := HTTPWorkEnd;
        Response := Client.Get('http://httpbin.org/get');
        TThread.Synchronize(nil,
          procedure
          begin
            Memo.Lines.Add(Response);
          end);
      finally
        Client.Free;
      end;
    end).Start;
end;

procedure TMainForm.HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  TThread.Queue(nil,
    procedure
    begin
      Memo.Lines.Add('HTTP Work Begin ' + AWorkCountMax.ToString);
    end);
end;

procedure TMainForm.HTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  TThread.Queue(nil,
    procedure
    begin
      Memo.Lines.Add('HTTP Work ' + AWorkCount.ToString);
    end);
end;

procedure TMainForm.HTTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  TThread.Queue(nil,
    procedure
    begin
      Memo.Lines.Add('HTTP Work End');
    end);
end;

end.
