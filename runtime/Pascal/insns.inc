
// #################################################
// # automatically generated file. do not edit !!! #
// #################################################

// see C:/Users/smp/Desktop/Parse-Easy/lib/Parse/Easy/Lexer/insns2pascal.pl.

const
  MAX_ARG_COUNT        = 2;
  MAX_PATTERN_COUNT    = 1;

  { instructions }
  INSN_INVALID   = 00;
  INSN_VMSTART   = 01;
  INSN_VMEND     = 02;
  INSN_CALL      = 03;
  INSN_B         = 04;
  INSN_BEQ       = 05;
  INSN_BNEQ      = 06;
  INSN_BGT       = 07;
  INSN_BGE       = 08;
  INSN_BLT       = 09;
  INSN_BLE       = 10;
  INSN_NOP       = 11;
  INSN_PEEK      = 12;
  INSN_ADVANCE   = 13;
  INSN_FORGET    = 14;
  INSN_RET       = 15;
  INSN_SETSTATE  = 16;
  INSN_MARK      = 17;
  INSN_CMP       = 18;
  INSN_INRANGE   = 19;
  INSN_ISATX     = 20;
  INSN_HINT      = 21;
  { arguments }
  ARG_NONE   = 00;
  ARG_REL8   = 01;
  ARG_REL16  = 02;
  ARG_REL32  = 03;
  ARG_UIMM32 = 04;
  ARG_IMM8   = 05;
  ARG_IMM16  = 06;
  ARG_IMM32  = 07;
  ARG_R0     = 08;
  ARG_UIMM8  = 09;
  ARG_UIMM16 = 10;
  ARG_RR     = 11;
  ARG_OFFSET = 12;
  { patterns }
  PAT_NONE   = 00;
  PAT_OB     = 01;
  PAT_OW     = 02;
  PAT_OD     = 03;
  PAT_U32    = 04;
  PAT_I8     = 05;
  PAT_I16    = 06;
  PAT_I32    = 07;
  PAT_U8     = 08;
  PAT_U16    = 09;
  PAT_MF     = 10;

type 
  TInstructionDscrp = record 
    IID      : Integer;
    Args     : array [ 0 .. MAX_ARG_COUNT     -1 ] of Integer;
    Patterns : array [ 0 .. MAX_PATTERN_COUNT -1 ] of Integer;
  end;
  PInstructionDscrp = ^TInstructionDscrp;
  
