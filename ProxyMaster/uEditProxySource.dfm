object EditProxySourceForm: TEditProxySourceForm
  Left = 0
  Top = 0
  Margins.Left = 4
  Margins.Top = 4
  Margins.Right = 4
  Margins.Bottom = 4
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Edit proxy source'
  ClientHeight = 307
  ClientWidth = 651
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 20
  object Label1: TLabel
    Left = 9
    Top = 9
    Width = 19
    Height = 20
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Url'
  end
  object Label2: TLabel
    Left = 9
    Top = 80
    Width = 74
    Height = 20
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Scan depth'
  end
  object UrlEdit: TEdit
    Left = 9
    Top = 30
    Width = 632
    Height = 28
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 0
  end
  object SaveButton: TButton
    Left = 270
    Top = 250
    Width = 94
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Save'
    TabOrder = 1
    OnClick = SaveButtonClick
  end
  object NumberBox1: TNumberBox
    Left = 9
    Top = 108
    Width = 102
    Height = 28
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    MaxValue = 2.000000000000000000
    TabOrder = 2
    SpinButtonOptions.ButtonWidth = 21
    SpinButtonOptions.Placement = nbspInline
  end
end
