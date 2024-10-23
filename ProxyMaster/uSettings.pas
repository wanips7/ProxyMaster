unit uSettings;

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
  Winapi.Windows, System.SysUtils, System.Classes, System.IniFiles,
  System.Rtti, System.TypInfo;

type
  ESettingsException = class(Exception);

type
  SettingsAttribute = class(TCustomAttribute)
  strict private
    FSection: string;
    FDefaultValue: string;
  public
    constructor Create(const Section, DefaultValue: string); overload;
    constructor Create(const Section: string; DefaultValue: Integer); overload;
    constructor Create(const Section:string; DefaultValue: Boolean); overload;
    property Section: string read FSection;
    property DefaultValue: string read FDefaultValue;
  end;

type
  PSettingsData = ^TSettingsData;
  TSettingsData = record
  public const
    SECTION_MAIN = 'Main';
  public
    [Settings(SECTION_MAIN, 1)]
    CheckerThreadCount: Integer;
    [Settings(SECTION_MAIN, 1)]
    GrabberThreadCount: Integer;

    [Settings(SECTION_MAIN, 0)]
    ActiveCheckerPresetID: Integer;
    [Settings(SECTION_MAIN, 0)]
    ActiveSchedulerCheckerPresetID: Integer;

    [Settings(SECTION_MAIN, 10)]
    SchedulerPeriod: Integer;
    [Settings(SECTION_MAIN, 8000)]
    LocalServerPort: Integer;

    [Settings(SECTION_MAIN, False)]
    AddGrabbedProxiesToTable: Boolean;
    [Settings(SECTION_MAIN, False)]
    SaveGrabbedProxiesToFile: Boolean;
  end;

type
  TSettings = class
  public const
    DEFAULT_SECTION = 'Main';
  strict private class var
    FFile: TIniFile;
    FData: TSettingsData;
    class function GetSettingsData: PSettingsData; static;
  protected
    class procedure Init; static;
    class procedure Deinit; static;
    class procedure CheckFile; static;
  public
    class property Data: PSettingsData read GetSettingsData;
    class procedure Load(const FileName: string); static;
    class procedure Save; static;
    class function IsLoaded: Boolean; static;
  end;

implementation

{ SettingsAttribute }

constructor SettingsAttribute.Create(const Section, DefaultValue: string);
begin
  if Section.IsEmpty then
    raise ESettingsException.Create('Error: section value is empty.');

  FSection := Section;
  FDefaultValue := DefaultValue;
end;

constructor SettingsAttribute.Create(const Section: string; DefaultValue: Boolean);
begin
  Create(Section, DefaultValue.ToString);
end;

constructor SettingsAttribute.Create(const Section: string; DefaultValue: Integer);
begin
  Create(Section, DefaultValue.ToString);
end;

procedure RaiseUnknownFieldType(const FieldName: string);
begin
  raise ESettingsException.CreateFmt('Error: field %s has unknown type.', [FieldName]);
end;

{ TSettings }

class procedure TSettings.Init;
begin
  FData := Default(TSettingsData);
  FFile := nil;
end;

class function TSettings.IsLoaded: Boolean;
begin
  Result := Assigned(FFile);
end;

class procedure TSettings.CheckFile;
begin
  if not IsLoaded then
    raise ESettingsException.Create('Error: settings file is not specified.');
end;

class procedure TSettings.Deinit;
begin
  FFile.Free;
end;

class function TSettings.GetSettingsData: PSettingsData;
begin
  CheckFile;

  Result := @FData;
end;

class procedure TSettings.Load(const FileName: string);
var
  Rec: TRttiRecordType;
  Context: TRttiContext;
  Field: TRttiField;
  Value: TValue;
  Section: string;
  Attribute: SettingsAttribute;
  DefaultValue: string;
  Str: string;
begin
  FreeAndNil(FFile);
  FFile := TIniFile.Create(FileName);

  FData := Default(TSettingsData);

  Context := TRttiContext.Create;
  try
    Rec := Context.GetType(TypeInfo(TSettingsData)).AsRecord;
    for Field in Rec.GetFields do
    begin
      Value := Field.GetValue(@FData);

      if Field.HasAttribute<SettingsAttribute> then
      begin
        Attribute := Field.GetAttribute<SettingsAttribute>;

        Section := Attribute.Section;
        DefaultValue := Attribute.DefaultValue;
      end
        else
      begin
        Section := DEFAULT_SECTION;
        DefaultValue := '';
      end;

      Str := FFile.ReadString(Section, Field.Name, DefaultValue);

      case Field.FieldType.TypeKind of
        tkString, tkLString, tkWString, tkUString:
        begin
          Value := Str;
        end;

        tkInteger:
        begin
          var v: Integer := 0;
          TryStrToInt(Str, v);
          Value := v;
        end;

        tkFloat:
        begin
          var v: Single := 0;
          TryStrToFloat(Str, v);
          Value := v;
        end;

        else
          if Value.IsType<Boolean> then
          begin
            var v: Boolean := False;
            TryStrToBool(Str, v);
            Value := v;
          end
            else
          if Value.IsType<Double> then
          begin
            var v: Double := 0;
            TryStrToFloat(Str, v);
            Value := v;
          end
            else
          begin
            RaiseUnknownFieldType(Field.Name);
          end;

      end;

      Field.SetValue(@FData, Value);

    end;

  finally
    Context.Free;
  end;

end;


class procedure TSettings.Save;
var
  Rec: TRttiRecordType;
  Context: TRttiContext;
  Field: TRttiField;
  Value: TValue;
  Section: string;
  Attribute: SettingsAttribute;
begin
  CheckFile;

  Context := TRttiContext.Create;

  try
    Rec := Context.GetType(TypeInfo(TSettingsData)).AsRecord;
    for Field in Rec.GetFields do
    begin
      Value := Field.GetValue(@FData);

      if Field.HasAttribute<SettingsAttribute> then
      begin
        Attribute := Field.GetAttribute<SettingsAttribute>;

        Section := Attribute.Section;
      end
        else
      begin
        Section := DEFAULT_SECTION;
      end;

      case Field.FieldType.TypeKind of
        tkString, tkLString, tkWString, tkUString:
        begin
          FFile.WriteString(Section, Field.Name, Value.AsString);
        end;

        tkInteger:
        begin
          FFile.WriteInteger(Section, Field.Name, Value.AsInteger);
        end;

        tkFloat:
        begin
          FFile.WriteFloat(Section, Field.Name, Value.AsType<Single>);
        end;

        else
          if Value.IsType<Boolean> then
          begin
            FFile.WriteBool(Section, Field.Name, Value.AsBoolean);
          end
            else
          if Value.IsType<Double> then
          begin
            FFile.WriteFloat(Section, Field.Name, Value.AsType<Double>);
          end
            else
          begin
            RaiseUnknownFieldType(Field.Name);
          end;

      end;
    end;

  finally
    Context.Free;
  end;

end;

initialization
  TSettings.Init;

finalization
  TSettings.Deinit;

end.
