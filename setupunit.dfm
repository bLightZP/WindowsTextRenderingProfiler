object SetupForm: TSetupForm
  Left = 489
  Top = 310
  Width = 400
  Height = 234
  Caption = 'SetupForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object LabelTextToRender: TLabel
    Left = 26
    Top = 22
    Width = 66
    Height = 13
    Caption = 'Text to render'
  end
  object Label1: TLabel
    Left = 152
    Top = 96
    Width = 43
    Height = 13
    Caption = 'Iterations'
  end
  object FontButton: TButton
    Left = 250
    Top = 76
    Width = 111
    Height = 45
    Caption = 'Configure Font'
    TabOrder = 0
    OnClick = FontButtonClick
  end
  object TestButton: TButton
    Left = 250
    Top = 128
    Width = 111
    Height = 45
    Caption = 'Test'
    TabOrder = 1
    OnClick = TestButtonClick
  end
  object TextRenderEdit: TEdit
    Left = 24
    Top = 36
    Width = 337
    Height = 21
    TabOrder = 2
    Text = 
      'Testing the Windows 10 creators edition text rendering capabilit' +
      'ies'
  end
  object FunctionRG: TRadioGroup
    Left = 24
    Top = 72
    Width = 113
    Height = 101
    Caption = ' Function : '
    ItemIndex = 0
    Items.Strings = (
      'ExtTextgOutW '
      'DrawTextExW')
    TabOrder = 3
  end
  object ClippingCB: TCheckBox
    Left = 150
    Top = 75
    Width = 89
    Height = 17
    Caption = 'Clipping'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object IterationEdit: TEdit
    Left = 150
    Top = 110
    Width = 85
    Height = 21
    TabOrder = 5
    Text = '100'
  end
  object SaveLogButton: TButton
    Left = 150
    Top = 144
    Width = 85
    Height = 29
    Caption = 'Save log file'
    TabOrder = 6
    OnClick = SaveLogButtonClick
  end
  object FontDialog: TFontDialog
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -96
    Font.Name = 'Arial'
    Font.Style = []
    Left = 216
    Top = 76
  end
end
