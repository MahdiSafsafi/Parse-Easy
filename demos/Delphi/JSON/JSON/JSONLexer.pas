
// -------------------------------------------------------
//
// This file was generated using Parse::Easy v1.0 alpha.
//
// https://github.com/MahdiSafsafi/Parse-Easy
//
// DO NOT EDIT !!! ANY CHANGE MADE HERE WILL BE LOST !!!
//
// -------------------------------------------------------

unit JSONLexer;

interface

uses System.SysUtils, WinApi.Windows,
     Parse.Easy.Lexer.CustomLexer;

type TJSONLexer = class(TCustomLexer)
  protected
    procedure UserAction(Index: Integer); override;
  public
    class constructor Create;
    function  GetTokenName(Index: Integer): string; override;
end;

const

  EOF        = 0000;
  BACKSLASH  = 0001;
  LPAREN     = 0002;
  RPAREN     = 0003;
  LBRACE     = 0004;
  RBRACE     = 0005;
  LBRACK     = 0006;
  RBRACK     = 0007;
  SQUOTE     = 0008;
  DQUOTE     = 0009;
  PLUS       = 0010;
  MINUS      = 0011;
  COLON      = 0012;
  COMMA      = 0013;
  TK_FALSE   = 0014;
  TK_TRUE    = 0015;
  TK_NULL    = 0016;
  DQSTRING   = 0017;
  DIGIT      = 0018;
  FRAC       = 0019;
  EXP        = 0020;
  WS         = 0021;
  SECTION_DEFAULT = 0000;


implementation

{$R JSONLexer.RES}

{ TJSONLexer }

class constructor TJSONLexer.Create;
begin
  Deserialize('JSONLEXER');
end;

procedure TJSONLexer.UserAction(Index: Integer);
begin
  case Index of
  0000:
    begin
      Skip
    end;
  end;
end;

function TJSONLexer.GetTokenName(Index: Integer): string;
begin
  case Index of
    0000 : exit('EOF'     );
    0001 : exit('BACKSLASH');
    0002 : exit('LPAREN'  );
    0003 : exit('RPAREN'  );
    0004 : exit('LBRACE'  );
    0005 : exit('RBRACE'  );
    0006 : exit('LBRACK'  );
    0007 : exit('RBRACK'  );
    0008 : exit('SQUOTE'  );
    0009 : exit('DQUOTE'  );
    0010 : exit('PLUS'    );
    0011 : exit('MINUS'   );
    0012 : exit('COLON'   );
    0013 : exit('COMMA'   );
    0014 : exit('TK_FALSE');
    0015 : exit('TK_TRUE' );
    0016 : exit('TK_NULL' );
    0017 : exit('DQSTRING');
    0018 : exit('DIGIT'   );
    0019 : exit('FRAC'    );
    0020 : exit('EXP'     );
    0021 : exit('WS'      );
  end;
  Result := 'Unkown' + IntToStr(Index);
end;

end.
