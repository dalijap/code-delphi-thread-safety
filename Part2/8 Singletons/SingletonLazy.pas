unit SingletonLazy;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.SyncObjs,
  SingletonClasses;

type
  TSingletonLock = class
  private
    class var FInstance: TFooObject;
    class var FLock: TCriticalSection;
    class constructor ClassCreate;
    class destructor ClassDestroy;
    class function GetInstance: TFooObject; static;
  public
    class property Instance: TFooObject read GetInstance;
  end;

  TSingletonDoubleLock = class
  private
    class var FInstance: TFooObject;
    class var FLock: TCriticalSection;
    class constructor ClassCreate;
    class destructor ClassDestroy;
    class function GetInstance: TFooObject; static;
  public
    class property Instance: TFooObject read GetInstance;
  end;

  TSingletonLockFree = class
  private
    class var FInstance: TFooObject;
    class destructor ClassDestroy;
    class function GetInstance: TFooObject; static;
  public
    class property Instance: TFooObject read GetInstance;
  end;

  TSingletonLockFreeIntf = class
  public
    class var FInstance: IFoo;
    class function GetInstance: IFoo; static;
  public
    class property Instance: IFoo read GetInstance;
  end;

  TSingletonFlag = class
  private
    class var FInstance: IFoo;
    class var FFlag: Integer;
    class function GetInstance: IFoo; static;
  public
    class property Instance: IFoo read GetInstance;
  end;

  TWriteableInstance = class
  private
    class var FInstance: TFooObject;
    class var FLock: TCriticalSection;
    class constructor ClassCreate;
    class destructor ClassDestroy;
    class function GetInstance: TFooObject; static;
    class procedure SetInstance(Value: TFooObject); static;
  public
    class property Instance: TFooObject read GetInstance write SetInstance;
  end;

implementation

{ TSingletonLock }

class constructor TSingletonLock.ClassCreate;
begin
  FLock := TCriticalSection.Create;
end;

class destructor TSingletonLock.ClassDestroy;
begin
  FInstance.Free;
  FLock.Free;
end;

class function TSingletonLock.GetInstance: TFooObject;
begin
  FLock.Enter;
  try
    if FInstance = nil then
      FInstance := TFooObject.Create;
    Result := FInstance;
  finally
    FLock.Leave;
  end;
end;

{ TSingletonDoubleLock }

class constructor TSingletonDoubleLock.ClassCreate;
begin
  FLock := TCriticalSection.Create;
end;

class destructor TSingletonDoubleLock.ClassDestroy;
begin
  FInstance.Free;
  FLock.Free;
end;

class function TSingletonDoubleLock.GetInstance: TFooObject;
begin
  if FInstance = nil then
    begin
      FLock.Enter;
      try
        if FInstance = nil then
          FInstance := TFooObject.Create;
      finally
        FLock.Leave;
      end;
    end;
  Result := FInstance;
end;

{ TSingletonLockFree }

class destructor TSingletonLockFree.ClassDestroy;
begin
  FInstance.Free;
end;

class function TSingletonLockFree.GetInstance: TFooObject;
var
  LInstance: TFooObject;
begin
  if FInstance = nil then
    begin
      LInstance := TFooObject.Create;
      if TInterlocked.CompareExchange<TFooObject>(FInstance, LInstance, nil) <> nil then
        LInstance.Free;
    end;
  Result := FInstance;
end;


{ TSingletonLockFreeIntf }

class function TSingletonLockFreeIntf.GetInstance: IFoo;
begin
  if FInstance = nil then
    begin
      Result := TFoo.Create;
      if TInterlocked.CompareExchange(Pointer(FInstance), Pointer(Result), nil) = nil then
        Pointer(Result) := nil;
    end;
  Result := FInstance;
end;

{ TSingletonFlag }

class function TSingletonFlag.GetInstance: IFoo;
begin
  while FInstance = nil do
    begin
      if TInterlocked.CompareExchange(FFlag, 1, 0) = 0 then
        FInstance := TFoo.Create
      else
        YieldProcessor;
    end;
  Result := FInstance;
end;

{ TWriteableInstance }

class constructor TWriteableInstance.ClassCreate;
begin
  FLock := TCriticalSection.Create;
end;

class destructor TWriteableInstance.ClassDestroy;
begin
  FInstance.Free;
  FLock.Free;
end;

class function TWriteableInstance.GetInstance: TFooObject;
begin
  FLock.Enter;
  try
    Result := FInstance;
  finally
    FLock.Leave;
  end;
end;

class procedure TWriteableInstance.SetInstance(Value: TFooObject);
begin
  FLock.Enter;
  try
    FInstance.Free;
    FInstance := Value;
  finally
    FLock.Leave;
  end;
end;

end.
