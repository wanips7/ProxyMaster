unit uProxyAllocator;

interface
  
uses
  Winapi.Windows, System.SysUtils, System.SyncObjs, Rapid.Generics, uProxy;

type
  TProxyAllocator = class;

  PProxyData = ^TProxyData;
  TProxyData = packed record
  public type
    TStatus = (Free, Sleeping, Busy);
  private
    FOwner: TProxyAllocator;
    FProxy: TProxy;
    FOfflineCounter: Integer;
    FWakeUpTic: Cardinal;
    FStatus: TStatus;
    procedure SetStatus(const Value: TStatus);
  public
    property Proxy: TProxy read FProxy;
    property Status: TStatus read FStatus;
    property OfflineCounter: Integer read FOfflineCounter;
    constructor Create(const Owner: TProxyAllocator; const Proxy: TProxy);
    procedure SetFree;
    procedure ResetOfflineCounter;
    procedure IncOfflineCounter;
    procedure Sleep(const Ms: Cardinal);
  end;

  TProxyAllocator = class
  public const
    MAX_OFFLINE_TIC = 10;
  public type
    TCounters = record
    public
      BusyCount: Integer;
      FreeCount: Integer;
      SleepingCount: Integer;
    end;

  strict private
    FLock: TCriticalSection;
    FList: TList<PProxyData>;
    FOfflineMax: Integer;
    function GetCount: Integer;
    function GetNextIndex: Integer;
    function GetNextProxy: PProxyData;
    procedure Filter;
    procedure Remove(const Index: Integer);
  protected
    FIndex: Integer;
    FCounters: TCounters;
    procedure Add(const ProxyData: TProxyData); inline;
  public
    property Count: Integer read GetCount;
    property Counters: TCounters read FCounters;
    constructor Create;
    destructor Destroy; override;
    function IsEmpty: Boolean;
    procedure Clear;
    function GetFreeProxy(out Proxy: PProxyData): Boolean;
    procedure SetOfflineMax(const Value: Integer);
    procedure Load(List: TList<TProxy>);
  end;

implementation

{ TProxyData }

constructor TProxyData.Create(const Owner: TProxyAllocator; const Proxy: TProxy);
begin
  Self := Default(TProxyData);
  FOwner := Owner;
  FStatus := TStatus.Free;
  FProxy := Proxy;
  FWakeUpTic := 0;
  ResetOfflineCounter;

  AtomicIncrement(FOwner.FCounters.FreeCount);
end;

procedure TProxyData.IncOfflineCounter;
begin
  Inc(FOfflineCounter);
end;

procedure TProxyData.SetFree;
begin
  SetStatus(TStatus.Free);
end;

procedure TProxyData.ResetOfflineCounter;
begin
  FOfflineCounter := 0;
end;

procedure TProxyData.SetStatus(const Value: TStatus);
begin
  if Value = FStatus then
    Exit;

  case FStatus of
    TStatus.Free:
      AtomicDecrement(FOwner.FCounters.FreeCount);

    TStatus.Sleeping:
      AtomicDecrement(FOwner.FCounters.SleepingCount);

    TStatus.Busy:
      AtomicDecrement(FOwner.FCounters.BusyCount);
  end;

  case Value of
    TStatus.Free:
      AtomicIncrement(FOwner.FCounters.FreeCount);

    TStatus.Sleeping:
      AtomicIncrement(FOwner.FCounters.SleepingCount);

    TStatus.Busy:
      AtomicIncrement(FOwner.FCounters.BusyCount);
  end;

  FStatus := Value;
end;

procedure TProxyData.Sleep(const Ms: Cardinal);
begin
  SetStatus(TStatus.Sleeping);
  FWakeUpTic := GetTickCount + Ms;
end;

{ TProxyAllocator }

procedure TProxyAllocator.Add(const ProxyData: TProxyData);
var
  Ptr: PProxyData;
begin
  New(Ptr);
  Ptr^ := ProxyData;
  FList.Add(Ptr);
end;

procedure TProxyAllocator.Clear;
var
  i: Integer;
begin
  if not IsEmpty then
    for i := 0 to FList.Count - 1 do
    begin
      Dispose(FList[i]);
    end;

  FList.Clear;
  FCounters := Default(TCounters);
  FIndex := 0;
end;

constructor TProxyAllocator.Create;
begin
  FLock := TCriticalSection.Create;
  FList := TList<PProxyData>.Create;

  Clear;

  SetOfflineMax(MAX_OFFLINE_TIC);
end;

destructor TProxyAllocator.Destroy;
begin
  Clear;

  FLock.Free;
  FList.Free;

  inherited;
end;

procedure TProxyAllocator.Filter;
var
  i: Integer;
  P: PProxyData;
  Tic: Cardinal;
  Count: Integer;
begin
  Tic := GetTickCount;

  i := 0;
  Count := GetCount;
  if Count > 0 then
    while i < Count do
    begin
      P := FList.List[i];

      if P.Status <> TProxyData.TStatus.Busy then
      begin
        if P.FOfflineCounter > FOfflineMax then
        begin
          Remove(i);
          Continue;
        end;

        if P.FWakeUpTic > Tic then
        begin
          P.SetStatus(TProxyData.TStatus.Free);
        end;
      end;

      Inc(i);
    end;
end;

function TProxyAllocator.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TProxyAllocator.GetFreeProxy(out Proxy: PProxyData): Boolean;
var
  CurrentProxy: PProxyData;
begin
  Result := False;
  Proxy := nil;

  if IsEmpty then
    Exit;

  FLock.Enter;

  { Get proxy }
  while FCounters.FreeCount > 0 do
  begin
    CurrentProxy := GetNextProxy;

    if CurrentProxy.FStatus = TProxyData.TStatus.Free then
    begin
      Proxy := CurrentProxy;
      Proxy.SetStatus(TProxyData.TStatus.Busy);
      Break;
    end;
  end;

  Result := Assigned(Proxy);

  FLock.Leave;
end;

function TProxyAllocator.GetNextIndex: Integer;
begin
  Result := AtomicIncrement(FIndex);

  if Result >= GetCount then
  begin
    FIndex := 0;
    Result := 0;
    Filter;
  end;
end;

function TProxyAllocator.GetNextProxy: PProxyData;
begin
  Result := FList.List[GetNextIndex];
end;

function TProxyAllocator.IsEmpty: Boolean;
begin
  Result := FList.Count = 0;
end;

procedure TProxyAllocator.Load(List: TList<TProxy>);
var
  Proxy: TProxy;
begin
  FList.Clear;

  for Proxy in List do
  begin
    Add(TProxyData.Create(Self, Proxy));
  end;

end;

procedure TProxyAllocator.Remove(const Index: Integer);
var
  Proxy: PProxyData;
begin
  if Index >= GetCount then
    Exit;

  Proxy := FList.List[Index];

  case Proxy.FStatus of
    TProxyData.TStatus.Free:
      AtomicDecrement(Proxy.FOwner.FCounters.FreeCount);

    TProxyData.TStatus.Sleeping:
      AtomicDecrement(Proxy.FOwner.FCounters.SleepingCount);

    TProxyData.TStatus.Busy:
      AtomicDecrement(Proxy.FOwner.FCounters.BusyCount);
  end;

  Dispose(Proxy);
  FList.Delete(Index);
end;

procedure TProxyAllocator.SetOfflineMax(const Value: Integer);
begin
  FOfflineMax := Value;
end;

end.
