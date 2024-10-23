unit uUtils;

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

function ExtractBetween(const Text, TagFirst, TagLast: string; Offset: Integer = 1): string;
function InRange(const Value, Min, Max: Integer): Boolean;

implementation

function ExtractBetween(const Text, TagFirst, TagLast: string; Offset: Integer = 1): string;
var
  TFPos, TLPos: Integer;
begin
  Result := '';
  TFPos := Pos(TagFirst, Text, Offset);
  TLPos := Pos(TagLast, Text, TFPos + Length(TagFirst));

  if (TLPos <> 0) and (TFPos <> 0) then
    Result := Copy(Text, TFPos + Length(TagFirst), TLPos - TFPos - Length(TagFirst));
end;

function InRange(const Value, Min, Max: Integer): Boolean;
begin
  Result := (Value >= Min) and (Value <= Max);
end;

end.