const instructions : array [ 0 .. 256 - 1 ] of TInstructionDscrp = (
  {00} (IID: INSN_VMSTART; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {01} (IID: INSN_VMEND  ; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {02} (IID: INSN_CALL   ; Args: (ARG_REL8, ARG_NONE  ); Patterns: (PAT_OB)),
  {03} (IID: INSN_CALL   ; Args: (ARG_REL16, ARG_NONE ); Patterns: (PAT_OW)),
  {04} (IID: INSN_CALL   ; Args: (ARG_REL32, ARG_NONE ); Patterns: (PAT_OD)),
  {05} (IID: INSN_B      ; Args: (ARG_REL8, ARG_NONE  ); Patterns: (PAT_OB)),
  {06} (IID: INSN_B      ; Args: (ARG_REL16, ARG_NONE ); Patterns: (PAT_OW)),
  {07} (IID: INSN_B      ; Args: (ARG_REL32, ARG_NONE ); Patterns: (PAT_OD)),
  {08} (IID: INSN_BEQ    ; Args: (ARG_REL8, ARG_NONE  ); Patterns: (PAT_OB)),
  {09} (IID: INSN_BEQ    ; Args: (ARG_REL16, ARG_NONE ); Patterns: (PAT_OW)),
  {10} (IID: INSN_BEQ    ; Args: (ARG_REL32, ARG_NONE ); Patterns: (PAT_OD)),
  {11} (IID: INSN_BNEQ   ; Args: (ARG_REL8, ARG_NONE  ); Patterns: (PAT_OB)),
  {12} (IID: INSN_BNEQ   ; Args: (ARG_REL16, ARG_NONE ); Patterns: (PAT_OW)),
  {13} (IID: INSN_BNEQ   ; Args: (ARG_REL32, ARG_NONE ); Patterns: (PAT_OD)),
  {14} (IID: INSN_BGT    ; Args: (ARG_REL8, ARG_NONE  ); Patterns: (PAT_OB)),
  {15} (IID: INSN_BGT    ; Args: (ARG_REL16, ARG_NONE ); Patterns: (PAT_OW)),
  {16} (IID: INSN_BGT    ; Args: (ARG_REL32, ARG_NONE ); Patterns: (PAT_OD)),
  {17} (IID: INSN_BGE    ; Args: (ARG_REL8, ARG_NONE  ); Patterns: (PAT_OB)),
  {18} (IID: INSN_BGE    ; Args: (ARG_REL16, ARG_NONE ); Patterns: (PAT_OW)),
  {19} (IID: INSN_BGE    ; Args: (ARG_REL32, ARG_NONE ); Patterns: (PAT_OD)),
  {20} (IID: INSN_BLT    ; Args: (ARG_REL8, ARG_NONE  ); Patterns: (PAT_OB)),
  {21} (IID: INSN_BLT    ; Args: (ARG_REL16, ARG_NONE ); Patterns: (PAT_OW)),
  {22} (IID: INSN_BLT    ; Args: (ARG_REL32, ARG_NONE ); Patterns: (PAT_OD)),
  {23} (IID: INSN_BLE    ; Args: (ARG_REL8, ARG_NONE  ); Patterns: (PAT_OB)),
  {24} (IID: INSN_BLE    ; Args: (ARG_REL16, ARG_NONE ); Patterns: (PAT_OW)),
  {25} (IID: INSN_BLE    ; Args: (ARG_REL32, ARG_NONE ); Patterns: (PAT_OD)),
  {26} (IID: INSN_NOP    ; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {27} (IID: INSN_PEEK   ; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {28} (IID: INSN_ADVANCE; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {29} (IID: INSN_FORGET ; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {30} (IID: INSN_RET    ; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {31} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {32} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {33} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {34} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {35} (IID: INSN_SETSTATE; Args: (ARG_UIMM32, ARG_NONE); Patterns: (PAT_U32)),
  {36} (IID: INSN_MARK   ; Args: (ARG_IMM8, ARG_NONE  ); Patterns: (PAT_I8)),
  {37} (IID: INSN_MARK   ; Args: (ARG_IMM16, ARG_NONE ); Patterns: (PAT_I16)),
  {38} (IID: INSN_MARK   ; Args: (ARG_IMM32, ARG_NONE ); Patterns: (PAT_I32)),
  {39} (IID: INSN_CMP    ; Args: (ARG_R0, ARG_UIMM8   ); Patterns: (PAT_U8)),
  {40} (IID: INSN_CMP    ; Args: (ARG_R0, ARG_UIMM16  ); Patterns: (PAT_U16)),
  {41} (IID: INSN_CMP    ; Args: (ARG_R0, ARG_UIMM32  ); Patterns: (PAT_U32)),
  {42} (IID: INSN_INRANGE; Args: (ARG_RR, ARG_OFFSET  ); Patterns: (PAT_MF)),
  {43} (IID: INSN_ISATX  ; Args: (ARG_IMM8, ARG_NONE  ); Patterns: (PAT_I8)),
  {44} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {45} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {46} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {47} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {48} (IID: INSN_HINT   ; Args: (ARG_UIMM8, ARG_NONE ); Patterns: (PAT_U8)),
  {49} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {50} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {51} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {52} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {53} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {54} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {55} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {56} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {57} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {58} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {59} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {60} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {61} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {62} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {63} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {64} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {65} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {66} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {67} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {68} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {69} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {70} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {71} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {72} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {73} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {74} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {75} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {76} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {77} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {78} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {79} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {80} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {81} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {82} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {83} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {84} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {85} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {86} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {87} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {88} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {89} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {90} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {91} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {92} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {93} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {94} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {95} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {96} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {97} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {98} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {99} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {100} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {101} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {102} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {103} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {104} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {105} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {106} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {107} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {108} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {109} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {110} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {111} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {112} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {113} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {114} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {115} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {116} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {117} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {118} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {119} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {120} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {121} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {122} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {123} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {124} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {125} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {126} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {127} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {128} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {129} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {130} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {131} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {132} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {133} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {134} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {135} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {136} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {137} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {138} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {139} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {140} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {141} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {142} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {143} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {144} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {145} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {146} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {147} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {148} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {149} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {150} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {151} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {152} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {153} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {154} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {155} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {156} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {157} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {158} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {159} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {160} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {161} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {162} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {163} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {164} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {165} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {166} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {167} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {168} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {169} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {170} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {171} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {172} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {173} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {174} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {175} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {176} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {177} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {178} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {179} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {180} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {181} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {182} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {183} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {184} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {185} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {186} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {187} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {188} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {189} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {190} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {191} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {192} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {193} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {194} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {195} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {196} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {197} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {198} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {199} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {200} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {201} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {202} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {203} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {204} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {205} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {206} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {207} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {208} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {209} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {210} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {211} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {212} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {213} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {214} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {215} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {216} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {217} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {218} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {219} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {220} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {221} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {222} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {223} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {224} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {225} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {226} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {227} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {228} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {229} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {230} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {231} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {232} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {233} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {234} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {235} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {236} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {237} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {238} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {239} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {240} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {241} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {242} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {243} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {244} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {245} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {246} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {247} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {248} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {249} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {250} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {251} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {252} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {253} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {254} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE)),
  {255} (IID: INSN_INVALID; Args: (ARG_NONE, ARG_NONE  ); Patterns: (PAT_NONE))
);
