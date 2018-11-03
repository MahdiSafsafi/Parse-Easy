// ----------- Parse::Easy::Runtime -----------
// https://github.com/MahdiSafsafi/Parse-Easy
// --------------------------------------------

unit Parse.Easy.Lexer.VirtualMachine;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  Parse.Easy.Lexer.Token,
  Parse.Easy.Lexer.CodePointStream;

const
  MAX_STACK_SIZE = 16000;
  MAX_STACK_ITEM_COUNT = MAX_STACK_SIZE div SizeOf(Integer);
  MAX_SECTION_COUNT = 1000;
  MAX_VM_REGISTER_COUNT = 7;
  MAX_MARK_COUNT = 256;

const
  TK_ILLEGAL = -2;

type
  TFlag = (F_E, F_G, F_L);
  TFlags = set of TFlag;
  TTokenFlag = (tfSkip, tfReject);
  TTokenFlags = set of TTokenFlag;
  VMException = Exception;

  TVirtualMachine = class(TObject)
  strict private
  class var
    CResourceStream: TResourceStream;
    CMemory: Pointer;
    CByteCode: Pointer;
    CFirstRule: Pointer;
  private
    FAtStart: Boolean;
    FMemory: Pointer;
    FBytecode: Pointer;
    FFirstRule: Pointer;
    FCodePointStream: TCodePointStream;
    FTerminate: Boolean;
    FStartPos: Integer;
    FMarkedPosition: Integer;
    FOpCode: Integer;
    FIP: PByte; // instruction pointer.
    FImmediate: Integer;
    FUImmediate: Cardinal;
    FRelative: Integer;
    FOffset: Integer;
    FFlags: TFlags; // instruction control flow flags.
    FIA: PByte; // instruction address.
    FRR: Integer; // register MR.RR.
    FTokenFlags: TTokenFlags;
    { stacks }
    FStack: array [0 .. MAX_STACK_ITEM_COUNT - 1] of Integer; // vm stack.
    FSections: array [0 .. MAX_SECTION_COUNT - 1] of Integer; // section stack.
    FRegisters: array [0 .. MAX_VM_REGISTER_COUNT - 1] of Integer;
    FMarked: array [0 .. MAX_MARK_COUNT - 1] of Integer;
    FState: Integer;
    { stack indexes }
    FMI: Integer;
    FSI: Integer; // vm stack index.
    FSSI: Integer; // section stack index.
    FTokens: TList;
    function FindRuleInfoFromIndex(Index: Integer): Pointer;
    procedure RecoverTokenText(Token: TToken);
  protected
    class procedure Deserialize(const Name: string);
    procedure UserAction(Index: Integer); virtual; abstract;
    procedure InitVM();
    procedure Decode();
    procedure Execute();
    procedure Run();
    { internal }
    procedure _PUSH(Value: Integer);
    function _POP(): Integer;
    { VM instructions }
    procedure EXEC_UNDEFINED();
    procedure EXEC_UNIMPLEMENTED();
    procedure EXEC_BEQ();
    procedure EXEC_BNEQ();
    procedure EXEC_CALL();
    procedure EXEC_B();
    procedure EXEC_BGT();
    procedure EXEC_BGE();
    procedure EXEC_BLT();
    procedure EXEC_BLE();
    procedure EXEC_RET();
    procedure EXEC_VMEND();
    procedure EXEC_SETSTATE();
    procedure EXEC_FORGET();
    procedure EXEC_PEEK();
    procedure EXEC_MARK();
    procedure EXEC_ADVANCE();
    procedure EXEC_INRANGE();
    procedure EXEC_ISATX();
  public
    class constructor Create();
    class destructor Destroy();
    constructor Create(AStream: TStringStream); virtual;
    destructor Destroy(); override;
    function Parse(): TToken;
    procedure PushSection(Section: Integer);
    function PopSection(): Integer;
    function CurrentSection(): Integer;
    procedure Skip();
    procedure UnSkip();
    procedure Reject();
    procedure UnReject();
  end;

implementation

{ TVirtualMachine }
{$I insns.inc}


const
  ILLEGAL_ACTION_INDEX = -1;

type
  THeader = packed record
    MajorVersion: Integer;
    MinorVersion: Integer;
    SizeOfMemory: Cardinal;
    SizeOfByteCode: Cardinal;
    NumberOfRules: Integer;
    FirstRuleOffset: Integer;
  end;

  PHeader = ^THeader;

  TRuleInfo = packed record
    TokenType: Integer;
    ActionIndex: Integer;
  end;

  PRuleInfo = ^TRuleInfo;

