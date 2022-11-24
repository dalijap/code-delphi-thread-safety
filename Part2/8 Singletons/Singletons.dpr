program Singletons;

uses
  Vcl.Forms,
  SingletonsMainF in 'SingletonsMainF.pas' {MainForm},
  SingletonLocal in 'SingletonLocal.pas',
  SingletonClasses in 'SingletonClasses.pas',
  SingletonClassProp in 'SingletonClassProp.pas',
  SingletonLazy in 'SingletonLazy.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

