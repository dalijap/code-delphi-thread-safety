program Serialization;

uses
  Vcl.Forms,
  SerializationMainF in 'SerializationMainF.pas' {MainForm};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