class constructor TVirtualMachine.Create;
begin
  CResourceStream := nil;
end;

class destructor TVirtualMachine.Destroy;
begin
  if Assigned(CResourceStream) then
      CResourceStream.Free();
end;

constructor TVirtualMachine.Create(AStream: TStringStream);
begin
  FCodePointStream := TCodePointStream.Create(AStream);
  FTokens := TList.Create;
  FBytecode := CByteCode;
  FMemory := CMemory;
  FFirstRule := CFirstRule;
  FSSI := 0;
  PushSection(0);
end;

destructor TVirtualMachine.Destroy;
var
  I: Integer;
begin
  for I := 0 to FTokens.Count - 1 do
    if Assigned(FTokens[I]) then
        TToken(FTokens[I]).Free();
  FTokens.Free();
  FCodePointStream.Free();
  inherited;
end;

procedure TVirtualMachine.Decode;
var
  PDscrp: PInstructionDscrp;
  I: Integer;
  Pattern: Integer;
  MR: Cardinal;
  Size: Cardinal;
  Power: Integer;
begin
  FIA := FIP;
  FOpCode := PByte(FIP)^;
  PDscrp := @instructions[FOpCode];
  Inc(FIP); // eat opcode.
  for I := 0 to MAX_PATTERN_COUNT - 1 do
  begin
    Pattern := PDscrp^.Patterns[I];
    case Pattern of
      PAT_NONE: break;
      PAT_OB:
        begin
          FRelative := PShortInt(FIP)^;
          Inc(FIP, SizeOf(ShortInt));
        end;
      PAT_OW:
        begin
          FRelative := PSmallInt(FIP)^;
          Inc(FIP, SizeOf(SmallInt));
        end;
      PAT_OD:
        begin
          FRelative := PLongInt(FIP)^;
          Inc(FIP, SizeOf(LongInt));
        end;
      PAT_U8:
        begin
          FUImmediate := PByte(FIP)^;
          Inc(FIP, SizeOf(Byte));
        end;
      PAT_U16:
        begin
          FUImmediate := PWord(FIP)^;
          Inc(FIP, SizeOf(Word));
        end;
      PAT_U32:
        begin
          FUImmediate := PCardinal(FIP)^;
          Inc(FIP, SizeOf(Cardinal));
        end;
      PAT_I8:
        begin
          FImmediate := PShortInt(FIP)^;
          Inc(FIP, SizeOf(ShortInt));
        end;
      PAT_I16:
        begin
          FImmediate := PSmallInt(FIP)^;
          Inc(FIP, SizeOf(SmallInt));
        end;
      PAT_I32:
        begin
          FImmediate := PLongInt(FIP)^;
          Inc(FIP, SizeOf(LongInt));
        end;
      {
        PAT_MR:
        begin
        MR := PByte(FIP)^;
        Inc(FIP);
        RR := (MR and $E0) shr 5;
        end;
      }
      PAT_MF:
        begin
          MR := PByte(FIP)^;
          Inc(FIP);
          FRR := (MR and $E0) shr 5;
          FOffset := 0;
          if (MR and $1F <> 0) then
          begin
            Size := MR and 3;
            Power := (MR and $1C) shr 2;
            case Power of
              7: Power := 64;
              6: Power := 32;
              5: Power := 16;
              4: Power := 8;
              3: Power := 4;
              2: Power := 2;
              1: Power := 1;
              0: begin
                  // die.
                end;
            end;
            case Size of
              0: begin
                  FOffset := PByte(FIP)^;
                  Inc(FIP);
                end;
              1: begin
                  FOffset := PWord(FIP)^;
                  Inc(FIP, SizeOf(Word));
                end;
              2: begin
                  FOffset := PCardinal(FIP)^;
                  Inc(FIP, SizeOf(Cardinal));
                end;
              3: begin
                  // die.
                end;
            end;
            FOffset := FOffset * Power;
          end;
        end;
    end;
  end;
end;

procedure TVirtualMachine.Execute;
var
  PDscrp: PInstructionDscrp;
