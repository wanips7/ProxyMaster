unit uLocalServer;

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
  Winapi.Windows, System.SysUtils, System.Classes, System.Threading,
  System.Generics.Collections, uProxyList, blcksock;

type
  TLocalServer = class
  private type
    PProxies = ^TProxies;
    TProxies = record
      Http: string;
      Socks4: string;
      Socks5: string;
    end;

   PStatistics = ^TStatistics;
   TStatistics = record
     HttpCount: Integer;
     Socks4Count: Integer;
     Socks5Count: Integer;
     GoodCount: Integer;
     BadCount: Integer;
     TotalCount: Integer;
     LastUpdated: TDateTime;
   end;

  strict private
    FOnStart: TNotifyEvent;
    FOnStop: TNotifyEvent;
    FSock: TTCPBlockSocket;
    FBindedAddress: string;
    FTask: ITask;
    FPort: Word;
    FStop: Boolean;
    FStatistics: TStatistics;
    FProxies: TProxies;
    FProxyResultList: TProxyResultList;
    procedure DoStart;
    procedure DoStop;
    function TryBind(const Port: Word): Boolean;
    procedure SetPort(const Value: Word);
  public
    property OnStart: TNotifyEvent read FOnStart write FOnStart;
    property OnStop: TNotifyEvent read FOnStop write FOnStop;
    property BindedAddress: string read FBindedAddress;
    property Port: Word read FPort write SetPort;
    constructor Create(ProxyResultList: TProxyResultList);
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
    function IsRunning: Boolean;
    procedure UpdateResponse;
    function GetPathList: TArray<string>;
  end;

implementation

uses
  uProxy, uUtils, synsock;

type
  TResponseThread = class(TThread)
  strict private
    FSock: TTCPBlockSocket;
    FProxies: TLocalServer.PProxies;
    FStatistics: TLocalServer.PStatistics;
    function GetPath(const Request: string): string;
    function GetMainPageText: string;
    procedure ProcessRequest(const Data: string);
  public
    constructor Create(hSock: TSocket; Proxies: TLocalServer.PProxies; Statistics: TLocalServer.PStatistics);
    destructor Destroy; override;
    procedure Execute; override;
  end;

const
  LOCAL_PATH_LIST: TArray<String> =
    ['/http', '/socks4', '/socks5'];

{ TLocalServer }

constructor TLocalServer.Create(ProxyResultList: TProxyResultList);
begin
  FOnStart := nil;
  FOnStop := nil;
  FStop := False;
  FSock := TTCPBlockSocket.Create;
  FProxies := default(TProxies);
  FStatistics := default(TStatistics);
  FProxyResultList := ProxyResultList;

  SetPort(8000);

end;

destructor TLocalServer.Destroy;
begin
  if IsRunning then
  begin
    Stop;
    FTask.Wait(50);
  end;

  FSock.Free;

  inherited;
end;

procedure TLocalServer.DoStart;
begin
  if Assigned(FOnStart) then
    FOnStart(Self);
end;

procedure TLocalServer.DoStop;
begin
  if Assigned(FOnStop) then
    FOnStop(Self);
end;

function TLocalServer.GetPathList: TArray<string>;
begin
  Result := LOCAL_PATH_LIST;
end;

procedure TLocalServer.SetPort(const Value: Word);
begin
  FPort := Value;
  FBindedAddress := 'http://' + cLocalhost + ':' + Value.ToString;
end;

procedure TLocalServer.Start;
begin
  if IsRunning then
    Exit;

  DoStart;

  FStop := False;

  FTask := TTask.Run
 (procedure()
  begin
    if TryBind(FPort) then
    begin
      FSock.Listen;

      repeat
        Sleep(10);

        if FSock.CanRead(1000) then
          if FSock.LastError = 0 then
          begin

            TResponseThread.Create(FSock.Accept, @FProxies, @FStatistics);

          end;

      until FStop;

      FSock.CloseSocket;
    end;

    DoStop;
  end);

end;

