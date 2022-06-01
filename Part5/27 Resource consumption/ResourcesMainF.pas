unit ResourcesMainF;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Threading,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.GIFImg,
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
    FPool: TThreadPool;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;


var
  MainForm: TMainForm;

const
  Declare path to some larger (at least 12MP) JPEG image
  JpegFile = 'C:\....jpg';

implementation

{$R *.dfm}

// This code will excessively consume resources and eventually crash.
// Crash is easier to reproduce with larger images (at least 12MP)
procedure TMainForm.Button1Click(Sender: TObject);
var
  i: Integer;
begin
  Memo.Lines.Add('Running');
  for i := 0 to 100 do
    TThread.CreateAnonymousThread(
      procedure
      var
        Pic: TPicture;
        Bmp: TBitmap;
      begin
        try
          Bmp := nil;
          Pic := TPicture.Create;
          try
            Bmp := TBitmap.Create;
            Bmp.Width := 150;
            Bmp.Height := 100;
            // path to some image
            // for demonstration we can load the same image
            Pic.LoadFromFile(JpegFile);
            Bmp.Canvas.StretchDraw(Rect(0, 0, Bmp.Width, Bmp.Height), Pic.Graphic);
          finally
            Pic.Free;
            // intentional leak of thumbnail bitmap
            // to simulate adding bitmap to some image list
            // Bmp.Free;
          end;
        except
          on E: Exception do
            TThread.Queue(nil,
              procedure
              begin
                Memo.Lines.Add(E.Message);
              end);
        end;
      end).Start;
end;

// Single thread with a loop
// This example consumes the least resources, but
// it requires the most time
// Anonymous thread can be replaced with single task
procedure TMainForm.Button2Click(Sender: TObject);
begin
  Memo.Lines.Add('Running');
    TThread.CreateAnonymousThread(
      procedure
      var
        Pic: TPicture;
        Bmp: TBitmap;
        i: Integer;
      begin
        try
          for i := 0 to 100 do
            begin
              Bmp := nil;
              Pic := TPicture.Create;
              try
                Bmp := TBitmap.Create;
                Bmp.Width := 150;
                Bmp.Height := 100;
                // path to some image
                // for demonstration we can load the same image
                Pic.LoadFromFile(JpegFile);
                Bmp.Canvas.StretchDraw(Rect(0, 0, Bmp.Width, Bmp.Height), Pic.Graphic);
              finally
                Pic.Free;
                // intentional leak of thumbnail bitmap
                // to simulate adding bitmap to some image list
                // Bmp.Free;
              end;
            end;
          TThread.Queue(nil,
            procedure
            begin
              Memo.Lines.Add('Completed');
            end);
          except
            on E: Exception do
              TThread.Queue(nil,
                procedure
                begin
                  Memo.Lines.Add(E.Message);
                end);
          end;
      end).Start;
end;

// Tasks
// This example significantly reduces memory consumption
// However, resource exhaustion is still possible, as the number of
// running tasks will be determined by number of CPU cores and
// with higher number of tasks running on 32-bit platforms issues
// can happen more often
procedure TMainForm.Button3Click(Sender: TObject);
var
  i: Integer;
begin
  Memo.Lines.Add('Running');
  for i := 0 to 100 do
    TTask.Run(
      procedure
      var
        Pic: TPicture;
        Bmp: TBitmap;
      begin
        try
          Bmp := nil;
          Pic := TPicture.Create;
          try
            Bmp := TBitmap.Create;
            Bmp.Width := 150;
            Bmp.Height := 100;
            // path to some image
            // for demonstration we can load the same image
            Pic.LoadFromFile(JpegFile);
            Bmp.Canvas.StretchDraw(Rect(0, 0, Bmp.Width, Bmp.Height), Pic.Graphic);
          finally
            Pic.Free;
            // intentional leak of thumbnail bitmap
            // to simulate adding bitmap to some image list
            // Bmp.Free;
          end;
        except
          on E: Exception do
            TThread.Queue(nil,
              procedure
              begin
                Memo.Lines.Add(E.Message);
              end);
        end;
      end);
end;

// Tasks with dedicated thread pool
// This example significantly reduces memory consumption
procedure TMainForm.Button4Click(Sender: TObject);
var
  i: Integer;
begin
  Memo.Lines.Add('Running');
  for i := 0 to 100 do
    TTask.Run(
      procedure
      var
        Pic: TPicture;
        Bmp: TBitmap;
      begin
        try
          Bmp := nil;
          Pic := TPicture.Create;
          try
            Bmp := TBitmap.Create;
            Bmp.Width := 150;
            Bmp.Height := 100;
            // path to some image
            // for demonstration we can load the same image
            Pic.LoadFromFile(JpegFile);
            Bmp.Canvas.StretchDraw(Rect(0, 0, Bmp.Width, Bmp.Height), Pic.Graphic);
          finally
            Pic.Free;
            // intentional leak of thumbnail bitmap
            // to simulate adding bitmap to some image list
            // Bmp.Free;
          end;
        except
          on E: Exception do
            TThread.Queue(nil,
              procedure
              begin
                Memo.Lines.Add(E.Message);
              end);
        end;
      end, FPool);
end;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  FPool := TThreadPool.Create;
  FPool.SetMinWorkerThreads(2);
  FPool.SetMaxWorkerThreads(4);
end;

destructor TMainForm.Destroy;
begin
  FPool.Free;
  inherited;
end;

end.
