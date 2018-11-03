// ----------- Parse::Easy::Runtime -----------
// https://github.com/MahdiSafsafi/Parse-Easy
// --------------------------------------------

unit Parse.Easy.Parser.Deserializer;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  Parse.Easy.Lexer.CustomLexer,
  Parse.Easy.Parser.State,
  Parse.Easy.Parser.Rule,
  Parse.Easy.Parser.Action;

type
  TDeserializer = class(TObject)
  strict private
  class var
    CResourceStream: TResourceStream;
    CRules: TList;
    CStates: TList;
  private
    FRules: TList;
    FStates: TList;
    FLexer: TCustomLexer;
  protected
    class procedure Deserialize(const Name: string);
  public
    class constructor Create();
    class destructor Destroy();
    constructor Create(ALexer: TCustomLexer); virtual;
    { properties }
    property Rules: TList read FRules;
    property States: TList read FStates;
    property Lexer: TCustomLexer read FLexer;
  end;

implementation

type
  THeader = packed record
    MajorVersion: Integer;
    MinorVersion: Integer;
    NumberOfStates: Integer;
    NumberOfRules: Integer;
    NumberOfTokens: Integer;
  end;

  PHeader = ^THeader;

  { TDeserializer }

class constructor TDeserializer.Create();
begin
  CRules := nil;
  CStates := nil;
  CResourceStream := nil;
end;

class destructor TDeserializer.Destroy();
  procedure DestroyTermsOrNoTerms(List: TList);
  var
    I: Integer;
    J: Integer;
    Actions: TList;
    Action: TAction;
  begin
    if not Assigned(List) then
        exit();
    for I := 0 to List.Count - 1 do
    begin
      Actions := List[I];
      if Assigned(Actions) then
      begin
        for J := 0 to Actions.Count - 1 do
        begin
          Action := Actions[J];
          if Assigned(Action) then
              Action.Free();
        end;
      end;
    end;
  end;

var
  I: Integer;
  State: TState;
begin
  if Assigned(CRules) then
  begin
    for I := 0 to CRules.Count - 1 do
      if Assigned(CRules[I]) then
          TRule(CRules[I]).Free();
    CRules.Free();
  end;
  if Assigned(CStates) then
  begin
    for I := 0 to CStates.Count - 1 do
    begin
      State := CStates[I];
      if Assigned(State) then
      begin
        DestroyTermsOrNoTerms(State.Terms);
        DestroyTermsOrNoTerms(State.NoTerms);
        TState(CStates[I]).Free();
      end;
    end;
    CStates.Free();
  end;
  if Assigned(CResourceStream) then
      CResourceStream.Free();
end;

constructor TDeserializer.Create(ALexer: TCustomLexer);
begin
  FRules := CRules;
  FStates := CStates;
  FLexer := ALexer;
end;

class procedure TDeserializer.Deserialize(const Name: string);
var
  Header: THeader;
  procedure ReadRules();
    function Raw2RuleFlags(Value: Integer): TRuleFlags;
    begin
      Result := [];
      if (Value and 1) <> 0 then
          Include(Result, rfAccept);
    end;

  var
    I: Integer;
    Rule: TRule;
    Value: Integer;
  begin
    CRules := TList.Create;
    for I := 0 to Header.NumberOfRules - 1 do
    begin
      Rule := TRule.Create;
      CRules.Add(Rule);
      Rule.Index := I;

      CResourceStream.Read(Value, SizeOf(Value));
      Rule.Id := Value;

      CResourceStream.Read(Value, SizeOf(Value));
      Rule.Flags := Raw2RuleFlags(Value);

      CResourceStream.Read(Value, SizeOf(Value));
      Rule.NumberOfItems := Value;

      CResourceStream.Read(Value, SizeOf(Value));
      Rule.ActionIndex := Value;
    end;
  end;
  procedure ReadStates();
  var
    I, J, K: Integer;
    State: TState;
    Index: Integer;
    NumberOfTerms: Integer;
    NumberOfNoTerms: Integer;
    NumberOfActions: Integer;
    ActionType: TActionType;
    ActionValue: Integer;
    Tmp: Integer;
    Action: TAction;
    Actions: TList;
    TermOrNoTerm: TList;
    NumberOfTermOrNoTerm: Integer;
  label ReadGotos;
  begin
    CStates := TList.Create();
    for I := 0 to Header.NumberOfStates - 1 do
    begin
      State := TState.Create();
      CStates.Add(State);
    end;
    for I := 0 to Header.NumberOfStates - 1 do
    begin
      CResourceStream.Read(Index, SizeOf(Index)); // index.
      State := CStates[Index];
      State.Index := Index;
      State.NumberOfTerms := Header.NumberOfTokens;
      State.NumberOfNoTerms := Header.NumberOfRules;
      CResourceStream.Read(NumberOfTerms, SizeOf(NumberOfTerms));
      CResourceStream.Read(NumberOfNoTerms, SizeOf(NumberOfNoTerms));

      { read goto table }
      TermOrNoTerm := State.Terms;
      NumberOfTermOrNoTerm := NumberOfTerms;

    ReadGotos:
      for J := 0 to NumberOfTermOrNoTerm - 1 do
      begin
        CResourceStream.Read(Index, SizeOf(Index)); // token.
        CResourceStream.Read(NumberOfActions, SizeOf(NumberOfActions)); // NumberOfActions.
        Actions := TList.Create();
        TermOrNoTerm[Index] := Actions;
        for K := 0 to NumberOfActions - 1 do
        begin
          CResourceStream.Read(Tmp, SizeOf(Tmp));
          CResourceStream.Read(ActionValue, SizeOf(ActionValue));
          case Tmp of
            1: ActionType := atShift;
            2: ActionType := atReduce;
            3: ActionType := atJump;
          else
            raise Exception.Create('encoding error: Invalid action type.');
          end;
          Action := TAction.Create(ActionType, ActionValue);
          Actions.Add(Action);
        end;
      end;
      if TermOrNoTerm = State.Terms then
      begin
        TermOrNoTerm := State.NoTerms;
        NumberOfTermOrNoTerm := NumberOfNoTerms;
        goto ReadGotos;
      end;
    end;
  end;

begin
  CResourceStream := TResourceStream.Create(HInstance, Name, RT_RCDATA);
  try
    CResourceStream.Read(Header, SizeOf(THeader));
    ReadRules();
    ReadStates();
  except
      RaiseLastOSError();
  end;
end;

end.
