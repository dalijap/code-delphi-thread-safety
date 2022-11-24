unit SingletonClasses;

interface

type
  IFoo = interface
  end;

  TFoo = class(TInterfacedObject, IFoo);

  TFooObject = class
  end;

implementation

end.
