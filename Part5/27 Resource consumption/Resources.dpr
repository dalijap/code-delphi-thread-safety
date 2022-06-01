program Resources;

uses
  Vcl.Forms,
  ResourcesMainF in 'ResourcesMainF.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

