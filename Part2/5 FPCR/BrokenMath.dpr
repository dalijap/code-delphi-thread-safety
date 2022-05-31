program BrokenMath;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Math;

// Note: Writing to console is not thread-safe and the output can be garbled.
// However, this doesn't have direct impact on showing FPCR issue as the bug
// will appear before we write the message and if we end up in broken code
// path the content of the message itself is not important


procedure BrokenExceptionMask;
var
  OK: Boolean;
begin
  OK := True;
  TThread.CreateAnonymousThread(
    procedure
    var
      i: integer;
      f, d: Double;
      m: TArithmeticExceptionMask;
    begin
      i := 0;
      d := 0;
      while OK do
        begin
          Inc(i);
          m := SetExceptionMask([TArithmeticException.exPrecision]);
          try
            f := 10 / d;
            // if it ends here - broken
            OK := False;
            Writeln('BROKEN FLOAT 1 ' + i.ToString);
          except
          end;
        end;
    end).Start;
  TThread.CreateAnonymousThread(
    procedure
    var
      i: integer;
      f, d: Double;
      m: TArithmeticExceptionMask;
    begin
      i := 0;
      d := 0;
      while OK do
        begin
          Inc(i);
          m := SetExceptionMask([TArithmeticException.exZeroDivide]);
          try
            f := 10 / d;
          except
            // if it ends here - broken
            OK := False;
            Writeln('BROKEN FLOAT 2 ' + i.ToString);
          end;
        end;
    end).Start;

  // run infinite loop until code breaks
  while OK do;
end;

procedure BrokenExceptionMaskMain;
var
  OK: Boolean;
  i: integer;
  f, d: Double;
begin
  OK := True;
  i := 0;
  d := 0;
  TThread.CreateAnonymousThread(
    procedure
    var
      i: integer;
      f, d: Double;
    begin
      i := 0;
      d := 0;
      while OK do
        try
          Inc(i);
          SetExceptionMask([TArithmeticException.exPrecision]);
          f := 10 / d;
          // if it ends here - broken
          OK := False;
          Writeln('BROKEN FLOAT 1 ' + i.ToString);
        except
        end;
    end).Start;

  // run infinite loop until code breaks
  while OK do
    try
      Inc(i);
      SetExceptionMask([TArithmeticException.exZeroDivide]);
      f := 10 / d;
    except
      // if it ends here - broken
      OK := False;
      Writeln('BROKEN FLOAT MAIN ' + i.ToString);
    end;
end;

begin
  try
    BrokenExceptionMask;
//    BrokenExceptionMaskMain;
  except
    on E: Exception do Writeln(E.ClassName, ': ', E.Message);
  end;
  Writeln;
  Writeln('DONE');
  Readln;
end.
