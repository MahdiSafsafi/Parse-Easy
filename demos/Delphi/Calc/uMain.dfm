object Main: TMain
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Calc validator'
  ClientHeight = 142
  ClientWidth = 446
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object DocLabel: TLabel
    Left = 8
    Top = 8
    Width = 409
    Height = 26
    Caption = 
      'This example will check whether a given expression is valid or n' +
      'ot. If it'#39's not valid, an exception will occur.'
    WordWrap = True
  end
  object ParseBtn: TButton
    Left = 8
    Top = 109
    Width = 431
    Height = 25
    Caption = 'Parse'
    TabOrder = 0
    OnClick = ParseBtnClick
  end
  object ExpressionEdit: TLabeledEdit
    Left = 64
    Top = 63
    Width = 375
    Height = 21
    EditLabel.Width = 56
    EditLabel.Height = 13
    EditLabel.Caption = 'Expression:'
    LabelPosition = lpLeft
    TabOrder = 1
    TextHint = 'eg: -1 + (5 * 2)'
  end
end
