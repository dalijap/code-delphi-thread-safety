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


unit NX.Chronos;

interface

uses
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ELSE}
  Posix.Base,
  Posix.Time,
{$IFDEF ANDROID}
  Androidapi.JNI.JavaTypes,
  Androidapi.Helpers,
  Androidapi.Log,
{$ENDIF}
{$IFDEF IOS}
  Macapi.Mach,
  Macapi.Helpers,
  Macapi.ObjectiveC,
  iOSapi.Foundation,
{$ENDIF}
{$IFDEF OSX}
  Macapi.Mach,
  Macapi.Helpers,
  Macapi.ObjectiveC,
  Macapi.Foundation,
{$ENDIF}
{$ENDIF}
  System.SysUtils,
  System.Classes;

type
  TNxChronoMode =
    (CalendarTime, ProcessTime, ThreadTime, ProcessCycles, ThreadCycles);

  TNxChronometer = record
  private
    fMode: TNxChronoMode;
    // accumulated time
    fElapsed: UInt64;
    // current time stamp - if 0 nothing is being measured
    fStartTimeStamp: UInt64;
    function CurrentTimeStamp: UInt64;
    function GetElapsedMs: UInt64;
    function GetElapsedNs: UInt64;
  public
    constructor Create(aMode: TNxChronoMode);
    constructor Start(aMode: TNxChronoMode); overload;
    procedure Start; overload;
    procedure Stop;
    procedure Clear;
    property Elapsed: UInt64 read fElapsed;
    property ElapsedNs: UInt64 read GetElapsedNs;
    property ElapsedMs: UInt64 read GetElapsedMs;
  end;

implementation

// ***** Time measuring APIs *****

{$IFDEF MACOS}
type
  clockid_t = clock_res_t;

function clock_gettime_nsec_np(clock_id: clockid_t): uint64_t; cdecl;
  external libc name _PU + 'clock_gettime_nsec_np';
{$EXTERNALSYM clock_gettime_nsec_np}

function clock_gettime(clk_id: clockid_t; ts: Ptimespec): Integer; cdecl;
  external libc name _PU + 'clock_gettime';
{$EXTERNALSYM clock_gettime}

const
  CLOCK_REALTIME = 0;
  CLOCK_MONOTONIC_RAW = 4;
  CLOCK_MONOTONIC_RAW_APPROX = 5;
  CLOCK_MONOTONIC = 6;
  CLOCK_UPTIME_RAW = 8;
  CLOCK_UPTIME_RAW_APPROX = 9;
  CLOCK_PROCESS_CPUTIME_ID = 12;
  CLOCK_THREAD_CPUTIME_ID = 16;

  NSEC_PER_USEC = 1000;       // nanoseconds per microsecond
  USEC_PER_SEC  = 1000000;    // microseconds per second
  NSEC_PER_SEC  = 1000000000; // nanoseconds per second
  NSEC_PER_MSEC = 1000000;    // nanoseconds per millisecond
{$ENDIF}

{$IFDEF MSWINDOWS}
function GetCalendarTimeStamp: UInt64;
begin
  Result := GetTickCount * UInt64(10000);
end;

function GetProcessTimeStamp: UInt64;
var
  lpCreationTime, lpExitTime, lpKernelTime, lpUserTime: TFileTime;
  ts: ULARGE_INTEGER;
begin
  Result := 0;
  if GetProcessTimes(GetCurrentProcess, lpCreationTime, lpExitTime,
    lpKernelTime, lpUserTime) then
    begin
      ts.HighPart := lpKernelTime.dwHighDateTime;
      ts.LowPart := lpKernelTime.dwLowDateTime;
      Result := ts.QuadPart;
      ts.HighPart := lpUserTime.dwHighDateTime;
      ts.LowPart := lpUserTime.dwLowDateTime;
      Result := Result + ts.QuadPart;
    end;
end;

function GetThreadTimeStamp: UInt64;
var
  lpCreationTime, lpExitTime, lpKernelTime, lpUserTime: TFileTime;
  ts: ULARGE_INTEGER;
