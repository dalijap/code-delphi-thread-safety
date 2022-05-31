program Logging;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  NX.Log in 'NX.Log.pas',
  System.SysUtils,
  System.Threading;

procedure Test;
var
  t1, t2, t3, t4: ITask;
begin
  t1 := TTask.Run(
    procedure
    begin
      for var i := 0 to 100 do
        NxLog.D('TASK 1');
    end);

  t2 := TTask.Run(
    procedure
    begin
      for var i := 0 to 100 do
        NxLog.D('TASK 2');
    end);

  t3 := TTask.Run(
    procedure
    begin
      for var i := 0 to 100 do
        NxLog.D('TASK 3');
    end);

  t4 := TTask.Run(
    procedure
    begin
      for var i := 0 to 100 do
        NxLog.D('TASK 4');
    end);

  TTask.WaitForAll([t1, t2, t3, t4]);
end;

begin
  try
    Test;
    NxLog.D('Done');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
