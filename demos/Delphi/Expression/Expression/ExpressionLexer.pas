
// -------------------------------------------------------
//
// This file was generated using Parse::Easy v1.0 alpha.
//
// https://github.com/MahdiSafsafi/Parse-Easy
//
// DO NOT EDIT !!! ANY CHANGE MADE HERE WILL BE LOST !!!
//
// -------------------------------------------------------

unit ExpressionLexer;

interface

uses System.SysUtils, WinApi.Windows,
     Parse.Easy.Lexer.CustomLexer;

type TExpressionLexer = class(TCustomLexer)
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
  PERCENT    = 0007;
  COMMA      = 0008;
  EQUAL      = 0009;
  SEMICOLON  = 0010;
  COS        = 0011;
  SIN        = 0012;
  TAN        = 0013;
  MIN        = 0014;
  MAX        = 0015;
  TK_VAR     = 0016;
  CLEAR      = 0017;
  ECHO       = 0018;
  SQ_STRING  = 0019;
  DQ_STRING  = 0020;
  DIGIT      = 0021;
  FLOAT      = 0022;
  HEX        = 0023;
  ID         = 0024;
  COMMENT    = 0025;
  WS         = 0026;
  SECTION_DEFAULT = 0000;


implementation

{$R ExpressionLexer.RES}

{ TExpressionLexer }

class constructor TExpressionLexer.Create;
begin
  Deserialize('EXPRESSIONLEXER');
end;

procedure TExpressionLexer.UserAction(Index: Integer);
begin
  case Index of
  0000:
    begin
      skip
    end;
  0001:
    begin
      skip
    end;
  end;
end;

function TExpressionLexer.GetTokenName(Index: Integer): string;
begin
  case Index of
    0000 : exit('EOF'     );
    0001 : exit('LPAREN'  );
    0002 : exit('RPAREN'  );
    0003 : exit('PLUS'    );
    0004 : exit('MINUS'   );
    0005 : exit('STAR'    );
    0006 : exit('SLASH'   );
    0007 : exit('PERCENT' );
    0008 : exit('COMMA'   );
    0009 : exit('EQUAL'   );
    0010 : exit('SEMICOLON');
    0011 : exit('COS'     );
    0012 : exit('SIN'     );
    0013 : exit('TAN'     );
    0014 : exit('MIN'     );
    0015 : exit('MAX'     );
    0016 : exit('TK_VAR'  );
    0017 : exit('CLEAR'   );
    0018 : exit('ECHO'    );
    0019 : exit('SQ_STRING');
    0020 : exit('DQ_STRING');
    0021 : exit('DIGIT'   );
    0022 : exit('FLOAT'   );
    0023 : exit('HEX'     );
    0024 : exit('ID'      );
    0025 : exit('COMMENT' );
    0026 : exit('WS'      );
  end;
  Result := 'Unkown' + IntToStr(Index);
end;

end.
