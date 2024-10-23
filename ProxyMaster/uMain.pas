unit uMain;

interface

{$REGION 'Licence'}
(*****************************************************************************

  Copyright (c) 2024 Ivan
  https://github.com/wanips7/ProxyMaster

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

******************************************************************************)
{$ENDREGION}

uses
  Winapi.Windows, System.SysUtils, System.Classes, Rapid.Generics, System.Diagnostics,
  System.IOUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.ExtCtrls, VirtualTrees.BaseAncestorVCL, VirtualTrees.BaseTree, VirtualTrees.AncestorVCL,
  VirtualTrees, VirtualTrees.Types, Vcl.StdCtrls, Vcl.NumberBox, uProxyList, uProxy,
  uProxyGrabberService, uProxyCheckerService, uTypes, uProxyGeo, Vcl.Menus, uLocalServer,
  uScheduler, uClientIp, uLogger;

type
  TMainForm = class(TForm)
    PageControl: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    ProxiesVirtualStringTree: TVirtualStringTree;
    ProxySourcesVirtualStringTree: TVirtualStringTree;
    TabSheet6: TTabSheet;
    MemoLog: TMemo;
    AddProxySourceButton: TButton;
    EditProxySourceButton: TButton;
    RemoveProxySourceButton: TButton;
    Label1: TLabel;
    StatusBar: TStatusBar;
    GroupBox2: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    AddProxiesButton: TButton;
    ClearProxiesButton: TButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    CheckerPresetsComboBox: TComboBox;
    AddCheckerPresetButton: TButton;
    EditCheckerPresetButton: TButton;
    RemoveCheckerPresetButton: TButton;
    Label18: TLabel;
    GroupBox6: TGroupBox;
    Label17: TLabel;
    StartProxyGrabberButton: TButton;
    NumberBox2: TNumberBox;
    StopProxyGrabberButton: TButton;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    StartCheckerButton: TButton;
    NumberBox1: TNumberBox;
    StopCheckerButton: TButton;
    AddProxyToTableButton: TButton;
    ExportProxyTableButton: TButton;
    TabSheet7: TTabSheet;
    Label19: TLabel;
    ClearProxyTableButton: TButton;
    CheckBox3: TCheckBox;
    ProxyTablePopupMenu: TPopupMenu;
    Copyproxy1: TMenuItem;
    TabSheet8: TTabSheet;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    StartLocalServerButton: TButton;
    StopLocalServerButton: TButton;
    Label24: TLabel;
    NumberBox3: TNumberBox;
    Edit1: TEdit;
    Label26: TLabel;
    GroupBox7: TGroupBox;
    Edit2: TEdit;
    Edit3: TEdit;
    Label25: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    StartSchedulerButton: TButton;
    StopSchedulerButton: TButton;
    NumberBox4: TNumberBox;
    Label30: TLabel;
    Label31: TLabel;
    ComboBox1: TComboBox;
    Label32: TLabel;
    GroupBox3: TGroupBox;
    GroupBox8: TGroupBox;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label33: TLabel;
    GroupBox9: TGroupBox;
    CheckerProgressBar: TProgressBar;
    CheckBox1: TCheckBox;
    ClearLogButton: TButton;
    procedure AddProxiesButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ClearProxiesButtonClick(Sender: TObject);
    procedure AddProxySourceButtonClick(Sender: TObject);
    procedure ProxySourcesVirtualStringTreeFreeNode(
      Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure ProxySourcesVirtualStringTreeGetText(
      Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVstTextType; var CellText: string);
    procedure EditProxySourceButtonClick(Sender: TObject);
    procedure RemoveProxySourceButtonClick(Sender: TObject);
    procedure AddCheckerPresetButtonClick(Sender: TObject);
    procedure EditCheckerPresetButtonClick(Sender: TObject);
    procedure RemoveCheckerPresetButtonClick(Sender: TObject);
    procedure AddProxyToTableButtonClick(Sender: TObject);
    procedure ProxiesVirtualStringTreeFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure ProxiesVirtualStringTreeGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVstTextType;
      var CellText: string);
    procedure StartProxyGrabberButtonClick(Sender: TObject);
    procedure StopProxyGrabberButtonClick(Sender: TObject);
    procedure ClearProxyTableButtonClick(Sender: TObject);
    procedure CopyProxy1Click(Sender: TObject);
    procedure StopCheckerButtonClick(Sender: TObject);
    procedure StartCheckerButtonClick(Sender: TObject);
    procedure ExportProxyTableButtonClick(Sender: TObject);
    procedure ProxiesVirtualStringTreeStateChange(Sender: TBaseVirtualTree;
      Enter, Leave: TVirtualTreeStates);
    procedure ProxySourcesVirtualStringTreeStateChange(
      Sender: TBaseVirtualTree; Enter, Leave: TVirtualTreeStates);
    procedure StartLocalServerButtonClick(Sender: TObject);
    procedure StopLocalServerButtonClick(Sender: TObject);
    procedure StopSchedulerButtonClick(Sender: TObject);
    procedure NumberBox1ChangeValue(Sender: TObject);
    procedure NumberBox2ChangeValue(Sender: TObject);
    procedure NumberBox4ChangeValue(Sender: TObject);
    procedure NumberBox3ChangeValue(Sender: TObject);
    procedure CheckerPresetsComboBoxChange(Sender: TObject);
    procedure StartSchedulerButtonClick(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ClearLogButtonClick(Sender: TObject);
  private
    FTimer: TTimer;
    FProxyGrabberService: TProxyGrabberService;
    FProxyCheckerService: TProxyCheckerService;
    FProxyGeoFetcher: TProxyGeoFetcher;
    FLocalServer: TLocalServer;
    FScheduler: TScheduler;
    FClientIpFetcher: TClientIpFetcher;

    procedure TimerEventHandler(Sender: TObject);
    procedure ProxyListChangeEventHandler(Sender: TObject; const Action: TProxyList.TAction);
    procedure ProxySourcesTableChangeEventHandler(Sender: TObject);
    procedure CheckerPresetsTableChangeEventHandler(Sender: TObject);
    procedure StartProxyGrabberEventHandler(Sender: TObject);
    procedure FinishProxyGrabberEventHandler(Sender: TObject);
    procedure StartProxyCheckerEventHandler(Sender: TObject);
    procedure RunProxyCheckerEventHandler(Sender: TObject);
    procedure FinishProxyCheckerEventHandler(Sender: TObject);
    procedure StartLocalServerEventHandler(Sender: TObject);
    procedure LogEventHandler(Sender: TObject; const LogData: TLogData);
    procedure ClientIpFetchEventHandler(Sender: TObject; const FetchResult: TIpFetchResult);
    procedure SetStatusBarText(const Index: Integer; const Text: string);
    procedure LoadSettings;
    procedure LoadCheckerPresets;
    procedure LoadProxySources;
    procedure UpdateCheckerStats;
    procedure UpdateGrabberStats;
    procedure UpdateLocalServerAddress;
    procedure AddGoodProxiesToTable;
    function GetSelectedProxySource(out Value: TProxySource): Boolean;
    function GetSelectedCheckerPreset(out Value: TCheckerPreset): Boolean;
    function GetSelectedSchedulerCheckerPreset(out Value: TCheckerPreset): Boolean;
    function GetSelectedProxy(out Value: TProxyEx): Boolean;
    function ShowQuestionBox(const Text, Title: string): Boolean;
    procedure ShowMessageBox(const Text, Title: string);
    procedure ShowErrorMessageBox(const Text: string);
    procedure SaveCheckedProxiesToFile;
    procedure SaveGrabbedProxiesToFile;
    procedure CreateDirectoryIfNotExist(const Value: string);
    function MillisecondsToSeconds(const Value: Cardinal): Cardinal;
  public
    procedure Prepare;
    procedure AddProxyToTable(const Value: TProxyEx); overload;
    procedure AddProxyToTable(const Value: TProxy); overload;
    procedure AddProxyListToTable(const Value: TProxyList);
  end;

var
  MainForm: TMainForm;
  AppPath: string;

implementation

{$R *.dfm}

uses
  System.Threading, uAddProxies, uDatabase, uEditProxySource, uEditCheckerPreset, uSettings,
  Vcl.Clipbrd, uProxyParser, uUrlParser, uConst;

procedure TMainForm.AddProxyToTable(const Value: TProxyEx);
var
  Node: PVirtualNode;
  Data: PProxyEx;
begin
  Node := ProxiesVirtualStringTree.AddChild(nil);
  Data := ProxiesVirtualStringTree.GetNodeData(Node);
  if Assigned(Data) then
  begin
    Data^ := Value;
    FProxyGeoFetcher.TryFetch(Data);
  end;
end;

procedure TMainForm.AddProxyToTable(const Value: TProxy);
var
  ProxyEx: TProxyEx;
begin
  ProxyEx.Clear;
  ProxyEx.Proxy := Value;
  AddProxyToTable(ProxyEx);
end;

procedure TMainForm.Prepare;
begin
  AddProxiesForm.Init(FProxyCheckerService.Proxies);

  FClientIpFetcher.Fetch;
end;

procedure TMainForm.RemoveCheckerPresetButtonClick(Sender: TObject);
var
  CheckerPreset: TCheckerPreset;
begin
  if GetSelectedCheckerPreset(CheckerPreset) then
    if ShowQuestionBox('Do you want to delete selected checker preset?', 'Delete') then
      Database.CheckerPresetsTable.Remove(CheckerPreset.Id);
end;

procedure TMainForm.StartLocalServerButtonClick(Sender: TObject);
begin
  FLocalServer.Start;
end;

procedure TMainForm.StopLocalServerButtonClick(Sender: TObject);
begin
  FLocalServer.Stop;
end;

procedure TMainForm.StartSchedulerButtonClick(Sender: TObject);
var
  Period: Cardinal;
  CheckerPreset: TCheckerPreset;
begin
  if GetSelectedSchedulerCheckerPreset(CheckerPreset) then
  begin
    Period := MillisecondsToSeconds(NumberBox4.ValueInt);

    FScheduler.CheckerPreset := CheckerPreset;
    FScheduler.Start(Period, TSettings.Data.CheckerThreadCount, TSettings.Data.GrabberThreadCount);
  end;

end;

procedure TMainForm.StopSchedulerButtonClick(Sender: TObject);
begin
  FScheduler.Stop;
end;

procedure TMainForm.StartCheckerButtonClick(Sender: TObject);
var
  CheckerPreset: TCheckerPreset;
begin
  if GetSelectedCheckerPreset(CheckerPreset) then
  begin
    FProxyCheckerService.Preset := CheckerPreset;
    FProxyCheckerService.Start(TSettings.Data.CheckerThreadCount);
  end
    else
  begin
    ShowErrorMessageBox('Checker preset is not specified.');
  end;

end;

procedure TMainForm.StartLocalServerEventHandler(Sender: TObject);
begin
  //
end;

procedure TMainForm.RunProxyCheckerEventHandler(Sender: TObject);
begin
  GroupBox2.Enabled := False;
  GroupBox5.Enabled := False;
end;

procedure TMainForm.StartProxyCheckerEventHandler(Sender: TObject);
begin
  ProxiesVirtualStringTree.Clear;

  UpdateCheckerStats;

  Logger.Log('[Proxy checker] Started.');
end;

procedure TMainForm.FinishProxyCheckerEventHandler(Sender: TObject);
var
  s: string;
begin
  UpdateCheckerStats;

  if FProxyCheckerService.Preset.SaveToFile then
  begin
    SaveCheckedProxiesToFile;
  end;

  if FProxyCheckerService.Preset.SaveToLocalServer then
  begin
    FLocalServer.Start;
    FLocalServer.UpdateResponse;
  end;

  if FProxyCheckerService.Preset.AddGoodProxyToTable then
  begin
    AddGoodProxiesToTable;
  end;

  GroupBox2.Enabled := True;
  GroupBox5.Enabled := True;

  s := 'Http(s) count: ' + FProxyCheckerService.Results.HttpList.Count.ToString + sLineBreak +
    'Socks4 count: ' + FProxyCheckerService.Results.Socks4List.Count.ToString + sLineBreak +
    'Socks5 count: ' + FProxyCheckerService.Results.Socks5List.Count.ToString + sLineBreak +
    'Good count: ' + FProxyCheckerService.Results.GetGoodCount.ToString + sLineBreak +
    'Bad count: ' + FProxyCheckerService.Results.BadList.Count.ToString + sLineBreak +
    'Total count: ' + FProxyCheckerService.Results.GetTotalCount.ToString;

  Logger.Log('[Proxy checker] Finished. Report:' + sLineBreak + s);
end;

procedure TMainForm.StartProxyGrabberButtonClick(Sender: TObject);
begin
  FProxyGrabberService.Start(TSettings.Data.GrabberThreadCount);
end;

procedure TMainForm.StopCheckerButtonClick(Sender: TObject);
begin
  FProxyCheckerService.Stop;
end;

procedure TMainForm.StopProxyGrabberButtonClick(Sender: TObject);
begin
  FProxyGrabberService.Stop;
end;

procedure TMainForm.AddProxySourceButtonClick(Sender: TObject);
begin
  EditProxySourceForm.ShowModalForAdding;
end;

procedure TMainForm.EditProxySourceButtonClick(Sender: TObject);
var
  ProxySource: TProxySource;
begin
  if GetSelectedProxySource(ProxySource) then
    EditProxySourceForm.ShowModalForEditing(ProxySource);
end;

procedure TMainForm.RemoveProxySourceButtonClick(Sender: TObject);
var
  ProxySource: TProxySource;
begin
  if GetSelectedProxySource(ProxySource) then
    if ShowQuestionBox('Do you want to delete selected proxy source?', 'Delete') then
      Database.ProxySourcesTable.Remove(ProxySource.Id);
end;

procedure TMainForm.AddProxyToTableButtonClick(Sender: TObject);
begin
  AddProxiesForm.ShowModal(TAddPlace.Table);
end;

procedure TMainForm.ExportProxyTableButtonClick(Sender: TObject);
var
  Text: string;
  SaveDialog : TSaveDialog;
begin
  SaveDialog := TSaveDialog.Create(self);
  SaveDialog.InitialDir := GetCurrentDir;
  SaveDialog.Filter := 'Text file|*.txt';
  SaveDialog.DefaultExt := 'txt';
  SaveDialog.FilterIndex := 1;

  if SaveDialog.Execute then
  begin
    Text := ProxiesVirtualStringTree.ContentToText(TVSTTextSourceType.tstVisible, ' ');
    TFile.WriteAllText(SaveDialog.FileName, Text);
  end;

  SaveDialog.Free;
end;

procedure TMainForm.ClearProxyTableButtonClick(Sender: TObject);
begin
  ProxiesVirtualStringTree.Clear;
end;

procedure TMainForm.AddCheckerPresetButtonClick(Sender: TObject);
begin
  EditCheckerPresetForm.ShowModalForAdding;
end;

procedure TMainForm.EditCheckerPresetButtonClick(Sender: TObject);
var
  CheckerPreset: TCheckerPreset;
begin
  if GetSelectedCheckerPreset(CheckerPreset) then
    EditCheckerPresetForm.ShowModalForEditing(CheckerPreset);
end;

procedure TMainForm.CheckBox1Click(Sender: TObject);
begin
  TSettings.Data.SaveGrabbedProxiesToFile := CheckBox1.Checked;
end;

procedure TMainForm.CheckBox3Click(Sender: TObject);
begin
  TSettings.Data.AddGrabbedProxiesToTable := CheckBox3.Checked;
end;

procedure TMainForm.CheckerPresetsComboBoxChange(Sender: TObject);
var
  CheckerPreset: TCheckerPreset;
begin
  if GetSelectedCheckerPreset(CheckerPreset) then
    TSettings.Data.ActiveCheckerPresetID := CheckerPreset.Id;
end;

procedure TMainForm.CheckerPresetsTableChangeEventHandler(Sender: TObject);
begin
  LoadCheckerPresets;
end;

procedure TMainForm.ClearLogButtonClick(Sender: TObject);
begin
  MemoLog.Clear;
end;

procedure TMainForm.ClearProxiesButtonClick(Sender: TObject);
begin
  FProxyCheckerService.Proxies.Clear;
end;

procedure TMainForm.ClientIpFetchEventHandler(Sender: TObject; const FetchResult: TIpFetchResult);
begin
  TThread.Synchronize(nil,
  procedure ()
  begin
    if FetchResult.Status = TIpFetchStatus.Success then
    begin
      Label32.Caption := 'Client ip: ' + FetchResult.Ip;

      FProxyCheckerService.ClientIp := FetchResult.Ip;
    end
      else
    begin
      Label32.Caption := 'Client ip: error';
    end;

  end);
end;

procedure TMainForm.CopyProxy1Click(Sender: TObject);
var
  ProxyEx: TProxyEx;
begin
  if GetSelectedProxy(ProxyEx) then
  begin
    Clipboard.Open;
    Clipboard.AsText := ProxyEx.Proxy.AsString;
    Clipboard.Close;
  end;
end;

procedure TMainForm.CreateDirectoryIfNotExist(const Value: string);
begin
  if not TDirectory.Exists(Value) then
    TDirectory.CreateDirectory(Value);
end;

procedure TMainForm.AddGoodProxiesToTable;

  procedure AddFromList(List: TList<TProxyEx>);
  var
    ProxyEx: TProxyEx;
  begin
    for ProxyEx in List do
    begin
      AddProxyToTable(ProxyEx);
    end;
  end;

begin
  ProxiesVirtualStringTree.Clear;

  AddFromList(FProxyCheckerService.Results.HttpList);
  AddFromList(FProxyCheckerService.Results.Socks4List);
  AddFromList(FProxyCheckerService.Results.Socks5List);

end;

procedure TMainForm.AddProxiesButtonClick(Sender: TObject);
begin
  AddProxiesForm.ShowModal(TAddPlace.List);
end;

procedure TMainForm.AddProxyListToTable(const Value: TProxyList);
var
  Proxy: TProxy;
begin
  ProxiesVirtualStringTree.BeginUpdate;

  for Proxy in Value do
  begin
    AddProxyToTable(Proxy);
  end;

  ProxiesVirtualStringTree.EndUpdate;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FProxyCheckerService.IsRunning or FProxyGrabberService.IsRunning or FScheduler.IsRunning then
  begin
    CanClose := False;
    ShowErrorMessageBox('Stop working before closing the app.');
  end;


end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  AppPath := ExtractFilePath(ParamStr(0));

  TThreadPool.Default.SetMaxWorkerThreads(128);

  TSettings.Load(AppPath + SETTINGS_FILE_NAME);

  FTimer := TTimer.Create(Self);
  FTimer.OnTimer := TimerEventHandler;
  FTimer.Interval := 500;
  FTimer.Enabled := True;

  Logger.OnLog := LogEventHandler;

  FProxyGeoFetcher := TProxyGeoFetcher.Create(AppPath + IP_GEO_FILE_NAME);

  FClientIpFetcher := TClientIpFetcher.Create;
  FClientIpFetcher.OnFetch := ClientIpFetchEventHandler;

  FProxyGrabberService := TProxyGrabberService.Create;
  FProxyGrabberService.OnStart := StartProxyGrabberEventHandler;
  FProxyGrabberService.OnFinish := FinishProxyGrabberEventHandler;

  FProxyCheckerService := TProxyCheckerService.Create;
  FProxyCheckerService.OnStart := StartProxyCheckerEventHandler;
  FProxyCheckerService.OnRun := RunProxyCheckerEventHandler;
  FProxyCheckerService.OnFinish := FinishProxyCheckerEventHandler;
  FProxyCheckerService.Proxies.OnChange := ProxyListChangeEventHandler;

  FScheduler := TScheduler.Create(FProxyCheckerService, FProxyGrabberService);

  FLocalServer := TLocalServer.Create(FProxyCheckerService.Results);
  FLocalServer.OnStart := StartLocalServerEventHandler;

  ProxySourcesVirtualStringTree.NodeDataSize := SizeOf(TProxySource);
  ProxiesVirtualStringTree.NodeDataSize := SizeOf(TProxyEx);

  Database := TDatabase.Create;
  Database.ProxySourcesTable.OnChange := ProxySourcesTableChangeEventHandler;
  Database.CheckerPresetsTable.OnChange := CheckerPresetsTableChangeEventHandler;
  Database.Connect(AppPath + DATABASE_FILE_NAME);

  LoadCheckerPresets;
  LoadProxySources;
  LoadSettings;
  UpdateLocalServerAddress;

  PageControl.ActivePageIndex := 0;

  Label26.Caption := 'ProxyMaster v ' + APP_VERSION;

  Logger.Log('App started.');

end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  TSettings.Save;

  Database.Free;

  FScheduler.Free;
  FLocalServer.Free;
  FClientIpFetcher.Free;
  FProxyGeoFetcher.Free;
  FProxyCheckerService.Free;
  FProxyGrabberService.Free;

end;

function TMainForm.GetSelectedCheckerPreset(out Value: TCheckerPreset): Boolean;
var
  s: string;
begin
  Result := False;

  if CheckerPresetsComboBox.ItemIndex >= 0 then
  begin
    s := CheckerPresetsComboBox.Text;

    Result := Database.CheckerPresetsTable.GetByName(s, Value);
  end;
end;

function TMainForm.GetSelectedSchedulerCheckerPreset(out Value: TCheckerPreset): Boolean;
var
  s: string;
begin
  Result := False;

  if ComboBox1.ItemIndex >= 0 then
  begin
    s := ComboBox1.Text;

    Result := Database.CheckerPresetsTable.GetByName(s, Value);
  end;
end;

function TMainForm.GetSelectedProxy(out Value: TProxyEx): Boolean;
var
  Node: PVirtualNode;
  Data: PProxyEx;
begin
  Result := False;

  Node := ProxiesVirtualStringTree.GetFirstSelected;

  if not Assigned(Node) then
    Exit;

  Data := ProxiesVirtualStringTree.GetNodeData(Node);
  if Assigned(Data) then
  begin
    Value := Data^;
    Result := True;
  end;
end;

function TMainForm.GetSelectedProxySource(out Value: TProxySource): Boolean;
var
  Node: PVirtualNode;
  Data: PProxySource;
begin
  Result := False;

  Node := ProxySourcesVirtualStringTree.GetFirstSelected;

  if not Assigned(Node) then
    Exit;

  Data := ProxySourcesVirtualStringTree.GetNodeData(Node);
  if Assigned(Data) then
  begin
    Result := Database.ProxySourcesTable.GetById(Data.Id, Value);
  end;
end;

procedure TMainForm.ProxySourcesTableChangeEventHandler(Sender: TObject);
begin
  LoadProxySources;
end;

procedure TMainForm.ProxySourcesVirtualStringTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PProxySource;
begin
  Data := Sender.GetNodeData(Node);
  if Assigned(Data) then
    Finalize(Data^);
end;

procedure TMainForm.ProxySourcesVirtualStringTreeGetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVstTextType; var CellText: string);
var
  Data: PProxySource;
