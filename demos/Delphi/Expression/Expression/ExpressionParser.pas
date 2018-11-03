
// -------------------------------------------------------
//
// This file was generated using Parse::Easy v1.0 alpha.
//
// https://github.com/MahdiSafsafi/Parse-Easy
//
// DO NOT EDIT !!! ANY CHANGE MADE HERE WILL BE LOST !!!
//
// -------------------------------------------------------

unit ExpressionParser;

interface

uses System.SysUtils, System.Classes, WinApi.Windows, 
     ExpressionBase,
     System.Math,
     Parse.Easy.Lexer.Token,
     Parse.Easy.Parser.LR1,
     Parse.Easy.Parser.CustomParser;

type TExpressionParser = class(TExpressionBase)
  protected
    procedure UserAction(Index: Integer); override;
  public
    class constructor Create;
end;

implementation

{$R 'ExpressionParser.res'}

{ TExpressionParser }

class constructor TExpressionParser.Create;
begin
  Deserialize('EXPRESSIONPARSER');
end;

procedure TExpressionParser.UserAction(Index: Integer);
begin
  case Index of
  0002:
    begin
       DoClear() 
    end;
  0003:
    begin
       DoEcho(PValue(Values[Values.Count - 1 - 1])^.AsPChar)
    end;
  0004:
    begin
       ReturnValue^.AsPChar := SQString(PValue(Values[Values.Count - 1 - 0])^.AsToken.Text) 
    end;
  0005:
    begin
       ReturnValue^.AsPChar := DQString(PValue(Values[Values.Count - 1 - 0])^.AsToken.Text) 
    end;
  0000:
    begin
      ReturnValue^.AsList := CreateNewList(); ReturnValue^.AsList.Add(PValue(Values[Values.Count - 1 - 0])^.AsToken);
    end;
  0001:
    begin
      ReturnValue^.AsList := nil;
    end;
  0006:
    begin
       
    DoAssignment(Assigned(PValue(Values[Values.Count - 1 - 3])^.AsList), PValue(Values[Values.Count - 1 - 2])^.AsToken.Text, PValue(Values[Values.Count - 1 - 0])^.AsDouble);
  
    end;
  0007:
    begin
       ReturnValue^.AsDouble := PValue(Values[Values.Count - 1 - 2])^.AsDouble + PValue(Values[Values.Count - 1 - 0])^.AsDouble 
    end;
  0008:
    begin
       ReturnValue^.AsDouble := PValue(Values[Values.Count - 1 - 2])^.AsDouble - PValue(Values[Values.Count - 1 - 0])^.AsDouble 
    end;
  0009:
    begin
       ReturnValue^.AsDouble := PValue(Values[Values.Count - 1 - 2])^.AsDouble *   PValue(Values[Values.Count - 1 - 0])^.AsDouble 
    end;
  0010:
    begin
       ReturnValue^.AsDouble := PValue(Values[Values.Count - 1 - 2])^.AsDouble /   PValue(Values[Values.Count - 1 - 0])^.AsDouble 
    end;
  0011:
    begin
       ReturnValue^.AsDouble := Fmod(PValue(Values[Values.Count - 1 - 2])^.AsDouble, PValue(Values[Values.Count - 1 - 0])^.AsDouble) 
    end;
  0012:
    begin
       ReturnValue^.AsDouble := +PValue(Values[Values.Count - 1 - 0])^.AsDouble 
    end;
  0013:
    begin
       ReturnValue^.AsDouble := -PValue(Values[Values.Count - 1 - 0])^.AsDouble 
    end;
  0014:
    begin
       ReturnValue^.AsDouble := PValue(Values[Values.Count - 1 - 1])^.AsDouble 
    end;
  0015:
    begin
       ReturnValue^.AsDouble := GetVarValue(PValue(Values[Values.Count - 1 - 0])^.AsToken.Text) 
    end;
  0016:
    begin
       ReturnValue^.AsDouble := PValue(Values[Values.Count - 1 - 0])^.AsDouble    
    end;
  0017:
    begin
       ReturnValue^.AsDouble := StrToFloat(PValue(Values[Values.Count - 1 - 0])^.AsToken.Text) 
    end;
  0018:
    begin
       ReturnValue^.AsDouble := Cos(PValue(Values[Values.Count - 1 - 1])^.AsDouble) 
    end;
  0019:
    begin
       ReturnValue^.AsDouble := Sin(PValue(Values[Values.Count - 1 - 1])^.AsDouble) 
    end;
  0020:
    begin
       ReturnValue^.AsDouble := Tangent(PValue(Values[Values.Count - 1 - 1])^.AsDouble) 
    end;
  0021:
    begin
       ReturnValue^.AsDouble := DoMin(PValue(Values[Values.Count - 1 - 0])^.AsList) 
    end;
  0022:
    begin
       ReturnValue^.AsDouble := DoMax(PValue(Values[Values.Count - 1 - 0])^.AsList) 
    end;
  0023:
    begin
       ReturnValue^.AsDouble := StrToFloat(PValue(Values[Values.Count - 1 - 0])^.AsToken.Text) 
    end;
  0024:
    begin
       ReturnValue^.AsDouble := HexToFloat(PValue(Values[Values.Count - 1 - 0])^.AsToken.Text) 
    end;
  0025:
    begin
       ReturnValue^.AsList := PValue(Values[Values.Count - 1 - 1])^.AsList 
    end;
  0026:
    begin
       ReturnValue^.AsList := PValue(Values[Values.Count - 1 - 2])^.AsList; ReturnValue^.AsList.Add(@PValue(Values[Values.Count - 1 - 0])^.AsDouble) 
    end;
  0027:
    begin
       ReturnValue^.AsList := CreateNewList() 
    end;
  end;
end;

end.
