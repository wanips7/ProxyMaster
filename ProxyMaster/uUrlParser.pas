unit uUrlParser;

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
  System.SysUtils, Rapid.Generics;

type
  EHtmlUrlParserError = class(Exception);

type
  THtmlUrlParser = class
  public const
    DEFAULT_CAPACITY = 50;
  strict private
    FResults: TDictionary<string, Byte>;
    FMainUrl: string;
    FCapacity: Integer;
    function IsValidUrl(const Value: string): Boolean;
    function RemoveUrlPath(const Value: string): string;
    procedure RemoveAnchor(var Value: string);
    procedure SetMainUrl(const Value: string);
  public
    property Capacity: Integer read FCapacity write FCapacity;
    property MainUrl: string read FMainUrl write SetMainUrl;
    property Results: TDictionary<string, Byte> read FResults;
    constructor Create;
    destructor Destroy; override;
    function Parse(const Text: string): Boolean;
  end;

implementation

uses
  uUtils;

{ THtmlUrlParser }

constructor THtmlUrlParser.Create;
begin
  FResults := TDictionary<string, Byte>.Create;
  FMainUrl := '';
  FCapacity := DEFAULT_CAPACITY;
end;

destructor THtmlUrlParser.Destroy;
begin
  FResults.Free;
  inherited;
end;

function THtmlUrlParser.IsValidUrl(const Value: string): Boolean;
begin
  Result := (Value.Length > 11) and (Value.StartsWith('http://') or Value.StartsWith('https://')) ;
end;

function THtmlUrlParser.Parse(const Text: string): Boolean;
const
  TAG_FIRST = 'href="';
  TAG_LAST = '"';
var
  Url: string;
  Offset: Integer;
  TagPos: Integer;
begin
  Result := False;
  FResults.Clear;
  Offset := 1;

  while True do
  begin
    TagPos := Pos(TAG_FIRST, Text, Offset);

    if TagPos = 0 then
      Break;

    Url := ExtractBetween(Text, TAG_FIRST, TAG_LAST, Offset);

    if IsValidUrl(Url) then
    begin
      RemoveAnchor(Url);

      if FMainUrl.IsEmpty or (not FMainUrl.IsEmpty and Url.StartsWith(FMainUrl)) then
      begin
        FResults.AddOrSetValue(Url, 0);
      end;
    end;

    Offset := TagPos + Length(TAG_FIRST) + Url.Length + Length(TAG_LAST);

    if ((FCapacity > 0) and (FResults.Count >= FCapacity)) then
      Break;
  end;

  Result := FResults.Count > 0;

end;

procedure THtmlUrlParser.RemoveAnchor(var Value: string);
var
  i: Integer;
begin
  i := Pos('#', Value);
  if i <> 0 then
  begin
    SetLength(Value, i - 1);
  end;
end;

function THtmlUrlParser.RemoveUrlPath(const Value: string): string;
var
  i: Integer;
begin
  Result := Value;

  if IsValidUrl(Value) then
  begin
    i := Pos('/', Value, 10);
    if i <> 0 then
    begin
      SetLength(Result, i - 1);
    end;

  end;
end;

procedure THtmlUrlParser.SetMainUrl(const Value: string);
begin
  if not IsValidUrl(Value) then
    raise EHtmlUrlParserError.Create('Invalid url.');

  FMainUrl := RemoveUrlPath(Value);

end;

end.
