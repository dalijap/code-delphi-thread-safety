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

unit NX.Horizon;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.TypInfo,
  System.SyncObjs,
  System.Threading;

type
  INxEvent<T> = interface
    function GetValue: T;
    property Value: T read GetValue;
  end;

  TNxEventMethod<T> = procedure(const aEvent: T) of object;
  TNxEventMethod = TNxEventMethod<TObject>;

  TNxHorizonDelivery = (
    Sync,     // Run synchronously on current thread - BLOCKING
    Async,    // Run asynchronously in a random background thread
    MainSync, // Run synchronously on main thread - BLOCKING
    MainAsync // Run asynchronously on main thread
  );

  INxEventSubscription = interface
  ['{15BE488F-CFE3-4EFB-A3DA-910D0C443D50}']
    function BeginWork: Boolean;
    procedure EndWork;
    procedure WaitFor;
    procedure Cancel;
    function GetIsActive: Boolean;
    function GetIsCanceled: Boolean;
    property IsActive: Boolean read GetIsActive;
    property IsCanceled: Boolean read GetIsCanceled;
  end;

  TNxEventObject<T> = class(TInterfacedObject, INxEvent<T>)
  protected
    fValue: T;
    function GetValue: T;
  public
    constructor Create(const aValue: T);
    destructor Destroy; override;
    property Value: T read GetValue;
    class function New(const aValue: T): INxEvent<T>;
  end;

  TNxEvent<T> = record
  private
    fValue: T;
    function GetValue: T;
  public
    constructor New(const aValue: T);
    property Value: T read GetValue;
  end;

  TNxEventSubscription = class(TInterfacedObject, INxEventSubscription)
  protected
    fCountdown: TCountdownEvent;
    fEventMethod: TNxEventMethod;
    fEventInfo: PTypeInfo;
    fDelivery: TNxHorizonDelivery;
    fIsCanceled: Boolean;
    function GetIsActive: Boolean;
    function GetIsCanceled: Boolean;
  public
    constructor Create(aEventInfo: PTypeInfo; aDelivery: TNxHorizonDelivery; aObserver: TNxEventMethod);
    destructor Destroy; override;
    function BeginWork: Boolean;
    procedure EndWork;
    procedure WaitFor;
    procedure Cancel;
    property IsActive: Boolean read GetIsActive;
    property IsCanceled: Boolean read GetIsCanceled;
  end;

  TNxHorizon = class
  protected
    fLock: IReadWriteSync;
    fSubscriptions: TDictionary<PTypeInfo, TList<INxEventSubscription>>;
    procedure DispatchEvent<T>(const aEvent: T; const aSubscription: INxEventSubscription; aDelivery: TNxHorizonDelivery; aObserver: TNxEventMethod);
  public
    constructor Create;
    destructor Destroy; override;
    function Subscribe<T>(aDelivery: TNxHorizonDelivery; aObserver: TNxEventMethod<T>): INxEventSubscription;
    procedure Unsubscribe(const aSubscription: INxEventSubscription); 
    procedure UnsubscribeAsync(const aSubscription: INxEventSubscription);
    procedure Post<T>(const aEvent: T);
    procedure Send<T>(const aEvent: T; aDelivery: TNxHorizonDelivery);
  end;

  NxHorizon = class
  protected
    class var
      fInstance: TNxHorizon;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  public
    class property Instance: TNxHorizon read fInstance;
  end;

implementation

{ TNxEventObject<T> }

constructor TNxEventObject<T>.Create(const aValue: T);
begin
  fValue := aValue;
end;

destructor TNxEventObject<T>.Destroy;
var
  Obj: TObject;
begin
  if PTypeInfo(TypeInfo(T)).Kind = tkClass then
    begin
      PObject(@Obj)^ := PPointer(@fValue)^;
      Obj.Free;
    end;
  inherited;
end;

function TNxEventObject<T>.GetValue: T;
begin
  Result := fValue;
end;

class function TNxEventObject<T>.New(const aValue: T): INxEvent<T>;
begin
  Result := TNxEventObject<T>.Create(aValue);
end;

{ TNxEvent<T> }

constructor TNxEvent<T>.New(const aValue: T);
begin
  fValue := aValue;
end;

function TNxEvent<T>.GetValue: T;
begin
  Result := fValue;
end;

{ TNxEventSubscription }

constructor TNxEventSubscription.Create(aEventInfo: PTypeInfo; aDelivery: TNxHorizonDelivery; aObserver: TNxEventMethod);
begin
  fEventInfo := aEventInfo;
  fDelivery := aDelivery;
  fEventMethod := aObserver;
  fCountdown := TCountdownEvent.Create(1);
end;

destructor TNxEventSubscription.Destroy;
begin
  fCountdown.Free;
  inherited;
end;

function TNxEventSubscription.BeginWork: Boolean;
begin
  Result := (not fIsCanceled) and fCountdown.TryAddCount;
end;

procedure TNxEventSubscription.EndWork;
begin
  fCountdown.Signal;
end;

procedure TNxEventSubscription.WaitFor;
begin
  fIsCanceled := True;
  fCountdown.Signal;
  fCountdown.WaitFor;
end;

function TNxEventSubscription.GetIsActive: Boolean;
begin
  Result := not fIsCanceled;
end;

function TNxEventSubscription.GetIsCanceled: Boolean;
begin
  Result := fIsCanceled;
end;

procedure TNxEventSubscription.Cancel;
begin
  fIsCanceled := True;
end;

{ TNxHorizon }

