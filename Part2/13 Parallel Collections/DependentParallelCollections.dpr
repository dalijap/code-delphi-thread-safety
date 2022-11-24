program DependentParallelCollections;

uses
  Vcl.Forms,
  DependentParallelCollectionsMainF in 'DependentParallelCollectionsMainF.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