begin
  Data := Sender.GetNodeData(Node);
  if Assigned(Data) then
  case Column of
    0: CellText := Data.Id.ToString;
    1: CellText := Data.Url;
    2: CellText := Data.CollectedLastTime.ToString;

    else
      CellText := '';
  end;

end;

procedure TMainForm.ProxySourcesVirtualStringTreeStateChange(
  Sender: TBaseVirtualTree; Enter, Leave: TVirtualTreeStates);
begin
  Label18.Caption := 'Count: ' + ProxySourcesVirtualStringTree.TotalCount.ToString;
end;

procedure TMainForm.LoadCheckerPresets;

  procedure FillComboBox(Value: TComboBox);
  var
    Preset: TCheckerPreset;
  begin
    Value.Clear;

    Database.CheckerPresetsTable.First;
    while Database.CheckerPresetsTable.GetNext(Preset) do
    begin
      Value.Items.Add(Preset.Name);
    end;

    if Value.Items.Count > 0 then
      Value.ItemIndex := 0;
  end;

begin
  FillComboBox(CheckerPresetsComboBox);
  FillComboBox(ComboBox1);

end;

procedure TMainForm.LoadProxySources;
var
  ProxySource: TProxySource;
  Node: PVirtualNode;
  Data: PProxySource;
