unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TMain = class(TForm)
    ParseBtn: TButton;
    DocLabel: TLabel;
    ExpressionEdit: TLabeledEdit;
    procedure ParseBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation

{$R *.dfm}


uses
  CalcLexer,
  CalcParser;

procedure TMain.ParseBtnClick(Sender: TObject);
var
  StringStream: TStringStream;
  Lexer: TCalcLexer;
  Parser: TCalcParser;
begin
  StringStream := TStringStream.Create(ExpressionEdit.Text, TEncoding.UTF8);
  try
    Lexer := TCalcLexer.Create(StringStream);
    try
      Parser := TCalcParser.Create(Lexer);
      try
          Parser.Parse();
      finally
          Parser.Free();
      end;
    finally
        Lexer.Free();
    end;
  finally
      StringStream.Free();
  end;
end;

end.
