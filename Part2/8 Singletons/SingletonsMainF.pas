unit SingletonsMainF;

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
  SingletonClasses,
  SingletonLocal,
  SingletonClassProp,
  SingletonLazy;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Memo: TMemo;
    procedure Button1Click(Sender: TObject);
  private
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.Button1Click(Sender: TObject);
begin
  // Any of the provided singleton classes can be safely
  // accessed from multiple threads.
  // That safety is only valid for retrieving singleton reference - f
  // Whether working with data stored in instance itself is thread-safe
  // depends on the safety of TFoo and TFooObject classes
  TThread.CreateAnonymousThread(
    procedure
    begin
      var f := TSingletonFlag.Instance;
    end).Start;
  var f := TSingletonFlag.Instance;
end;

end.
