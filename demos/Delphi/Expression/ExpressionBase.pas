unit ExpressionBase;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.StdCtrls,
  Parse.Easy.Lexer.CustomLexer,
  Parse.Easy.Parser.LR1;

type
  TExpressionBase = class(TLR1)
  private
    FVars: TList;
    FConsole: TMemo;
    FStringReference: TList;
  protected
    function HexToFloat(const S: string): Double;
    function FindVar(const Name: string): Pointer;
    function GetVarValue(const Name: string): Double;
    function RegisterVar(const Name: string): Pointer;
    function SQString(const Str: string): PChar;
    function DQString(const Str: string): PChar;
    procedure DoClear();
    function DoMin(List: TList): Double;
    function DoMax(List: TList): Double;
    procedure DoEcho(Text: PChar);
    procedure InternalClean();
    procedure DoAssignment(IsNew: Boolean; Name: string; Expression: Double);
  public
    constructor Create(ALexer: TCustomLexer); override;
    destructor Destroy(); override;
    property Console: TMemo read FConsole write FConsole;
  end;

implementation

{ TExpressionBase }
type
  TVariable = record
    Name: string;
    Value: Double;
  end;

  PVariable = ^TVariable;

constructor TExpressionBase.Create(ALexer: TCustomLexer);
begin
  inherited;
  FVars := TList.Create();
  FStringReference := TList.Create();
end;

destructor TExpressionBase.Destroy();
begin
  InternalClean();
  FVars.Free();
  FStringReference.Free();
  inherited;
end;

procedure TExpressionBase.DoAssignment(IsNew: Boolean; Name: string; Expression: Double);
var
  Variable: PVariable;
begin
  if (IsNew) then
      Variable := RegisterVar(Name)
  else
      Variable := FindVar(Name);
  if not Assigned(Variable) then
      raise Exception.Create('Error Message');
  Variable^.Value := Expression;
end;

procedure TExpressionBase.DoClear;
begin
  Console.Clear();
end;

procedure TExpressionBase.DoEcho(Text: PChar);
var
  S: string;
begin
  S := string(Text);
  Console.Lines.Add(S);
end;

function TExpressionBase.DoMax(List: TList): Double;
var
  I: Integer;
  Value: Double;
begin
  for I := 0 to List.Count - 1 do
  begin
    Value := PDouble(List[I])^;
    if I = 0 then
    begin
      Result := Value;
      Continue;
    end;
    if Value > Result then
        Result := Value;
  end;
end;

function TExpressionBase.DoMin(List: TList): Double;
var
  I: Integer;
  Value: Double;
begin
  for I := 0 to List.Count - 1 do
  begin
    Value := PDouble(List[I])^;
    if I = 0 then
    begin
      Result := Value;
      Continue;
    end;
    if Value < Result then
        Result := Value;
  end;
end;

function TExpressionBase.FindVar(const Name: string): Pointer;
var
  I: Integer;
  Variable: PVariable;
begin
  for I := 0 to FVars.Count - 1 do
  begin
    Variable := FVars[I];
    if (Assigned(Variable)) then
    begin
      if (SameText(Variable^.Name, Name)) then
          exit(Variable);
    end;
  end;
  Result := nil;
end;

function TExpressionBase.GetVarValue(const Name: string): Double;
var
  Variable: PVariable;
begin
  Variable := FindVar(Name);
  if not Assigned(Variable) then
      raise Exception.Create('Error Message');
  Result := Variable^.Value;
end;

function TExpressionBase.HexToFloat(const S: string): Double;
var
  Value: Integer;
begin
  S.Replace('0x', '$');
  Value := StrToInt(S);
  Result := Value;
end;

procedure TExpressionBase.InternalClean();
var
  I: Integer;
  P: Pointer;
begin
  for I := 0 to FVars.Count - 1 do
  begin
    P := FVars[I];
    if Assigned(P) then
    begin
      FinalizeRecord(P, TypeInfo(TVariable));
      FreeMem(P);
    end;
  end;
  FVars.Clear();
  for I := 0 to FStringReference.Count - 1 do
  begin
    P := FStringReference[I];
    if Assigned(P) then
        FreeMem(P);
  end;
  FStringReference.Clear();
end;

function TExpressionBase.RegisterVar(const Name: string): Pointer;
var
  Variable: PVariable;
begin
  Variable := FindVar(Name);
  if Assigned(Variable) then
      raise Exception.Create('Error Message');
  GetMem(Variable, SizeOf(TVariable));
  FillChar(Variable^, SizeOf(TVariable), 0);
  Variable^.Name := Name;
  FVars.Add(Variable);
  Result := Variable;
end;

function TExpressionBase.SQString(const Str: string): PChar;
var
  I: Integer;
  n: Integer;
  C: Char;
  S: string;
  P: PChar;