begin
  PDscrp := @instructions[FOpCode];
  case PDscrp^.IID of
    INSN_BEQ: EXEC_BEQ();
    INSN_BNEQ: EXEC_BNEQ();
    INSN_BGT: EXEC_BGT();
    INSN_BGE: EXEC_BGE();
    INSN_BLT: EXEC_BLT();
    INSN_BLE: EXEC_BLE();
    INSN_B: EXEC_B();
    INSN_CALL: EXEC_CALL();
    INSN_RET: EXEC_RET();
    INSN_VMEND: EXEC_VMEND();
    INSN_PEEK: EXEC_PEEK();
    INSN_ADVANCE: EXEC_ADVANCE();
    INSN_FORGET: EXEC_FORGET();
    INSN_MARK: EXEC_MARK();
    INSN_SETSTATE: EXEC_SETSTATE();
    INSN_INRANGE: EXEC_INRANGE();
    INSN_ISATX: EXEC_ISATX();
    INSN_INVALID: EXEC_UNDEFINED();
    INSN_NOP, INSN_HINT, INSN_VMSTART:;
  else
    EXEC_UNIMPLEMENTED;
  end;
end;

class procedure TVirtualMachine.Deserialize(const Name: string);
var
  Header: THeader;
begin
  CResourceStream := TResourceStream.Create(HInstance, Name, RT_RCDATA);
  try
    CResourceStream.Read(Header, SizeOf(THeader));
    CMemory := PByte(CResourceStream.Memory) + SizeOf(THeader);
    CByteCode := PByte(CMemory) + Header.SizeOfMemory;
    CFirstRule := PByte(CMemory) + Header.FirstRuleOffset;
  except
      RaiseLastOSError();
  end;
end;

procedure TVirtualMachine._PUSH(Value: Integer);
begin
  FStack[FSI] := Value;
  Inc(FSI);
end;

function TVirtualMachine._POP(): Integer;
begin
  Result := FStack[FSI - 1];
  Dec(FSI);
end;

procedure TVirtualMachine.PushSection(Section: Integer);
begin
  FSections[FSSI] := Section;
  FRegisters[1] := Section;
  Inc(FSSI);
end;

function TVirtualMachine.PopSection(): Integer;
begin
  Result := FSections[FSSI - 1];
  FRegisters[1] := Result;
  Dec(FSSI);
end;

function TVirtualMachine.CurrentSection(): Integer;
begin
  Result := FSections[FSSI - 1];
end;

procedure TVirtualMachine.EXEC_SETSTATE();
begin
  FState := FUImmediate;
end;

procedure TVirtualMachine.EXEC_UNDEFINED();
begin
  raise VMException.CreateFmt('opcode %02x is undefined.', [FOpCode]);
end;

procedure TVirtualMachine.EXEC_UNIMPLEMENTED();
begin
  raise VMException.Create('unimplemented code encountered.');
end;

procedure TVirtualMachine.EXEC_VMEND();
begin
  FTerminate := True;
end;

function TVirtualMachine.FindRuleInfoFromIndex(Index: Integer): Pointer;
begin
  Result := FFirstRule;
  Inc(PRuleInfo(Result), Index);
end;

procedure TVirtualMachine.EXEC_PEEK();
begin
  FRegisters[0] := FCodePointStream.Peek();
end;

procedure TVirtualMachine.EXEC_ADVANCE();
begin
  FRegisters[0] := FCodePointStream.Advance();
end;

procedure TVirtualMachine.EXEC_BEQ();
begin
  // branch if equal.
  if F_E in FFlags then
      FIP := FIA + FRelative;
  FFlags := [];
end;

procedure TVirtualMachine.EXEC_BNEQ();
begin
  // branch if not equal.
  if not(F_E in FFlags) then
      FIP := FIA + FRelative;
  FFlags := [];
end;

procedure TVirtualMachine.EXEC_BGT();
begin
  // branch if greater than.
  if F_G in FFlags then
      FIP := FIA + FRelative;
end;

procedure TVirtualMachine.EXEC_BGE();
begin
  // branch if greater than or equal.
  if (F_G in FFlags) or (F_E in FFlags) then
      FIP := FIA + FRelative;
end;

procedure TVirtualMachine.EXEC_BLT();
begin
  // branch if less than.
  if F_L in FFlags then
      FIP := FIA + FRelative;
end;

procedure TVirtualMachine.EXEC_BLE();
begin
  // branch if less than or equal.
  if (F_L in FFlags) or (F_E in FFlags) then
      FIP := FIA + FRelative;
end;

procedure TVirtualMachine.EXEC_B();
begin
  FIP := FIA + FRelative;
end;

procedure TVirtualMachine.EXEC_CALL();
begin
  _PUSH(Integer(FIP));
  FIP := FIA + FRelative;
end;

procedure TVirtualMachine.EXEC_RET();
begin
  FIP := PByte(_POP);
end;