begin
  Result := 0;
  if GetThreadTimes(TThread.CurrentThread.Handle, lpCreationTime, lpExitTime,
    lpKernelTime, lpUserTime) then
    begin
      ts.HighPart := lpKernelTime.dwHighDateTime;
      ts.LowPart := lpKernelTime.dwLowDateTime;
      Result := ts.QuadPart;
      ts.HighPart := lpUserTime.dwHighDateTime;
      ts.LowPart := lpUserTime.dwLowDateTime;
      Result := Result + ts.QuadPart;
    end;
end;

function GetProcessCycles: UInt64;
begin
  if not QueryProcessCycleTime(GetCurrentProcess, Result) then
    Result := 0;
end;

function GetThreadCycles: UInt64;
begin
  if not QueryThreadCycleTime(TThread.CurrentThread.Handle, Result) then
    Result := 0;
end;

{$ELSE}
function GetCalendarTimeStamp: UInt64;
var
  ts: timespec;
begin
  Result := 0;
  if clock_gettime(CLOCK_MONOTONIC, @ts) = 0 then
    Result := (Int64(1000000000) * ts.tv_sec + ts.tv_nsec) div 100;
end;

function GetProcessTimeStamp: UInt64;
var
  ts: timespec;
begin
  Result := 0;
  if clock_gettime(CLOCK_PROCESS_CPUTIME_ID, @ts) = 0 then
    Result := (Int64(1000000000) * ts.tv_sec + ts.tv_nsec) div 100;
end;

function GetThreadTimeStamp: UInt64;
var
  ts: timespec;
begin
  Result := 0;
  if clock_gettime(CLOCK_THREAD_CPUTIME_ID, @ts) = 0 then
    Result := (Int64(1000000000) * ts.tv_sec + ts.tv_nsec) div 100;
end;

function GetProcessCycles: UInt64;
var
  ts: timespec;
begin
  Result := 0;
  if clock_gettime(CLOCK_PROCESS_CPUTIME_ID, @ts) = 0 then
    Result := (Int64(1000000000) * ts.tv_sec + ts.tv_nsec) div 100;
end;

function GetThreadCycles: UInt64;
var
  ts: timespec;
begin
  Result := 0;
  if clock_gettime(CLOCK_THREAD_CPUTIME_ID, @ts) = 0 then
    Result := (Int64(1000000000) * ts.tv_sec + ts.tv_nsec) div 100;
end;
{$ENDIF}

// ***** TNxChronometer *****

constructor TNxChronometer.Create(aMode: TNxChronoMode);
begin
  fMode := aMode;
  fElapsed := 0;
  fStartTimeStamp := 0;
end;

constructor TNxChronometer.Start(aMode: TNxChronoMode);
begin
  fMode := aMode;
  fElapsed := 0;
  fStartTimeStamp := CurrentTimeStamp;
end;

procedure TNxChronometer.Start;
begin
  fStartTimeStamp := CurrentTimeStamp;
end;

procedure TNxChronometer.Stop;
var
  Current: UInt64;
begin
  if fStartTimeStamp = 0 then
    Exit;
  Current := CurrentTimeStamp - fStartTimeStamp;
  fStartTimeStamp := 0;
  if Current > 0 then
    fElapsed := fElapsed + Current;
end;

procedure TNxChronometer.Clear;
begin
  fStartTimeStamp := 0;
  fElapsed := 0;
end;

function TNxChronometer.CurrentTimeStamp: UInt64;
begin
  case fMode of
    CalendarTime : Result := GetCalendarTimeStamp;
    ProcessTime : Result := GetProcessTimeStamp;
    ThreadTime : Result := GetThreadTimeStamp;
    ProcessCycles : Result := GetProcessCycles;
    ThreadCycles : Result := GetThreadCycles;
    else Result := 0;
  end;
end;

function TNxChronometer.GetElapsedNs: UInt64;
begin
  Result := fElapsed * 100;
end;

function TNxChronometer.GetElapsedMs: UInt64;
begin
  Result := fElapsed div 10000;
end;

end.

