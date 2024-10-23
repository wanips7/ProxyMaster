object EditCheckerPresetForm: TEditCheckerPresetForm
  Left = 0
  Top = 0
  Margins.Left = 4
  Margins.Top = 4
  Margins.Right = 4
  Margins.Bottom = 4
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Edit checker preset'
  ClientHeight = 500
  ClientWidth = 749
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
  object SaveButton: TButton
    Left = 310
    Top = 459
    Width = 141
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Save'
    TabOrder = 0
    OnClick = SaveButtonClick
  end
  object PageControl: TPageControl
    Left = 0
    Top = 9
    Width = 741
    Height = 442
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ActivePage = TabSheet2
    TabOrder = 1
    object TabSheet1: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Main'
      object Label1: TLabel
        Left = 20
        Top = 20
        Width = 81
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Preset name'
      end
      object PresetNameEdit: TEdit
        Left = 20
        Top = 40
        Width = 311
        Height = 28
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Request'
      ImageIndex = 1
      object Label2: TLabel
        Left = 14
        Top = 4
        Width = 22
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Url:'
      end
      object Label3: TLabel
        Left = 510
        Top = 4
        Width = 91
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Timeout (ms):'
      end
      object Label4: TLabel
        Left = 15
        Top = 80
        Width = 112
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Request headers:'
      end
      object Label5: TLabel
        Left = 15
        Top = 307
        Width = 74
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'User agent:'
      end
      object Edit2: TEdit
        Left = 14
        Top = 32
        Width = 447
        Height = 28
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 0
      end
      object NumberBox1: TNumberBox
        Left = 510
        Top = 32
        Width = 181
        Height = 28
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        MinValue = 100.000000000000000000
        MaxValue = 10000.000000000000000000
        SmallStep = 100.000000000000000000
        TabOrder = 1
        Value = 1000.000000000000000000
        SpinButtonOptions.ButtonWidth = 21
        SpinButtonOptions.Placement = nbspInline
      end
      object Memo1: TMemo
        Left = 14
        Top = 108
        Width = 707
        Height = 188
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ScrollBars = ssVertical
        TabOrder = 2
      end
      object Edit3: TEdit
        Left = 15
        Top = 330
        Width = 706
        Height = 28
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 3
      end
    end
    object TabSheet3: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Good conditions'
      ImageIndex = 2
      object Label6: TLabel
        Left = 20
        Top = 20
        Width = 77
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Status code'
      end
      object NumberBox2: TNumberBox
        Left = 20
        Top = 48
        Width = 121
        Height = 28
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        MinValue = 100.000000000000000000
        MaxValue = 599.000000000000000000
        TabOrder = 0
        Value = 200.000000000000000000
        SpinButtonOptions.ButtonWidth = 21
      end
    end
    object TabSheet4: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Save'
      ImageIndex = 3
      object GroupBox1: TGroupBox
        Left = 4
        Top = 0
        Width = 157
        Height = 231
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Save type'
        TabOrder = 0
        object CheckBox4: TCheckBox
          Left = 20
          Top = 40
          Width = 98
          Height = 18
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Http(s)'
          TabOrder = 0
        end
        object CheckBox3: TCheckBox
          Left = 20
          Top = 66
          Width = 98
          Height = 18
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Socks4'
          TabOrder = 1
        end
        object CheckBox5: TCheckBox
          Left = 20
          Top = 92
          Width = 98
          Height = 18
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Socks5'
          TabOrder = 2
        end
        object CheckBox6: TCheckBox
          Left = 20
          Top = 118
          Width = 98
          Height = 18
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Bad'
          TabOrder = 3
        end
      end
      object CheckBox2: TCheckBox
        Left = 4
        Top = 328
        Width = 301
        Height = 23
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Caption = 'Add good proxy to table'
        TabOrder = 1
      end
      object CheckBox7: TCheckBox
        Left = 4
        Top = 255
        Width = 217
        Height = 23
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Caption = 'Save to file'
        TabOrder = 2
      end
      object CheckBox8: TCheckBox
        Left = 5
        Top = 288
        Width = 217
        Height = 23
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Caption = 'Save to local server'
        TabOrder = 3
      end
    end
  end
end
