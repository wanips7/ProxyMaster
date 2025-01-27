unit uProxyCheckerService;

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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Threading,
  System.SyncObjs, System.Generics.Defaults, System.Generics.Collections, uProxy, uTypes,
  uProxyList, uProxyChecker, uHttpClient, uProxyGeo;

type
  PStatistics = ^TStatistics;
  TStatistics = record
  public
    CheckedCount: Integer;
    TotalCount: Integer;
    BadCount: Integer;
    OnlineCount: Integer;
    GoodCount: Integer;
    HttpCount: Integer;
    Socks4Count: Integer;
    Socks5Count: Integer;
    procedure Clear;
    function GetProgress: Single;
    function GetRemainCount: Integer;
  end;

type
  EProxyCheckerServiceError = class(Exception);

type
  TOnResultEvent = procedure(Sender: TObject; const ProxyEx: TProxyEx) of object;

type
  TWorkerThreads = class;
  TWorkerThread = class;
  TProxyCheckerService = class;

  TWorkerThread = class(TThread)
  strict private
    FId: Integer;
    FStop: PBoolean;
    FStatistics: PStatistics;
    FProxies: TProxyList;
    FActiveCount: PInteger;
    FProxyChecker: TProxyChecker;
    FPreset: PCheckerPreset;
    FResults: TProxyResultList;
    FOnResult: TOnResultEvent;
    FIndex: PInteger;
    procedure UpdateStatistics(const ProxyEx: TProxyEx);
    procedure DoResult(const ProxyEx: TProxyEx);
  protected
    procedure DoTerminate; override;
    procedure Execute; override;
  public
    property Id: Integer read FId;
    property ProxyChecker: TProxyChecker read FProxyChecker;
    constructor Create(const Id: Integer; ActiveCount: PInteger; Stop: PBoolean;
      Statistics: PStatistics; Proxies: TProxyList; Preset: PCheckerPreset; Index: PInteger;
      Results: TProxyResultList; OnResult: TOnResultEvent; const ClientIp: string; ProxyGeoFetcher: TProxyGeoFetcher);
    destructor Destroy; override;
  end;

  TWorkerThreadList = TArray<TWorkerThread>;

  TWorkerThreads = class
  public const
    MAX_COUNT = 1000;
  strict private
    FList: TWorkerThreadList;
    FActiveCount: Integer;
    FCount: Integer;
    FOwner: TProxyCheckerService;
    FStop: Boolean;
    FIndex: Integer;
  protected
    procedure FreeThreads;
    property List: TWorkerThreadList read FList;
    procedure Start(const Count: Integer);
    procedure Stop;
  public
    property ActiveCount: Integer read FActiveCount;
    property Count: Integer read FCount;
    constructor Create(const Owner: TProxyCheckerService);
    destructor Destroy; override;
    function HasActive: Boolean;
  end;

  TProxyCheckerService = class
  strict private const
    MONITOR_RATE = 500;
    MAX_CONNECT_TIC = 10000;
  strict private
    FOnStart: TNotifyEvent;
    FOnFinish: TNotifyEvent;
    FOnResult: TOnResultEvent;
    FOnRun: TNotifyEvent;
    FStatistics: TStatistics;
    FWorkerThreads: TWorkerThreads;
    FProxies: TProxyList;
    FPreset: TCheckerPreset;
    FResults: TProxyResultList;
    FMainTask: ITask;
    FMonitorTask: ITask;
    FStartDateTime: TDateTime;
    FFinishEvent: TEvent;
    FClientIp: string;
    procedure DoStart;
    procedure DoFinish;
    procedure DoRun;
    procedure StartMonitorTask;
    procedure RunMainTask(const ThreadCount: Integer);
    procedure CheckCanStart(const ThreadCount: Integer);
    procedure RaiseError(const Text: string);
    procedure RaiseErrorF(const Text: string; const Args: array of const);
  protected
    FProxyGeoFetcher: TProxyGeoFetcher;
  public
    property OnStart: TNotifyEvent read FOnStart write FOnStart;
    property OnFinish: TNotifyEvent read FOnFinish write FOnFinish;
    property OnRun: TNotifyEvent read FOnRun write FOnRun;
    property OnResult: TOnResultEvent read FOnResult write FOnResult;
    property ClientIp: string read FClientIp write FClientIp;
    property FinishEvent: TEvent read FFinishEvent;
    property Proxies: TProxyList read FProxies;
    property Preset: TCheckerPreset read FPreset write FPreset;
    property Results: TProxyResultList read FResults;
    property Statistics: TStatistics read FStatistics;
    property StartDateTime: TDateTime read FStartDateTime;
    property Threads: TWorkerThreads read FWorkerThreads;
    constructor Create(ProxyGeoFetcher: TProxyGeoFetcher);
    destructor Destroy; override;
    procedure Start(const ThreadCount: Integer);
    procedure Stop;
    function IsRunning: Boolean;
  end;

