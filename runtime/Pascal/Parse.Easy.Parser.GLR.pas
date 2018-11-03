// ----------- Parse::Easy::Runtime -----------
// https://github.com/MahdiSafsafi/Parse-Easy
// --------------------------------------------

unit Parse.Easy.Parser.GLR;

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
  TGLR = class;

  PFrame = ^TFrame;

  TFrame = record
  public
    function Peek(): TToken;
    function Advance(): TToken;

  var
    Parser: TGLR;
    Alive: Boolean;
    Reduce: Boolean;
    Link: PFrame;
    Parent: PFrame;
    State: TState;
    TokenCacheIndex: Integer;
    NumberOfChilds: Integer;
    case Boolean { Reduce } of
      False: (Token: TToken);
      True: (Rule: TRule);
  end;

  TGLR = class(TCustomParser)
  private
    FFramePool: PFrame;
    FNumberOfFrameInCurrentPool: Integer;
    FStop: PFrame;
    FConflicts: Integer;

    FGarbageFrameList: TStackPtr;
    FFramePoolList: TList;
    FTokenCache: TList;
    FFrames: TList;
    FShiftActionList: TList;
    FPostponedRules: TList;
  protected
    procedure Merge(Frame: PFrame);
    procedure Vanish(Frame: PFrame);
    procedure NewFramePool();
    procedure CleanFramePools();
    function NewFrame(): PFrame;
    function Consume(): TToken;
    function Reduce(Frame: PFrame; Rule: TRule): Boolean;
    function Shift(Frame: PFrame; State: TState): Boolean;
  public
    constructor Create(ALexer: TCustomLexer); override;
    destructor Destroy(); override;
    function Parse(): Boolean; override;
  end;

implementation

const
  SizeOfFramePool = 1040;
  NumberOfFramePerPool = SizeOfFramePool div SizeOf(TFrame);

  { TGLR }

constructor TGLR.Create(ALexer: TCustomLexer);
begin
  inherited;
  FFramePoolList := TList.Create;
  FTokenCache := TList.Create;
  FFrames := TList.Create;
  FShiftActionList := TList.Create;
  FPostponedRules := TList.Create;
  FGarbageFrameList := TStackPtr.Create;
  FFramePool := nil;
end;

destructor TGLR.Destroy();
begin
  CleanFramePools();
  FFramePoolList.Free();
  FTokenCache.Free();
  FFrames.Free();
  FShiftActionList.Free();
  FPostponedRules.Free();
  FGarbageFrameList.Free();
  inherited;
end;

procedure TGLR.CleanFramePools();
var
  I: Integer;
  P: Pointer;
begin
  for I := 0 to FFramePoolList.Count - 1 do
  begin
    P := FFramePoolList[I];
    if Assigned(P) then
        FreeMem(P, SizeOfFramePool);
  end;
  FFramePoolList.Clear();
  FFramePool := nil;
end;

function TGLR.Consume(): TToken;
begin
  Lexer.Advance();
  Result := Lexer.Peek();
  FTokenCache.Add(Result);
end;

function TGLR.NewFrame(): PFrame;
begin
  if FGarbageFrameList.Count > 0 then
      Exit(FGarbageFrameList.Pop());
  if not Assigned(FFramePool) then
      NewFramePool();
  Result := FFramePool;
  Inc(FNumberOfFrameInCurrentPool);
  Inc(FFramePool);
  if (FNumberOfFrameInCurrentPool = NumberOfFramePerPool) then
  begin
    NewFramePool();
  end;
end;

procedure TGLR.NewFramePool();
begin
  FNumberOfFrameInCurrentPool := 0;
  FFramePool := GetMemory(SizeOfFramePool);
  FFramePoolList.Add(FFramePool);
end;

procedure TGLR.Vanish(Frame: PFrame);
begin
  Dec(FConflicts);
  while (Assigned(Frame)) do
  begin
    if Frame^.NumberOfChilds > 1 then
        Break;
    Frame^.Alive := False;
    Frame := Frame^.Parent;
  end;
end;

function TGLR.Reduce(Frame: PFrame; Rule: TRule): Boolean;
var
  PopCount: Integer;
  Target: PFrame;
  State: TState;
  Actions: TList;
  Action: TAction;
  LFrame: PFrame;
begin
  if (rfAccept in Rule.Flags) then
  begin
    // this is the axiom rule.
    Exit(True);
  end;
  Target := Frame;
  PopCount := Rule.NumberOfItems;
  while (PopCount <> 0) do
  begin
    if not Assigned(Target) then
        Exit(False);
    Target := Target^.Link;
    Dec(PopCount);
  end;
  if (not Assigned(Target) or (not Target^.Alive)) then
      Exit(False);
  State := Target^.State;
  Actions := State.NoTerms[Rule.Id];
  Assert(Actions.Count = 1);
  Action := Actions[0];
  Assert(Action.ActionType = atJump);
  State := States[Action.ActionValue];
  Result := Shift(Frame, State);
  LFrame := FFrames.Last();
  LFrame^.Link := Target; // link to the stack of the previous frame.
  LFrame^.Reduce := True; // mark the frame as reduce.
  LFrame^.Rule := Rule;
end;

function TGLR.Shift(Frame: PFrame; State: TState): Boolean;
var
  New: PFrame;
