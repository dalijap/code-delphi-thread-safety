(*******************************************************************************

Licensed under MIT License

Code examples from Delphi Thread Safety Patterns book
Copyright (c) 2022 Dalija Prasnikar, Neven Prasnikar Jr.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
******************************************************************************)


unit NX.Log;

interface

uses
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF}
{$IFDEF ANDROID}
  Androidapi.JNI.JavaTypes,
  Androidapi.Helpers,
  Androidapi.Log,
{$ENDIF}
{$IFDEF IOS}
  Macapi.Helpers,
  Macapi.ObjectiveC,
  iOSapi.Foundation,
{$ENDIF}
{$IFDEF OSX}
  Macapi.Helpers,
  Macapi.ObjectiveC,
  Macapi.Foundation,
{$ENDIF}
{$IFDEF POSIX}
  Posix.Base,
  Posix.SysTypes,
  Posix.Pthread,
{$ENDIF}
  System.SysUtils,
  System.Classes,
  System.DateUtils;

type
  INxLogger = interface
    procedure Output(const aMsg: string);
  end;

  TNxLogLevel = (LogOff, LogFatal, LogError, LogWarning, LogInfo, LogDebug);

  TNxLogThread = (LogThreadOff, LogThreadID, LogThreadName);

  NxLog = class
  protected
  protected
    class var Logger: INxLogger;
    class var Level: TNxLogLevel;
    class var ThreadInfo: TNxLogThread;
    class var TimeStamp: Boolean;
    class constructor ClassCreate;
    class destructor ClassDestroy;
    class function GetThreadID: string; static;
    class function GetThreadName: string; static;
    class procedure SetThreadName(const aValue: string); static;
    class function PrepareOutput(aLevel: TNxLogLevel; const aMsg: string): string; static; inline;
  public
    class procedure SetLogger(const aValue: INxLogger); static;
    class procedure SetLevel(aValue: TNxLogLevel); static;
    class procedure SetThreadInfo(aValue: TNxLogThread); static;
    class procedure SetTimeStamp(aValue: Boolean); static;

    class procedure D(const aMsg: string); overload; static;
    class procedure I(const aMsg: string); static;
    class procedure W(const aMsg: string); static;
    class procedure E(const aMsg: string); static;
    class procedure F(const aMsg: string); static;

    class property ThreadID: string read GetThreadID;
    class property ThreadName: string read GetThreadName write SetThreadName;
  end;

  TNxSystemLogger = class(TInterfacedObject, INxLogger)
  public
    procedure Output(const aMsg: string);
    class function New: INxLogger;
  end;

  TNxFileLogger = class(TInterfacedObject, INxLogger)
  protected
    f: TFileStream;
  public
    constructor Create(const aFileName: string);
    destructor Destroy; override;
    procedure Output(const aMsg: string);
    class function New(const aFileName: string): INxLogger;
  end;

const
  LogDelimiter = ' - ';
  TNxLogLevelText: array[TNxLogLevel] of string =
    ('OFF' + LogDelimiter,
     'NXFATAL  ' + LogDelimiter,
     'NXERROR  ' + LogDelimiter,
     'NXWARNING' + LogDelimiter,
     'NXINFO   ' + LogDelimiter,
     'NXDEBUG  ' + LogDelimiter);

implementation

{$IFDEF LINUX}
function pthread_setname_np(Thread: pthread_t; Name: MarshaledAString): Integer; cdecl;
  external libpthread name _PU + 'pthread_setname_np';
{$EXTERNALSYM pthread_setname_np}
{$ENDIF}


{ NxLog }

class constructor NxLog.ClassCreate;
begin
{$IFDEF DEBUG}  
  Logger := TNxSystemLogger.New;
  Level := LogDebug;
{$ENDIF}
end;

class destructor NxLog.ClassDestroy;
begin
  SetLevel(LogOff);
end;

class procedure NxLog.SetLogger(const aValue: INxLogger);
begin
  if not Assigned(aValue) then
    Level := LogOff;
  Logger := aValue;
end;

class procedure NxLog.SetLevel(aValue: TNxLogLevel);
begin
  Level := aValue;
end;

class procedure NxLog.SetThreadInfo(aValue: TNxLogThread);
begin
  ThreadInfo := aValue;
end;

class procedure NxLog.SetTimeStamp(aValue: Boolean);
begin
  TimeStamp := aValue;
end;

class function NxLog.GetThreadID: string;
begin
  if TThread.CurrentThread.ThreadID = MainThreadID then
    Result := 'MT ' + UIntToStr(TThread.CurrentThread.ThreadID)
  else
    Result := 'BT ' + UIntToStr(TThread.CurrentThread.ThreadID);
end;

