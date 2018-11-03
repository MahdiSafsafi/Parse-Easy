grammar Calc;

// simple calc.

// lexer fragments:
// ----------------
fragment DIGIT : [0-9]+;

// lexer rules:
// ------------
LPAREN  : '(';
RPAREN  : ')';
PLUS    : '+';
MINUS   : '-';
STAR    : '*';
SLASH   : '/';

DECIMAL : DIGIT;
FLOAT   : DIGIT '.' DIGIT;

WS      : [ \t\n\r]+ {skip}; // ignore white-space and newline.

// parser rules:
// -------------
expression
  : addSubExpression
  ;
  
addSubExpression
  : addSubExpression (PLUS | MINUS) mulDivExpression
  | mulDivExpression
  ;
  
mulDivExpression
  : mulDivExpression (STAR | SLASH) unaryExpression
  | unaryExpression
  ;

unaryExpression
  : (PLUS | MINUS)? primaryExpression
  ;
  
primaryExpression
  : LPAREN expression RPAREN
  | DECIMAL
  | FLOAT
  ;