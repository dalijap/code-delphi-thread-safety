unit DependentParallelCollectionsMainF;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Threading,
  System.Generics.Collections,
  System.Diagnostics,
  System.Math,
  System.SyncObjs,
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
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure PopulateList(List: TList<TArray<Integer>>);
var
  i, j: Integer;
  a: TArray<Integer>;
begin
  for i := 0 to 10000 do
    begin
      SetLength(a, 10000);
      for j := 0 to High(a) do
        a[j] := Random(10000);
      List.Add(a);
    end;
end;


procedure SortItemsAndSumForLoop(List: TList<TArray<Integer>>);
var
  i, j: Integer;
  Sorted: TArray<Integer>;
  Total: Int64;
begin
  Total := 0;
  for i := 0 to List.Count - 1 do
    begin
      Sorted := List[i];
      TArray.Sort<Integer>(Sorted);
      for j := 0 to High(Sorted) do
        Total := Total + Sorted[j];
    end;
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  List: TList<TArray<Integer>>;
  t: TStopwatch;
begin
  Memo.Lines.Add('Running for loop in single thread...');
  List := TList<TArray<Integer>>.Create;
  try
    PopulateList(List);
    t := TStopwatch.StartNew;
    SortItemsAndSumForLoop(List);
    t.Stop;
    Memo.Lines.Add('Finished in ms ' + t.ElapsedMilliseconds.ToString);
  finally
    List.Free;
  end;
end;


procedure SortItemsAndSumParallelFor(List: TList<TArray<Integer>>);
var
  Total: Int64;
  Lock: TCriticalSection;
begin
  Total := 0;
  Lock := TCriticalSection.Create;
  try
    TParallel.For(0, List.Count - 1,
      procedure(TaskIndex: Integer)
      var
        Sorted: TArray<Integer>;
        i: integer;
      begin
        Sorted := List[TaskIndex];
        TArray.Sort<Integer>(Sorted);
        Lock.Enter;
        try
          for i := 0 to High(Sorted) do
            Total := Total + Sorted[i];
        finally
          Lock.Leave;
        end;
      end);
  finally
    Lock.Free;
  end;
end;

procedure TMainForm.Button2Click(Sender: TObject);
var
  List: TList<TArray<Integer>>;
  t: TStopwatch;
begin
  Memo.Lines.Add('Running parallel for with full lock ...');
  List := TList<TArray<Integer>>.Create;
  try
    PopulateList(List);
    t := TStopwatch.StartNew;
    SortItemsAndSumParallelFor(List);
    t.Stop;
    Memo.Lines.Add('Finished in ms ' + t.ElapsedMilliseconds.ToString);
  finally
    List.Free;
  end;
end;



procedure SortItemsAndSumParallelFor2(List: TList<TArray<Integer>>);
var
  Total: Int64;
  Lock: TCriticalSection;
begin
  Total := 0;
  Lock := TCriticalSection.Create;
  try
    TParallel.For(0, List.Count - 1,
      procedure(TaskIndex: Integer)
      var
        Sorted: TArray<Integer>;
        TempTotal: Int64;
        i: Integer;
      begin
        Sorted := List[TaskIndex];
        TArray.Sort<Integer>(Sorted);
        TempTotal := 0;
        for i := 0 to High(Sorted) do
          TempTotal := TempTotal + Sorted[i];
        Lock.Enter;
        try
          Total := Total + TempTotal;
        finally
          Lock.Leave;
        end;
      end);
  finally
    Lock.Free;
  end;
end;

procedure TMainForm.Button3Click(Sender: TObject);
var
  List: TList<TArray<Integer>>;
  t: TStopwatch;
begin
  Memo.Lines.Add('Running parallel for with temporary total...');
  List := TList<TArray<Integer>>.Create;
  try
    PopulateList(List);
    t := TStopwatch.StartNew;
    SortItemsAndSumParallelFor2(List);
    t.Stop;
    Memo.Lines.Add('Finished in ms ' + t.ElapsedMilliseconds.ToString);
  finally
    List.Free;
  end;
end;



procedure SortItemsAndSumParallelForLockFree(List: TList<TArray<Integer>>);
var
  Total: Int64;
begin
  Total := 0;
  TParallel.For(0, List.Count - 1,
    procedure(TaskIndex: Integer)
    var
      Sorted: TArray<Integer>;
      TempTotal: Int64;
      i: integer;
    begin
      Sorted := List[TaskIndex];
      TArray.Sort<Integer>(Sorted);
      TempTotal := 0;
      for i := 0 to High(Sorted) do
        TempTotal := TempTotal + Sorted[i];
      TInterlocked.Add(Total, TempTotal);
    end);
end;

procedure TMainForm.Button4Click(Sender: TObject);
var
  List: TList<TArray<Integer>>;
  t: TStopwatch;
begin
  Memo.Lines.Add('Running parallel for lock free...');
  List := TList<TArray<Integer>>.Create;
  try
    PopulateList(List);
    t := TStopwatch.StartNew;
    SortItemsAndSumParallelForLockFree(List);
    t.Stop;
    Memo.Lines.Add('Finished in ms ' + t.ElapsedMilliseconds.ToString);
  finally
    List.Free;
  end;
end;


initialization

 Randomize;

end.