begin
  ProxySourcesVirtualStringTree.Clear;
  ProxySourcesVirtualStringTree.BeginUpdate;

  Database.ProxySourcesTable.First;
  while Database.ProxySourcesTable.GetNext(ProxySource) do
  begin
    Node := ProxySourcesVirtualStringTree.AddChild(nil);
    Data := ProxySourcesVirtualStringTree.GetNodeData(Node);
    if Assigned(Data) then
    begin
      Data^ := ProxySource;
    end;

  end;

  ProxySourcesVirtualStringTree.EndUpdate;

end;

procedure TMainForm.LoadSettings;
begin
  NumberBox1.ValueInt := TSettings.Data.CheckerThreadCount;
  NumberBox2.ValueInt := TSettings.Data.GrabberThreadCount;
  NumberBox4.ValueInt := TSettings.Data.SchedulerPeriod;
  NumberBox3.ValueInt := TSettings.Data.LocalServerPort;

  CheckBox3.Checked := TSettings.Data.AddGrabbedProxiesToTable;
  CheckBox1.Checked := TSettings.Data.SaveGrabbedProxiesToFile;



end;

procedure TMainForm.LogEventHandler(Sender: TObject; const LogData: TLogData);
begin
  MemoLog.Lines.Add(LogData.GetFormatted);
