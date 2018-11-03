// ----------- Parse::Easy::Runtime -----------
// https://github.com/MahdiSafsafi/Parse-Easy
// --------------------------------------------

unit Parse.Easy.Lexer.CustomLexer;

interface

uses
  System.SysUtils,
  System.Types,
  System.Classes,
  System.ZLib,
  Vcl.Dialogs,
  Parse.Easy.Lexer.CodePointStream,
  Parse.Easy.Lexer.VirtualMachine,
  Parse.Easy.Lexer.Token;

type
  TCustomLexer = class(TVirtualMachine)
  private
    FToken: TToken;
  public
    constructor Create(AStream: TStringStream); override;
    destructor Destroy(); override;
    function Peek(): TToken;
    function Advance(): TToken;
    function GetTokenName(Index: Integer): string; virtual; abstract;
  end;

implementation

{ TCustomLexer }

constructor TCustomLexer.Create(AStream: TStringStream);
begin
  inherited;
  FToken := nil;
end;

destructor TCustomLexer.Destroy();
begin

  inherited;
end;

function TCustomLexer.Advance(): TToken;
begin
  Result := FToken;
  FToken := Parse();
end;

function TCustomLexer.Peek: TToken;
begin
  if not Assigned(FToken) then
      Advance();
  Result := FToken;
end;

end.
