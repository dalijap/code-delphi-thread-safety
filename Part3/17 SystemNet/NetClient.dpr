program NetClient;

uses
  Vcl.Forms,
  NetClientMainF in 'NetClientMainF.pas' {MainForm},
  NX.Log in '..\..\Part6\33 Logging\NX.Log.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