begin
  New := Self.NewFrame();
  New^.Alive := True;
  New^.Reduce := False;
  New^.Parser := Self;
  New^.Parent := Frame;
  New^.State := State;
  New^.TokenCacheIndex := Frame^.TokenCacheIndex;
  New^.NumberOfChilds := 0;
  New^.Link := Frame;
  New^.Token := Frame^.Peek();
  FFrames.Add(New);
  Result := True;
end;

procedure TGLR.Merge(Frame: PFrame);
var
  LFrame: PFrame;
  I, J: Integer;
  PopCount: Integer;
  Rule: TRule;
  Value: PValue;
begin
  // we dont merge if things are not clear yet.
  if FConflicts > 0 then
      Exit;

  FPostponedRules.Clear;
  LFrame := Frame;
  while (Assigned(LFrame) and (LFrame <> FStop)) do
  begin
    if (LFrame^.Alive) then
    begin
      if (LFrame^.Reduce) then
      begin
        FPostponedRules.Add(LFrame);
      end
      else
      begin
        Value := NewValue();
        Value^.AsToken := LFrame^.Token;
        Values.Push(Value);
      end;
    end
    else
    begin
      // fixme
      FGarbageFrameList.Push(LFrame);
    end;
    // go back to the caller.
    LFrame := LFrame^.Parent;
  end;

  // now everything is clear, we are safe
  // to execute rule's action.
  for I := 0 to FPostponedRules.Count - 1 do
  begin
    LFrame := FPostponedRules[I];
    Rule := LFrame^.Rule;
    PopCount := Rule.NumberOfItems;
    if (Rule.ActionIndex <> -1) then
    begin
      ReturnValue := NewValue();
      UserAction(Rule.ActionIndex);
    end;
    // remove rule's items from the stack values.
    for J := 0 to PopCount - 1 do
    begin
      Values.Pop();
    end;
    Values.Push(ReturnValue);
  end;
  // the next merge session will stop when it sees this frame.
  FStop := Frame;
end;

function TGLR.Parse(): Boolean;
var
  Frame: PFrame;
  State: TState;
  Token: TToken;
  Actions: TList;
  Action: TAction;
  I: Integer;
  J: Integer;
  Rule: TRule;
  LFrame: PFrame;
  EFrame: PFrame;
begin
  Result := False;
  if States.Count = 0 then
      Exit;
  FConflicts := 0;
  I := 0;
  FStop := nil;
  EFrame := nil;
  Token := nil;
  CleanFramePools();
  FFrames.Clear();
  FTokenCache.Clear();
  ExceptList.Clear();

  Consume();

  // init starting frame F0.
  Frame := NewFrame();
  Frame^.Alive := True;
  Frame^.Reduce := False;
  Frame^.Parser := Self;
  Frame^.Parent := nil;
  Frame^.Link := nil;
  Frame^.Token := nil;
  Frame^.State := States[0];
  Frame^.TokenCacheIndex := 0;
  FFrames.Add(Frame);
  ReturnValue := NewValue();
  while (I < FFrames.Count) do
  begin
    FShiftActionList.Clear();
    Frame := FFrames[I];
    Inc(I);
    Token := Frame^.Peek();
    State := Frame^.State;
    Actions := State.Terms[Token.TokenType];
    if not Assigned(Actions) then
    begin
      EFrame := Frame;
      Vanish(Frame);
      Continue;
    end;
    Frame^.NumberOfChilds := Actions.Count;
    Inc(FConflicts, Actions.Count - 1);

    { reduce actions }
    for J := 0 to Actions.Count - 1 do
    begin
      Action := Actions[J];
      case Action.ActionType of
        atReduce:
          begin
            Rule := Rules[Action.ActionValue];
            if not Reduce(Frame, Rule) then
            begin
              // invalid reduce action.
              EFrame := Frame;
              Vanish(Frame);
              Continue;
            end;
            if rfAccept in Rule.Flags then
            begin
              // axiom rule.
              Result := True;
              Break;
            end;
          end;
        atShift:
          begin
            // we shift later.
            FShiftActionList.Add(Action);
          end;
      else
        begin
          raise Exception.Create('Error Message');
        end;
      end;
    end;
    if Result then
        Break;

    { shift actions }
    for J := 0 to FShiftActionList.Count - 1 do
    begin
      Action := FShiftActionList[J];
      State := States[Action.ActionValue];
      if not Shift(Frame, State) then
      begin
        raise Exception.Create('Error Message');
      end
      else
      begin
        LFrame := FFrames.Last();
        LFrame^.Advance();
      end;
    end;
    Merge(Frame);
  end;

  if Result then
      Exit;

  if Assigned(EFrame) then
  begin
    State := EFrame^.State;
    for J := 0 to State.Terms.Count - 1 do
    begin
      Actions := State.Terms[J];
      if Assigned(Actions) then
          ExceptList.Add(Pointer(J));
    end;
    ExceptError(Token);
  end;
end;

{ TFrame }

function TFrame.Peek(): TToken;
begin
  Result := Parser.FTokenCache[TokenCacheIndex];
end;

function TFrame.Advance(): TToken;
begin
  Result := Peek();
  Inc(TokenCacheIndex);
  if TokenCacheIndex >= Parser.FTokenCache.Count then
      Parser.Consume();
end;

end.
