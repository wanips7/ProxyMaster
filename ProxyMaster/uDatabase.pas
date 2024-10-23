unit uDatabase;

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
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Dialogs, Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.VCLUI.Controls,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Stan.Def, FireDAC.VCLUI.Wait, FireDAC.Phys.SQLite,
  System.Generics.Collections, uTypes;

type
  TDatabase = class;

  TBaseTable<T> = class
  strict private
    FOnChange: TNotifyEvent;
    FEnableOnChange: Boolean;
    FTableName: string;
    FQuery: TFDQuery;
    FConnection: TFDConnection;
  private
    function GetCurrent: T; virtual; abstract;
    property Query: TFDQuery read FQuery;
    procedure ExecSQL(const Value: string);
    function SelectByQuery(const Value: string; out Output: T): Boolean;
  public
    property TableName: string read FTableName;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property EnableOnChange: Boolean read FEnableOnChange write FEnableOnChange;
    constructor Create(Connection: TFDConnection; const TableName: string);
    destructor Destroy; override;
    procedure DoChange;
    function GetCount: Integer;
    procedure Clear;
    procedure Remove(const Id: Integer);
    procedure First;
    function GetNext(out Value: T): Boolean;
    function GetById(const Id: Integer; out Output: T): Boolean;
  end;

  TProxySourcesTable = class(TBaseTable<TProxySource>)
  strict private
    function GetCurrent: TProxySource; override;
  public
    procedure Add(const Value: TProxySource);
    procedure Update(const Value: TProxySource);
  end;

  TCheckerPresetsTable = class(TBaseTable<TCheckerPreset>)
  strict private
    function GetCurrent: TCheckerPreset; override;
  public
    procedure Add(const Value: TCheckerPreset);
    procedure Update(const Value: TCheckerPreset);
    function ContainsName(const Value: string): Boolean;
    function GetByName(const Name: string; out CheckerPreset: TCheckerPreset): Boolean;
  end;

  TDatabase = class
  strict private
    FConnection: TFDConnection;
    FProxySourcesTable: TProxySourcesTable;
    FCheckerPresetsTable: TCheckerPresetsTable;
  public
    property ProxySourcesTable: TProxySourcesTable read FProxySourcesTable;
    property CheckerPresetsTable: TCheckerPresetsTable read FCheckerPresetsTable;
    constructor Create;
    destructor Destroy; override;
    procedure Connect(const FileName: string);
    procedure Disconnect;
  end;

var
  Database: TDatabase = nil;

implementation

{ TBaseTable<T> }

procedure TBaseTable<T>.Clear;
begin
  ExecSQL('DELETE FROM ' + FTableName);
end;

constructor TBaseTable<T>.Create(Connection: TFDConnection; const TableName: string);
begin
  FOnChange := nil;
  FEnableOnChange := True;
  FConnection := Connection;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := Connection;
  FTableName := TableName;
end;

destructor TBaseTable<T>.Destroy;
begin
  FQuery.Close;
  FQuery.Free;
  inherited;
end;

procedure TBaseTable<T>.DoChange;
begin
  if FEnableOnChange then
    if Assigned(FOnChange) then
      FOnChange(Self);
end;

procedure TBaseTable<T>.ExecSQL(const Value: string);
begin
  FConnection.ExecSQL(Value);

  DoChange;
end;

procedure TBaseTable<T>.First;
begin
  FQuery.Open('SELECT * FROM ' + FTableName);
  FQuery.First;
end;

function TBaseTable<T>.GetById(const Id: Integer; out Output: T): Boolean;
begin
  Result := SelectByQuery(Format('SELECT * FROM %s WHERE Id = %d', [FTableName, Id]), Output);
end;

function TBaseTable<T>.GetCount: Integer;
begin
  Result := FConnection.ExecSQLScalar('SELECT COUNT(*) FROM ' + FTableName);
end;

function TBaseTable<T>.GetNext(out Value: T): Boolean;
begin
  Result := not FQuery.Eof;

  if Result then
  begin
    Value := GetCurrent;

    FQuery.Next;
  end
    else
  FQuery.Close;
end;

procedure TBaseTable<T>.Remove(const Id: Integer);
begin
  ExecSQL(Format('DELETE FROM %s WHERE Id = %d', [FTableName, Id]));
end;

function TBaseTable<T>.SelectByQuery(const Value: string; out Output: T): Boolean;
begin
  FQuery.Open(Value);

  Result := not FQuery.Eof;

  if Result then
  begin
    Output := GetCurrent;
  end;

  FQuery.Close;
end;

{ TProxySourcesTable }

procedure TProxySourcesTable.Add(const Value: TProxySource);
begin
  ExecSQL(Format('INSERT INTO %s' +
    '(Url, ScanDepth) ' +
    'VALUES(''%s'', %d)',
    [TableName, Value.Url, Value.ScanDepth]));
end;

function TProxySourcesTable.GetCurrent: TProxySource;
begin
  Result.Id := Query.FieldByName('Id').AsInteger;
  Result.Url := Query.FieldByName('Url').AsString;
  Result.ScanDepth := Query.FieldByName('ScanDepth').AsInteger;
  Result.CollectedLastTime := Query.FieldByName('CollectedLastTime').AsInteger;