implementation

uses
  uUtils;

{ TStatistics }

procedure TStatistics.Clear;
begin
  Self := default(TStatistics);
end;

function TStatistics.GetProgress: Single;
begin
  Result := 0;

  if TotalCount > 0 then
    Result := (CheckedCount * 100) / TotalCount;
end;

function TStatistics.GetRemainCount: Integer;
begin
  Result := TotalCount - CheckedCount;
end;

{ TWorkerThread }

constructor TWorkerThread.Create(const Id: Integer; ActiveCount: PInteger; Stop: PBoolean;
  Statistics: PStatistics; Proxies: TProxyList; Preset: PCheckerPreset; Index: PInteger;
  Results: TProxyResultList; OnResult: TOnResultEvent; const ClientIp: string; ProxyGeoFetcher: TProxyGeoFetcher);
begin
  inherited Create(False);

  FreeOnTerminate := False;
  FStop := Stop;
  FId := Id;
  FActiveCount := ActiveCount;
  FIndex := Index;
  FStatistics := Statistics;

  FProxies := Proxies;
  FPreset := Preset;
  FResults := Results;

  FProxyChecker := TProxyChecker.Create(ProxyGeoFetcher);
  FProxyChecker.Preset := Preset^;
  FProxyChecker.ClientIP := ClientIp;

  FOnResult := OnResult;

  AtomicIncrement(FActiveCount^);
end;

destructor TWorkerThread.Destroy;
begin
  FProxyChecker.Free;

  inherited;
end;

procedure TWorkerThread.DoResult(const ProxyEx: TProxyEx);
begin
  if Assigned(FOnResult) then
    FOnResult(Self, ProxyEx);
end;

procedure TWorkerThread.DoTerminate;
begin
  inherited;

  AtomicDecrement(FActiveCount^);
end;

procedure TWorkerThread.Execute;
var
  Index: Integer;
  ProxyEx: TProxyEx;
begin
  while True do
  begin
    Index := AtomicIncrement(FIndex^);
    if (Index >= FProxies.Counters.Total) or FStop^ then
      Break;

    ProxyEx := FProxyChecker.Check(FProxies.Items[Index]);

    UpdateStatistics(ProxyEx);

    DoResult(ProxyEx);

    FResults.Add(ProxyEx);

  end;
end;

procedure TWorkerThread.UpdateStatistics(const ProxyEx: TProxyEx);
begin
  case ProxyEx.Status of
    TProxyStatus.Bad:
    begin
      AtomicIncrement(FStatistics.BadCount);
    end;

    TProxyStatus.Online:
    begin
      AtomicIncrement(FStatistics.OnlineCount);
    end;

    TProxyStatus.Good:
    begin
      AtomicIncrement(FStatistics.GoodCount);

      case ProxyEx.Proxy.Protocol of
        TProxy.TProtocol.Http:
        begin
          AtomicIncrement(FStatistics.HttpCount);
        end;

        TProxy.TProtocol.Socks4:
        begin
          AtomicIncrement(FStatistics.Socks4Count);
        end;

        TProxy.TProtocol.Socks5:
        begin
          AtomicIncrement(FStatistics.Socks5Count);
        end;
      end;
    end;
  end;

  AtomicIncrement(FStatistics.CheckedCount);
end;

{ TWorkerThreads }

constructor TWorkerThreads.Create(const Owner: TProxyCheckerService);
begin
  FStop := False;
  FActiveCount := 0;
  FCount := 0;
  FList := [];
  FOwner := Owner;
  FIndex := -1;
end;

destructor TWorkerThreads.Destroy;
begin

  inherited;
end;

procedure TWorkerThreads.FreeThreads;
var
  i: Integer;
begin
  if Length(FList) > 0 then
    for i := 0 to High(FList) do
      FreeAndNil(FList[i]);

  FList := [];
end;

function TWorkerThreads.HasActive: Boolean;
begin
  Result := FActiveCount > 0;
end;

procedure TWorkerThreads.Start(const Count: Integer);
var
  i: Integer;
