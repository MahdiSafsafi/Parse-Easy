// ----------- Parse::Easy::Runtime -----------
// https://github.com/MahdiSafsafi/Parse-Easy
// --------------------------------------------

unit Parse.Easy.Lexer.Token;

interface

uses System.SysUtils;

type
  TToken = class(TObject)
  private
    FLine: Integer;
    FColumn: Integer;
    FType: Integer;
    FText: string;
    FStartPos: Integer;
    FEndPos: Integer;
    function GetText: string;
    procedure SetText(const Value: string);
    function GetColumn: Integer;
    function GetLine: Integer;
    procedure SetColumn(const Value: Integer);
    procedure SetLine(const Value: Integer);
    function GetType: Integer;
    procedure SetType(const Value: Integer);
    function GetEndPos: Integer;
    function GetStartPos: Integer;
    procedure SetEndPos(const Value: Integer);
    procedure SetStartPos(const Value: Integer);
  public
    constructor Create(); virtual;
    destructor Destroy(); override;
    function Same(That: TToken): Boolean;
    property Text: string read GetText write SetText;
    property Line: Integer read GetLine write SetLine;
    property Column: Integer read GetColumn write SetColumn;
    property TokenType: Integer read GetType write SetType;
    property StartPos: Integer read GetStartPos write SetStartPos;
    property EndPos: Integer read GetEndPos write SetEndPos;
    function ToString: string; override;
  end;

  TTokenClass = class of TToken;

implementation

{ TToken }

constructor TToken.Create;
begin
  FLine := 0;
  FColumn := 0;
  FType := 0;
  FText := '';
end;

destructor TToken.Destroy;
begin

  inherited;
end;

function TToken.Same(That: TToken): Boolean;
begin
  Result := TokenType = That.TokenType;
end;

function TToken.GetColumn: Integer;
begin
  Result := FColumn;
end;

function TToken.GetEndPos: Integer;
begin
  Result := FEndPos;
end;

function TToken.GetStartPos: Integer;
begin
  Result := FStartPos;
end;

function TToken.GetLine: Integer;
begin
  Result := FLine;
end;

function TToken.GetText: string;
begin
  Result := FText;
end;

function TToken.GetType: Integer;
begin
  Result := FType;
end;

procedure TToken.SetColumn(const Value: Integer);
begin
  FColumn := Value;
end;

procedure TToken.SetEndPos(const Value: Integer);
begin
  FEndPos := Value;
end;

procedure TToken.SetLine(const Value: Integer);
begin
  FLine := Value;
end;

procedure TToken.SetStartPos(const Value: Integer);
begin
  FStartPos := Value;
end;

procedure TToken.SetText(const Value: string);
begin
  FText := Value;
end;

procedure TToken.SetType(const Value: Integer);
begin
  FType := Value;
end;

function TToken.ToString: string;
begin
  Result := Format('Token(%d, %d:%d, %d:%d)="%s"', [FType, FStartPos, FEndPos, FLine, FColumn, FText]);
end;

end.
