unit uProxyList;

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
  System.SysUtils, System.Classes, System.SyncObjs, Rapid.Generics, uProxy,
  uProxyParser, uTypes;

type
  TProxyList = class
  public type
    TAction = (Add, Clear);
    TOnChangeEvent = procedure(Sender: TObject; const Action: TAction) of object;
    TCounters = record
    public
      Total: Integer;
      Unknown: Integer;
      Http: Integer;
      Socks4: Integer;
      Socks5: Integer;
    end;

  strict private
    FOnChange: TOnChangeEvent;
    FDictionary: TDictionary<Int64, Byte>;
    FList: TList<TProxy>;
    FLastTimeAddedCount: Integer;
    FCounters: TCounters;
    procedure DoChange(const Action: TAction);
    function GetItem(Index: Integer): TProxy; inline;
    procedure TryAdd(const ProxyStr: string; const Protocol: TProxy.TProtocol); overload;
    procedure TryAdd(const Proxy: TProxy); overload;
  public
    property OnChange: TOnChangeEvent read FOnChange write FOnChange;
    property Counters: TCounters read FCounters;
    property LastTimeAddedCount: Integer read FLastTimeAddedCount;
    property Items[Index: Integer]: TProxy read GetItem;
    constructor Create;
    destructor Destroy; override;
    function IsEmpty: Boolean;
    procedure Clear;
    function GetEnumerator: TList<TProxy>.TEnumerator;
    procedure LoadFromFile(const PathFile: string; const Protocol: TProxy.TProtocol = TProxy.TProtocol.Unknown);
    procedure LoadFromText(const Text: string; const Protocol: TProxy.TProtocol = TProxy.TProtocol.Unknown);
    procedure LoadFromDictionary(const Value: TDictionary<Int64, TProxy>);
  end;

type
  TProxyResultList = class
  strict private
    FHttpList: TList<TProxyEx>;
    FSocks4List: TList<TProxyEx>;
    FSocks5List: TList<TProxyEx>;
    FBadList: TList<TProxyEx>;
    FLock: TCriticalSection;
    FLastUpdated: TDateTime;
    function GetList(const Protocol: TProxy.TProtocol): TList<TProxyEx>;
    function ListToString(const List: TList<TProxyEx>): string;
    procedure SaveListToFile(const List: TList<TProxyEx>; const FileName: string);
  public
    property LastUpdated: TDateTime read FLastUpdated;
    property HttpList: TList<TProxyEx> read FHttpList;
    property Socks4List: TList<TProxyEx> read FSocks4List;
    property Socks5List: TList<TProxyEx> read FSocks5List;
    property BadList: TList<TProxyEx> read FBadList;
    constructor Create;
    destructor Destroy; override;
    procedure Add(const ProxyEx: TProxyEx);
    procedure Clear;
    function GoodToString(const Protocol: TProxy.TProtocol): string;
    procedure SaveGoodToFile(const FileName: string; const Protocol: TProxy.TProtocol);
    procedure SaveBadToFile(const FileName: string);
    function GetTotalCount: Integer;
    function GetGoodCount: Integer;
  end;

implementation

uses
  System.IOUtils;

{ TProxyList }

constructor TProxyList.Create;
begin
  FOnChange := nil;
  FLastTimeAddedCount := 0;
  FList := TList<TProxy>.Create;
  FDictionary := TDictionary<Int64, Byte>.Create;

  Clear;

end;

destructor TProxyList.Destroy;
begin
  FDictionary.Free;
  FList.Free;

  inherited;
end;

procedure TProxyList.Clear;
begin
  FDictionary.Clear;
  FList.Clear;
  FCounters := default(TCounters);

  DoChange(TAction.Clear);
end;

function TProxyList.IsEmpty: Boolean;
begin
  Result := FList.Count = 0;
end;

procedure TProxyList.DoChange(const Action: TAction);
begin
  if Assigned(FOnChange) then
    FOnChange(Self, Action);
end;

function TProxyList.GetEnumerator: TList<TProxy>.TEnumerator;
begin
  Result := FList.GetEnumerator;
end;

function TProxyList.GetItem(Index: Integer): TProxy;
begin
  Result := FList[Index];
end;

procedure TProxyList.LoadFromDictionary(const Value: TDictionary<Int64, TProxy>);
var
  Proxy: TProxy;
begin
  FLastTimeAddedCount := FCounters.Total;

  for Proxy in Value.Values do
  begin
    TryAdd(Proxy);
  end;

  FLastTimeAddedCount := FCounters.Total - FLastTimeAddedCount;

  DoChange(TAction.Add);
end;

procedure TProxyList.LoadFromFile(const PathFile: string; const Protocol: TProxy.TProtocol);
begin
  LoadFromText(TFile.ReadAllText(PathFile), Protocol);
end;

{$R-}
procedure TProxyList.LoadFromText(const Text: string; const Protocol: TProxy.TProtocol);
var
  i: Integer;
  Parser: TProxyParser;
