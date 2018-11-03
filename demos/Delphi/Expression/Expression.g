grammar Expression;

use Parser::Units     ('ExpressionBase', 'System.Math');
use Parser::BaseClass qw/TExpressionBase/;

// Lexer rules:
// ------------

fragment A        : 'a' | 'A';
fragment B        : 'b' | 'B';
fragment C        : 'c' | 'C';
fragment D        : 'd' | 'D';
fragment E        : 'e' | 'E';
fragment F        : 'f' | 'F';
fragment G        : 'g' | 'G';
fragment H        : 'h' | 'H';
fragment I        : 'i' | 'I';
fragment J        : 'j' | 'J';
fragment K        : 'k' | 'K';
fragment L        : 'l' | 'L';
fragment M        : 'm' | 'M';
fragment N        : 'n' | 'N';
fragment O        : 'o' | 'O';
fragment P        : 'p' | 'P';
fragment Q        : 'q' | 'Q';
fragment R        : 'r' | 'R';
fragment S        : 's' | 'S';
fragment T        : 't' | 'T';
fragment U        : 'u' | 'U';
fragment V        : 'v' | 'V';
fragment W        : 'w' | 'W';
fragment X        : 'x' | 'X';
fragment Y        : 'y' | 'Y';
fragment Z        : 'z' | 'Z';

fragment SQUOTE   : "'"; // single quote '.
fragment DQUOTE   : '"'; // double quote ".
fragment BACKSLASH: "\\";

fragment DEC      : [0-9]+;

LPAREN            : '(';
RPAREN            : ')';
PLUS              : '+';
MINUS             : '-';
STAR              : '*';
SLASH             : '/';
PERCENT           : '%';
COMMA             : ',';
EQUAL             : '=';
SEMICOLON         : ';';

// reserved keywords:
COS               : C O S;
SIN               : S I N;
TAN               : T A N;
MIN               : M I N;
MAX               : M A X;
TK_VAR            : V A R;
CLEAR             : C L E A R;
ECHO              : E C H O;

// strings:
SQ_STRING         : SQUOTE ( SQUOTE SQUOTE    |  [^'\n] )* SQUOTE; //'
DQ_STRING         : DQUOTE ( BACKSLASH DQUOTE |  [^"\n] )* DQUOTE;

// numbers:
DIGIT             : DEC;
FLOAT             : DEC '.' DEC;  
HEX               : ('0x' | '$') [\pHex]+;

// identifier:
// this should be the last one after all reserved keywords.
ID                : '&'? [_\p{Letter}][\p{Letter}_0-9]*;

// comments:
fragment COMMENT1 : '//' [^\n]* [\n];                  //  single line comment //.
fragment COMMENT2 : '{'  [^\}]* '}';                   //  multi  line comment {}.
fragment COMMENT3 : '(*' ( [^\*] | '*' [^\)] )* '*)' ; //  multi  line comment (**).
COMMENT           : (COMMENT1 | COMMENT2 | COMMENT3) {skip};

// whitespace and newline:
WS                : [ \t\n\r]+ {skip};

// Parser rules:
// -------------

topLevel
  :  statements
  ;
  
statements
  : statements statement
  | statement  
  ;
  
statement
  : assignment  SEMICOLON
  | CLEAR       SEMICOLON { DoClear() } 
  | ECHO string SEMICOLON { DoEcho($2)}
  ;

string as PChar
  : SQ_STRING       { $$ := SQString($1.Text) }
  | DQ_STRING       { $$ := DQString($1.Text) }
  ;
  
assignment
  : TK_VAR? ID EQUAL expression
  { 
    DoAssignment(Assigned($1), $2.Text, $4);
  }
  ;
  
expression as Double
  : addSubExpression;

addSubExpression as Double
  : addSubExpression PLUS  mulDivExpression    { $$ := $1 + $3 }
  | addSubExpression MINUS mulDivExpression    { $$ := $1 - $3 }
  | mulDivExpression
  ;
  
mulDivExpression as Double
  : mulDivExpression STAR    unaryExpression     { $$ := $1 *   $3 }
  | mulDivExpression SLASH   unaryExpression     { $$ := $1 /   $3 }
  | mulDivExpression PERCENT unaryExpression     { $$ := Fmod($1, $3) }
  | unaryExpression
  ;
  
unaryExpression as Double
  : PLUS  primaryExpression     { $$ := +$2 }
  | MINUS primaryExpression     { $$ := -$2 }
  | primaryExpression        
  ;

primaryExpression as Double
  : LPAREN expression RPAREN     { $$ := $2 }
  | ID                           { $$ := GetVarValue($1.Text) }
  | integer                      { $$ := $1    }
  | FLOAT                        { $$ := StrToFloat($1.Text) }
  | COS LPAREN expression RPAREN { $$ := Cos($3) }
  | SIN LPAREN expression RPAREN { $$ := Sin($3) }
  | TAN LPAREN expression RPAREN { $$ := Tangent($3) }
  | MIN argumentList             { $$ := DoMin($2) } 
  | MAX argumentList             { $$ := DoMax($2) }
  ;
  
integer as Double
  : DIGIT  { $$ := StrToFloat($1.Text) }
  | HEX    { $$ := HexToFloat($1.Text) }
  ;
  
argumentList as TList
  : LPAREN expressionList RPAREN      { $$ := $2 }
  ;
  
expressionList as TList
  : expressionList COMMA expression   { $$ := $1; $$.Add(@$3) } 
  | expression                        { $$ := CreateNewList() }
  ;