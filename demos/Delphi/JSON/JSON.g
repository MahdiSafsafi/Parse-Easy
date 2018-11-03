grammar JSON;

fragment HEX : [0-9a-fA-F];

fragment ESCAPED_CHAR
  : "\\"
  | '"'
  | '/'
  | 'b'
  | 'n'
  | 'r'
  | 't'
  | 'u' HEX HEX HEX HEX
  ;

fragment CHAR        
  : [\X [\u0020-\uffff] - ["\\]]
  ;

fragment ESCAPE  
  : BACKSLASH ESCAPED_CHAR
  ;

BACKSLASH   : "\\";
LPAREN      : '(';
RPAREN      : ')';
LBRACE      : '{';
RBRACE      : '}';
LBRACK      : '[';
RBRACK      : ']';
SQUOTE      : "'";  //'
DQUOTE      : '"';
PLUS        : '+';
MINUS       : '-';
COLON       : ':';
COMMA       : ',';
   
TK_FALSE    : 'false';
TK_TRUE     : 'true';
TK_NULL     : 'null';

DQSTRING    : DQUOTE (CHAR | ESCAPE)* DQUOTE;

DIGIT       : '0' | [1-9][0-9]*;
FRAC        : '.' [0-9]+;
EXP         : [Ee] ('+'|'-') [0-9]+;

WS          : [\u0009\u000a\u000d\u0020]+ {Skip};


json
  : element
  ;

element
  : object
  | array
  | string
  | number
  | TK_FALSE
  | TK_TRUE
  | TK_NULL
  ;

object
  : LBRACE props? RBRACE
  ;

props
  : prop COMMA props
  | prop  
  ;

prop 
  : string COLON element
  ;
  
array
  : LBRACK elements? RBRACK
  ;
  
elements
  : element COMMA elements
  | element
  ;
  
string
  : DQSTRING
  ;

number
  : int FRAC? EXP?
  ;  
  
int
  : MINUS? DIGIT 
  ;
