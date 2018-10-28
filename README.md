# Status:
Parse::Easy is in an **ALPHA** state, meaning:
- You **MAY** encounter some issues, bugs, memory-leaks.
- Some features may not work as expected.
- Documentation is not completed yet.
- The specification is not final, and may also change. 
- There is a lot of features that are not availaible yet (some of them are partially implemented, the reset is not imlemented yet). The documentation and the examples will never refer/use them unless they are 100% imlemented.

Please, help improving this tools by providing your feed-back.

# Parse-Easy
Parse::Easy is a lexer and parser generator for Pascal. When I started working on it, two things were critical for me. The first thing, making it an easy tools (that's why it's called Easy), easy means user friendly, that's it easy to use and easy to read/write grammars. The second thing, making it powerful, Parse::Easy is thread-safe, object-oriented, supports unicode, regular expressions, LR1, GLR,...

## Lexer features:
- Parse::Easy::Lexer generates bytecodes instead of tables. which than handled by a virtual-machine (VM) that matches lexer patterns. 
- Parse::Easy::Lexer generates unicode lexer analyser. 
- Supports matching on particular conditions.
- Supports unicode properties.
- Supports character-set.
- Supports expression on character-set.
- Supports EBNF.
- Lexer analyser produced by Parse::Easy::Lexer is thread-safe.
 
## Parser features:
- Supports generating LR1 parser.
- Supports generating GLR parser.
- Supports EBNF.
- Thread-safe.

## Example: 
The following grammar, parses expression such ```5 * 2 + ((3.3 / 3) - 1)```. Note that it respects operator-precedences.

There is also a full example (see demos folder) that parses and evaluates expressions and outputs the result to the console.
```
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
```
