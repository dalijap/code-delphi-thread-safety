unit CollectionsMainF;

interface

{$R+} // turn on range checking

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Memo: TMemo;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
  public
    procedure ShowException(Msg: string);
  end;

// Various thread-safe collections

  TThreadList<T> = class
  private
    FList: TList<T>;
    // FLock is a custom managed record
    // which is automatically initialized
    FLock: TLightweightMREW;
    function GetCount: Integer;
    function GetItem(Index: Integer): T;
    procedure SetCount(const Value: Integer);
    procedure SetItem(Index: Integer; const Value: T);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add(const Value: T): Integer;
    procedure Delete(Index: Integer);
    function Contains(const Value: T): Boolean;

    function BeginRead: TList<T>;
    procedure EndRead;

    function BeginWrite: TList<T>;
    procedure EndWrite;

    procedure Enumerate(const AProc: TProc<T>);

    property Count: Integer read GetCount write SetCount;
    property Items[Index: Integer]: T read GetItem write SetItem; default;

    type
      TEnumerator = class(TEnumerator<T>)
      private
        FList: TThreadList<T>;
        FIndex: Integer;
        function GetCurrent: T; inline;
      protected
        function DoGetCurrent: T; override;
        function DoMoveNext: Boolean; override;
      public
        constructor Create(const AList: TThreadList<T>);
        destructor Destroy; override;
        function MoveNext: Boolean; inline;
        property Current: T read GetCurrent;
      end;

    function GetEnumerator: TEnumerator; inline;
  end;

  IList<T> = interface
    function BeginRead: TList<T>;
    procedure EndRead;
    function BeginWrite: TList<T>;
    procedure EndWrite;
  end;

  TIntfThreadList<T> = class(TInterfacedObject, IList<T>)
  protected
    FLock: TLightweightMREW;
    FList: TList<T>;
  public
    constructor Create;
    destructor Destroy; override;
    function BeginRead: TList<T>;
    procedure EndRead;
    function BeginWrite: TList<T>;
    procedure EndWrite;
  end;

  TThreadDictionary<K, V> = class
  protected
    FLock: TLightweightMREW;
    FDict: TDictionary<K, V>;
  public
    constructor Create;
    destructor Destroy; override;
    function BeginRead: TDictionary<K, V>;
    procedure EndRead;
    function BeginWrite: TDictionary<K, V>;
    procedure EndWrite;
  end;

  TThreadObjectDictionary<K, V> = class
  protected
    FLock: TLightweightMREW;
    FDict: TDictionary<K, V>;
  public
    constructor Create;
    destructor Destroy; override;
    function BeginRead: TDictionary<K, V>;
    procedure EndRead;
    function BeginWrite: TDictionary<K, V>;
    procedure EndWrite;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.ShowException(Msg: string);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      ShowMessage(Msg);
    end);
end;

// thread-unsafe
procedure TMainForm.Button1Click(Sender: TObject);
var
  List: array of Integer;
begin
  Memo.Lines.Clear;
  Memo.Lines.Add('Running thread-unsafe');
  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
      Len: Integer;
    begin
      try
        for i := 0 to 200 do
          begin
            Len := Length(List);
            SetLength(List, Len + 1);
            List[Len] := Len;
          end;
        TThread.Queue(nil,
          procedure
          begin
            Memo.Lines.Add('DONE 1');
          end);
      except
        on E: Exception do
          ShowException(E.Message);
      end;
    end).Start;

  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
      Len: Integer;
    begin
      try
        for i := 0 to 20 do
          begin
            Sleep(10);
            Len := Length(List);
            if Len > 0 then
              SetLength(List, Len -1);
          end;
        TThread.Queue(nil,
          procedure
          begin
            Memo.Lines.Add('DONE 2');
          end);
      except
        on E: Exception do
          ShowException(E.Message);
      end;
    end).Start;

  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
      Idx: Integer;
    begin
      try
        for i := 0 to 20 do
          begin
            for Idx := 0 to High(List) do
              OutputDebugString(PChar(List[Idx].ToString));
          end;
        TThread.Queue(nil,
          procedure
          begin
            Memo.Lines.Add('DONE 3');
          end);
      except
        on E: Exception do
          ShowException(E.Message);
      end;
    end).Start;
end;

// thread-safe using lock
procedure TMainForm.Button2Click(Sender: TObject);
var
  List: array of Integer;
  Lock: IReadWriteSync;
