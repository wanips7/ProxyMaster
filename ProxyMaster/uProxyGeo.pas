unit uProxyGeo;

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
  System.SysUtils, uTypes, uMMDBReader, uMMDBInfo, uMMDBIPAddress;

type
  EProxyGeoFetcherError = class(Exception);

type
  TProxyGeoFetcher = class
  strict private
    FMMDBReader: TMMDBReader;
    FIPAddress: TMMDBIPAddress;
  public
    constructor Create(const DatabaseFileName: string);
    destructor Destroy; override;
    function TryFetch(var ProxyEx: TProxyEx): Boolean; overload;
    function TryFetch(ProxyEx: PProxyEx): Boolean; overload;
  end;

implementation

{ TProxyGeoFetcher }

constructor TProxyGeoFetcher.Create(const DatabaseFileName: string);
begin
  FMMDBReader := nil;
  FMMDBReader := TMMDBReader.Create(DatabaseFileName);

end;

destructor TProxyGeoFetcher.Destroy;
begin
  FMMDBReader.Free;

  inherited;
end;

function TProxyGeoFetcher.TryFetch(ProxyEx: PProxyEx): Boolean;
begin
  Result := TryFetch(ProxyEx^);
end;

function TProxyGeoFetcher.TryFetch(var ProxyEx: TProxyEx): Boolean;
var
  prefixLength: Integer;
  IPCountryCityInfo: TMMDBIPCountryCityInfoEx;
begin
  Result := False;

  if not Assigned(FMMDBReader) then
    raise EProxyGeoFetcherError.Create('MMDBReader file is not specified.');

  IPCountryCityInfo := TMMDBIPCountryCityInfoEx.Create;

  try
    FIPAddress := TMMDBIPAddress.Parse(ProxyEx.Proxy.HostAsString);

    if FMMDBReader.Find<TMMDBIPCountryCityInfoEx>(FIPAddress, prefixLength, IPCountryCityInfo) then
    begin
      ProxyEx.Country := IPCountryCityInfo.Country.ISOCode;

      if not IPCountryCityInfo.City.Names.TryGetValue('en', ProxyEx.City) then
        ProxyEx.City := '-';

      Result := True;
    end;

  finally

  end;

  IPCountryCityInfo.Free;

end;

end.
