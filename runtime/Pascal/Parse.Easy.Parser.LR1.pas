// ----------- Parse::Easy::Runtime -----------
// https://github.com/MahdiSafsafi/Parse-Easy
// --------------------------------------------

unit Parse.Easy.Parser.LR1;

interface

uses
  System.SysUtils,
  System.Classes,
  Parse.Easy.StackPtr,
  Parse.Easy.Lexer.CustomLexer,
  Parse.Easy.Lexer.Token,
  Parse.Easy.Parser.CustomParser,
  Parse.Easy.Parser.State,
  Parse.Easy.Parser.Rule,
  Parse.Easy.Parser.Action;

type
  TLR1 = class(TCustomParser)
  private
    FStack: TStackPtr;
  public
    constructor Create(ALexer: TCustomLexer); override;
    destructor Destroy; override;
    function Parse: Boolean; override;
    property Stack: TStackPtr read FStack;
  end;

implementation

{ TLR1 }

constructor TLR1.Create(ALexer: TCustomLexer);
begin
  inherited;
  FStack := TStackPtr.Create;
end;

destructor TLR1.Destroy;
begin
  FStack.Free;
  inherited;
end;

function TLR1.Parse: Boolean;
var
  State: TState;
  EState: TState;
  Token: TToken;
  Actions: TList;
  Action: TAction;
  Rule: TRule;
  PopCount: Integer;
  I: Integer;
  J: Integer;
  Value: PValue;
begin
  Result := False;
  EState := nil;
  if States.Count = 0 then
      Exit;
  FStack.Push(States[0]);
  Token := nil;
  ReturnValue := NewValue();
  while (FStack.Count > 0) do
  begin
    State := FStack.Peek();
    EState := State;
    Token := Lexer.Peek();
    Actions := State.Terms[Token.TokenType];
    if not Assigned(Actions) then
    begin
      Result := False;
      Break;
    end;
    Action := Actions[0];
    case Action.ActionType of
      atShift:
        begin
          State := States[Action.ActionValue];
          Token := Lexer.Advance();
          FStack.Push(Token);
          FStack.Push(State);
          Value := NewValue();
          Value^.AsToken := Token;
          Values.Push(Value);
        end;
      atReduce:
        begin
          Rule := Rules[Action.ActionValue];
          PopCount := Rule.NumberOfItems;
          if (Rule.ActionIndex <> -1) then
          begin
            ReturnValue := NewValue();
            UserAction(Rule.ActionIndex);
          end;

          for I := 0 to PopCount - 1 do
              Values.Pop();
          Values.Push(ReturnValue);

          PopCount := PopCount * 2;
          for I := 0 to PopCount - 1 do
              FStack.Pop();

          if rfAccept in Rule.Flags then
          begin
            Result := True;
            Break;
          end;
          State := FStack.Peek();
          Actions := State.NoTerms[Rule.Id];
          if not Assigned(Actions) then
          begin
            Result := False;
            Break;
          end;
          Action := Actions[0];
          State := States[Action.ActionValue];
          FStack.Push(Rule);
          FStack.Push(State);
        end;
    else
      begin
        Result := False;
        Break;
      end;
    end;
  end;
  if Result then
      Exit;

  if Assigned(EState) then
  begin
    for J := 0 to EState.Terms.Count - 1 do
    begin
      Actions := EState.Terms[J];
      if Assigned(Actions) then
          ExceptList.Add(Pointer(J));
    end;
    ExceptError(Token);
  end;
end;

end.
