unit uEditCheckerPreset;

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
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.NumberBox, uTypes;

type
  TEditCheckerPresetForm = class(TForm)
    SaveButton: TButton;
    PageControl: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Label1: TLabel;
    PresetNameEdit: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    NumberBox1: TNumberBox;
    Label4: TLabel;
    Memo1: TMemo;
    Label5: TLabel;
    Edit3: TEdit;
    TabSheet4: TTabSheet;
    CheckBox2: TCheckBox;
    GroupBox1: TGroupBox;
    CheckBox4: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    Label6: TLabel;
    NumberBox2: TNumberBox;
    CheckBox8: TCheckBox;
    Label7: TLabel;
    Edit1: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    ComboBox1: TComboBox;
    NumberBox3: TNumberBox;
    CountriesHelpButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure CountriesHelpButtonClick(Sender: TObject);
  strict private
    FCheckerPreset: TCheckerPreset;
    procedure Clear;
    procedure Fill(const CheckerPreset: TCheckerPreset);
    function IsDataValid: Boolean;
    procedure SetFirstPage;
    procedure ShowMessageBox(const Text, Title: string);
    procedure ShowErrorMessageBox(const Text: string);
  public
    procedure ShowModalForAdding;
    procedure ShowModalForEditing(const CheckerPreset: TCheckerPreset);
  end;

var
  EditCheckerPresetForm: TEditCheckerPresetForm;

implementation

{$R *.dfm}

uses
  uDatabase;

const
  DEFAULT_USER_AGENT =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36';
  DEFAULT_REQUEST_HEADERS =
    'Accept-Language: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7' + sLineBreak +
    'Accept-Encoding: gzip, deflate';

{ TEditCheckingPresetForm }

procedure TEditCheckerPresetForm.Clear;
begin
  FCheckerPreset := default(TCheckerPreset);
  Fill(FCheckerPreset);

  Edit3.Text := DEFAULT_USER_AGENT;
  Memo1.Text := DEFAULT_REQUEST_HEADERS;
  NumberBox1.ValueInt := 5000;
  NumberBox2.ValueInt := 200;
  CheckBox4.Checked := True;
  CheckBox3.Checked := True;
  CheckBox5.Checked := True;
end;

procedure TEditCheckerPresetForm.CountriesHelpButtonClick(Sender: TObject);
begin
  ShowMessageBox('Use ISO country codes and '','' as a separator.', 'Help');
end;

procedure TEditCheckerPresetForm.Fill(const CheckerPreset: TCheckerPreset);
begin
  FCheckerPreset := CheckerPreset;

  PresetNameEdit.Text := CheckerPreset.Name;

  Edit2.Text := CheckerPreset.Request.Url;
  NumberBox1.ValueInt := CheckerPreset.Request.Timeout;
  Memo1.Text := CheckerPreset.Request.Headers;
  Edit3.Text := CheckerPreset.Request.UserAgent;

  NumberBox2.ValueInt := CheckerPreset.GoodProxy.StatusCode;
  Edit1.Text := CheckerPreset.GoodProxy.Countries;
  ComboBox1.ItemIndex := Integer(CheckerPreset.GoodProxy.AnonymityLevel);
  NumberBox3.ValueFloat := CheckerPreset.GoodProxy.MaxPing;

  CheckBox4.Checked := CheckerPreset.ProxySaving.Http;
  CheckBox3.Checked := CheckerPreset.ProxySaving.Socks4;
  CheckBox5.Checked := CheckerPreset.ProxySaving.Socks5;
  CheckBox6.Checked := CheckerPreset.ProxySaving.Bad;
  CheckBox7.Checked := CheckerPreset.ProxySaving.ToFile;
  CheckBox8.Checked := CheckerPreset.ProxySaving.ToLocalServer;

  CheckBox2.Checked := CheckerPreset.AddGoodProxyToTable;

end;

procedure TEditCheckerPresetForm.FormCreate(Sender: TObject);
begin
  Clear;
  SetFirstPage;
end;

function TEditCheckerPresetForm.IsDataValid: Boolean;
begin
  Result :=
    (PresetNameEdit.Text <> '') and
    (Edit2.Text <> '') and (Edit3.Text <> '') and (Memo1.Text <> '');

end;

procedure TEditCheckerPresetForm.SaveButtonClick(Sender: TObject);
begin
  if not IsDataValid then
  begin
    ShowErrorMessageBox('The data is invalid.');
    Exit;
  end;

  FCheckerPreset.Name := PresetNameEdit.Text;

  FCheckerPreset.Request.Url := Edit2.Text;
  FCheckerPreset.Request.Timeout := NumberBox1.ValueInt;
  FCheckerPreset.Request.Headers := Memo1.Text;
  FCheckerPreset.Request.UserAgent := Edit3.Text;

  FCheckerPreset.GoodProxy.StatusCode := NumberBox2.ValueInt;
  FCheckerPreset.GoodProxy.Countries := Edit1.Text;
  FCheckerPreset.GoodProxy.AnonymityLevel := TAnonymityLevel(ComboBox1.ItemIndex);
  FCheckerPreset.GoodProxy.MaxPing := NumberBox3.ValueFloat;

  FCheckerPreset.ProxySaving.Http := CheckBox4.Checked;
  FCheckerPreset.ProxySaving.Socks4 := CheckBox3.Checked;
  FCheckerPreset.ProxySaving.Socks5 := CheckBox5.Checked;
  FCheckerPreset.ProxySaving.Bad := CheckBox6.Checked;
  FCheckerPreset.ProxySaving.ToFile := CheckBox7.Checked;
  FCheckerPreset.ProxySaving.ToLocalServer := CheckBox8.Checked;

  FCheckerPreset.AddGoodProxyToTable := CheckBox2.Checked;

  if FCheckerPreset.Id = 0 then
  begin
    if Database.CheckerPresetsTable.ContainsName(PresetNameEdit.Text) then
    begin
      ShowErrorMessageBox('A preset with this name already exists.');
      Exit;
    end;

    Database.CheckerPresetsTable.Add(FCheckerPreset);
  end
    else
  begin
    Database.CheckerPresetsTable.Update(FCheckerPreset);
  end;

  Close;
end;

procedure TEditCheckerPresetForm.SetFirstPage;
begin
  PageControl.ActivePageIndex := 0;
end;

procedure TEditCheckerPresetForm.ShowErrorMessageBox(const Text: string);
begin
  MessageBox(Handle, PChar(Text), PChar('Error'), MB_OK or MB_ICONERROR);
end;

procedure TEditCheckerPresetForm.ShowMessageBox(const Text, Title: string);
begin
  MessageBox(Handle, PChar(Text), PChar(Title), MB_OK or MB_ICONINFORMATION);
end;

procedure TEditCheckerPresetForm.ShowModalForAdding;
begin
  SetFirstPage;
  Clear;
  ShowModal;
end;

procedure TEditCheckerPresetForm.ShowModalForEditing(const CheckerPreset: TCheckerPreset);
begin
  SetFirstPage;
  Fill(CheckerPreset);
  ShowModal;
end;

end.
