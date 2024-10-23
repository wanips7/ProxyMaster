object AddProxiesForm: TAddProxiesForm
  Left = 0
  Top = 0
  Margins.Left = 4
  Margins.Top = 4
  Margins.Right = 4
  Margins.Bottom = 4
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Add proxies'
  ClientHeight = 553
  ClientWidth = 483
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
    Width = 72
    Height = 20
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Proxy type:'
  end
  object Label2: TLabel
    Left = 9
    Top = 519
    Width = 54
    Height = 20
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Count: 0'
  end
  object ProxiesMemo: TMemo
    Left = 9
    Top = 45
    Width = 326
    Height = 466
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ScrollBars = ssVertical
    TabOrder = 0
    OnChange = ProxiesMemoChange
  end
  object ComboBox1: TComboBox
    Left = 106
    Top = 9
    Width = 145
    Height = 28
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 1
    Text = 'Unknown'
    Items.Strings = (
      'Unknown'
      'Http(s)'
      'Socks4'
      'Socks5')
  end
  object ClearButton: TButton
    Left = 343
    Top = 123
    Width = 94
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Clear'
    TabOrder = 2
    OnClick = ClearButtonClick
  end
  object AddFromTextButton: TButton
    Left = 343
    Top = 44
    Width = 94
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Add'
    TabOrder = 3
    OnClick = AddFromTextButtonClick
  end
  object AddFromFileButton: TButton
    Left = 343
    Top = 83
    Width = 131
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Add from file'
    TabOrder = 4
    OnClick = AddFromFileButtonClick
  end
end
