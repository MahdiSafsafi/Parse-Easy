unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TMain = class(TForm)
    ScriptMemo: TMemo;
    LogMemo: TMemo;
    ParseBtn: TButton;
    procedure ParseBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation

uses
  System.Math,
  ExpressionLexer,
  ExpressionParser;

{$R *.dfm}


procedure TMain.ParseBtnClick(Sender: TObject);
var
  Lexer: TExpressionLexer;
  Parser: TExpressionParser;
  StringStream: TStringStream;
begin
  StringStream := TStringStream.Create(ScriptMemo.Text, TEncoding.UTF8);
  try
    Lexer := TExpressionLexer.Create(StringStream);
    try
      Parser := TExpressionParser.Create(Lexer);
      try
        Parser.Console := LogMemo;
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

initialization

ReportMemoryLeaksOnShutdown := True;

end.
