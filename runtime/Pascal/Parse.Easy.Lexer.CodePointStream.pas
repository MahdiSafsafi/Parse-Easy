// ----------- Parse::Easy::Runtime -----------
// https://github.com/MahdiSafsafi/Parse-Easy
// --------------------------------------------

unit Parse.Easy.Lexer.CodePointStream;

interface

uses
  System.SysUtils,
  System.Classes;

type

  TCodePointStream = class(TObject)
  private
    FChars: TCharArray;
    FPosition: Integer;
    FCharCount: Integer;
    FLine: Integer;
    FColumn: Integer;
    function GetPosition: Integer;
    procedure SetPosition(const Value: Integer);
    function GetColumn: Integer;
    function GetLine: Integer;
    procedure SetColumn(const Value: Integer);
    procedure SetLine(const Value: Integer);
  public
    constructor Create(AStream: TStringStream); virtual;
    destructor Destroy(); override;
    function Peek(): Integer;
    function Advance(): Integer;
    function EndOfFile: Boolean;
    property Position: Integer read GetPosition write SetPosition;
    property Line: Integer read GetLine write SetLine;
    property Column: Integer read GetColumn write SetColumn;
    property Chars: TCharArray read FChars;
    property CharCount: Integer read FCharCount;
  end;

implementation

const
  EOF = -1;

  { TCodePointStream }

constructor TCodePointStream.Create(AStream: TStringStream);
begin
  FChars := AStream.Encoding.GetChars(AStream.Bytes, AStream.Position,
    AStream.Size - AStream.Position);
  FCharCount := Length(FChars);
  FPosition := 0;
  FLine := 1;
  FColumn := 1;
end;

destructor TCodePointStream.Destroy;
begin

  inherited;
end;

function TCodePointStream.GetPosition: Integer;
begin
  Result := FPosition;
end;

function TCodePointStream.GetColumn: Integer;
begin
  Result := FColumn;
end;

function TCodePointStream.GetLine: Integer;
begin
  Result := FLine;
end;

procedure TCodePointStream.SetColumn(const Value: Integer);
begin
  FColumn := Value;
end;

procedure TCodePointStream.SetLine(const Value: Integer);
begin
  FLine := Value;
end;

procedure TCodePointStream.SetPosition(const Value: Integer);
begin
  FPosition := Value;
end;

function TCodePointStream.EndOfFile: Boolean;
begin
  Result := FPosition >= FCharCount;
end;

function TCodePointStream.Peek: Integer;
begin
  if EndOfFile() then
      exit(EOF);
  Result := Ord(FChars[FPosition]);
end;

function TCodePointStream.Advance: Integer;
var
  CP: Integer;
begin
  Result := Peek();
  Inc(FPosition);
  CP := Peek();
  if (CP = $000A) then
  begin
    Inc(FLine);
    FColumn := 0;
  end
  else
      Inc(FColumn);
end;

end.

