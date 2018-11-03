
// -------------------------------------------------------
//
// This file was generated using Parse::Easy v1.0 alpha.
//
// https://github.com/MahdiSafsafi/Parse-Easy
//
// DO NOT EDIT !!! ANY CHANGE MADE HERE WILL BE LOST !!!
//
// -------------------------------------------------------

unit CalcLexer;

interface

uses System.SysUtils, WinApi.Windows,
     Parse.Easy.Lexer.CustomLexer;

type TCalcLexer = class(TCustomLexer)
  protected
    procedure UserAction(Index: Integer); override;
  public
    class constructor Create;
    function  GetTokenName(Index: Integer): string; override;
end;

const

  EOF        = 0000;
  LPAREN     = 0001;
  RPAREN     = 0002;
  PLUS       = 0003;
  MINUS      = 0004;
  STAR       = 0005;
  SLASH      = 0006;
  DECIMAL    = 0007;
  FLOAT      = 0008;
  WS         = 0009;
  SECTION_DEFAULT = 0000;


implementation

{$R CalcLexer.RES}

{ TCalcLexer }

class constructor TCalcLexer.Create;
begin
  Deserialize('CALCLEXER');
end;

procedure TCalcLexer.UserAction(Index: Integer);
begin
  case Index of
  0000:
    begin
      skip
    end;
  end;
end;

function TCalcLexer.GetTokenName(Index: Integer): string;
begin
  case Index of
    0000 : exit('EOF'     );
    0001 : exit('LPAREN'  );
    0002 : exit('RPAREN'  );
    0003 : exit('PLUS'    );
    0004 : exit('MINUS'   );
    0005 : exit('STAR'    );
    0006 : exit('SLASH'   );
    0007 : exit('DECIMAL' );
    0008 : exit('FLOAT'   );
    0009 : exit('WS'      );
  end;
  Result := 'Unkown' + IntToStr(Index);
end;

end.
