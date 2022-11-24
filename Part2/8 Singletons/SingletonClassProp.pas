unit SingletonClassProp;

interface

type
  TFoo = class
  private
    class var FInstance: TFoo;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  public
    class property Instance: TFoo read FInstance;
  end;

implementation

class constructor TFoo.ClassCreate;
begin
  FInstance := TFoo.Create;
end;

class destructor TFoo.ClassDestroy;
begin
  FInstance.Free;
end;

end.
