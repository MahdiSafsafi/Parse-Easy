// ----------- Parse::Easy::Runtime -----------
// https://github.com/MahdiSafsafi/Parse-Easy
// --------------------------------------------

unit Parse.Easy.Parser.Action;

interface

uses
  System.Classes,
  System.SysUtils;

type
  TActionType = (atUnkown,atShift, atReduce, atJump);

  TAction = class(TObject)
  private
    FType: TActionType;
    FValue: Integer;
  public
    constructor Create(AType: TActionType; AValue: Integer); virtual;
    property ActionType: TActionType read FType;
    property ActionValue: Integer read FValue;
  end;

implementation

{ TAction }

constructor TAction.Create(AType: TActionType; AValue: Integer);
begin
  FType := AType;
  FValue := AValue;
end;

end.
