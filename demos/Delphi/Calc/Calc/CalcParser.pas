
// -------------------------------------------------------
//
// This file was generated using Parse::Easy v1.0 alpha.
//
// https://github.com/MahdiSafsafi/Parse-Easy
//
// DO NOT EDIT !!! ANY CHANGE MADE HERE WILL BE LOST !!!
//
// -------------------------------------------------------

unit CalcParser;

interface

uses System.SysUtils, System.Classes, WinApi.Windows, 
     Parse.Easy.Lexer.Token,
     Parse.Easy.Parser.LR1,
     Parse.Easy.Parser.CustomParser;

type TCalcParser = class(TLR1)
  protected
    procedure UserAction(Index: Integer); override;
  public
    class constructor Create;
end;

implementation

{$R 'CalcParser.res'}

{ TCalcParser }

class constructor TCalcParser.Create;
begin
  Deserialize('CALCPARSER');
end;

procedure TCalcParser.UserAction(Index: Integer);
begin
  case Index of
  0000:
    begin
      ReturnValue^.AsList := CreateNewList(); ReturnValue^.AsList.Add(PValue(Values[Values.Count - 1 - 0])^.AsPointer);
    end;
  0001:
    begin
      ReturnValue^.AsList := nil;
    end;
  end;
end;

end.
