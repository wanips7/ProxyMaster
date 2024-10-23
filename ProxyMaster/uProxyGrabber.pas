unit uProxyGrabber;

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
  System.Generics.Defaults, System.Generics.Collections, System.Net.HttpClient, uProxy, uTypes,
  uProxyParser, uUrlParser;

type
  EProxyGrabberError = class(Exception);

type
  TProxyGrabber = class
  public const
    TIMEOUT = 5000;
    HTTP_OK = 200;
    USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36';
    SCAN_DEPTH_MAX = 2;
  strict private
    FResults: TDictionary<Int64, TProxy>;
    FHttpClient: THTTPClient;
    FProxyParser: TProxyParser;
    FUrlParser: THtmlUrlParser;
    FStop: Boolean;
    procedure Grab(const Urls: TArray<string>; Deep: Integer); overload;
    procedure SetHeaders;
  public
    property Results: TDictionary<Int64, TProxy> read FResults;
    constructor Create;
    destructor Destroy; override;
    function Grab(const ProxySource: TProxySource): Boolean; overload;
    procedure Stop;
  end;

implementation

uses
  uUtils;

{ TProxyGrabber }

constructor TProxyGrabber.Create;
begin
  FResults := TDictionary<Int64, TProxy>.Create;

  FHttpClient := THTTPClient.Create;
  FHttpClient.ConnectionTimeout := TIMEOUT;
  FHttpClient.SendTimeout := TIMEOUT;
  FHttpClient.ResponseTimeout := TIMEOUT;

  FProxyParser := TProxyParser.Create;
  FUrlParser := THtmlUrlParser.Create;

  FStop := False;

  SetHeaders;
end;

destructor TProxyGrabber.Destroy;
begin
  FUrlParser.Free;
  FProxyParser.Free;
  FResults.Free;
  FHttpClient.Free;
  inherited;
end;

procedure TProxyGrabber.SetHeaders;
begin
  FHttpClient.CustHeaders
    .Clear
    .Add('Accept', 'text/javascript, text/html, application/xml, text/xml, */*')
    .Add('Accept-Encoding', 'gzip, deflate')
    .Add('Accept-Language', 'q=0.9,en-US;q=0.8,en;q=0.7');

  FHttpClient.UserAgent := USER_AGENT;
  FHttpClient.CookieManager.Clear;
end;

procedure TProxyGrabber.Stop;
begin
  FStop := True;
end;

function TProxyGrabber.Grab(const ProxySource: TProxySource): Boolean;
begin
  if not InRange(ProxySource.ScanDepth, 0, SCAN_DEPTH_MAX) then
    raise EProxyGrabberError.CreateFmt('Scan deep value must be in range 0 .. %d', [SCAN_DEPTH_MAX]);

  FStop := False;
  FResults.Clear;

  FUrlParser.MainUrl := ProxySource.Url;

  Grab([ProxySource.Url], ProxySource.ScanDepth + 1);

  Result := not FResults.IsEmpty;
end;

procedure TProxyGrabber.Grab(const Urls: TArray<string>; Deep: Integer);
var
  Url: string;
  Proxy: TProxy;
  ResponseBody: string;
  Response: IHttpResponse;
begin
  Dec(Deep);

  for Url in Urls do
  begin
    if FStop then
      Exit;

    SetHeaders;
    try
      Response := FHttpClient.Get(Url);
    except
      Continue;
    end;

    if Response.StatusCode = HTTP_OK then
    begin
      try
        ResponseBody := Response.ContentAsString;
      except
        Continue;
      end;

      if FProxyParser.Parse(ResponseBody) then
      begin
        for Proxy in FProxyParser.Results do
          FResults.AddOrSetValue(Proxy.AsInt64, Proxy);
      end;

      if Deep > 0 then
        if FUrlParser.Parse(ResponseBody) then
        begin
          Grab(FUrlParser.Results.Keys.ToArray, Deep);
        end;
    end;

  end;
end;

end.