constructor TNxHorizon.Create;
begin
  fLock := TMultiReadExclusiveWriteSynchronizer.Create;
  fSubscriptions := TObjectDictionary<PTypeInfo, TList<INxEventSubscription>>.Create([doOwnsValues]);
end;

destructor TNxHorizon.Destroy;
begin
  fSubscriptions.Free;
  inherited;
end;

function TNxHorizon.Subscribe<T>(aDelivery: TNxHorizonDelivery; aObserver: TNxEventMethod<T>): INxEventSubscription;
var
  SubList: TList<INxEventSubscription>;
begin
  Result := TNxEventSubscription.Create(PTypeInfo(TypeInfo(T)), aDelivery, TNxEventMethod(aObserver));
  fLock.BeginWrite;
  try
    if not fSubscriptions.TryGetValue(PTypeInfo(TypeInfo(T)), SubList) then
      begin
        SubList := TList<INxEventSubscription>.Create;
        fSubscriptions.Add(PTypeInfo(TypeInfo(T)), SubList);
      end;
    SubList.Add(Result);
  finally
    fLock.EndWrite;
  end;
end;

procedure TNxHorizon.Unsubscribe(const aSubscription: INxEventSubscription);
var
  SubList: TList<INxEventSubscription>;
begin
  aSubscription.Cancel;
  fLock.BeginWrite;
  try
    if fSubscriptions.TryGetValue(TNxEventSubscription(aSubscription).fEventInfo, SubList) then
      SubList.Remove(aSubscription);
  finally
    fLock.EndWrite;
  end;
end;

procedure TNxHorizon.UnsubscribeAsync(const aSubscription: INxEventSubscription);
var
  [unsafe] lProc: TProc;
begin
  aSubscription.Cancel;
  lProc :=
    procedure
    begin
      Unsubscribe(aSubscription);
    end;
  TTask.Run(lProc);
end;

procedure TNxHorizon.DispatchEvent<T>(const aEvent: T; const aSubscription: INxEventSubscription; aDelivery: TNxHorizonDelivery; aObserver: TNxEventMethod);
var
  [unsafe] lProc: TProc;
begin
  lProc :=
    procedure
    begin
      if aSubscription.BeginWork then
        try
          TNxEventMethod<T>(aObserver)(aEvent);
        finally;
          aSubscription.EndWork;
        end;
    end;

  case aDelivery of
// Synchronous dispatching is done directly in Send and Post methods
//    Sync :
//      begin
//        // IsActive was already checked before entering dispatch
//        // in synchronous execution IsActive could not be changed in the meantime
//        TNxEventMethod<T>(aObserver)(aEvent);
//      end;
    Async :
      begin
        TTask.Run(lProc);
      end;
    MainSync :
      begin
        if TThread.CurrentThread.ThreadID = MainThreadID then
          lProc
        else
          TThread.Synchronize(nil, TThreadProcedure(lProc));
      end;
    MainAsync :
      begin
        TThread.ForceQueue(nil, TThreadProcedure(lProc));
      end;
  end;
end;

procedure TNxHorizon.Post<T>(const aEvent: T);
var
  SubList: TList<INxEventSubscription>;
  Sub: TNxEventSubscription;
  i: Integer;
begin
  fLock.BeginRead;
  try
    if fSubscriptions.TryGetValue(PTypeInfo(TypeInfo(T)), SubList) then
      for i := 0 to SubList.Count - 1 do
        begin
          Sub := TNxEventSubscription(SubList.List[i]);
          if Sub.IsActive and (Sub.fEventInfo = PTypeInfo(TypeInfo(T))) then
            begin
              // check if delivery is Sync because
              // DispatchEvent has anonymous methods setup
              // that is unnecessary for synchronous execution path
              if Sub.fDelivery = Sync then
                begin
                  if Sub.BeginWork then
                    try
                      TNxEventMethod<T>(Sub.fEventMethod)(aEvent);
                    finally
                      Sub.EndWork;
                    end;
                end
              else
                DispatchEvent(aEvent, Sub, Sub.fDelivery, Sub.fEventMethod);
            end;
        end;
  finally
    fLock.EndRead;
  end;
end;

procedure TNxHorizon.Send<T>(const aEvent: T; aDelivery: TNxHorizonDelivery);
var
  SubList: TList<INxEventSubscription>;
  Sub: TNxEventSubscription;
  i: Integer;
begin
  fLock.BeginRead;
  try
    if fSubscriptions.TryGetValue(PTypeInfo(TypeInfo(T)), SubList) then
      for i := 0 to SubList.Count - 1 do
        begin
          Sub := TNxEventSubscription(SubList.List[i]);
          if Sub.IsActive and (Sub.fEventInfo = PTypeInfo(TypeInfo(T))) then
            begin
              // check if delivery is Sync because
              // DispatchEvent has anonymous methods setup
              // that is unnecessary for synchronous execution path
              if aDelivery = Sync then
                begin
                  if Sub.BeginWork then
                    try
                      TNxEventMethod<T>(Sub.fEventMethod)(aEvent);
                    finally
                      Sub.EndWork;
                    end;
                end
              else
                DispatchEvent<T>(aEvent, Sub, aDelivery, Sub.fEventMethod);
            end;
        end;
  finally
    fLock.EndRead;
  end;
end;

{ NxHorizon }

class constructor NxHorizon.ClassCreate;
begin
  fInstance := TNxHorizon.Create;
end;

class destructor NxHorizon.ClassDestroy;
begin
  fInstance.Free;
end;

end.