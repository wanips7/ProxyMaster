unit uTypes;

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
  uProxy;

{$SCOPEDENUMS ON}

type
  TAddPlace = (List, Table);
  TAnonymityLevel = (Unknown, Transparent, Anonymous, Elite);
  TProxyStatus = (Bad, Online, Good);

type
  PProxySource = ^TProxySource;
  TProxySource = record
  public
    Id: Integer;
    Url: string;
    ScanDepth: Integer;
    CollectedLastTime: Integer;
  end;

type
  TGoodProxy = record
  public
    StatusCode: Integer;
    AnonymityLevel: TAnonymityLevel;
    Countries: string;
    MaxPing: Single;
  end;

type
  TProxySaving = record
  public
    Http: Boolean;
    Socks4: Boolean;
    Socks5: Boolean;
    Bad: Boolean;
    ToFile: Boolean;
    ToLocalServer: Boolean;
  end;

type
  TCheckerRequest = record
  public
    Url: string;
    Timeout: Integer;
    Headers: string;
    UserAgent: string;
  end;

type
  PCheckerPreset = ^TCheckerPreset;
  TCheckerPreset = record
  public
    Id: Integer;
    Name: string;
    Request: TCheckerRequest;
    AddGoodProxyToTable: Boolean;
    ProxySaving: TProxySaving;
    GoodProxy: TGoodProxy;
    procedure Clear;
    function IsValid: Boolean;
  end;

type
  PProxyEx = ^TProxyEx;
  TProxyEx = record
  public
    Proxy: TProxy;
    Status: TProxyStatus;
    StatusCode: Integer;
    AnonymityLevel: TAnonymityLevel;
    Country: string;
    City: string;
    Ping: Single;
    procedure Clear; inline;
  end;

implementation

uses
  System.SysUtils;

{ TProxyEx }

procedure TProxyEx.Clear;
begin
  Self := default(TProxyEx);
end;

{ TCheckerPreset }

procedure TCheckerPreset.Clear;
begin
  Self := default(TCheckerPreset);
end;

function TCheckerPreset.IsValid: Boolean;
begin
  Result := (Name <> '') and (Request.Url <> '') and (Request.Headers <> '') and (Request.UserAgent <> '');
end;

end.