procedure TLocalServer.Stop;
begin
  FStop := True;
end;

function TLocalServer.IsRunning: Boolean;
begin
  Result := Assigned(FTask) and (FTask.Status = TTaskStatus.Running);
end;

function TLocalServer.TryBind(const Port: Word): Boolean;
begin
  FSock.CloseSocket;
  FSock.CreateSocket;
  FSock.Bind(cLocalhost, Port.ToString);

  Result := FSock.LastError = 0;
end;

procedure TLocalServer.UpdateResponse;
begin
  FProxies.Http := FProxyResultList.GoodToString(TProxy.TProtocol.Http);
  FProxies.Socks4 := FProxyResultList.GoodToString(TProxy.TProtocol.Socks4);
  FProxies.Socks5 := FProxyResultList.GoodToString(TProxy.TProtocol.Socks5);

  FStatistics.HttpCount := FProxyResultList.HttpList.Count;
  FStatistics.Socks4Count := FProxyResultList.Socks4List.Count;
  FStatistics.Socks5Count := FProxyResultList.Socks5List.Count;
  FStatistics.GoodCount := FProxyResultList.GetGoodCount;
  FStatistics.BadCount := FProxyResultList.BadList.Count;
  FStatistics.TotalCount := FProxyResultList.GetTotalCount;
  FStatistics.LastUpdated := FProxyResultList.LastUpdated;

end;

{ TResponseThread }

constructor TResponseThread.Create(hSock: TSocket; Proxies: TLocalServer.PProxies; Statistics: TLocalServer.PStatistics);
begin
  FSock := TTCPBlockSocket.Create;
  FSock.Socket := hSock;
  FSock.GetSins;

  FProxies := Proxies;
  FStatistics := Statistics;

  FreeOnTerminate := True;
  inherited Create(False);
end;

destructor TResponseThread.Destroy;
begin
  FSock.Free;
  inherited;
end;

procedure TResponseThread.Execute;
var
  s: string;
begin
  if FSock.WaitingData <> 0 then
  begin
    s := FSock.RecvPacket(1000);
    if FSock.LastError = 0 then
      ProcessRequest(S);

  end;

  FSock.CloseSocket;
end;

function TResponseThread.GetMainPageText: string;
begin
  Result :=
    'Http(s) count: ' + FStatistics.HttpCount.ToString + sLineBreak +
    'Socks4 count: ' + FStatistics.Socks4Count.ToString + sLineBreak +
    'Socks5 count: ' + FStatistics.Socks5Count.ToString + sLineBreak +
    'Good count: ' + FStatistics.GoodCount.ToString + sLineBreak +
    'Bad count: ' + FStatistics.BadCount.ToString + sLineBreak +
    'Total count: ' + FStatistics.TotalCount.ToString + sLineBreak +
    'Last updated: ' + FormatDateTime('dd.mm.yyyy hh:nn:ss', FStatistics.LastUpdated);

end;

function TResponseThread.GetPath(const Request: string): string;
begin
  Result := ExtractBetween(Request, 'GET ', ' ');
end;

procedure TResponseThread.ProcessRequest(const Data: string);

  function AddHeaders(const Body: string): string;
  begin
    Result :=
      'HTTP/1.1 200 OK' + CRLF +
      'Server: ProxyMaster' + CRLF +
      'Content-Type: text/plain' + CRLF +
      'Content-Length: ' + Length(Body).ToString + CRLF + CRLF
       + Body;
  end;

var
  Text: string;
  Path: string;
begin
  Path := GetPath(Data).ToLower;

  if Path = LOCAL_PATH_LIST[0] then
  begin
    Text := FProxies.Http;
  end
    else
  if Path = LOCAL_PATH_LIST[1] then
  begin
    Text := FProxies.Socks4;
  end
    else
  if Path = LOCAL_PATH_LIST[2] then
  begin
    Text := FProxies.Socks5;
  end
    else
  begin
    Text := GetMainPageText;
  end;

  Text := AddHeaders(Text);

  FSock.SendString(Text);
end;

end.

