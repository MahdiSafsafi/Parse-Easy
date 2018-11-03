object Main: TMain
  Left = 0
  Top = 0
  Caption = 'Main'
  ClientHeight = 278
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ParseBtn: TButton
    Left = 0
    Top = 248
    Width = 554
    Height = 30
    Align = alBottom
    Caption = 'Parse'
    TabOrder = 0
    OnClick = ParseBtnClick
  end
  object LogMemo: TMemo
    Left = 0
    Top = 0
    Width = 554
    Height = 248
    Align = alClient
    Lines.Strings = (
      'this example loads all json files in the examples folder '
      'and parse them. if it fails an error will occur.')
    TabOrder = 1
    ExplicitHeight = 225
  end
end