begin
  Memo.Lines.Clear;
  Memo.Lines.Add('Running lock');
  Lock := TSimpleRWSync.Create;
  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
      Len: Integer;
    begin
      try
        for i := 0 to 200 do
          begin
            Lock.BeginWrite;
            try
              Len := Length(List);
              SetLength(List, Len + 1);
              List[Len] := Len;
            finally
              Lock.EndWrite;
            end;
          end;
        TThread.Queue(nil,
          procedure
          begin
            Memo.Lines.Add('DONE 1');
          end);
      except
        on E: Exception do
          ShowException(E.Message);
      end;
    end).Start;

  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
      Len: Integer;
    begin
      try
        for i := 0 to 20 do
          begin
            Sleep(10);
            Lock.BeginWrite;
            try
              Len := Length(List);
              if Len > 0 then
                SetLength(List, Len -1);
            finally
              Lock.EndWrite;
            end;
          end;
        TThread.Queue(nil,
          procedure
          begin
            Memo.Lines.Add('DONE 2');
          end);
      except
        on E: Exception do
          ShowException(E.Message);
      end;
    end).Start;

  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
      Idx: Integer;
      c: PChar;
    begin
      try
        for i := 0 to 20 do
          begin
            Lock.BeginRead;
            try
              for Idx := 0 to High(List) do
                OutputDebugString(PChar(List[Idx].ToString));
            finally
              Lock.EndRead;
            end;
          end;
        TThread.Queue(nil,
          procedure
          begin
            Memo.Lines.Add('DONE 3');
          end);
      except
        on E: Exception do
          ShowException(E.Message);
      end;
    end).Start;
end;

// thread-safe using monitor
procedure TMainForm.Button3Click(Sender: TObject);
var
  List: TList<Integer>;
begin
  Memo.Lines.Clear;
  Memo.Lines.Add('Running monitor');
  // this list will be leaked
  List := TList<Integer>.Create;
  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
    begin
      try
        for i := 0 to 200 do
          begin
            System.TMonitor.Enter(List);
            try
              List.Add(List.Count);
            finally
              System.TMonitor.Exit(List);
            end;
          end;
        TThread.Queue(nil,
          procedure
          begin
            Memo.Lines.Add('DONE 1');
          end);
      except
        on E: Exception do
          ShowException(E.Message);
      end;
    end).Start;

  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
    begin
      try
        for i := 0 to 20 do
          begin
            Sleep(10);
            System.TMonitor.Enter(List);
            try
              if List.Count > 0 then
                List.Delete(List.Count - 1);
            finally
              System.TMonitor.Exit(List);
            end;
          end;
        TThread.Queue(nil,
          procedure
          begin
            Memo.Lines.Add('DONE 2');
          end);
      except
        on E: Exception do
          ShowException(E.Message);
      end;
    end).Start;

  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
      Idx: Integer;
    begin
      try
        for i := 0 to 20 do
          begin
            System.TMonitor.Enter(List);
            try
              for Idx := 0 to List.Count - 1 do
                OutputDebugString(PChar(List[Idx].ToString));
            finally
              System.TMonitor.Exit(List);
            end;
          end;
        TThread.Queue(nil,
          procedure
          begin
            Memo.Lines.Add('DONE 3');
          end);
      except
        on E: Exception do
          ShowException(E.Message);
      end;
    end).Start;
end;

// thread-safe list wrapper
procedure TMainForm.Button4Click(Sender: TObject);
var
  List: TThreadList<Integer>;
begin
  Memo.Lines.Clear;
  Memo.Lines.Add('Running list wrapper');
  // this list will be leaked
  List := TThreadList<Integer>.Create;
  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
    begin
      try
        for i := 0 to 200 do
          List.Add(List.Count);
        TThread.Queue(nil,
          procedure
          begin
            Memo.Lines.Add('DONE 1');
          end);
      except
        on E: Exception do
          ShowException(E.Message);
      end;
    end).Start;

  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
      TempList: TList<Integer>;
    begin
      try
        for i := 0 to 20 do
          begin
            Sleep(10);
            TempList := List.BeginRead;
            try
              if TempList.Count > 0 then
                TempList.Delete(TempList.Count - 1);
            finally
              List.EndRead;
            end;
          end;
        TThread.Queue(nil,
          procedure
          begin
            Memo.Lines.Add('DONE 2');
          end);
      except
        on E: Exception do
          ShowException(E.Message);
      end;
    end).Start;

  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
      Value: Integer;
    begin
      try
        for i := 0 to 20 do
          begin
            for Value in List do
              begin
                OutputDebugString(PWideChar(Value.ToString));
              end;
          end;
        TThread.Queue(nil,
          procedure
          begin
            Memo.Lines.Add('DONE 3');
          end);
      except
        on E: Exception do
          ShowException(E.Message);
      end;
    end).Start;
end;

{ TThreadList<T> }

constructor TThreadList<T>.Create;
begin
  FList := TList<T>.Create;
end;

destructor TThreadList<T>.Destroy;
begin
  FList.Free;
  inherited;
end;

function TThreadList<T>.GetCount: Integer;
begin
  FLock.BeginRead;
  try
    Result := FList.Count;
  finally
    FLock.EndRead;
  end;
end;

procedure TThreadList<T>.SetCount(const Value: Integer);
begin
  FLock.BeginWrite;
  try
    FList.Count := Value;
  finally
    FLock.EndWrite;
  end;
end;

function TThreadList<T>.GetItem(Index: Integer): T;
begin
  FLock.BeginRead;
  try
    Result := FList.Items[Index];
  finally
    FLock.EndRead;
  end;