procedure TVirtualMachine.EXEC_MARK();
begin
  FMarkedPosition := FCodePointStream.Position;
  FMarked[FMI] := FImmediate;
  Inc(FMI);
end;

procedure TVirtualMachine.EXEC_FORGET();
begin
  FMI := 0;
  FMarked[0] := TK_ILLEGAL;
end;

procedure TVirtualMachine.EXEC_ISATX();
begin
  FFlags := [];
  if FImmediate = 0 then
  begin
    if FAtStart then
        Include(FFlags, F_E);
  end
  else
  begin
    if FCodePointStream.Peek = -1 then
        Include(FFlags, F_E);
  end;
end;

procedure TVirtualMachine.EXEC_INRANGE();
type
  TRange = record
    Min: Integer;
    Max: Integer;
  end;

  PRange = ^TRange;
var
  Count: Integer;
  I: Integer;
  Range: PRange;
  Reg: Integer;
begin
  I := 0;
  Range := PRange(PByte(FMemory) + FOffset);
  Dec(Range);
  Count := Range^.Max;
  Inc(Range);
  Reg := FRegisters[FRR];
  while (I <> Count) do
  begin
    if ((Reg >= Range^.Min) and (Reg <= Range^.Max)) then
    begin
      Include(FFlags, F_E);
      exit;
    end;
    Inc(I);
    Inc(Range);
  end;
  FFlags := [];
end;

procedure TVirtualMachine.InitVM();
begin
  FTerminate := False;
  FMI := 0;
  FSI := 0;
  FIP := FBytecode;
  FIA := nil;
  FFlags := [];
end;

procedure TVirtualMachine.RecoverTokenText(Token: TToken);
var
  Text: string;
  I: Integer;
begin
  if Token.TokenType = -1 then
  begin
    Token.Text := '<EOF>';
    exit;
  end;
  Text := '';
  for I := Token.StartPos to Token.EndPos do
      Text := Text + FCodePointStream.Chars[I];
  Token.Text := Text;
end;

procedure TVirtualMachine.Run();
begin
  InitVM();
  while not(FTerminate) do
  begin
    Decode();
    Execute();
  end;
end;

procedure TVirtualMachine.Skip();
begin
  Include(FTokenFlags, tfSkip);
end;

procedure TVirtualMachine.UnSkip();
begin
  Exclude(FTokenFlags, tfSkip);
end;

procedure TVirtualMachine.Reject();
begin
  Include(FTokenFlags, tfReject);
end;

procedure TVirtualMachine.UnReject();
begin
  Exclude(FTokenFlags, tfReject);
end;

function TVirtualMachine.Parse(): TToken;
var
  I: Integer;
  RuleInfo: PRuleInfo;
  LTokenType: Integer;
label Entry;
begin
Entry:
  Result := TToken.Create;
  FStartPos := FCodePointStream.Position;
  FTokens.Add(Pointer(Result));
  Result.StartPos := FStartPos;
  Result.Line := FCodePointStream.Line;
  Result.Column := FCodePointStream.Column;
  LTokenType := TK_ILLEGAL;
  FMarkedPosition := -1;
  EXEC_FORGET();

  if (FCodePointStream.Peek() = -1) then
  begin
    Result.TokenType := 0;
    exit;
  end;
  { run the VM }
  Run();

  Result.EndPos := FMarkedPosition;
  for I := 0 to MAX_MARK_COUNT - 1 do
  begin
    if FMarked[I] = TK_ILLEGAL then
        break;
    RuleInfo := FindRuleInfoFromIndex(FMarked[I]);
    if not(Assigned(RuleInfo)) then
        raise Exception.Create('Error Message');
    FTokenFlags := [];
    LTokenType := RuleInfo^.TokenType;
    if RuleInfo^.ActionIndex <> ILLEGAL_ACTION_INDEX then
    begin
      UserAction(RuleInfo^.ActionIndex);
      if tfReject in FTokenFlags then
      begin
        LTokenType := TK_ILLEGAL;
        Continue;
      end;
    end;
    break;
  end;
  if (LTokenType <> TK_ILLEGAL) then
  begin
    Result.TokenType := LTokenType;
    FCodePointStream.Column := FCodePointStream.Column -
      (FCodePointStream.Position - FMarkedPosition);
    FCodePointStream.Position := FMarkedPosition;
    Result.EndPos := FMarkedPosition - 1;
    RecoverTokenText(Result);
  end
  else
  begin
    raise Exception.Create('Invalid token at ' + IntToStr(FCodePointStream.Position));
  end;
  if tfSkip in FTokenFlags then
      goto Entry;
end;

end.
