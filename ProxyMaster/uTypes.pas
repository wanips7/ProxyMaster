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
  PCheckerPreset = ^TCheckerPreset;
  TCheckerPreset = record
  public
    Id: Integer;
    Name: string;
    { Request }
    Url: string;
    Timeout: Integer;
    RequestHeaders: string;
    UserAgent: string;
    StatusCode: Integer;
    { Save }
    SaveHttp: Boolean;
    SaveSocks4: Boolean;
    SaveSocks5: Boolean;
    SaveBad: Boolean;
    SaveToFile: Boolean;
    SaveToLocalServer: Boolean;
    AddGoodProxyToTable: Boolean;
    procedure Clear;
    function IsValid: Boolean;
  end;

type
  PProxyEx = ^TProxyEx;
  TProxyEx = record
  public
    Proxy: TProxy;
    Status: TProxyStatus;
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
  Result := (not Url.IsEmpty) and (not RequestHeaders.IsEmpty) and (not UserAgent.IsEmpty);
end;

end.
