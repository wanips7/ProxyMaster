unit uProxyChecker;

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
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections,
  System.SyncObjs, uProxy, uTypes, uHttpClient, uProxyParser, uProxyGeo;

type
  TProxyChecker = class
  public const
    COUNTRIES_SEPARATOR = ',';
  strict private
    FHttpClient: THttpClient;
    FPreset: TCheckerPreset;
    FConnectTic: Int64;
    FClientIP: string;
    FIsRunning: Boolean;
    FLock: TCriticalSection;
    FGoodProxyCountries: TDictionary<string, Byte>;
    FProxyGeoFetcher: TProxyGeoFetcher;
    function GetAnonymityLevel(Headers: string): TAnonymityLevel;
    function IsGoodProxy(const Value: TProxyEx): Boolean;
    procedure SetHttpClientSettings(const Proxy: TProxy);
    function CheckProxy(const Proxy: TProxy): TProxyEx;
    function ShouldCheck(const ProxyProtocol: TProxy.TProtocol): Boolean;
    procedure SetPreset(const Value: TCheckerPreset);
  public
    property ConnectTic: Int64 read FConnectTic;
    property IsRunning: Boolean read FIsRunning;
    property ClientIP: string read FClientIP write FClientIP;
    property Preset: TCheckerPreset read FPreset write SetPreset;
    constructor Create(ProxyGeoFetcher: TProxyGeoFetcher);
    destructor Destroy; override;
    function Check(Proxy: TProxy): TProxyEx;
    procedure CloseConnection;
  end;

implementation

{ TProxyChecker }

function TProxyChecker.Check(Proxy: TProxy): TProxyEx;
var
  Protocol: TProxy.TProtocol;
  Protocols: TArray<TProxy.TProtocol>;
begin
  Result.Clear;
  Result.Proxy := Proxy;

  if Proxy.Protocol <> TProxy.TProtocol.Unknown then
  begin
    Protocols := [Proxy.Protocol];
  end
    else
  begin
    Protocols := [TProxy.TProtocol.Http, TProxy.TProtocol.Socks4, TProxy.TProtocol.Socks5];
  end;

  for Protocol in Protocols do
    if ShouldCheck(Proxy.Protocol) then
    begin
      Proxy.Protocol := Protocol;

      Result := CheckProxy(Proxy);

      if Result.Status = TProxyStatus.Good then
        Break;
    end;

end;

function TProxyChecker.CheckProxy(const Proxy: TProxy): TProxyEx;
begin
  Result.Clear;
  Result.Proxy := Proxy;

  SetHttpClientSettings(Proxy);

  FConnectTic := GetTickCount;
  FIsRunning := True;

  if FHttpClient.RequestGet(FPreset.Request.Url) then
  begin
    Result.Status := TProxyStatus.Online;
    Result.StatusCode := FHttpClient.ResultCode;
    Result.AnonymityLevel := GetAnonymityLevel(FHttpClient.Headers.Text);
    Result.Ping := (GetTickCount - FConnectTic) / 1000;

    FProxyGeoFetcher.TryFetch(Result);

    if IsGoodProxy(Result) then
    begin
      Result.Status := TProxyStatus.Good;
    end;

  end;

  FIsRunning := False;

  FLock.Enter;
  try
    FHttpClient.Sock.CloseSocket;
  finally
    FLock.Leave;
  end;

end;

procedure TProxyChecker.CloseConnection;
begin
  FLock.Enter;
  try
    FHttpClient.Sock.AbortSocket;
  finally
    FLock.Leave;
  end;
end;

constructor TProxyChecker.Create(ProxyGeoFetcher: TProxyGeoFetcher);
begin
  FLock := TCriticalSection.Create;
  FHttpClient := THttpClient.Create;
  FGoodProxyCountries := TDictionary<string, Byte>.Create;
  FProxyGeoFetcher := ProxyGeoFetcher;
  FClientIP := '';
  FPreset := default(TCheckerPreset);
  FIsRunning := False;
  FConnectTic := 0;
end;

destructor TProxyChecker.Destroy;
begin
  FLock.Free;
  FGoodProxyCountries.Free;
  FHttpClient.Free;

  inherited;
end;

function TProxyChecker.GetAnonymityLevel(Headers: string): TAnonymityLevel;
const
  ProxyMarks: TArray<string> =
   ['via', 'x-forwarded-for', 'from', 'authorization', 'proxy-authorization', 'proxy-connection'];

var
  s: string;
begin
  Result := TAnonymityLevel.Unknown;

  if FClientIP.IsEmpty then
    Exit;

  Headers := Headers.ToLower;

  { Transparent }
  if Headers.Contains(FClientIP) then
    Exit(TAnonymityLevel.Transparent);

  { Anonymous }
  for s in ProxyMarks do
  begin
    if Headers.Contains(s) then
      Exit(TAnonymityLevel.Anonymous);
  end;

  { Elite }
  Result := TAnonymityLevel.Elite;

end;

function TProxyChecker.IsGoodProxy(const Value: TProxyEx): Boolean;
begin
  Result := Value.StatusCode = FPreset.GoodProxy.StatusCode;

  if not Result then
    Exit;

  if FPreset.GoodProxy.AnonymityLevel <> TAnonymityLevel.Unknown then
    Result := Value.AnonymityLevel = FPreset.GoodProxy.AnonymityLevel;

  if not Result then
    Exit;

  if not FPreset.GoodProxy.Countries.IsEmpty then
    Result := FGoodProxyCountries.ContainsKey(Value.Country);

  if not Result then
    Exit;

  if FPreset.GoodProxy.MaxPing > 0 then
    Result := Value.Ping <= FPreset.GoodProxy.MaxPing;

end;

procedure TProxyChecker.SetHttpClientSettings(const Proxy: TProxy);
begin
  FHttpClient.Clear;
  FHttpClient.Timeout := FPreset.Request.Timeout;
  FHttpClient.Proxy := Proxy;
  FHttpClient.UseProxy := True;
  FHttpClient.Headers.Text := FPreset.Request.Headers;
  FHttpClient.UserAgent := FPreset.Request.UserAgent;

end;

procedure TProxyChecker.SetPreset(const Value: TCheckerPreset);
var
  s: string;
begin
  FPreset := Value;

  FGoodProxyCountries.Clear;

  for s in Value.GoodProxy.Countries.Split([COUNTRIES_SEPARATOR]) do
    FGoodProxyCountries.TryAdd(s.Trim.ToUpper, 0);

end;

function TProxyChecker.ShouldCheck(const ProxyProtocol: TProxy.TProtocol): Boolean;
begin
  Result := (ProxyProtocol = TProxy.TProtocol.Unknown) or
    ((ProxyProtocol = TProxy.TProtocol.Http) and FPreset.ProxySaving.Http) or
    ((ProxyProtocol = TProxy.TProtocol.Socks4) and FPreset.ProxySaving.Socks4) or
    ((ProxyProtocol = TProxy.TProtocol.Socks5) and FPreset.ProxySaving.Socks5);
end;

end.