class function NxLog.GetThreadName: string;
{$IFDEF POSIX}
var
  Buf: array[0..16] of AnsiChar;
{$ENDIF}
begin
  {$IF defined(ANDROID)}
  Result := JStringToString(TJThread.JavaClass.currentThread.getName);
  {$ELSEIF defined(POSIX)}
  pthread_getname_np(pthread_self, @Buf, SizeOf(Buf));
  Result := string(Utf8String(buf));
  {$ELSE}
  Result := UIntToStr(TThread.CurrentThread.ThreadID);
  {$ENDIF}
  if TThread.CurrentThread.ThreadID = MainThreadID then
    Result := 'MT ' + Result
  else
    Result := 'BT ' + Result;
end;

class procedure NxLog.SetThreadName(const aValue: string);
begin
  {$IF defined(ANDROID)}
  TJThread.JavaClass.currentThread.setName(StringToJString(aValue));
  {$ELSEIF defined(LINUX)}
  pthread_setname_np(pthread_self, PUtf8Char(Utf8String(aValue)));
  {$ELSEIF defined(MACOS)}
  pthread_setname_np(PUtf8Char(Utf8String(aValue)));
  {$ELSE}
  // not implemented
  {$ENDIF}
end;

class function NxLog.PrepareOutput(aLevel: TNxLogLevel; const aMsg: string): string;
begin
  Result := TNxLogLevelText[aLevel];
  if TimeStamp then
    Result := Result + DateToISO8601(Now) + LogDelimiter;
  case ThreadInfo of
    LogThreadID : Result := Result + ThreadID + LogDelimiter;
    LogThreadName : Result := Result + ThreadName + LogDelimiter;
  end;
  Result := Result + aMsg;
end;

class procedure NxLog.D(const aMsg: string);
var
  Result: string;
begin
  if Ord(Level) >= Ord(LogDebug) then
    begin
      Result := PrepareOutput(LogDebug, aMsg);
      Logger.Output(Result);
    end;
end;

class procedure NxLog.I(const aMsg: string);
var
  Result: string;
begin
  if Ord(Level) >= Ord(LogInfo) then
    begin
      Result := PrepareOutput(LogInfo, aMsg);
      Logger.Output(Result);
    end;
end;

class procedure NxLog.W(const aMsg: string);
var
  Result: string;
begin
  if Ord(Level) >= Ord(LogWarning) then
    begin
      Result := PrepareOutput(LogWarning, aMsg);
      Logger.Output(Result);
    end
end;

class procedure NxLog.E(const aMsg: string);
var
  Result: string;
begin
  if Ord(Level) >= Ord(LogError) then
    begin
      Result := PrepareOutput(LogError, aMsg);
      Logger.Output(Result);
    end
end;

class procedure NxLog.F(const aMsg: string);
var
  Result: string;
begin
  if Ord(Level) >= Ord(LogFatal) then
    begin
      Result := PrepareOutput(LogFatal, aMsg);
      Logger.Output(Result);
    end
end;

{ TNxSystemLogger }

{$IF defined(MSWINDOWS)}
procedure TNxSystemLogger.Output(const aMsg: string);
begin
  OutputDebugString(PChar(aMsg));
  if IsConsole then
    begin
      TMonitor.Enter(Self);
      try
        Writeln(aMsg);
      finally
        TMonitor.Exit(Self);
      end;
    end;
end;
{$ELSEIF defined(ANDROID)}
procedure TNxSystemLogger.Output(const aMsg: string);
begin
  LOGI(PUtf8Char(Utf8String(aMsg)));
end;
{$ELSEIF defined(MACOS)}
procedure TNxSystemLogger.Output(const aMsg: string);
begin
  NSLog(StringToID(aMsg));
end;
{$ELSEIF defined(LINUX)}
procedure TNxSystemLogger.Output(const aMsg: string);
begin
  if IsConsole then
    begin
      TMonitor.Enter(Self);
      try
        Writeln(aMsg);
      finally
        TMonitor.Exit(Self);
      end;
    end;
end;
{$ELSE}
procedure TNxSystemLogger.Output(const aMsg: string);
begin
end;
{$ENDIF}

class function TNxSystemLogger.New: INxLogger;
begin
  Result := TNxSystemLogger.Create;
end;

{ TNxFileLogger }

constructor TNxFileLogger.Create(const aFileName: string);
begin
  inherited Create;
  f := TFileStream.Create(aFileName, fmCreate or fmShareExclusive);
end;

destructor TNxFileLogger.Destroy;
begin
  f.Free;
  inherited;
end;

procedure TNxFileLogger.Output(const aMsg: string);
var
  Buf: TBytes;
begin
  Buf := TEncoding.UTF8.GetBytes(aMsg + #13#10);
  TMonitor.Enter(f);
  try
    f.WriteData(Buf, Length(Buf));
  finally
    TMonitor.Exit(f);
  end;
end;

class function TNxFileLogger.New(const aFileName: string): INxLogger;
begin
  Result := TNxFileLogger.Create(aFileName);
end;

end.


