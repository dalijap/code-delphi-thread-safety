program SafeMath;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

// Thread safe implementations of FPCR functions
// that can be used for patching RTL

{$IFDEF MSWINDOWS}
procedure SafeSet8087CW(NewCW: Word);
var
  CW: Word;
asm
  MOV CW, AX
  FNCLEX  // don't raise pending exceptions enabled by the new flags
  FLDCW  CW
end;

procedure SafeSetMXCSR(NewMXCSR: LongWord);
var
  MXCSR: LongWord;
asm
  AND EAX, $FFC0 //Remove flag bits
  MOV MXCSR, EAX
  LDMXCSR MXCSR
end;

procedure SetDefault8087CW(NewCW: Word);
var
  CW: Word;
asm
    MOV CW, AX
    MOV Default8087CW, AX
    FNCLEX  // don't raise pending exceptions enabled by the new flags
    FLDCW  CW
end;

procedure SetDefaultMXCSR(NewMXCSR: LongWord);
var
  MXCSR: LongWord;
asm
  AND     EAX, $FFC0 // Remove flag bits
  MOV     MXCSR, EAX
  MOV     DefaultMXCSR, EAX
  LDMXCSR MXCSR
end;

procedure _FpuClear;
asm
  FNSTCW [ESP-$02]
  FNINIT
  FLDCW [ESP-$02]
  {$IF Defined(CPUX86)}

  CMP System.TestSSE, 0
  JE @Exit
  {$ENDIF}

  STMXCSR [ESP-$04]
  AND [ESP-$04], $FFC0 //Remove flag bits
  LDMXCSR [ESP-$04]
@Exit:
end;
{$ENDIF}

{$IFDEF POSIX}
procedure _FpuClear;
begin
  FClearExcept;
end;
{$ENDIF}

begin
  Writeln('DONE');
  Readln;
end.
