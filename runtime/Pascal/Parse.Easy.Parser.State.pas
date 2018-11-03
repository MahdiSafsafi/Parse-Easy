// ----------- Parse::Easy::Runtime -----------
// https://github.com/MahdiSafsafi/Parse-Easy
// --------------------------------------------

unit Parse.Easy.Parser.State;

interface

uses
  System.Classes,
  System.SysUtils;

type
  TState = class(TObject)
  private
    FIndex: Integer;
    FTerms: TList;
    FNoTerms: TList;
    FNumberOfTerms: Integer;
    FNumberOfNoTerms: Integer;
    procedure SetNumberOfNoTerms(const Value: Integer);
    procedure SetNumberOfTerms(const Value: Integer);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property Index: Integer read FIndex write FIndex;
    property NumberOfTerms: Integer read FNumberOfTerms write SetNumberOfTerms;
    property NumberOfNoTerms: Integer read FNumberOfNoTerms write SetNumberOfNoTerms;
    property Terms: TList read FTerms;
    property NoTerms: TList read FNoTerms;
  end;

implementation

{ TState }

constructor TState.Create;
begin
  FNumberOfTerms := -1;
  FNumberOfNoTerms := -1;
  FTerms := TList.Create;
  FNoTerms := TList.Create;
end;

destructor TState.Destroy;
var
  I: Integer;
begin
  for I := 0 to FTerms.Count - 1 do
    if Assigned(FTerms[I]) then
        TObject(FTerms[I]).Free;

  for I := 0 to FNoTerms.Count - 1 do
    if Assigned(FNoTerms[I]) then
        TObject(FNoTerms[I]).Free;

  FTerms.Free;
  FNoTerms.Free;
  inherited;
end;

procedure TState.SetNumberOfNoTerms(const Value: Integer);
var
  I: Integer;
begin
  if (FNumberOfNoTerms <> Value) then
  begin
    FNumberOfNoTerms := Value;
    FNoTerms.Clear;
    for I := 0 to Value - 1 do
        FNoTerms.Add(nil);
  end;
end;

procedure TState.SetNumberOfTerms(const Value: Integer);
var
  I: Integer;
begin
  if (FNumberOfTerms <> Value) then
  begin
    FNumberOfTerms := Value;
    FTerms.Clear;
    for I := 0 to Value - 1 do
        FTerms.Add(nil);
  end;
end;

end.
