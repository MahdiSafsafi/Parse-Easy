program ExpressionDemo;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Main},
  ExpressionLexer in 'Expression\ExpressionLexer.pas',
  ExpressionParser in 'Expression\ExpressionParser.pas',
  ExpressionBase in 'ExpressionBase.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
