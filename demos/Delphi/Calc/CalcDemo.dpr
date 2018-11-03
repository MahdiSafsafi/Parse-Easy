program CalcDemo;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Main},
  CalcLexer in 'Calc\CalcLexer.pas',
  CalcParser in 'Calc\CalcParser.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