begin
  FLastTimeAddedCount := 0;

  Parser := TProxyParser.Create;
  if Parser.Parse(Text) then
  begin
    FLastTimeAddedCount := FCounters.Total;

    for i := 0 to Parser.Results.Count - 1 do
    begin
      Parser.Results.List[i].Protocol := Protocol;
      TryAdd(Parser.Results[i]);
    end;

    FLastTimeAddedCount := FCounters.Total - FLastTimeAddedCount;

    DoChange(TAction.Add);
  end;
  Parser.Free;
end;
{$R+}

procedure TProxyList.TryAdd(const ProxyStr: string; const Protocol: TProxy.TProtocol);
var
  Proxy: TProxy;
begin
  if Proxy.TryParse(ProxyStr) then
  begin
    Proxy.Protocol := Protocol;
    TryAdd(Proxy);
  end;
end;

procedure TProxyList.TryAdd(const Proxy: TProxy);
var
  Key: Int64;
begin
  Key := Proxy.AsInt64;

  if not FDictionary.ContainsKey(Key) then
  begin
    FDictionary.Add(Key, 0);
    FList.Add(Proxy);

    case Proxy.Protocol of
      TProxy.TProtocol.Unknown: Inc(FCounters.Unknown);
      TProxy.TProtocol.Http: Inc(FCounters.Http);
      TProxy.TProtocol.Socks4: Inc(FCounters.Socks4);
      TProxy.TProtocol.Socks5: Inc(FCounters.Socks5);
    end;

    Inc(FCounters.Total);
  end;
end;

{ TProxyResultList }

procedure TProxyResultList.Add(const ProxyEx: TProxyEx);
var
  List: TList<TProxyEx>;
begin
  if ProxyEx.Status = TProxyStatus.Good then
    List := GetList(ProxyEx.Proxy.Protocol)
  else
    List := FBadList;

  FLock.Enter;
  FLastUpdated := Now;
  try
    List.Add(ProxyEx);
  finally
    FLock.Leave;
  end;

end;

procedure TProxyResultList.Clear;
begin
  FLock.Enter;

  FBadList.Clear;
  FSocks5List.Clear;
  FSocks4List.Clear;
  FHttpList.Clear;

  FLock.Leave;
end;

constructor TProxyResultList.Create;
begin
  FLastUpdated := 0;
  FHttpList := TList<TProxyEx>.Create;
  FSocks4List := TList<TProxyEx>.Create;
  FSocks5List := TList<TProxyEx>.Create;
  FBadList := TList<TProxyEx>.Create;

  FLock := TCriticalSection.Create;
end;

destructor TProxyResultList.Destroy;
begin
  FLock.Free;
  FBadList.Free;
  FSocks5List.Free;
  FSocks4List.Free;
  FHttpList.Free;
  inherited;
end;

function TProxyResultList.GetGoodCount: Integer;
begin
  Result := GetTotalCount - FBadList.Count;
end;

function TProxyResultList.GetList(const Protocol: TProxy.TProtocol): TList<TProxyEx>;
begin
  case Protocol of
    TProxy.TProtocol.Unknown:
    begin
      Result := nil;
      raise Exception.Create('Proxy protocol must be specified.');
    end;

    TProxy.TProtocol.Http:
    begin
      Result := FHttpList;
    end;

    TProxy.TProtocol.Socks4:
    begin
      Result := FSocks4List;
    end;

    TProxy.TProtocol.Socks5:
    begin
      Result := FSocks5List;
    end;
  end;
end;

function TProxyResultList.GetTotalCount: Integer;
begin
  Result := FHttpList.Count + FSocks4List.Count + FSocks5List.Count + FBadList.Count;
end;

function TProxyResultList.ListToString(const List: TList<TProxyEx>): string;
var
  i, Len, Size, Count: Integer;
  P: PChar;
  S: string;
begin
  Result := '';

  Count := List.Count;

  if Count = 0 then
    Exit;

  Size := 0;
  for i := 0 to Count - 1 do
    Inc(Size, List[i].Proxy.GetStringLength + Length(sLineBreak));

  Dec(Size, Length(sLineBreak));

  SetString(Result, nil, Size);
  P := Pointer(Result);

  for i := 0 to Count - 1 do
  begin
    if i = Count - 1 then
      S := List[i].Proxy.AsString
    else
      S := List[i].Proxy.AsString + sLineBreak;

    Len := Length(S);
    if Len <> 0 then
    begin
      System.Move(Pointer(S)^, P^, Len * SizeOf(Char));
      Inc(P, Len);
    end;
  end;
end;

procedure TProxyResultList.SaveBadToFile(const FileName: string);
begin
  SaveListToFile(FBadList, FileName);
end;

procedure TProxyResultList.SaveGoodToFile(const FileName: string; const Protocol: TProxy.TProtocol);
begin
  SaveListToFile(GetList(Protocol), FileName);
end;

function TProxyResultList.GoodToString(const Protocol: TProxy.TProtocol): string;
begin
  FLock.Enter;
  try
    Result := ListToString(GetList(Protocol));
  finally
    FLock.Leave;
  end;
end;

procedure TProxyResultList.SaveListToFile(const List: TList<TProxyEx>; const FileName: string);
begin
  if List.Count = 0 then
    Exit;

  FLock.Enter;
  try
    TFile.WriteAllText(FileName, ListToString(List));
  finally
    FLock.Leave;
  end;
end;

end.
