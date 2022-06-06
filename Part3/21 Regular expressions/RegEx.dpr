program RegEx;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Threading,
  System.RegularExpressions;

var
  OK: Boolean;

procedure SafeSplit;
var
  a: TArray<string>;
  s: string;
begin
  a := TRegEx.Split('abcfoo 123 abac458', 'ab*c');
  for s in a do
    Writeln(s);
end;

procedure ThreadUnsafe;
var
  Reg: TRegEx;
  t1, t2: ITask;
begin
  // THREAD UNSAFE - INCORRECT CODE
  Reg := TRegEx.Create('ab*c');
  t1 := TTask.Run(
    procedure
    var
      Found: Boolean;
    begin
      Found := Reg.IsMatch('abcfoo 123 abac458');
      if not Found then
        begin
          OK := False;
          Writeln('WRONG MATCH');
        end;
    end);

  t2 := TTask.Run(
    procedure
    var
      Found: Boolean;
    begin
      Found := Reg.IsMatch('foo');
      if Found then
        begin
          OK := False;
          Writeln('WRONG MATCH');
        end;
    end);
end;

procedure ThreadUnsafeLoop;
begin
  OK := True;
  while OK do
    ThreadUnsafe;
end;

procedure ThreadSafe;
var
  t1, t2: ITask;
begin
  // THREAD SAFE CORRECTCODE
  t1 := TTask.Run(
    procedure
    var
      Reg: TRegEx;
      Found: Boolean;
    begin
      Reg := TRegEx.Create('ab*c');
      Found := Reg.IsMatch('abcfoo 123 abac458');
      if not Found then
        begin
          OK := False;
          Writeln('WRONG MATCH');
        end;
    end);

  t2 := TTask.Run(
    procedure
    var
      Reg: TRegEx;
      Found: Boolean;
    begin
      Reg := TRegEx.Create('ab*c');
      Found := Reg.IsMatch('foo');
      if Found then
        begin
          OK := False;
          Writeln('WRONG MATCH');
        end;
    end);
end;

procedure ThreadSafeLoop;
begin
  // This loop will never end because code will always run correctly
  OK := True;
  while OK do
    ThreadSafe;
end;

begin
  try
    ThreadUnsafeLoop;
//    ThreadSafeLoop;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Writeln('DONE');
  Readln;
end.
