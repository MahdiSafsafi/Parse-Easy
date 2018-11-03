program JSONDemo;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Main},
  JSONLexer in 'JSON\JSONLexer.pas',
  JSONParser in 'JSON\JSONParser.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