begin
  S := '';
  I := 1;
  n := Length(Str);
  while (True) do
  begin
    Inc(I);
    C := Str[I];
    if (C = '''') then
    begin
      if I < n then
      begin
        C := Str[I + 1];
        if (C = '''') then
        begin
          S := S + C;
          Inc(I);
          Continue;
        end;
      end;
      Break;
    end;
    S := S + C;
  end;
  GetMem(Result, (Length(S) + 1) * 2);
  P := Result;
  FStringReference.Add(Result);
  for I := 1 to S.Length do
  begin
    P^ := S[I];
    Inc(P);
  end;
  P^ := #0000;
end;

function TExpressionBase.DQString(const Str: string): PChar;
  function IsSeparator(C: Char): Boolean;
  var
    CP: Integer;
  begin
    Result := False;
    CP := Ord(C);
    case CP of
      0 .. 64, 91 .. 96, 123 .. 169, 171 .. 180, 182 .. 185, 187 .. 191, 215, 247,
        706 .. 709, 722 .. 735, 741 .. 747, 749, 751 .. 879, 885, 888 .. 889, 894,
        896 .. 901, 903, 907, 909, 930, 1014, 1154 .. 1161, 1328, 1367 .. 1368,
        1370 .. 1376, 1416 .. 1487, 1515 .. 1519, 1523 .. 1567, 1611 .. 1645, 1648,
        1748, 1750 .. 1764, 1767 .. 1773, 1776 .. 1785, 1789 .. 1790, 1792 .. 1807,
        1809, 1840 .. 1868, 1958 .. 1968, 1970 .. 1993, 2027 .. 2035, 2038 .. 2041,
        2043 .. 2047, 2070 .. 2073, 2075 .. 2083, 2085 .. 2087, 2089 .. 2111, 2137 .. 2207,
        2229, 2238 .. 2307, 2362 .. 2364, 2366 .. 2383, 2385 .. 2391, 2402 .. 2416,
        2433 .. 2436, 2445 .. 2446, 2449 .. 2450, 2473, 2481, 2483 .. 2485, 2490 .. 2492, 2494 .. 2509,
        2511 .. 2523, 2526, 2530 .. 2543, 2546 .. 2564, 2571 .. 2574, 2577 .. 2578, 2601, 2609, 2612, 2615, 2618 .. 2648, 2653, 2655 .. 2673, 2677 .. 2692, 2702,
        2706, 2729, 2737, 2740, 2746 .. 2748, 2750 .. 2767, 2769 .. 2783, 2786 .. 2808, 2810 .. 2820, 2829 .. 2830, 2833 .. 2834, 2857, 2865, 2868, 2874 .. 2876,
        2878 .. 2907, 2910, 2914 .. 2928, 2930 .. 2946, 2948, 2955 .. 2957, 2961, 2966 .. 2968, 2971, 2973, 2976 .. 2978, 2981 .. 2983, 2987 .. 2989,
        3002 .. 3023, 3025 .. 3076, 3085, 3089, 3113, 3130 .. 3132, 3134 .. 3159, 3163 .. 3167, 3170 .. 3199, 3201 .. 3204, 3213, 3217, 3241, 3252, 3258 .. 3260,
        3262 .. 3293, 3295, 3298 .. 3312, 3315 .. 3332, 3341, 3345, 3387 .. 3388, 3390 .. 3405, 3407 .. 3411, 3415 .. 3422, 3426 .. 3449, 3456 .. 3460,
        3479 .. 3481, 3506, 3516, 3518 .. 3519, 3527 .. 3584, 3633, 3636 .. 3647, 3655 .. 3712, 3715, 3717 .. 3718, 3721, 3723 .. 3724, 3726 .. 3731, 3736, 3744,
        3748, 3750, 3752 .. 3753, 3756, 3761, 3764 .. 3772, 3774 .. 3775, 3781, 3783 .. 3803, 3808 .. 3839, 3841 .. 3903, 3912, 3949 .. 3975, 3981 .. 4095,
        4139 .. 4158, 4160 .. 4175, 4182 .. 4185, 4190 .. 4192, 4194 .. 4196, 4199 .. 4205, 4209 .. 4212, 4226 .. 4237, 4239 .. 4255, 4294, 4296 .. 4300,
        4302 .. 4303, 4347, 4681, 4686 .. 4687, 4695, 4697, 4702 .. 4703, 4745, 4750 .. 4751, 4785, 4790 .. 4791, 4799, 4801, 4806 .. 4807, 4823, 4881,
        4886 .. 4887, 4955 .. 4991, 5008 .. 5023, 5110 .. 5111, 5118 .. 5120, 5741 .. 5742, 5760, 5787 .. 5791, 5867 .. 5872, 5881 .. 5887, 5901, 5906 .. 5919,
        5938 .. 5951, 5970 .. 5983, 5997, 6001 .. 6015, 6068 .. 6102, 6104 .. 6107, 6109 .. 6175, 6264 .. 6271, 6277 .. 6278, 6313, 6315 .. 6319, 6390 .. 6399,
        6431 .. 6479, 6510 .. 6511, 6517 .. 6527, 6572 .. 6575, 6602 .. 6655, 6679 .. 6687, 6741 .. 6822, 6824 .. 6916, 6964 .. 6980, 6988 .. 7042, 7073 .. 7085,
        7088 .. 7097, 7142 .. 7167, 7204 .. 7244, 7248 .. 7257, 7294 .. 7295, 7305 .. 7400, 7405, 7410 .. 7412, 7415 .. 7423, 7616 .. 7679, 7958 .. 7959,
        7966 .. 7967, 8006 .. 8007, 8014 .. 8015, 8024, 8026, 8028, 8030, 8062 .. 8063, 8117, 8125, 8127 .. 8129, 8133, 8141 .. 8143, 8148 .. 8149, 8156 .. 8159,
        8173 .. 8177, 8181, 8189 .. 8304, 8306 .. 8318, 8320 .. 8335, 8349 .. 8449, 8451 .. 8454, 8456 .. 8457, 8468, 8470 .. 8472, 8478 .. 8483, 8485, 8487,
        8489, 8494, 8506 .. 8507, 8512 .. 8516, 8522 .. 8525, 8527 .. 8578, 8581 .. 11263, 11311, 11359, 11493 .. 11498, 11503 .. 11505, 11508 .. 11519, 11558,
        11560 .. 11564, 11566 .. 11567, 11624 .. 11630, 11632 .. 11647, 11671 .. 11679, 11687, 11695, 11703, 11711, 11719, 11727, 11735, 11743 .. 11822,
        11824 .. 12292, 12295 .. 12336, 12342 .. 12346, 12349 .. 12352, 12439 .. 12444, 12448, 12539, 12544 .. 12548, 12590 .. 12592, 12687 .. 12703,
        12731 .. 12783, 12800 .. 13311, 19894 .. 19967, 40918 .. 40959, 42125 .. 42191, 42238 .. 42239, 42509 .. 42511, 42528 .. 42537, 42540 .. 42559,
        42607 .. 42622, 42654 .. 42655, 42726 .. 42774, 42784 .. 42785, 42889 .. 42890, 42927, 42936 .. 42998, 43010, 43014, 43019, 43043 .. 43071,
        43124 .. 43137, 43188 .. 43249, 43256 .. 43258, 43260, 43262 .. 43273, 43302 .. 43311, 43335 .. 43359, 43389 .. 43395, 43443 .. 43470, 43472 .. 43487,
        43493, 43504 .. 43513, 43519, 43561 .. 43583, 43587, 43596 .. 43615, 43639 .. 43641, 43643 .. 43645, 43696, 43698 .. 43700, 43703 .. 43704,
        43710 .. 43711, 43713, 43715 .. 43738, 43742 .. 43743, 43755 .. 43761, 43765 .. 43776, 43783 .. 43784, 43791 .. 43792, 43799 .. 43807, 43815, 43823,
        43867, 43878 .. 43887, 44003 .. 44031, 55204 .. 55215, 55239 .. 55242, 55292 .. 63743, 64110 .. 64111, 64218 .. 64255, 64263 .. 64274, 64280 .. 64284,
        64286, 64297, 64311, 64317, 64319, 64322, 64325, 64434 .. 64466, 64830 .. 64847, 64912 .. 64913, 64968 .. 65007, 65020 .. 65135, 65141, 65277 .. 65312,
        65339 .. 65344, 65371 .. 65381, 65471 .. 65473,
        65480 .. 65481, 65488 .. 65489, 65496 .. 65497, 65501 .. 65535: Result := True;
    end;
  end;

var
  I: Integer;
  n: Integer;
  C: Char;
  S: string;
  ID: string;
  J: Integer;
  Value: Double;
  P: PChar;
begin
  S := '';
  I := 1;
  n := Length(Str);
  while (True) do
  begin
    Inc(I);
    C := Str[I];
    if (C = '\') then
    begin
      Inc(I);
      C := Str[I];
      S := S + C;
      Continue;
    end;
    if (C = '$') then
    begin
      ID := '';
      Inc(I);
      for J := I to n - 1 do
      begin
        C := Str[J];
        if IsSeparator(C) then
            Break;
        ID := ID + C;
        Inc(I);
      end;
      Dec(I);
      Value := GetVarValue(ID);
      S := S + FloatToStr(Value);
      Continue;
    end;
    if (C = '"') then
        Break;
    S := S + C;
  end;

  GetMem(Result, (Length(S) + 1) * 2);
  FStringReference.Add(Result);
  P := Result;
  for I := 1 to S.Length do
  begin
    P^ := S[I];
    Inc(P);
  end;
  P^ := #0000;
end;

end.
