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


unit NX.Tokens;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type
  INxCancellationToken = interface
    function GetIsCanceled: Boolean;
    procedure Cancel;
    procedure RaiseIfCanceled;
    property IsCanceled: Boolean read GetIsCanceled;
  end;

  TNxCancellationToken = class(TInterfacedObject, INxCancellationToken)
  protected
    fIsCanceled: Boolean;
    function GetIsCanceled: Boolean;
  public
    procedure Cancel;
    procedure RaiseIfCanceled;
    property IsCanceled: Boolean read GetIsCanceled;
  end;

  TNxEmptyCancellationToken = class(TInterfacedObject, INxCancellationToken)
  protected
    function GetIsCanceled: Boolean;
  public
    procedure Cancel;
    procedure RaiseIfCanceled;
    property IsCanceled: Boolean read GetIsCanceled;
  end;

implementation

{ TNxCancellationToken }

function TNxCancellationToken.GetIsCanceled: Boolean;
begin
  Result := fIsCanceled;
end;

procedure TNxCancellationToken.Cancel;
begin
  fIsCanceled := True;
end;

procedure TNxCancellationToken.RaiseIfCanceled;
begin
  if fIsCanceled then
    raise EOperationCancelled.Create('Operation canceled');
end;

{ TNxEmptyCancellationToken }

function TNxEmptyCancellationToken.GetIsCanceled: Boolean;
begin
  Result := False;
end;

procedure TNxEmptyCancellationToken.Cancel;
begin
  // do nothing
end;

procedure TNxEmptyCancellationToken.RaiseIfCanceled;
begin
  // do nothing
end;

end.
