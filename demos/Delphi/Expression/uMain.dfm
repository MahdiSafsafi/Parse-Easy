object Main: TMain
  Left = 0
  Top = 0
  Caption = 'Main'
  ClientHeight = 372
  ClientWidth = 660
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ScriptMemo: TMemo
    Left = 0
    Top = 0
    Width = 660
    Height = 235
    Align = alClient
    Lines.Strings = (
      '{'
      '  this is a simple scripting language !'
      '  it parses expressions and evaluates them'
      '  and finally sets the result to the output console (memo).'
      ' '
      '  variable type can be either : '
      '    - decimal  eg : 15.'
      '    -  hex       eg : $1234abc, 0x1234abc.'
      '    - float       eg : 5.2.'
      '  '
      '  string can be either : '
      
        '    - single quoted string   => just like pascal ( double '#39' to e' +
        'scape '#39'):'
      '                    '#39'string'#39', '#39#39', '#39#39#39#39'. '
      '    - double quoted string => just like perl  (use \ to escape):'
      
        '                   "", "\"", "string $variable", "string \$novar' +
        'iable", ...'
      '  '
      '  comments: just like pascal:'
      '    - // single line.'
      '    - (* multi line *).'
      '    - just like this one with {. '
      '  '
      '  operators: '
      '    - +/*-%'
      ''
      '  built in function:'
      '    - min '
      '    - max'
      '    - sin'
      '    - cos'
      '    - tan'
      '    - clear'
      '    - echo'
      '}'
      ''
      'clear;     // clear console.'
      ''
      'var a = 00;        // decimal'
      'var b = 0x0a;    // hex'
      'var c = $0a;      // pascal hex'
      'var d = 00.20;  // float'
      ''
      'var vmin  = min(a, b, c, d);'
      'var vmax = max(a, b, c, d);'
      ''
      'echo "min = $vmin ; max = $vmax";'
      ''
      
        'echo '#39'calculating expression :'#39#39'a = max(1, 10, vmax - 1) * sin( ' +
        'min(d % 2, 4, vmin + 1.1) ) + 10 - ( 5 / 2)'#39#39' '#39';'
      
        'a = max(1, 10, vmax - 1) * sin( min(d % 2, 4, vmin + 1.1) ) + 10' +
        ' - ( 5 / 2);'
      'echo "a = $a.";'
      ''
      '// end of script:'
      'echo '#39#39';'
      'echo '#39#39';'
      'echo '#39'script ended.'#39';')
    ScrollBars = ssVertical
    TabOrder = 0
    ExplicitWidth = 626
    ExplicitHeight = 185
  end
  object LogMemo: TMemo
    Left = 0
    Top = 235
    Width = 660
    Height = 104
    Align = alBottom
    Lines.Strings = (
      'Memo2')
    ScrollBars = ssVertical
    TabOrder = 1
    ExplicitTop = 208
    ExplicitWidth = 626
  end
  object ParseBtn: TButton
    Left = 0
    Top = 339
    Width = 660
    Height = 33
    Align = alBottom
    Caption = 'Parse'
    TabOrder = 2
    OnClick = ParseBtnClick
    ExplicitTop = 312
    ExplicitWidth = 626
  end
end
