unit uClientIp;

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
  Winapi.Windows, System.SysUtils, System.Threading, System.Classes,
  System.Net.HttpClient, System.Generics.Collections;

{$SCOPEDENUMS ON}

type
  TIpFetchStatus = (Error, Success);

type
  TIpFetchResult = record
  public
    Status: TIpFetchStatus;
    Ip: string;
  end;

type
  TOnFetchEvent = procedure(Sender: TObject; const FetchResult: TIpFetchResult) of object;

type
  TClientIpFetcher = class
  public const
    TIMEOUT = 5000;
    HTTP_OK = 200;
    IP_URL = 'https://api.ipify.org/';
    USER_AGENT =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36';
    COLLECT_IP_REGEX = '^.+$';
  strict private
    FOnFetch: TOnFetchEvent;
    FTask: ITask;
    FHttpClient: THTTPClient;
    FResult: TIpFetchResult;
    procedure DoFetch(const FetchResult: TIpFetchResult);
    procedure SetHeaders;
  public
    property OnFetch: TOnFetchEvent read FOnFetch write FOnFetch;
    property Result: TIpFetchResult read FResult;
    constructor Create;
    destructor Destroy; override;
    function IsRunning: Boolean;
    procedure Fetch;
  end;

implementation

uses
  System.RegularExpressions;

{ TClientIpFetcher }

constructor TClientIpFetcher.Create;
begin
  FOnFetch := nil;
  FHttpClient := THTTPClient.Create;
  FHttpClient.ConnectionTimeout := TIMEOUT;
  FHttpClient.SendTimeout := TIMEOUT;
  FHttpClient.ResponseTimeout := TIMEOUT;

  FResult := default(TIpFetchResult);
end;

destructor TClientIpFetcher.Destroy;
begin
  FHttpClient.Free;
  inherited;
end;

procedure TClientIpFetcher.DoFetch(const FetchResult: TIpFetchResult);
begin
  if Assigned(FOnFetch) then
    FOnFetch(Self, FetchResult);
end;

function TClientIpFetcher.IsRunning: Boolean;
begin
  Result := Assigned(FTask) and (FTask.Status = TTaskStatus.Running);
end;

procedure TClientIpFetcher.SetHeaders;
begin
  FHttpClient.CustHeaders
    .Clear
    .Add('Accept', 'text/javascript, text/html, application/xml, text/xml, */*')
    .Add('Accept-Encoding', 'gzip, deflate')
    .Add('Accept-Language', 'q=0.9,en-US;q=0.8,en;q=0.7');

  FHttpClient.UserAgent := USER_AGENT;
  FHttpClient.CookieManager.Clear;
end;

procedure TClientIpFetcher.Fetch;
begin
  if IsRunning then
    Exit;

  FTask := TTask.Run
 (procedure()
  var
    Response: IHttpResponse;
    Content: string;
    Match: TMatch;
    RegEx: TRegEx;
  begin
    FResult := default(TIpFetchResult);

    SetHeaders;

    try
      Response := FHttpClient.Get(IP_URL);
    except

    end;

    if Response.StatusCode = HTTP_OK then
    begin
      Content := Response.ContentAsString;

      RegEx := TRegEx.Create(COLLECT_IP_REGEX, [roMultiLine]);
      Match := RegEx.Match(Content);

      if Match.Success then
      begin
        FResult.Ip := Match.Value;
        FResult.Status := TIpFetchStatus.Success;
      end;

    end;

    DoFetch(FResult);

  end);
end;

end.