end;

procedure TThreadList<T>.SetItem(Index: Integer; const Value: T);
begin
  FLock.BeginWrite;
  try
    FList.Items[Index] := Value;
  finally
    FLock.EndWrite;
  end;
end;

procedure TThreadList<T>.Clear;
begin
  FLock.BeginWrite;
  try
    FList.Clear;
  finally
    FLock.EndWrite;
  end;
end;

function TThreadList<T>.Add(const Value: T): Integer;
begin
  FLock.BeginWrite;
  try
    Result := FList.Add(Value);
  finally
    FLock.EndWrite;
  end;
end;

procedure TThreadList<T>.Delete(Index: Integer);
begin
  FLock.BeginWrite;
  try
    FList.Delete(Index);
  finally
    FLock.EndWrite;
  end;
end;

function TThreadList<T>.Contains(const Value: T): Boolean;
begin
  FLock.BeginRead;
  try
    Result := FList.Contains(Value);
  finally
    FLock.EndRead;
  end;
end;

function TThreadList<T>.BeginRead: TList<T>;
begin
  FLock.BeginRead;
  Result := FList;
end;

procedure TThreadList<T>.EndRead;
begin
  FLock.EndRead;
end;

function TThreadList<T>.BeginWrite: TList<T>;
begin
  FLock.BeginWrite;
  Result := FList;
end;

procedure TThreadList<T>.EndWrite;
begin
  FLock.EndWrite;
end;

procedure TThreadList<T>.Enumerate(const AProc: TProc<T>);
var
  Idx: Integer;
begin
  FLock.BeginRead;
  try
    for Idx := 0 to FList.Count - 1 do
      AProc(FList.List[Idx]);
  finally
    FLock.EndRead;
  end;
end;

{ TThreadList<T>.TEnumerator }

constructor TThreadList<T>.TEnumerator.Create(const AList: TThreadList<T>);
begin
  inherited Create;
  FList := AList;
  FIndex := -1;
  FList.FLock.BeginRead;
end;

destructor TThreadList<T>.TEnumerator.Destroy;
begin
  FList.FLock.EndRead;
  inherited;
end;

function TThreadList<T>.TEnumerator.GetCurrent: T;
begin
  Result := FList.FList.List[FIndex];
end;

function TThreadList<T>.TEnumerator.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < FList.FList.Count;
end;

function TThreadList<T>.TEnumerator.DoGetCurrent: T;
begin
  Result := Current;
end;

function TThreadList<T>.TEnumerator.DoMoveNext: Boolean;
begin
  Result := MoveNext;
end;

function TThreadList<T>.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(Self);
end;

{ TIntfThreadList<T> }

constructor TIntfThreadList<T>.Create;
begin
  FList := TList<T>.Create;
end;

destructor TIntfThreadList<T>.Destroy;
begin
  FList.Free;
  inherited;
end;

function TIntfThreadList<T>.BeginRead: TList<T>;
begin
  FLock.BeginRead;
  Result := FList;
end;

function TIntfThreadList<T>.BeginWrite: TList<T>;
begin
  FLock.BeginWrite;
  Result := FList;
end;

procedure TIntfThreadList<T>.EndRead;
begin
  FLock.EndRead;
end;

procedure TIntfThreadList<T>.EndWrite;
begin
  FLock.EndWrite;
end;

{ TThreadDictionary<K, V> }

constructor TThreadDictionary<K, V>.Create;
begin
  FDict := TDictionary<K, V>.Create;
end;

destructor TThreadDictionary<K, V>.Destroy;
begin
  FDict.Free;
  inherited;
end;

function TThreadDictionary<K, V>.BeginRead: TDictionary<K, V>;
begin
  FLock.BeginRead;
  Result := FDict;
end;

function TThreadDictionary<K, V>.BeginWrite: TDictionary<K, V>;
begin
  FLock.BeginWrite;
  Result := FDict;
end;

procedure TThreadDictionary<K, V>.EndRead;
begin
  FLock.EndRead;
end;

procedure TThreadDictionary<K, V>.EndWrite;
begin
  FLock.EndWrite;
end;

{ TThreadObjectDictionary<K, V> }

constructor TThreadObjectDictionary<K, V>.Create;
begin
  FDict := TObjectDictionary<K, V>.Create([doOwnsValues]);
end;

destructor TThreadObjectDictionary<K, V>.Destroy;
begin
  FDict.Free;
  inherited;
end;

function TThreadObjectDictionary<K, V>.BeginRead: TDictionary<K, V>;
begin
  FLock.BeginRead;
  Result := FDict;
end;

function TThreadObjectDictionary<K, V>.BeginWrite: TDictionary<K, V>;
begin
  FLock.BeginWrite;
  Result := FDict;
end;

procedure TThreadObjectDictionary<K, V>.EndRead;
begin
  FLock.EndRead;
end;

procedure TThreadObjectDictionary<K, V>.EndWrite;
begin
  FLock.EndWrite;
end;

end.
