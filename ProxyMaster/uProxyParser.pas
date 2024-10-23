unit uProxyParser;

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
  System.SysUtils, Rapid.Generics, uProxy;

type
  TProxyParser = class
  strict private
    FResults: TList<TProxy>;
  public
    property Results: TList<TProxy> read FResults;
    constructor Create;
    destructor Destroy; override;
    function Parse(const Text: string): Boolean;
  end;

implementation

{$R-}
{$POINTERMATH ON}

{ TProxyParser }

constructor TProxyParser.Create;
begin
  FResults := TList<TProxy>.Create;
end;

destructor TProxyParser.Destroy;
begin
  FResults.Free;
  inherited;
end;

function TProxyParser.Parse(const Text: string): Boolean;
const
  PROXY_MIN_LEN = 10;
  PROXY_MAX_LEN = 15;
  HOST_MIN_LEN = 7;
  HOST_MAX_LEN = 15;
  PORT_MIN_LEN = 2;
  PORT_MAX_LEN = 5;

  function IsNum(Value: Char): Boolean; inline;
  var
    i: Integer;
  begin
    i := Ord(Value);
    Result := (i > 47) and (i < 58);
  end;

var
  i, n: Integer;
  s: string;
  Proxy: TProxy;
  Host: string;
  Port: string;
  Len: Integer;
  c: PChar;
  StartChar: PChar;
  lc: PChar;
  OctetLen, PortLen: Integer;
  Skip: Boolean;
begin
  Result := False;
  FResults.Clear;

  Len := Length(Text);

  if Len < PROXY_MIN_LEN then
    Exit;

  StartChar := PChar(Text);
  c := StartChar;

  Dec(c);

  while True do
  begin
    Inc(c);

    if (c^ = #0) then
      Break;

    if not IsNum(c^) then
      Continue;

    { Trying to parse host }
    lc := c;
    Skip := False;

    for i := 0 to 3 do
    begin
      OctetLen := 0;
      for n := 0 to 3 do
      begin
        if IsNum(lc^) then
          Inc(OctetLen)
        else
          Break;

        Inc(lc);
      end;

      if ((i <> 3) and (lc^ <> '.')) or (OctetLen = 0) or (OctetLen > 3) then
      begin
        Skip := True;
        Break;
      end;

      if (lc^ <> #0) then
        Inc(lc);

      if Skip then
        Break;
    end;

    if Skip then
      Continue;

    Host := Copy(Text, c - StartChar + 1, lc - c - 1);

    while not IsNum(lc^) do
    begin
      if (lc^ = #0) then
      begin
        Skip := True;
        Break;
      end;

      Inc(lc);
    end;

    if Skip then
      Continue;

    { Trying to parse port }
    PortLen := 0;
    for n := 0 to PORT_MAX_LEN do
    begin
      if not IsNum(lc^) or (lc^ = #0) then
        Break;

      Inc(lc);
      Inc(PortLen);
    end;

    if (PortLen < PORT_MIN_LEN) or (PortLen > PORT_MAX_LEN) then
      Continue;

    Port := Copy(Text, lc - StartChar - PortLen + 1, PortLen);

    Proxy.Clear;
    if Proxy.TryParse(Host, Port) then
    begin
      FResults.Add(Proxy);

      c := lc;
      Dec(c);
    end;

  end;

  Result := FResults.Count > 0;
end;

end.
