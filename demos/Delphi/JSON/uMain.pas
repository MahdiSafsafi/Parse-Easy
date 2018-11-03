unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TMain = class(TForm)
    ParseBtn: TButton;
    LogMemo: TMemo;
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
  System.Types,
  System.IOUtils,
  JSONLexer,
  JSONParser;

procedure TMain.ParseBtnClick(Sender: TObject);
var
  StringStream: TStringStream;
  Lexer: TJSONLexer;
  Parser: TJSONParser;
  Files: TStringDynArray;
  I: Integer;
  Path: string;
begin
  Files := System.IOUtils.TDirectory.GetFiles('../../examples');
  LogMemo.Clear();
  for I := 0 to Length(Files) - 1 do
  begin
    Path := Files[I];
    LogMemo.Lines.Add(Format('parsing json file "%s"', [Path]));
    Sleep(100);
    StringStream := TStringStream.Create();
    try
      StringStream.LoadFromFile(Path);
      Lexer := TJSONLexer.Create(StringStream);
      try
        Parser := TJSONParser.Create(Lexer);
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
end;

end.
