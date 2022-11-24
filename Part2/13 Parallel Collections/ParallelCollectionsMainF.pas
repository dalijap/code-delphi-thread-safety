unit ParallelCollectionsMainF;

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
    Button5: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
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



procedure SortItemsForLoop(List: TList<TArray<Integer>>);
var
  i: Integer;
  Sorted: TArray<Integer>;
begin
  for i := 0 to List.Count - 1 do
    begin
      Sorted := List[i];
      TArray.Sort<Integer>(Sorted);
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
    SortItemsForLoop(List);
    t.Stop;
    Memo.Lines.Add('Finished in ms ' + t.ElapsedMilliseconds.ToString);
  finally
    List.Free;
  end;
end;



procedure SortItemsThreads(List: TList<TArray<Integer>>);
var
  Finished: Integer;

procedure RunThread(Sorted: TArray<Integer>);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      TArray.Sort<Integer>(Sorted);
      TInterlocked.Decrement(Finished);
    end).Start;
end;

var
  i: Integer;
begin
  Finished := List.Count;
  for i := 0 to List.Count - 1 do
    RunThread(List[i]);

  while Finished > 0 do
    begin
      Sleep(100);
      Application.ProcessMessages;
    end;
end;

procedure TMainForm.Button2Click(Sender: TObject);
var
  List: TList<TArray<Integer>>;
  t: TStopwatch;
begin
  Memo.Lines.Add('Running multiple threads - can crash ...');
  List := TList<TArray<Integer>>.Create;
  try
    PopulateList(List);
    t := TStopwatch.StartNew;
    SortItemsThreads(List);
    t.Stop;
    Memo.Lines.Add('Finished in ms ' + t.ElapsedMilliseconds.ToString);
  finally
    List.Free;
  end;
end;



procedure SortItemsTasks(List: TList<TArray<Integer>>);
var
  Finished: Integer;

procedure RunTask(Sorted: TArray<Integer>);
begin
  TTask.Run(
    procedure
    begin
      TArray.Sort<Integer>(Sorted);
      TInterlocked.Decrement(Finished);
    end);
end;

var
  i: Integer;
begin
  Finished := List.Count;
  for i := 0 to List.Count - 1 do
    RunTask(List[i]);

  while Finished > 0 do
    begin
      Sleep(100);
      Application.ProcessMessages;
    end;
end;

procedure TMainForm.Button3Click(Sender: TObject);
var
  List: TList<TArray<Integer>>;
  t: TStopwatch;
begin
  Memo.Lines.Add('Running multiple tasks...');
  List := TList<TArray<Integer>>.Create;
  try
    PopulateList(List);
    t := TStopwatch.StartNew;
    SortItemsTasks(List);
    t.Stop;
    Memo.Lines.Add('Finished in ms ' + t.ElapsedMilliseconds.ToString);
  finally
    List.Free;
  end;
end;



procedure SortItemsParallelLoop(List: TList<TArray<Integer>>);
begin
  TParallel.For(10, 0, List.Count - 1,
    procedure(TaskIndex: Integer)
    begin
      TArray.Sort<Integer>(List[TaskIndex]);
    end);
end;

procedure TMainForm.Button4Click(Sender: TObject);
var
  List: TList<TArray<Integer>>;
  t: TStopwatch;
begin
  Memo.Lines.Add('Running parallel for loop...');
  List := TList<TArray<Integer>>.Create;
  try
    PopulateList(List);
    t := TStopwatch.StartNew;
    SortItemsParallelLoop(List);
    t.Stop;
    Memo.Lines.Add('Finished in ms ' + t.ElapsedMilliseconds.ToString);
  finally
    List.Free;
  end;
end;



procedure SortItemsParallelThreads(List: TList<TArray<Integer>>);
var
  Finished: Integer;

procedure SortItemsBatch(List: TList<TArray<Integer>>; L, H: Integer);
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
      Sorted: TArray<Integer>;
    begin
      for i := L to H do
        begin
          Sorted := List[i];
          TArray.Sort<Integer>(Sorted);
          TInterlocked.Decrement(Finished);
        end;
     end).Start;
end;

var
  i: Integer;
  Stride: Integer;
  L, H: Integer;
begin
  Finished := List.Count;

  if List.Count <= CPUCount then
    Stride := 1
  else
    Stride := List.Count div CPUCount;

  for i := 0 to List.Count div Stride do
    begin
      L := i * Stride;
      H := (i + 1) * Stride - 1;
      if H >= List.Count then
        H := List.Count - 1;
      if L <= H then
        SortItemsBatch(List, L, H);
    end;

  while Finished > 0 do
    begin
      Sleep(100);
      Application.ProcessMessages;
    end;
end;

procedure TMainForm.Button5Click(Sender: TObject);
var
  List: TList<TArray<Integer>>;
  t: TStopwatch;
begin
  Memo.Lines.Add('Running multiple batch threads...');
  List := TList<TArray<Integer>>.Create;
  try
    PopulateList(List);
    t := TStopwatch.StartNew;
    SortItemsParallelThreads(List);
    t.Stop;
    Memo.Lines.Add('Finished in ms ' + t.ElapsedMilliseconds.ToString);
  finally
    List.Free;
  end;
end;


initialization

 Randomize;

end.
