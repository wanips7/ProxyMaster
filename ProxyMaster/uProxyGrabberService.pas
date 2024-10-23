unit uProxyGrabberService;

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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Threading, System.SyncObjs,
  Rapid.Generics, System.Net.HttpClient, uProxy, uTypes, uProxyParser, uProxyGrabber;

{$SCOPEDENUMS ON}

type
  PStatistics = ^TStatistics;
  TStatistics = record
  public
    Left: Integer;
    Total: Integer;
  end;

type
  EEmailCheckerError = class(Exception);

type
  TProxyGrabberService = class
  strict private const
    MAX_THREAD_COUNT = 100;
  strict private
    FOnStart: TNotifyEvent;
    FOnFinish: TNotifyEvent;
    FOnRun: TNotifyEvent;
    FStatistics: TStatistics;
    FLock: TCriticalSection;
    FTasks: TArray<ITask>;
    FProxySources: TList<TProxySource>;
    FResults: TDictionary<Int64, TProxy>;
    FMainTask: ITask;
    FStop: Boolean;
    FStartDateTime: TDateTime;
    FFinishEvent: TEvent;
    procedure DoStart;
    procedure DoFinish;
    procedure DoRun;
    procedure RunMainTask(const ThreadCount: Integer);
    procedure CheckCanStart(const ThreadCount: Integer);
    procedure RaiseError(const Text: string);
    procedure RaiseErrorF(const Text: string; const Args: array of const);
  public
    property OnStart: TNotifyEvent read FOnStart write FOnStart;
    property OnFinish: TNotifyEvent read FOnFinish write FOnFinish;
    property OnRun: TNotifyEvent read FOnRun write FOnRun;
    property FinishEvent: TEvent read FFinishEvent;
    property Statistics: TStatistics read FStatistics;
    property StartDateTime: TDateTime read FStartDateTime;
    property ProxySources: TList<TProxySource> read FProxySources;
    property Results: TDictionary<Int64, TProxy> read FResults;
    constructor Create;
    destructor Destroy; override;
    procedure SaveResultsToFile(const FileName: string);
    procedure Start(const ThreadCount: Integer);
    procedure Stop;
    function IsRunning: Boolean;
  end;

implementation

uses
  uUtils;

{ TProxyGrabberService }

constructor TProxyGrabberService.Create;
begin
  FStatistics := default(TStatistics);
  FFinishEvent := TEvent.Create;
  FStartDateTime := 0;
  FStop := False;
  FOnStart := nil;
  FOnFinish := nil;
  FOnRun := nil;
  FProxySources := TList<TProxySource>.Create;
  FResults := TDictionary<Int64, TProxy>.Create;
  FLock := TCriticalSection.Create;


end;

destructor TProxyGrabberService.Destroy;
begin
  FFinishEvent.Free;
  FProxySources.Free;
  FResults.Free;
  FLock.Free;

  inherited;
end;

procedure TProxyGrabberService.RunMainTask(const ThreadCount: Integer);
begin
  FMainTask := TTask.Run
 (procedure()
  var
    i: Integer;
    SourceIndex: Integer;
  begin
    SourceIndex := -1;
    SetLength(FTasks, ThreadCount);

    for i := 0 to High(FTasks) do
    begin
      FTasks[i] := TTask.Run
     (procedure ()
      var
        Index: Integer;
        ProxyGrabber: TProxyGrabber;
        Proxy: TProxy;
      begin
        ProxyGrabber := TProxyGrabber.Create;

        while True do
        begin
          Index := AtomicIncrement(SourceIndex);
          if (Index >= FProxySources.Count) or FStop then
            Break;

          ProxyGrabber.Grab(FProxySources[Index]);

          if not ProxyGrabber.Results.IsEmpty then
          begin
            FProxySources.List[Index].CollectedLastTime := ProxyGrabber.Results.Count;

            FLock.Enter;
            for Proxy in ProxyGrabber.Results.Values do
            begin
              FResults.AddOrSetValue(Proxy.AsInt64, Proxy);
            end;
            FLock.Leave;

          end;

          AtomicIncrement(FStatistics.Left);
        end;

        ProxyGrabber.Free;

      end);

    end;

    TTask.WaitForAll(FTasks);

    TThread.Synchronize(nil, DoFinish);

    FFinishEvent.SetEvent;
    FFinishEvent.ResetEvent;
  end);
end;

procedure TProxyGrabberService.DoFinish;
begin
  if Assigned(FOnFinish) then
    FOnFinish(Self);
end;

procedure TProxyGrabberService.DoRun;
begin
  if Assigned(FOnRun) then
    FOnRun(Self);
end;

procedure TProxyGrabberService.DoStart;
begin
  if Assigned(FOnStart) then
    FOnStart(Self)
end;

function TProxyGrabberService.IsRunning: Boolean;
begin
  Result := Assigned(FMainTask) and (FMainTask.Status = TTaskStatus.Running);
end;

procedure TProxyGrabberService.RaiseError(const Text: string);
begin
  raise EEmailCheckerError.Create(Text);
end;

procedure TProxyGrabberService.RaiseErrorF(const Text: string; const Args: array of const);
begin
  RaiseError(Format(Text, Args));
end;

procedure TProxyGrabberService.CheckCanStart(const ThreadCount: Integer);
begin
  if not InRange(ThreadCount, 1, MAX_THREAD_COUNT) then
    RaiseErrorF('Start error: thread count value must be in range 1 .. %d.', [MAX_THREAD_COUNT]);

  if FProxySources.Count = 0 then
    RaiseError('Start error: proxy sources is empty.');
end;

procedure TProxyGrabberService.SaveResultsToFile(const FileName: string);
var
  List: TStringList;
  Proxy: TProxy;
begin
  if FResults.Count = 0 then
    Exit;

  List := TStringList.Create;

  for Proxy in FResults.Values do
    List.Add(Proxy.AsString);

  List.SaveToFile(FileName);
  List.Free;
end;

procedure TProxyGrabberService.Start(const ThreadCount: Integer);
begin
  if IsRunning then
    Exit;

  TThread.Synchronize(nil, DoStart);

  CheckCanStart(ThreadCount);

  FResults.Clear;
  FStop := False;

  FStatistics := default(TStatistics);
  FStatistics.Total := FProxySources.Count;

  FStartDateTime := Now;

  TThread.Synchronize(nil, DoRun);

  RunMainTask(ThreadCount);

end;

procedure TProxyGrabberService.Stop;
begin
  if IsRunning then
  begin
    FStop := True;
  end;
end;

end.
