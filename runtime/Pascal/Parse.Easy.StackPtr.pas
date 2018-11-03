// ----------- Parse::Easy::Runtime -----------
// https://github.com/MahdiSafsafi/Parse-Easy
// --------------------------------------------

unit Parse.Easy.StackPtr;

interface

const
  MAX_STACK_ITEM_COUNT = 4000;

type
  TStackPtr = class(TObject)
  private
    FIndex: Integer;
    FArray: array [0 .. MAX_STACK_ITEM_COUNT - 1] of Pointer;
    function GetCount: Integer;
    function GetItem(Index: Integer): Pointer;
    procedure SetItem(Index: Integer; const Value: Pointer);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Push(Value: Pointer);
    function Pop(): Pointer;
    function Peek(): Pointer;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: Pointer read GetItem write SetItem; default;
  end;

implementation

{ TStackPtr }

constructor TStackPtr.Create;
begin
  FIndex := 0;
end;

destructor TStackPtr.Destroy;
begin

  inherited;
end;

function TStackPtr.GetCount: Integer;
begin
  Result := FIndex;
end;

function TStackPtr.Peek: Pointer;
begin
  Result := FArray[FIndex - 1];
end;

function TStackPtr.Pop: Pointer;
begin
  Result := FArray[FIndex - 1];
  Dec(FIndex);
end;

procedure TStackPtr.Push(Value: Pointer);
begin
  FArray[FIndex] := Value;
  Inc(FIndex);
end;

function TStackPtr.GetItem(Index: Integer): Pointer;
begin
  Result := FArray[index];
end;

procedure TStackPtr.SetItem(Index: Integer; const Value: Pointer);
begin
  FArray[Index] := Value;
end;

end.
