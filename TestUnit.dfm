object TestForm: TTestForm
  Left = 909
  Top = 307
  BorderStyle = bsNone
  ClientHeight = 166
  ClientWidth = 340
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object TestImage: TImage
    Left = 0
    Top = 0
    Width = 340
    Height = 166
    Align = alClient
    OnClick = TestImageClick
  end
end
