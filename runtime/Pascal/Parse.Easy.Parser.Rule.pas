// ----------- Parse::Easy::Runtime -----------
// https://github.com/MahdiSafsafi/Parse-Easy
// --------------------------------------------

unit Parse.Easy.Parser.Rule;

interface

uses
  System.Classes,
  System.SysUtils;

type
  TRuleFlag = (rfAccept);
  TRuleFlags = set of TRuleFlag;

  TRule = class(TObject)
  private
    FIndex: Integer;
    FID: Integer;
    FNumberOfItems: Integer;
    FActionIndex: Integer;
    FFlags: TRuleFlags;
  public
    constructor Create; virtual;
    property Id: Integer read FID write FID;
    property Index: Integer read FIndex write FIndex;
    property NumberOfItems: Integer read FNumberOfItems write FNumberOfItems;
    property ActionIndex: Integer read FActionIndex write FActionIndex;
    property Flags: TRuleFlags read FFlags write FFlags;
  end;

implementation

{ TRule }

constructor TRule.Create;
begin
  FFlags := [];
end;

end.
