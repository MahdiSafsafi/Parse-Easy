// ----------- Parse::Easy::Runtime -----------
// https://github.com/MahdiSafsafi/Parse-Easy
// --------------------------------------------

unit Parse.Easy.Parser.CustomParser;

interface

uses
  System.SysUtils,
  System.Classes,
  Parse.Easy.StackPtr,
  Parse.Easy.Lexer.CustomLexer,
  Parse.Easy.Lexer.Token,
  Parse.Easy.Parser.Deserializer;

type
  TValue = record
    case Integer of
      0: (AsUByte: Byte);
      1: (AsUWord: Word);
      2: (AsULong: Cardinal);
      3: (AsObject: Pointer);
      4: (AsClass: TClass);
      5: (AsShortInt: ShortInt);
      6: (AsSmallInt: SmallInt);
      7: (AsInteger: Integer);
      8: (AsSingle: Single);
      9: (AsDouble: Double);
      10: (AsExtended: Extended);
      11: (AsComp: Comp);
      12: (AsCurrency: Currency);
      13: (AsUInt64: UInt64);
      14: (AsSInt64: Int64);
      15: (AsMethod: TMethod);
      16: (AsPointer: Pointer);
      17: (AsToken: TToken);
      18: (AsList: TList);
      19: (AsPChar: PChar);
  end;

  PValue = ^TValue;

  TCustomParser = class(TDeserializer)
  private
    FReturnValue: PValue;
    FValues: TStackPtr;
    FExceptList: TList;
    FInternalObjectHolderList: TList;
    FValueList: TList;
  protected
    procedure ExceptError(Token: TToken);
    procedure UserAction(Index: Integer); virtual; abstract;
    function CreateNewList(): TList;
    function NewValue(): PValue;
  public
    function Parse: Boolean; virtual; abstract;
    constructor Create(ALexer: TCustomLexer); override;
    destructor Destroy(); override;
    { properties }
    property Values: TStackPtr read FValues;
    property ReturnValue: PValue read FReturnValue write FReturnValue;
    property ExceptList: TList read FExceptList;
  end;

implementation

{ TCustomParser }

constructor TCustomParser.Create(ALexer: TCustomLexer);
begin
  inherited;
  FInternalObjectHolderList := TList.Create();
  FValueList := TList.Create();
  FExceptList := TList.Create();
  FValues := TStackPtr.Create();
  FReturnValue := nil;
end;

function TCustomParser.CreateNewList(): TList;
begin
  Result := TList.Create();
  FInternalObjectHolderList.Add(Result);
end;

destructor TCustomParser.Destroy();
var
  I: Integer;
begin
  FExceptList.Free();
  FValues.Free();
  for I := 0 to FValueList.Count - 1 do
    if Assigned(FValueList[I]) then
        FreeMemory(FValueList[I]);
  FValueList.Free();

  for I := 0 to FInternalObjectHolderList.Count - 1 do
    if Assigned(FInternalObjectHolderList[I]) then
        TObject(FInternalObjectHolderList[I]).Free();
  FInternalObjectHolderList.Free();
  inherited;
end;

procedure TCustomParser.ExceptError(Token: TToken);
var
  StrList: TStringList;
  S: string;
  I: Integer;
  LNear: string;
begin
  LNear := EmptyStr;
  S := EmptyStr;
  if (Assigned(Token)) then
      LNear := Lexer.GetTokenName(Token.TokenType);
  StrList := TStringList.Create();
  try
    for I := 0 to ExceptList.Count - 1 do
        StrList.Add(Lexer.GetTokenName(Integer(ExceptList[I])));
    StrList.Delimiter := ',';
    S := StrList.DelimitedText;
  finally
      StrList.Free();
  end;
  raise Exception.CreateFmt('Neer %s ... Expecting one of this: [%s]', [LNear, S]);
end;

function TCustomParser.NewValue: PValue;
begin
  Result := GetMemory(SizeOf(TValue));
  FValueList.Add(Result);
end;

end.