end;

function TMainForm.MillisecondsToSeconds(const Value: Cardinal): Cardinal;
begin
  Result := Value * 1000 * 60;
end;

procedure TMainForm.NumberBox1ChangeValue(Sender: TObject);
begin
  TSettings.Data.CheckerThreadCount := NumberBox1.ValueInt;
end;

procedure TMainForm.NumberBox2ChangeValue(Sender: TObject);
begin
  TSettings.Data.GrabberThreadCount := NumberBox2.ValueInt;
end;

procedure TMainForm.NumberBox3ChangeValue(Sender: TObject);
begin
  TSettings.Data.LocalServerPort := NumberBox3.ValueInt;

  UpdateLocalServerAddress;
end;

procedure TMainForm.NumberBox4ChangeValue(Sender: TObject);
begin
  TSettings.Data.SchedulerPeriod := NumberBox4.ValueInt;
end;

procedure TMainForm.ProxiesVirtualStringTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PProxyEx;
begin
  Data := Sender.GetNodeData(Node);
  if Assigned(Data) then
    Finalize(Data^);
end;

procedure TMainForm.ProxiesVirtualStringTreeGetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVstTextType; var CellText: string);
var
  Data: PProxyEx;
begin
  Data := Sender.GetNodeData(Node);
  if Assigned(Data) then
  case Column of
    0: CellText := (Sender.AbsoluteIndex(Node) + 1).ToString;
    1: CellText := Data.Proxy.AsString;
    2: CellText := PROXY_PROTOCOL_STRING[Data.Proxy.Protocol];
    3: CellText := ANONIMOUS_LEVEL_STRING[Data.AnonymityLevel];
    4: CellText := Data.Country;
    5: CellText := Data.City;
    6: begin
         if Data.Ping = 0 then
           CellText := ''
         else
           CellText := Format('%.2f', [Data.Ping]);
       end;

    else
      CellText := '';
  end;

