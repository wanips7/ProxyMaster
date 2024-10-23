unit uHttpClient;

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
  uProxy, httpsend, ssl_openssl;

{$SCOPEDENUMS ON}

type
  EHttpClientError = class(Exception);

type
  THttpClient = class(THTTPSend)
  public const
    DEFAULT_TIMEOUT = 10000;
  strict private
    FUseProxy: Boolean;
    FProxy: TProxy;
    FTimeout: Integer;
    FResponseBody: string;
    procedure ClearProxy;
    procedure SetProxy(const Value: TProxy);
    procedure SetTimeout(const Value: Integer);
    procedure SetUseProxy(const Value: Boolean);
    procedure SetHttpProxy(const Host, Port, Login, Password: string);
    procedure SetSocksProxy(const Host, Port, Login, Password: string);
    procedure SetResponseBody;
    function GetContentEncoding: string;
  public
    property ResponseBody: string read FResponseBody;
    property Proxy: TProxy read FProxy write SetProxy;
    property UseProxy: Boolean read FUseProxy write FUseProxy;
    property Timeout: Integer read FTimeout write SetTimeout;
    constructor Create;
    destructor Destroy; override;
    function RequestGet(const URL: string): Boolean;
    procedure Clear;
  end;

implementation

uses
  System.ZLib, blcksock;

{ THttpClient }

procedure THttpClient.Clear;
begin
  inherited Clear;

end;

procedure THttpClient.ClearProxy;
begin
  SetHttpProxy('', '', '', '');
  SetSocksProxy('', '', '', '');
end;

constructor THttpClient.Create;
begin
  inherited;

  FResponseBody := '';
  SetUseProxy(False);
  FProxy.Clear;

  SetTimeout(DEFAULT_TIMEOUT);

  OutputStream := TStringStream.Create;

  Protocol := '1.1';
  KeepAlive := False;

end;

destructor THttpClient.Destroy;
begin
  OutputStream.Free;

  inherited;
end;

function THttpClient.GetContentEncoding: string;
var
  s, line: string;
begin
  Result := '';

  for line in Headers do
  begin
    s := line.ToLower;

    if s.StartsWith('content-encoding:') then
    begin
      if s.EndsWith('deflate') then
        Result := 'deflate'
      else if s.EndsWith('gzip') then
        Result := 'gzip';

      Break;
    end;

  end;
end;

function THttpClient.RequestGet(const URL: string): Boolean;
begin
  Result := HTTPMethod('GET', URL);

  SetResponseBody;

end;

procedure THttpClient.SetHttpProxy(const Host, Port, Login, Password: string);
begin
  ProxyHost := Host;
  ProxyPort := Port;
  ProxyUser := Login;
  ProxyPass := Password;
end;

procedure THttpClient.SetSocksProxy(const Host, Port, Login, Password: string);
begin
  Sock.SocksIP := Host;
  Sock.SocksPort := Port;
  Sock.SocksUsername := Login;
  Sock.SocksPassword := Password;
end;

procedure THttpClient.SetProxy(const Value: TProxy);
begin
  if Value.Protocol = TProxy.TProtocol.Unknown then
    raise EHttpClientError.Create('Proxy protocol must be specified.');

  FProxy := Value;

  ClearProxy;

  if FProxy.Protocol = TProxy.TProtocol.Http then
  begin
    SetHttpProxy(FProxy.HostAsString, FProxy.Port.ToString, FProxy.Login, FProxy.Password);
  end
    else
  begin
    SetSocksProxy(FProxy.HostAsString, FProxy.Port.ToString, FProxy.Login, FProxy.Password);

    if FProxy.Protocol = TProxy.TProtocol.Socks4 then
      Sock.SocksType := TSocksType.ST_Socks4
    else
      Sock.SocksType := TSocksType.ST_Socks5;
  end;

end;

procedure THttpClient.SetTimeout(const Value: Integer);
begin
  inherited Timeout := Value;
  Sock.SetTimeout(Value);
  Sock.SocksTimeout := Value;
end;

procedure THttpClient.SetUseProxy(const Value: Boolean);
begin
  FUseProxy := Value;

  if not Value then
    ClearProxy;
end;

procedure THttpClient.SetResponseBody;
var
  StringStream: TStringStream;
  Stream: TStream;
  ContentEncoding: string;
begin
  FResponseBody := '';

  if OutputStream.Size = 0 then
    Exit;

  ContentEncoding := GetContentEncoding;

  if ContentEncoding.IsEmpty then
  begin
    try
      FResponseBody := TStringStream(OutputStream).DataString;
    except
      FResponseBody := '';
    end;
  end
    else
  begin
    Stream := nil;

    if ContentEncoding = 'deflate' then
      Stream := TDecompressionStream.Create(OutputStream, 15)
    else if ContentEncoding = 'gzip' then
      Stream := TDecompressionStream.Create(OutputStream, 15 + 16);

    if Assigned(Stream) then
    begin
      StringStream := TStringStream.Create;

      try
        StringStream.CopyFrom(Stream, 0);
        FResponseBody := StringStream.DataString;
      finally
        Stream.Free;
      end;

      StringStream.Free;
    end;

  end;

end;

end.
