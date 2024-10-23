unit uProxy;

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
  System.SysUtils;

type
  PProxy = ^TProxy;
  TProxy = record
  public const
    OCTET_COUNT = 4;
    DEFAULT_PORT = 80;
    SEPARATOR_CHAR = ':';
    SEPARATOR_CHAR_2 = ';';
  public type
    TProtocol = (Unknown, Http, Socks4, Socks5);
    THost = array [0 .. OCTET_COUNT - 1] of Byte;
  strict private
    FHost: THost;
    FPort: Word;
    FProtocol: TProtocol;
    FLogin: string;
    FPassword: string;
    function TryParseHost(const Value: string; var Output: THost): Boolean;
  public
    property Host: THost read FHost;
    property Port: Word read FPort;
    property Login: string read FLogin;
    property Password: string read FPassword;
    property Protocol: TProtocol read FProtocol write FProtocol;
    constructor Create(const Host: THost; Port: Word; Protocol: TProtocol = TProtocol.Unknown); overload;
    constructor Create(const Host: THost; Port: Word; const Login, Password: string; Protocol: TProtocol = TProtocol.Unknown); overload;
    function GetStringLength: Integer;
    function HostAsString: string;
    function HostAsUInt: Cardinal;
    procedure Assign(const Value: Int64);
    function AsString: string;
    function AsInt64: Int64; inline; { host + port + protocol }
    function TryParse(const Value: string): Boolean; overload;
    function TryParse(const Host, Port: string): Boolean; overload;
    procedure Clear; inline;
    procedure Random;
    function HasLoginData: Boolean;
  end;

implementation

{$R-}

const
  DOT_CHAR = '.';

var
  ByteLookup: array [Byte] of string;

procedure InitByteLookup;
var
  i: Integer;
begin
  for i := 0 to High(ByteLookup) do
    ByteLookup[i] := i.ToString;
end;

function FastByteToString(Value: Byte): string; inline;
begin
  Result := ByteLookup[Value];
end;

{ TProxy }

function TProxy.AsInt64: Int64;
begin
  Result := Cardinal(FHost) + Int64(FPort) shl 32 + Int64(FProtocol) shl 48;
end;

procedure TProxy.Assign(const Value: Int64);
begin
  Cardinal(FHost) := Value;
  FPort := Value shr 32;
  FProtocol := TProxy.TProtocol(Value shr 48);
end;

function TProxy.AsString: string;
begin
  Result := HostAsString + SEPARATOR_CHAR + Port.ToString;
end;

procedure TProxy.Clear;
begin
  FHost := Default(THost);
  FPort := DEFAULT_PORT;
  FLogin := '';
  FPassword := '';
  FProtocol := TProxy.TProtocol.Unknown;
end;

constructor TProxy.Create(const Host: THost; Port: Word; const Login, Password: string; Protocol: TProtocol);
begin
  FHost := Host;
  FPort := Port;
  FLogin := Login;
  FPassword := Password;
  FProtocol := Protocol;
end;

constructor TProxy.Create(const Host: THost; Port: Word; Protocol: TProtocol = TProtocol.Unknown);
begin
  Create(Host, Port, '', '', Protocol);
end;

function TProxy.GetStringLength: Integer;
var
  b: Byte;
begin
  Result := 4;

  for b in FHost do
  begin
    Inc(Result, Length(ByteLookup[b]));
  end;

  if FPort < 1000 then
  begin
    if FPort < 10 then
      Inc(Result)
    else
      if FPort < 100 then
        Inc(Result, 2)
      else
        Inc(Result, 3);
  end
    else
  begin
    if FPort < 10000 then
      Inc(Result, 4)
    else
      Inc(Result, 5);
  end;
end;

function TProxy.HasLoginData: Boolean;
begin
  Result := (Login <> '') and (Password <> '');
end;

function TProxy.HostAsString: string;
var
  i: Integer;
begin
  Result := '';

  for i := 0 to High(FHost) do
    Result := Result + FastByteToString(FHost[i]) + DOT_CHAR;

  SetLength(Result, Length(Result) - 1);
end;

function TProxy.HostAsUInt: Cardinal;
begin
  Result := Cardinal(FHost);
end;

procedure TProxy.Random;
begin
  PCardinal(@FHost)^ := System.Random(Cardinal.MaxValue);
  FPort := System.Random(Word.MaxValue);
end;

function TProxy.TryParse(const Value: string): Boolean;
var
  List: TArray<string>;
  i: Integer;
  Len: Integer;
begin
  Result := False;
  Clear;

  if Length(Value) > 0 then
  begin
    List := Value.Split([DOT_CHAR, SEPARATOR_CHAR, SEPARATOR_CHAR_2]);
    Len := Length(List);

    if (Len = 5) or (Len = 7) then
    begin
      { Host }
      for i := 0 to 3 do
      begin
        if not Byte.TryParse(List[i], FHost[i]) then
          Exit;
      end;

      { Port }
      if not Word.TryParse(List[4], FPort) then
        Exit;

      { Login, password }
      if Len = 7 then
      begin
        FLogin := List[5];
        FPassword := List[6];
      end;

      Result := True;
    end
  end
end;

function TProxy.TryParse(const Host, Port: string): Boolean;
begin
  Result := TryParseHost(Host, FHost) and Word.TryParse(Port, FPort);
end;

function TProxy.TryParseHost(const Value: string; var Output: THost): Boolean;
var
  List: TArray<string>;
  i: Integer;
begin
  Result := False;

  List := Value.Split([DOT_CHAR]);

  if Length(List) = OCTET_COUNT then
  begin
    for i := 0 to 3 do
    begin
      if not Byte.TryParse(List[i], Output[i]) then
        Exit;
    end;

    Result := True;
  end;
end;

Initialization
  InitByteLookup;

end.