end;

procedure TMainForm.ProxiesVirtualStringTreeStateChange(
  Sender: TBaseVirtualTree; Enter, Leave: TVirtualTreeStates);
begin
  Label19.Caption := 'Count: ' + ProxiesVirtualStringTree.TotalCount.ToString;
end;

procedure TMainForm.ProxyListChangeEventHandler(Sender: TObject; const Action: TProxyList.TAction);
begin
  Label7.Caption := 'Unknown: ' + FProxyCheckerService.Proxies.Counters.Unknown.ToString;
  Label4.Caption := 'Http(s): ' + FProxyCheckerService.Proxies.Counters.Http.ToString;
  Label5.Caption := 'Socks4: ' + FProxyCheckerService.Proxies.Counters.Socks4.ToString;
  Label6.Caption := 'Socks5: ' + FProxyCheckerService.Proxies.Counters.Socks5.ToString;
  Label3.Caption := 'Total: ' + FProxyCheckerService.Proxies.Counters.Total.ToString;

  if Action = TProxyList.TAction.Add then
  begin
    Logger.Log('Unique proxies added: ' + FProxyCheckerService.Proxies.LastTimeAddedCount.ToString);

  end;

end;

procedure TMainForm.SaveCheckedProxiesToFile;
var
  Path: string;
