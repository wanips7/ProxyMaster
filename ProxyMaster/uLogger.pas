unit uLogger;

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
  Winapi.Windows, System.SysUtils, System.Classes, System.SyncObjs,
  System.Generics.Collections;

{$SCOPEDENUMS ON}

type
  TLogType = (Normal, Notification, Warning, Error);

type
  TLogData = record
  public
    DateTime: TDateTime;
    Text: string;
    &Type: TLogType;
    function GetFormatted: string;
  end;

type
  TOnLogEvent = procedure(Sender: TObject; const LogData: TLogData) of object;

type
  TLogger = class
  strict private
    FOnLog: TOnLogEvent;
    FLock: TCriticalSection;
    FList: TList<TLogData>;
    FStoreMessages: Boolean;
    procedure DoLog(const LogData: TLogData);
    function GetCount: Integer;
  public
    property Count: Integer read GetCount;
    property OnLog: TOnLogEvent read FOnLog write FOnLog;
    property List: TList<TLogData> read FList;
    property StoreMessages: Boolean read FStoreMessages write FStoreMessages;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Log(const Text: string; LogType: TLogType = TLogType.Normal);
    procedure LogF(const Text: string; const Args: array of const; LogType: TLogType = TLogType.Normal);
    procedure SaveToFile(const FileName: string);
  end;

var
  Logger: TLogger;

implementation

{ TLogData }

function TLogData.GetFormatted: string;
begin
  Result := FormatDateTime('[dd.mm.yy hh:nn:ss] ', DateTime) + Text;
end;

{ TLogger }

procedure TLogger.Log(const Text: string; LogType: TLogType);
var
  LogData: TLogData;
begin
  if Text.IsEmpty then
    Exit;

  FLock.Enter;
  try
    LogData.DateTime := Now;
    LogData.Text := Text;
    LogData.&Type := LogType;

    if FStoreMessages then
      FList.Add(LogData);

    DoLog(LogData);

  finally
    FLock.Leave;
  end;

end;

procedure TLogger.LogF(const Text: string; const Args: array of const; LogType: TLogType);
begin
  Log(Format(Text, Args));
end;

procedure TLogger.SaveToFile(const FileName: string);
begin
  //
end;

procedure TLogger.Clear;
begin
  FLock.Enter;
  FList.Clear;
  FLock.Leave;
end;

constructor TLogger.Create;
begin
  FStoreMessages := False;
  FOnLog := nil;
  FLock := TCriticalSection.Create;
  FList := TList<TLogData>.Create;

end;

destructor TLogger.Destroy;
begin
  FList.Free;
  FLock.Free;

  inherited;
end;

procedure TLogger.DoLog(const LogData: TLogData);
begin
  if Assigned(FOnLog) then
    FOnLog(Self, LogData);
end;

function TLogger.GetCount: Integer;
begin
  Result := FList.Count;
end;

initialization
  Logger := TLogger.Create;

finalization
  FreeAndNil(Logger);

end.
