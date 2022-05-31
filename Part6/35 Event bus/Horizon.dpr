program Horizon;

uses
  Vcl.Forms,
  HorizonMainF in 'HorizonMainF.pas' {MainForm},
  NX.Horizon in 'NX.Horizon.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