end;

procedure TProxySourcesTable.Update(const Value: TProxySource);
begin
  ExecSQL(Format(
    'UPDATE %s SET Url = ''%s'', ScanDepth = %d, CollectedLastTime = %d ' +
    'WHERE Id = %d',
    [TableName, Value.Url, Value.ScanDepth, Value.CollectedLastTime, Value.Id]));

end;

{ TCheckerPresetsTable }

procedure TCheckerPresetsTable.Add(const Value: TCheckerPreset);
begin
  ExecSQL(Format('INSERT INTO %s' +
    '(Url, Name, Timeout, RequestHeaders, UserAgent, StatusCode, SaveHttp, ' +
    'SaveSocks4, SaveSocks5, SaveBad, SaveToFile, AddGoodProxyToTable) ' +
    'VALUES(''%s'', ''%s'', %d, ''%s'', ''%s'', %d, %d, %d, %d, %d, %d, %d, %d)',
    [TableName, Value.Url, Value.Name, Value.Timeout,
    Value.RequestHeaders, Value.UserAgent, Value.StatusCode, Integer(Value.SaveHttp),
    Integer(Value.SaveSocks4), Integer(Value.SaveSocks5), Integer(Value.SaveBad),
    Integer(Value.SaveToFile), Integer(Value.SaveToLocalServer), Integer(Value.AddGoodProxyToTable)]));
end;

function TCheckerPresetsTable.ContainsName(const Value: string): Boolean;
var
  Preset: TCheckerPreset;
begin
  Result := GetByName(Value, Preset);
end;

function TCheckerPresetsTable.GetByName(const Name: string; out CheckerPreset: TCheckerPreset): Boolean;
begin
  Result := SelectByQuery(Format('SELECT * FROM %s WHERE Name = ''%s''',
    [TableName, Name]), CheckerPreset);
end;

function TCheckerPresetsTable.GetCurrent: TCheckerPreset;
begin
  Result.Id := Query.FieldByName('Id').AsInteger;
  Result.Url := Query.FieldByName('Url').AsString;

  Result.Name := Query.FieldByName('Name').AsString;

  Result.Timeout := Query.FieldByName('Timeout').AsInteger;
  Result.RequestHeaders := Query.FieldByName('RequestHeaders').AsString;
  Result.UserAgent := Query.FieldByName('UserAgent').AsString;
  Result.StatusCode := Query.FieldByName('StatusCode').AsInteger;

  Result.SaveHttp := Query.FieldByName('SaveHttp').AsBoolean;
  Result.SaveSocks4 := Query.FieldByName('SaveSocks4').AsBoolean;
  Result.SaveSocks5 := Query.FieldByName('SaveSocks5').AsBoolean;
  Result.SaveBad := Query.FieldByName('SaveBad').AsBoolean;
  Result.SaveToFile := Query.FieldByName('SaveToFile').AsBoolean;
  Result.SaveToLocalServer := Query.FieldByName('SaveToLocalServer').AsBoolean;

  Result.AddGoodProxyToTable := Query.FieldByName('AddGoodProxyToTable').AsBoolean;


end;

procedure TCheckerPresetsTable.Update(const Value: TCheckerPreset);
begin
  ExecSQL(Format(
    'UPDATE %s SET Url = ''%s'', Name = ''%s'', Timeout = %d, ' +
    'RequestHeaders = ''%s'', UserAgent = ''%s'', StatusCode = %d, SaveHttp = %d, SaveSocks4 = %d, ' +
    'SaveSocks5 = %d, SaveBad = %d, SaveToFile = %d, SaveToLocalServer = %d, AddGoodProxyToTable = %d ' +
    'WHERE Id = %d',
    [TableName, Value.Url, Value.Name, Value.Timeout,
    Value.RequestHeaders, Value.UserAgent, Value.StatusCode, Integer(Value.SaveHttp),
    Integer(Value.SaveSocks4), Integer(Value.SaveSocks5), Integer(Value.SaveBad),
    Integer(Value.SaveToFile), Integer(Value.SaveToLocalServer), Integer(Value.AddGoodProxyToTable),
    Value.Id]));
end;

{ TDatabase }

procedure TDatabase.Connect(const FileName: string);
begin
  Disconnect;

  FConnection.DriverName := 'SQLite';
  FConnection.Params.Values['Database'] := FileName;
  FConnection.LoginPrompt := False;

  try
    FConnection.Open;

  except
    on E: EDatabaseError do
      ShowMessage('Database connect error. Message: ' + E.Message);
  end;

end;

constructor TDatabase.Create;
begin
  FConnection := TFDConnection.Create(nil);

  FProxySourcesTable := TProxySourcesTable.Create(FConnection, 'ProxySources');
  FCheckerPresetsTable := TCheckerPresetsTable.Create(FConnection, 'CheckerPresets');
end;

destructor TDatabase.Destroy;
begin
  Disconnect;

  FCheckerPresetsTable.Free;
  FProxySourcesTable.Free;

  FConnection.Free;
  inherited;
end;

procedure TDatabase.Disconnect;
begin
  FConnection.Close;
end;

end.
