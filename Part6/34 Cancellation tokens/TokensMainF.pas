unit TokensMainF;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Threading,
  System.Types,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  NX.Log,
  NX.Tokens;

type
  TFooOperation = class
  public
    procedure Foo(const Token: INxCancellationToken);
  end;

  TMainForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Memo: TMemo;
    CancelBtn: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
  public
    Foo: TFooOperation;
    fToken: INxCancellationToken;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TFooOperation.Foo(const Token: INxCancellationToken);
begin
  NxLog.D('Foo step 1');
  Sleep(1000);
  NxLog.D('Foo step 2');
  Token.RaiseIfCanceled;
  NxLog.D('Foo step 3');
  Sleep(1000);
  NxLog.D('Foo step 4');
  Token.RaiseIfCanceled;
  NxLog.D('Foo step 5');
  Sleep(1000);
  NxLog.D('Foo step 6');
  Token.RaiseIfCanceled;
  NxLog.D('Foo step 7');
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Foo := TFooOperation.Create;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Foo.Free;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  Memo.Lines.Add('Task Started');
  fToken := TNxCancellationToken.Create;
  TTask.Run(
    procedure
    begin
      NxLog.D('Task step 1');
      Sleep(1000);
      NxLog.D('Task step 2');
      fToken.RaiseIfCanceled;
      NxLog.D('Task step 3');
      Sleep(1000);
      NxLog.D('Task step 4');
      fToken.RaiseIfCanceled;
      NxLog.D('Task step 5');
      Sleep(1000);
      NxLog.D('Task step 6');
      fToken.RaiseIfCanceled;
      NxLog.D('Task step 7');
      TThread.Queue(nil,
        procedure
        begin
          Memo.Lines.Add('Task Completed');
        end);
    end);
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  Memo.Lines.Add('Thread Started');
  fToken := TNxCancellationToken.Create;
  TThread.CreateAnonymousThread(
    procedure
    begin
      NxLog.D('Thread step 1');
      Sleep(1000);
      NxLog.D('Thread step 2');
      fToken.RaiseIfCanceled;
      NxLog.D('Thread step 3');
      Sleep(1000);
      NxLog.D('Thread step 4');
      fToken.RaiseIfCanceled;
      NxLog.D('Thread step 5');
      Sleep(1000);
      NxLog.D('Thread step 6');
      fToken.RaiseIfCanceled;
      NxLog.D('Thread step 7');
      TThread.Queue(nil,
        procedure
        begin
          Memo.Lines.Add('Thread Completed');
        end);
    end).Start;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  Memo.Lines.Add('Foo Started');
  fToken := TNxCancellationToken.Create;
  TTask.Run(
    procedure
    begin
      NxLog.D('Foo start');
      Foo.Foo(fToken);
      NxLog.D('Foo completed');
      TThread.Queue(nil,
        procedure
        begin
          Memo.Lines.Add('Foo Completed');
        end);
    end);
end;

procedure TMainForm.CancelBtnClick(Sender: TObject);
begin
  if Assigned(fToken) then
    begin
      NxLog.D('Canceling');
      fToken.Cancel;
      NxLog.D('Canceled');
      Memo.Lines.Add('Canceled');
    end;
end;

end.
