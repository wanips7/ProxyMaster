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
  uProxy, uTypes, uHttpClient, uProxyParser, System.SyncObjs;

type
  TProxyChecker = class
  strict private
    FHttpClient: THttpClient;
    FPreset: TCheckerPreset;
    FConnectTic: Int64;
    FClientIP: string;
    FIsRunning: Boolean;
    FLock: TCriticalSection;
    function GetAnonymityLevel(Headers: string): TAnonymityLevel;
    procedure SetHttpClientSettings(const Proxy: TProxy);
    function CheckProxy(const Proxy: TProxy): TProxyEx;
    function ShouldCheck(const ProxyProtocol: TProxy.TProtocol): Boolean;
  public
    property ConnectTic: Int64 read FConnectTic;
    property IsRunning: Boolean read FIsRunning;
    property ClientIP: string read FClientIP write FClientIP;
    property Preset: TCheckerPreset read FPreset write FPreset;
    constructor Create;
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

  if FHttpClient.RequestGet(FPreset.Url) then
  begin
    Result.Status := TProxyStatus.Online;
    Result.Ping := (GetTickCount - FConnectTic) / 1000;

    if FHttpClient.ResultCode = FPreset.StatusCode then
    begin
      Result.AnonymityLevel := GetAnonymityLevel(FHttpClient.Headers.Text);
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

constructor TProxyChecker.Create;
begin
  FLock := TCriticalSection.Create;
  FHttpClient := THttpClient.Create;
  FClientIP := '';
  FPreset := default(TCheckerPreset);
  FIsRunning := False;
  FConnectTic := 0;
end;

destructor TProxyChecker.Destroy;
begin
  FLock.Free;
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

procedure TProxyChecker.SetHttpClientSettings(const Proxy: TProxy);
begin
  FHttpClient.Clear;
  FHttpClient.Timeout := FPreset.Timeout;
  FHttpClient.Proxy := Proxy;
  FHttpClient.UseProxy := True;
  FHttpClient.Headers.Text := FPreset.RequestHeaders;
  FHttpClient.UserAgent := FPreset.UserAgent;

end;

function TProxyChecker.ShouldCheck(const ProxyProtocol: TProxy.TProtocol): Boolean;
begin
  Result := (ProxyProtocol = TProxy.TProtocol.Unknown) or
    ((ProxyProtocol = TProxy.TProtocol.Http) and FPreset.SaveHttp) or
    ((ProxyProtocol = TProxy.TProtocol.Socks4) and FPreset.SaveSocks4) or
    ((ProxyProtocol = TProxy.TProtocol.Socks5) and FPreset.SaveSocks5);
end;

end.
