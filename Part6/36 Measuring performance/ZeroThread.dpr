program ZeroThread;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  NX.Chronos in 'NX.Chronos.pas';

procedure Measure;
var
  Thread: TThread;
begin
  Thread := TThread.CreateAnonymousThread(
    procedure
    var
      tsr, tsc, ts: TNxChronometer;
      i: Integer;
    begin
      tsr := TNxChronometer.Start(CalendarTime);
      tsc := TNxChronometer.Start(ThreadCycles);
      ts := TNxChronometer.Start(ThreadTime);
      for i := 0 to 1000 do
        begin
          Sleep(1);
        end;
      ts.Stop;
      tsc.Stop;
      tsr.Stop;
      Writeln('Real time: ', tsr.ElapsedMs);
      Writeln('Thread time: ', ts.Elapsed);
      Writeln('Cycles: ', tsc.Elapsed);
    end);
  Thread.FreeOnTerminate := False;
  Thread.Start;
  Thread.WaitFor;
  Thread.Free;
end;

begin
  try
    Measure;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
