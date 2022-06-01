unit ImagesMainF;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Threading,
  System.IOUtils,
  Winapi.GDIPOBJ,
  ActiveX,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.GIFImg,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  System.ImageList,
  Vcl.ImgList,
  Vcl.ComCtrls;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    ListView1: TListView;
    ThnList: TImageList;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
  public
    procedure AddThumbnail(const FileName: string; Bmp: TBitmap);
  end;

var
  MainForm: TMainForm;

const
  Declare path to folder with some image files
  DataFolder = 'C:\...\';

implementation

{$R *.dfm}

// Generate Jpeg thumbnails
procedure TMainForm.Button1Click(Sender: TObject);
var
  Folder: string;
begin
  Folder := DataFolder;
  TTask.Run(
    procedure
    var
      Files: TArray<string>;
      jpeg: TJpegImage;
      Bmp: TBitmap;
      i: Integer;
    begin
      Files := TDirectory.GetFiles(Folder, '*.jpg');
      Bmp := nil;
      jpeg := TJpegImage.Create;
      try
        jpeg.Scale := jsEighth;
        Bmp := TBitmap.Create;
        Bmp.Width := 150;
        Bmp.Height := 100;
        for i := 0 to high(Files) do
          begin
            jpeg.LoadFromFile(Files[i]);
            jpeg.Canvas.Lock;
            try
              Bmp.Canvas.Lock;
              try
                Bmp.Canvas.StretchDraw(Rect(0, 0, 150, 100), jpeg);
              finally
                Bmp.Canvas.Unlock;
              end;
            finally
              jpeg.Canvas.Unlock;
            end;
            TThread.Synchronize(nil,
              procedure
              var
                Item: TListItem;
                Index: Integer;
              begin
                index := ThnList.Add(Bmp, nil);
                Item := ListView1.Items.Add;
                Item.Caption := Files[i];
                Item.ImageIndex := index;
              end);
          end;
      finally
        jpeg.Free;
        Bmp.Free;
      end;
    end);
end;

// Generate image thumbnails with Synchronize method
procedure TMainForm.Button2Click(Sender: TObject);
var
  Folder: string;
begin
  Folder := DataFolder;
  TTask.Run(
    procedure
    var
      Files: TArray<string>;
      Bmp: TBitmap;
      i: Integer;
      Image: TGPBitmap;
      Dest: TGPGraphics;
      ImgStream: IStream;
    begin
      Files := TDirectory.GetFiles(Folder, '*.*');
      Bmp := TBitmap.Create;
      try
        Bmp.Width := 150;
        Bmp.Height := 100;
        for i := 0 to high(Files) do
          begin
            ImgStream := TStreamAdapter.Create(TFileStream.Create(Files[i], fmOpenRead or fmShareDenyWrite), soOwned);
            Image := nil;
            Dest := nil;
            Bmp.Canvas.Lock;
            try
              Bmp.Canvas.FillRect(Rect(0, 0, 150, 100));
              Image := TGPBitmap.Create(ImgStream);
              Dest := TGPGraphics.Create(Bmp.Canvas.Handle);
              Dest.DrawImage(Image, 0, 0, 150, 100);
            finally
              Dest.Free;
              Image.Free;
              Bmp.Canvas.Unlock;
            end;
            TThread.Synchronize(nil,
              procedure
              var
                Item: TListItem;
                Index: Integer;
              begin
                index := ThnList.Add(Bmp, nil);
                Item := ListView1.Items.Add;
                Item.Caption := Files[i];
                Item.ImageIndex := index;
              end);
          end;
      finally
        Bmp.Free;
      end;
    end);
end;

procedure TMainForm.AddThumbnail(const FileName: string; Bmp: TBitmap);
begin
  TThread.Queue(nil,
    procedure
    var
      Item: TListItem;
      Index: Integer;
    begin
      try
        index := ThnList.Add(Bmp, nil);
        Item := ListView1.Items.Add;
        Item.Caption := FileName;
        Item.ImageIndex := index;
      finally
        Bmp.Free;
      end;
    end);
end;

// Generate image thumbnails with Queue method
procedure TMainForm.Button3Click(Sender: TObject);
var
  Folder: string;
begin
  Folder := DataFolder;
  TTask.Run(
    procedure
    var
      Files: TArray<string>;
      Bmp: TBitmap;
      i: Integer;
      Image: TGPBitmap;
      Dest: TGPGraphics;
      ImgStream: IStream;
    begin
      Files := TDirectory.GetFiles(Folder, '*.*');
      for i := 0 to high(Files) do
        begin
          ImgStream := TStreamAdapter.Create(TFileStream.Create(Files[i], fmOpenRead or fmShareDenyWrite), soOwned);
          Image := nil;
          Dest := nil;
          Bmp := TBitmap.Create;
          try
            Bmp.Width := 150;
            Bmp.Height := 100;
            Bmp.Canvas.Lock;
            try
              Bmp.Canvas.FillRect(Rect(0, 0, 150, 100));
              Image := TGPBitmap.Create(ImgStream);
              Dest := TGPGraphics.Create(Bmp.Canvas.Handle);
              Dest.DrawImage(Image, 0, 0, 150, 100);
            finally
              Dest.Free;
              Image.Free;
              Bmp.Canvas.Unlock;
            end;
            AddThumbnail(Files[i], Bmp);
          except
            Bmp.Free;
            raise;
          end;
        end;
    end);
end;

end.
