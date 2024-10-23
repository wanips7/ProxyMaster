object MainForm: TMainForm
  Left = 0
  Top = 0
  Margins.Left = 4
  Margins.Top = 4
  Margins.Right = 4
  Margins.Bottom = 4
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'ProxyMaster'
  ClientHeight = 573
  ClientWidth = 882
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 20
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 882
    Height = 553
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ActivePage = TabSheet4
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Checker'
      object GroupBox2: TGroupBox
        Left = 4
        Top = 233
        Width = 252
        Height = 242
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Proxies'
        TabOrder = 0
        object Label3: TLabel
          Left = 17
          Top = 200
          Width = 48
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Total: 0'
        end
        object Label4: TLabel
          Left = 17
          Top = 116
          Width = 61
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Http(s): 0'
        end
        object Label5: TLabel
          Left = 17
          Top = 144
          Width = 60
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Socks4: 0'
        end
        object Label6: TLabel
          Left = 17
          Top = 172
          Width = 60
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Socks5: 0'
        end
        object Label7: TLabel
          Left = 17
          Top = 88
          Width = 76
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Unknown: 0'
        end
        object AddProxiesButton: TButton
          Left = 17
          Top = 35
          Width = 44
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = '+'
          TabOrder = 0
          OnClick = AddProxiesButtonClick
        end
        object ClearProxiesButton: TButton
          Left = 69
          Top = 35
          Width = 94
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Clear'
          TabOrder = 1
          OnClick = ClearProxiesButtonClick
        end
      end
      object GroupBox4: TGroupBox
        Left = 264
        Top = 4
        Width = 231
        Height = 221
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Checking stats'
        TabOrder = 1
        object Label10: TLabel
          Left = 20
          Top = 35
          Width = 58
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Online: 0'
        end
        object Label11: TLabel
          Left = 20
          Top = 63
          Width = 52
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Good: 0'
        end
        object Label12: TLabel
          Left = 20
          Top = 91
          Width = 41
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Bad: 0'
        end
        object Label13: TLabel
          Left = 20
          Top = 119
          Width = 61
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Http(s): 0'
        end
        object Label14: TLabel
          Left = 20
          Top = 147
          Width = 60
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Socks4: 0'
        end
        object Label15: TLabel
          Left = 20
          Top = 175
          Width = 60
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Socks5: 0'
        end
      end
      object GroupBox5: TGroupBox
        Left = 4
        Top = 79
        Width = 252
        Height = 146
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Presets'
        TabOrder = 2
        object Label16: TLabel
          Left = 20
          Top = 30
          Width = 96
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Current preset:'
        end
        object CheckerPresetsComboBox: TComboBox
          Left = 20
          Top = 58
          Width = 221
          Height = 28
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Style = csDropDownList
          TabOrder = 0
          OnChange = CheckerPresetsComboBoxChange
        end
        object AddCheckerPresetButton: TButton
          Left = 20
          Top = 94
          Width = 41
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = '+'
          TabOrder = 1
          OnClick = AddCheckerPresetButtonClick
        end
        object EditCheckerPresetButton: TButton
          Left = 69
          Top = 94
          Width = 42
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = '...'
          TabOrder = 2
          OnClick = EditCheckerPresetButtonClick
        end
        object RemoveCheckerPresetButton: TButton
          Left = 119
          Top = 94
          Width = 42
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = '-'
          TabOrder = 3
          OnClick = RemoveCheckerPresetButtonClick
        end
      end
      object GroupBox1: TGroupBox
        Left = 4
        Top = 4
        Width = 252
        Height = 67
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Control'
        TabOrder = 3
        object Label2: TLabel
          Left = 97
          Top = 28
          Width = 52
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Threads'
        end
        object StartCheckerButton: TButton
          Left = 16
          Top = 24
          Width = 31
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #9656
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -33
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = StartCheckerButtonClick
        end
        object NumberBox1: TNumberBox
          Left = 157
          Top = 24
          Width = 84
          Height = 28
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          MinValue = 1.000000000000000000
          MaxValue = 2000.000000000000000000
          SmallStep = 10.000000000000000000
          TabOrder = 1
          Value = 1.000000000000000000
          SpinButtonOptions.ButtonWidth = 21
          SpinButtonOptions.Placement = nbspCompact
          OnChangeValue = NumberBox1ChangeValue
        end
        object StopCheckerButton: TButton
          Left = 55
          Top = 24
          Width = 34
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #9724
          TabOrder = 2
          OnClick = StopCheckerButtonClick
        end
      end
      object GroupBox9: TGroupBox
        Left = 264
        Top = 233
        Width = 231
        Height = 146
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Progress'
        TabOrder = 4
        object Label8: TLabel
          Left = 20
          Top = 35
          Width = 93
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Checked: 0 / 0'
        end
        object Label21: TLabel
          Left = 20
          Top = 91
          Width = 106
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Progress: 0.00 %'
        end
        object Label22: TLabel
          Left = 20
          Top = 63
          Width = 131
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Active threads: 0 / 0'
        end
        object CheckerProgressBar: TProgressBar
          Left = 20
          Top = 119
          Width = 191
          Height = 10
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Max = 1000
          Smooth = True
          MarqueeInterval = 1
          Step = 1
          TabOrder = 0
        end
      end
    end
    object TabSheet2: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Grabber'
      ImageIndex = 1
      object Label1: TLabel
        Left = 4
        Top = 79
        Width = 54
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Sources:'
      end
      object Label18: TLabel
        Left = 4
        Top = 495
        Width = 54
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Count: 0'
      end
      object Label20: TLabel
        Left = 280
        Top = 31
        Width = 103
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Processed: 0 / 0'
      end
      object ProxySourcesVirtualStringTree: TVirtualStringTree
        Left = 4
        Top = 100
        Width = 797
        Height = 391
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        DefaultNodeHeight = 25
        Header.AutoSizeIndex = 0
        Header.Height = 24
        Header.MainColumn = 1
        Header.MaxHeight = 12500
        Header.MinHeight = 13
        Header.Options = [hoColumnResize, hoShowSortGlyphs, hoVisible]
        Indent = 23
        Margin = 5
        ScrollBarOptions.ScrollBars = ssVertical
        TabOrder = 0
        TextMargin = 5
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
        TreeOptions.SelectionOptions = [toFullRowSelect, toRightClickSelect, toSelectNextNodeOnRemoval]
        OnFreeNode = ProxySourcesVirtualStringTreeFreeNode
        OnGetText = ProxySourcesVirtualStringTreeGetText
        OnStateChange = ProxySourcesVirtualStringTreeStateChange
        Touch.InteractiveGestures = [igPan, igPressAndTap]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
        Columns = <
          item
            Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus, coEditable, coStyleColor]
            Position = 0
            Text = 'Id'
          end
          item
            Position = 1
            Text = 'Url'
            Width = 600
          end
          item
            Position = 2
            Text = 'Grabbed'
            Width = 100
          end>
      end
      object AddProxySourceButton: TButton
        Left = 820
        Top = 100
        Width = 43
        Height = 31
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = '+'
        TabOrder = 1
        OnClick = AddProxySourceButtonClick
      end
      object RemoveProxySourceButton: TButton
        Left = 820
        Top = 178
        Width = 43
        Height = 31
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = '-'
        TabOrder = 2
        OnClick = RemoveProxySourceButtonClick
      end
      object EditProxySourceButton: TButton
        Left = 820
        Top = 139
        Width = 43
        Height = 31
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = '...'
        TabOrder = 3
        OnClick = EditProxySourceButtonClick
      end
      object GroupBox6: TGroupBox
        Left = 4
        Top = 4
        Width = 252
        Height = 67
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Control'
        TabOrder = 4
        object Label17: TLabel
          Left = 97
          Top = 28
          Width = 52
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Threads'
        end
        object StartProxyGrabberButton: TButton
          Left = 16
          Top = 24
          Width = 31
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #9656
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -33
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = StartProxyGrabberButtonClick
        end
        object NumberBox2: TNumberBox
          Left = 157
          Top = 24
          Width = 84
          Height = 28
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          MinValue = 1.000000000000000000
          MaxValue = 100.000000000000000000
          TabOrder = 1
          Value = 1.000000000000000000
          SpinButtonOptions.ButtonWidth = 21
          SpinButtonOptions.Placement = nbspCompact
          OnChangeValue = NumberBox2ChangeValue
        end
        object StopProxyGrabberButton: TButton
          Left = 55
          Top = 24
          Width = 34
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #9724
          TabOrder = 2
          OnClick = StopProxyGrabberButtonClick
        end
      end
    end
    object TabSheet3: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Table'
      ImageIndex = 2
      object Label19: TLabel
        Left = 4
        Top = 495
        Width = 54
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Count: 0'
      end
      object ProxiesVirtualStringTree: TVirtualStringTree
        Left = 4
        Top = 43
        Width = 866
        Height = 444
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        DefaultNodeHeight = 25
        Header.AutoSizeIndex = -1
        Header.Height = 24
        Header.MainColumn = 1
        Header.MaxHeight = 12500
        Header.MinHeight = 13
        Header.Options = [hoColumnResize, hoShowSortGlyphs, hoVisible]
        Indent = 23
        Margin = 5
        PopupMenu = ProxyTablePopupMenu
        ScrollBarOptions.ScrollBars = ssVertical
        TabOrder = 0
        TextMargin = 5
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
        TreeOptions.SelectionOptions = [toFullRowSelect, toRightClickSelect, toSelectNextNodeOnRemoval]
        OnFreeNode = ProxiesVirtualStringTreeFreeNode
        OnGetText = ProxiesVirtualStringTreeGetText
        OnStateChange = ProxiesVirtualStringTreeStateChange
        Touch.InteractiveGestures = [igPan, igPressAndTap]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
        Columns = <
          item
            Position = 0
            Text = 'N'
          end
          item
            Position = 1
            Text = 'Proxy'
            Width = 200
          end
          item
            Position = 2
            Text = 'Type'
            Width = 80
          end
          item
            Position = 3
            Text = 'Anon'
            Width = 100
          end
          item
            Position = 4
            Text = 'Country'
            Width = 80
          end
          item
            Position = 5
            Text = 'City'
            Width = 180
          end
          item
            Position = 6
            Text = 'Ping'
            Width = 100
          end>
      end
      object AddProxyToTableButton: TButton
        Left = 4
        Top = 4
        Width = 57
        Height = 31
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = '+'
        TabOrder = 1
        OnClick = AddProxyToTableButtonClick
      end
      object ExportProxyTableButton: TButton
        Left = 674
        Top = 4
        Width = 94
        Height = 31
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Export'
        TabOrder = 2
        OnClick = ExportProxyTableButtonClick
      end
      object ClearProxyTableButton: TButton
        Left = 776
        Top = 4
        Width = 94
        Height = 31
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Clear'
        TabOrder = 3
        OnClick = ClearProxyTableButtonClick
      end
    end
    object TabSheet4: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Scheduler'
      ImageIndex = 3
      object GroupBox3: TGroupBox
        Left = 20
        Top = 14
        Width = 401
        Height = 147
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Control'
        TabOrder = 0
        object Label30: TLabel
          Left = 20
          Top = 69
          Width = 111
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Period (minutes):'
        end
        object Label31: TLabel
          Left = 190
          Top = 69
          Width = 100
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Checker preset:'
        end
        object Label29: TLabel
          Left = 190
          Top = 14
          Width = 123
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Status: not running'
        end
        object Label33: TLabel
          Left = 190
          Top = 42
          Width = 63
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Remain: -'
        end
        object StartSchedulerButton: TButton
          Left = 20
          Top = 30
          Width = 31
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #9656
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -33
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = StartSchedulerButtonClick
        end
        object StopSchedulerButton: TButton
          Left = 59
          Top = 30
          Width = 31
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #9724
          TabOrder = 1
          OnClick = StopSchedulerButtonClick
        end
        object NumberBox4: TNumberBox
          Left = 20
          Top = 97
          Width = 141
          Height = 28
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          MinValue = 1.000000000000000000
          MaxValue = 10000.000000000000000000
          SmallStep = 10.000000000000000000
          TabOrder = 2
          Value = 10.000000000000000000
          SpinButtonOptions.ButtonWidth = 21
          SpinButtonOptions.Placement = nbspInline
          OnChangeValue = NumberBox4ChangeValue
        end
        object ComboBox1: TComboBox
          Left = 190
          Top = 97
          Width = 181
          Height = 28
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Style = csDropDownList
          TabOrder = 3
        end
      end
    end
    object TabSheet7: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Local server'
      ImageIndex = 6
      object GroupBox7: TGroupBox
        Left = 20
        Top = 177
        Width = 281
        Height = 214
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Address:'
        TabOrder = 0
        object Label25: TLabel
          Left = 20
          Top = 30
          Width = 46
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Http(s)'
        end
        object Label27: TLabel
          Left = 20
          Top = 85
          Width = 45
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Socks4'
        end
        object Label28: TLabel
          Left = 20
          Top = 141
          Width = 45
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Socks5'
        end
        object Edit1: TEdit
          Left = 18
          Top = 49
          Width = 243
          Height = 28
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          ReadOnly = True
          TabOrder = 0
        end
        object Edit2: TEdit
          Left = 18
          Top = 105
          Width = 243
          Height = 28
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          ReadOnly = True
          TabOrder = 1
        end
        object Edit3: TEdit
          Left = 18
          Top = 161
          Width = 243
          Height = 28
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          ReadOnly = True
          TabOrder = 2
        end
      end
      object GroupBox8: TGroupBox
        Left = 20
        Top = 20
        Width = 281
        Height = 140
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Control'
        TabOrder = 1
        object Label23: TLabel
          Left = 125
          Top = 24
          Width = 126
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Status: Not running'
        end
        object Label24: TLabel
          Left = 20
          Top = 67
          Width = 29
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Port:'
        end
        object NumberBox3: TNumberBox
          Left = 20
          Top = 95
          Width = 131
          Height = 28
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          LargeStep = 1.000000000000000000
          MaxValue = 65535.000000000000000000
          TabOrder = 0
          Value = 8000.000000000000000000
          SpinButtonOptions.ButtonWidth = 21
          SpinButtonOptions.Placement = nbspInline
          OnChangeValue = NumberBox3ChangeValue
        end
        object StartLocalServerButton: TButton
          Left = 20
          Top = 28
          Width = 31
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #9656
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -33
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = StartLocalServerButtonClick
        end
        object StopLocalServerButton: TButton
          Left = 59
          Top = 28
          Width = 31
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #9724
          TabOrder = 2
          OnClick = StopLocalServerButtonClick
        end
      end
    end
    object TabSheet5: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Settings'
      ImageIndex = 4
      object Label32: TLabel
        Left = 20
        Top = 180
        Width = 68
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Client ip: -'
      end
      object CheckBox3: TCheckBox
        Left = 20
        Top = 58
        Width = 301
        Height = 21
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Add grabbed proxies to table'
        TabOrder = 0
        OnClick = CheckBox3Click
      end
      object CheckBox1: TCheckBox
        Left = 20
        Top = 87
        Width = 251
        Height = 18
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Save grabbed proxies to file'
        TabOrder = 1
        OnClick = CheckBox1Click
      end
    end
    object TabSheet6: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Log'
      ImageIndex = 5
      object MemoLog: TMemo
        Left = 4
        Top = 4
        Width = 764
        Height = 510
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object ClearLogButton: TButton
        Left = 776
        Top = 483
        Width = 94
        Height = 31
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Clear'
        TabOrder = 1
        OnClick = ClearLogButtonClick
      end
    end
    object TabSheet8: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Info'
      ImageIndex = 7
      object Label26: TLabel
        Left = 30
        Top = 20
        Width = 126
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'ProxyMaster v 1.0.0'
      end
      object Label34: TLabel
        Left = 30
        Top = 140
        Width = 112
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'This project uses:'
      end
      object Label35: TLabel
        Left = 30
        Top = 180
        Width = 316
        Height = 280
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 
          'Synapse'#13#10'https://github.com/geby/synapse'#13#10#13#10'Rapid.Generics'#13#10'http' +
          's://github.com/d-mozulyov/Rapid.Generics'#13#10#13#10'MMDB Reader'#13#10'https:/' +
          '/github.com/optinsoft/MMDBReader'#13#10#13#10'DelphiBigNumbers'#13#10'https://gi' +
          'thub.com/rvelthuis/DelphiBigNumbers'#13#10#13#10'IP geolocation database'#13#10 +
          'https://github.com/P3TERX/GeoLite.mmdb'
      end
      object Label36: TLabel
        Left = 30
        Top = 48
        Width = 270
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'https://github.com/wanips7/ProxyMaster'
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 553
    Width = 882
    Height = 20
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Panels = <
      item
        Text = 'Checker: not running'
        Width = 200
      end
      item
        Text = 'Grabber: not running'
        Width = 200
      end
      item
        Text = 'Scheduler: not running'
        Width = 200
      end>
  end
  object ProxyTablePopupMenu: TPopupMenu
    Left = 709
    Top = 459
    object Copyproxy1: TMenuItem
      Caption = 'Copy proxy'
      OnClick = Copyproxy1Click
    end
  end
end
