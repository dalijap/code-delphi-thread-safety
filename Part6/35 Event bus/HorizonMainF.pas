unit HorizonMainF;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Threading,
  System.SyncObjs,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  NX.Horizon;

type
  TFooEvent = type string;

  TMainForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Memo: TMemo;
    Button2: TButton;
    Timer1: TTimer;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  public
    fIntSubscription: INxEventSubscription;
    fFooSubscripton: INxEventSubscription;
    fStringSubscription: INxEventSubscription;
    procedure OnIntData(const aEvent: Integer);
    procedure OnStringData(const aEvent: string);
    procedure OnFooData(const aEvent: TFooEvent);
  end;

var
  MainForm: TMainForm;
  Count: Integer;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  fFooSubscripton := NxHorizon.Instance.Subscribe<TFooEvent>(Sync, OnFooData);
  fStringSubscription := NxHorizon.Instance.Subscribe<string>(MainAsync, OnStringData);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(fIntSubscription) then
    fIntSubscription.WaitFor;
  fFooSubscripton.WaitFor;
  fStringSubscription.WaitFor;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  NxHorizon.Instance.Post('abcd');
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  TTask.Run(
    procedure
    begin
       NxHorizon.Instance.Post<TFooEvent>('Foo');
    end);
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  fIntSubscription := NxHorizon.Instance.Subscribe<Integer>(Sync, OnIntData);
end;

procedure TMainForm.OnFooData(const aEvent: TFooEvent);
begin
  TThread.Queue(nil,
    procedure
    begin
      Memo.Lines.Add(aEvent);
    end);
end;

procedure TMainForm.OnIntData(const aEvent: Integer);
begin
  Memo.Lines.Add(aEvent.ToString);
  NxHorizon.Instance.UnsubscribeAsync(fIntSubscription);
end;

procedure TMainForm.OnStringData(const aEvent: string);
begin
  Memo.Lines.Add(aEvent);
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  Inc(Count);
  NxHorizon.Instance.Send(Count, Sync);
end;

end.
