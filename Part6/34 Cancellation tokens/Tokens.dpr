program Tokens;

uses
  NX.Log in '..\33 Logging\NX.Log.pas',
  Vcl.Forms,
  NX.Tokens in 'NX.Tokens.pas',
  TokensMainF in 'TokensMainF.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