begin
  Path := AppPath + CHECKER_RESULTS_FOLDER + '\';

  CreateDirectoryIfNotExist(Path);

  Path := Path + FormatDateTime('dd.mm.yy hh.nn.ss', Now) + '\';

  CreateDirectoryIfNotExist(Path);

  if FProxyCheckerService.Preset.SaveHttp then
    FProxyCheckerService.Results.SaveGoodToFile(Path + 'Http.txt', TProxy.TProtocol.Http);

  if FProxyCheckerService.Preset.SaveSocks4 then
    FProxyCheckerService.Results.SaveGoodToFile(Path + 'Socks4.txt', TProxy.TProtocol.Socks4);

  if FProxyCheckerService.Preset.SaveSocks5 then
    FProxyCheckerService.Results.SaveGoodToFile(Path + 'Socks5.txt', TProxy.TProtocol.Socks5);

  if FProxyCheckerService.Preset.SaveBad then
    FProxyCheckerService.Results.SaveBadToFile(Path + 'Bad.txt');
end;

procedure TMainForm.SaveGrabbedProxiesToFile;
var
  Path: string;
begin
  Path := AppPath + GRABBER_RESULTS_FOLDER + '\';

  CreateDirectoryIfNotExist(Path);

  Path := Path + FormatDateTime('dd.mm.yy hh.nn.ss', Now) + '.txt';

  FProxyGrabberService.SaveResultsToFile(Path);