begin
  FStop := False;
  FActiveCount := 0;
  FCount := Count;
  FIndex := -1;

  SetLength(FList, Count);

  if Length(FList) > 0 then
    for i := 0 to High(FList) do
      FList[i] := TWorkerThread.Create(i, @FActiveCount, @FStop, @FOwner.Statistics, FOwner.Proxies,
      @FOwner.Preset, @FIndex, FOwner.Results, FOwner.OnResult, FOwner.ClientIp, FOwner.FProxyGeoFetcher);
end;

procedure TWorkerThreads.Stop;
begin
  FStop := True;
end;

{ TProxyCheckerService }

constructor TProxyCheckerService.Create(ProxyGeoFetcher: TProxyGeoFetcher);
begin
  FProxyGeoFetcher := ProxyGeoFetcher;
  FWorkerThreads := TWorkerThreads.Create(Self);
  FProxies := TProxyList.Create;
  FResults := TProxyResultList.Create;
  FStatistics.Clear;
  FFinishEvent := TEvent.Create;
  FStartDateTime := 0;
  FClientIp := '';
  FOnStart := nil;
  FOnFinish := nil;
  FOnResult := nil;
  FOnRun := nil;
end;

destructor TProxyCheckerService.Destroy;
begin
  FFinishEvent.Free;
  FResults.Free;
  FProxies.Free;
  FWorkerThreads.Free;

  inherited;
end;

procedure TProxyCheckerService.RunMainTask(const ThreadCount: Integer);
begin
  FMainTask := TTask.Run
 (procedure()
  begin
    FWorkerThreads.Start(ThreadCount);

    StartMonitorTask;
    FMonitorTask.Wait;

    FWorkerThreads.FreeThreads;

    TThread.Synchronize(nil, DoFinish);

    FFinishEvent.SetEvent;
    FFinishEvent.ResetEvent;
  end);
end;

procedure TProxyCheckerService.DoFinish;
begin
  if Assigned(FOnFinish) then
    FOnFinish(Self);
end;

procedure TProxyCheckerService.DoRun;
begin
  if Assigned(FOnRun) then
    FOnRun(Self);
end;

procedure TProxyCheckerService.DoStart;
begin
  if Assigned(FOnStart) then
    FOnStart(Self)
end;

function TProxyCheckerService.IsRunning: Boolean;
begin
  Result := Assigned(FMainTask) and (FMainTask.Status = TTaskStatus.Running);
end;

procedure TProxyCheckerService.RaiseError(const Text: string);
begin
  raise EProxyCheckerServiceError.Create(Text);
end;

procedure TProxyCheckerService.RaiseErrorF(const Text: string; const Args: array of const);
begin
  RaiseError(Format(Text, Args));
end;

procedure TProxyCheckerService.CheckCanStart(const ThreadCount: Integer);
begin
  if FProxies.IsEmpty then
    RaiseError('Start error: proxy list is empty.');

  if not InRange(ThreadCount, 1, TWorkerThreads.MAX_COUNT) then
    RaiseErrorF('Start error: thread count value must be in range 1 .. %d.', [TWorkerThreads.MAX_COUNT]);

  if not FPreset.IsValid then
    RaiseError('Start error: preset is invalid.');
end;

procedure TProxyCheckerService.Start(const ThreadCount: Integer);
begin
  if IsRunning then
    Exit;

  TThread.Synchronize(nil, DoStart);

  CheckCanStart(ThreadCount);

  FResults.Clear;
  FStatistics.Clear;
  FStatistics.TotalCount := FProxies.Counters.Total;
  FStartDateTime := Now;

  TThread.Synchronize(nil, DoRun);

  RunMainTask(ThreadCount);

end;

procedure TProxyCheckerService.StartMonitorTask;
begin
  FMonitorTask := TTask.Run
 (procedure()
  var
    WorkerThread: TWorkerThread;
    Tic: Int64;
  begin
    while FWorkerThreads.HasActive do
    begin
      Tic := GetTickCount;

      for WorkerThread in FWorkerThreads.List do
        if WorkerThread.ProxyChecker.IsRunning then
        begin
          if (Tic - WorkerThread.ProxyChecker.ConnectTic) > MAX_CONNECT_TIC then
            WorkerThread.ProxyChecker.CloseConnection;

          Sleep(0);
        end;

      Sleep(MONITOR_RATE);
    end;

  end);
end;

procedure TProxyCheckerService.Stop;
begin
  if IsRunning then
  begin
    FWorkerThreads.Stop;
  end;
end;

end.
