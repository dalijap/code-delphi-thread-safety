program CollectionsTest;

uses
  Vcl.Forms,
  CollectionsMainF in 'CollectionsMainF.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

