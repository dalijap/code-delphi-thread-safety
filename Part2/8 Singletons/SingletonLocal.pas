unit SingletonLocal;

interface

uses
  System.Classes,
  SingletonClasses;

function LocalObject: TFooObject;
function LocalInterface: IFoo;

implementation

var
  Foo: IFoo;
  FooObj: TFooObject;

function LocalObject: TFooObject;
begin
  Result := FooObj;
end;

function LocalInterface: IFoo;
begin
  Result := Foo;
end;

initialization

  Foo := TFoo.Create;
  FooObj := TFooObject.Create;

finalization

  FooObj.Free;

end.