end;

procedure TMainForm.SetStatusBarText(const Index: Integer; const Text: string);
begin
  StatusBar.Panels.Items[Index].Text := Text;
end;

procedure TMainForm.ShowErrorMessageBox(const Text: string);
begin
  MessageBox(Handle, PChar(Text), PChar('Error'), MB_OK or MB_ICONERROR);
end;

procedure TMainForm.ShowMessageBox(const Text, Title: string);
begin
  MessageBox(Handle, PChar(Text), PChar(Title), MB_OK or MB_ICONINFORMATION);
end;

function TMainForm.ShowQuestionBox(const Text, Title: string): Boolean;
begin
  Result := MessageBox(Handle, PChar(Text), PChar(Title),
    MB_YESNO or MB_ICONQUESTION) = IDYES;
end;

procedure TMainForm.StartProxyGrabberEventHandler(Sender: TObject);
var
  ProxySource: TProxySource;
begin
  FProxyGrabberService.ProxySources.Clear;

  Database.ProxySourcesTable.First;
  while Database.ProxySourcesTable.GetNext(ProxySource) do
  begin
    FProxyGrabberService.ProxySources.Add(ProxySource);
  end;

  UpdateGrabberStats;

  Logger.Log('[Proxy grabber] Started.');
end;

procedure TMainForm.FinishProxyGrabberEventHandler(Sender: TObject);
var
  ProxySource: TProxySource;
  Proxy: TProxy;
