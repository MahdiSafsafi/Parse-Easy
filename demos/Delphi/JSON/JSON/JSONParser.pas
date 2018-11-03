
// -------------------------------------------------------
//
// This file was generated using Parse::Easy v1.0 alpha.
//
// https://github.com/MahdiSafsafi/Parse-Easy
//
// DO NOT EDIT !!! ANY CHANGE MADE HERE WILL BE LOST !!!
//
// -------------------------------------------------------

unit JSONParser;

interface

uses System.SysUtils, System.Classes, WinApi.Windows, 
     Parse.Easy.Lexer.Token,
     Parse.Easy.Parser.LR1,
     Parse.Easy.Parser.CustomParser;

type TJSONParser = class(TLR1)
  protected
    procedure UserAction(Index: Integer); override;
  public
    class constructor Create;
end;

implementation

{$R 'JSONParser.res'}

{ TJSONParser }

class constructor TJSONParser.Create;
begin
  Deserialize('JSONPARSER');
end;

procedure TJSONParser.UserAction(Index: Integer);
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
  0002:
    begin
      ReturnValue^.AsList := CreateNewList(); ReturnValue^.AsList.Add(PValue(Values[Values.Count - 1 - 0])^.AsPointer);
    end;
  0003:
    begin
      ReturnValue^.AsList := nil;
    end;
  0004:
    begin
      ReturnValue^.AsList := CreateNewList(); ReturnValue^.AsList.Add(PValue(Values[Values.Count - 1 - 0])^.AsToken);
    end;
  0005:
    begin
      ReturnValue^.AsList := nil;
    end;
  0006:
    begin
      ReturnValue^.AsList := CreateNewList(); ReturnValue^.AsList.Add(PValue(Values[Values.Count - 1 - 0])^.AsToken);
    end;
  0007:
    begin
      ReturnValue^.AsList := nil;
    end;
  0008:
    begin
      ReturnValue^.AsList := CreateNewList(); ReturnValue^.AsList.Add(PValue(Values[Values.Count - 1 - 0])^.AsToken);
    end;
  0009:
    begin
      ReturnValue^.AsList := nil;
    end;
  end;
end;

end.
