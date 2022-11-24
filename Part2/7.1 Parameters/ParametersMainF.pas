unit ParametersMainF;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Memo: TMemo;
    CancelBtn: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
  public
    Canceled: Boolean;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

function IntValue(Value: Integer): Integer;
begin
  Result := Value;
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  Value: Integer;
begin
  Memo.Lines.Add('Working');
  Canceled := False;
  TThread.CreateAnonymousThread(
    procedure
    begin
      while not Canceled do
        begin
          Value := -1;
        end;
    end).Start;

  TThread.CreateAnonymousThread(
    procedure
    var
      ValueCopy: Integer;
    begin
      while not Canceled do
        begin
          Value := 0;
          ValueCopy := IntValue(Value);
          if ValueCopy <> 0 then
            begin
              Canceled := True;
              TThread.Synchronize(nil,
                procedure
                begin
                  Memo.Lines.Add('Not zero ' + ValueCopy.ToHexString);
                end);
            end;
        end;
    end).Start;
end;

function Int64Value(Value: Int64): Int64;
begin
  Result := Value;
end;

procedure TMainForm.Button2Click(Sender: TObject);
var
  Value: Int64;
begin
  Memo.Lines.Add('Working');
  Canceled := False;
  TThread.CreateAnonymousThread(
    procedure
    begin
      while not Canceled do
        begin
          Value := -1;
        end;
    end).Start;

  TThread.CreateAnonymousThread(
    procedure
    var
      ValueCopy: Int64;
    begin
      while not Canceled do
        begin
          Value := 0;
          ValueCopy := Int64Value(Value);
          if (ValueCopy <> 0) and (ValueCopy <> -1) then
            begin
              Canceled := True;
              TThread.Synchronize(nil,
                procedure
                begin
                  Memo.Lines.Add('Not zero ' + ValueCopy.ToHexString);
                end);
            end;
        end;
    end).Start;
end;

procedure TMainForm.CancelBtnClick(Sender: TObject);
begin
  Canceled := True;
  Memo.Lines.Add('Canceled');
end;

end.