begin
  Database.ProxySourcesTable.EnableOnChange := False;

  for ProxySource in FProxyGrabberService.ProxySources do
    Database.ProxySourcesTable.Update(ProxySource);

  Database.ProxySourcesTable.EnableOnChange := True;

  LoadProxySources;

  UpdateGrabberStats;

  if TSettings.Data.AddGrabbedProxiesToTable then
  begin
    ProxiesVirtualStringTree.Clear;
    ProxiesVirtualStringTree.BeginUpdate;

    for Proxy in FProxyGrabberService.Results.Values do
    begin
      AddProxyToTable(Proxy);
    end;

    ProxiesVirtualStringTree.EndUpdate;
  end;

  if TSettings.Data.SaveGrabbedProxiesToFile then
  begin
    SaveGrabbedProxiesToFile;
  end;

  Logger.LogF('[Proxy grabber] Finished. Grabbed count %d.', [FProxyGrabberService.Results.Count]);

end;

procedure TMainForm.TimerEventHandler(Sender: TObject);
var
  s: string;
begin
  { Checker }
  if FProxyCheckerService.IsRunning then
  begin
    s := 'Checker: running';
    UpdateCheckerStats;
  end
    else
  begin
    s := 'Checker: not running';
  end;

  SetStatusBarText(0, s);

  { Grabber }
  if FProxyGrabberService.IsRunning then
  begin
    s := 'Grabber: running';
    UpdateGrabberStats;
  end
    else
  begin
    s := 'Grabber: not running';
  end;

  SetStatusBarText(1, s);

  { Local server }
  if FLocalServer.IsRunning then
    Label23.Caption := 'Status: running'
  else
    Label23.Caption := 'Status: not running';

  { Scheduler }
  if FScheduler.IsRunning then
  begin
    Label29.Caption := 'Status: running';
    Label33.Caption := 'Remain: ' + FScheduler.RemainTimeStamp;
    s := 'Scheduler: running';
  end
    else
  begin
    Label29.Caption := 'Status: not running';
    Label33.Caption := 'Remain: -';
    s := 'Scheduler: not running';
  end;

  SetStatusBarText(2, s);

end;

procedure TMainForm.UpdateCheckerStats;
begin
  Label10.Caption := 'Online: ' + FProxyCheckerService.Statistics.OnlineCount.ToString;
  Label11.Caption := 'Good: ' + FProxyCheckerService.Statistics.GoodCount.ToString;
  Label12.Caption := 'Bad: ' + FProxyCheckerService.Statistics.BadCount.ToString;
  Label13.Caption := 'Http(s): ' + FProxyCheckerService.Statistics.HttpCount.ToString;
  Label14.Caption := 'Socks4: ' + FProxyCheckerService.Statistics.Socks4Count.ToString;
  Label15.Caption := 'Socks5: ' + FProxyCheckerService.Statistics.Socks5Count.ToString;

  Label8.Caption := Format('Checked: %d / %d',
    [FProxyCheckerService.Statistics.CheckedCount, FProxyCheckerService.Statistics.TotalCount]);
  Label21.Caption := Format('Progress: %.2f %%', [FProxyCheckerService.Statistics.GetProgress]);
  Label22.Caption := Format('Active threads: %d / %d',
    [FProxyCheckerService.Threads.ActiveCount, FProxyCheckerService.Threads.Count]);

  CheckerProgressBar.Position := Round(FProxyCheckerService.Statistics.GetProgress * 10);


end;

procedure TMainForm.UpdateGrabberStats;
var
  s: string;
begin
  Label20.Caption := Format('Processed: %d / %d',
    [FProxyGrabberService.Statistics.Left, FProxyGrabberService.Statistics.Total]);


end;

procedure TMainForm.UpdateLocalServerAddress;
var
  Paths: TArray<string>;
begin
  FLocalServer.Port := TSettings.Data.LocalServerPort;

  Paths := FLocalServer.GetPathList;

  Edit1.Text := FLocalServer.BindedAddress + Paths[0];
  Edit2.Text := FLocalServer.BindedAddress + Paths[1];
  Edit3.Text := FLocalServer.BindedAddress + Paths[2];
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

end.
