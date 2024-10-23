unit uEditProxySource;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uTypes, Vcl.NumberBox;

type
  TEditProxySourceForm = class(TForm)
    Label1: TLabel;
    UrlEdit: TEdit;
    SaveButton: TButton;
    Label2: TLabel;
    NumberBox1: TNumberBox;
    procedure SaveButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FProxySource: TProxySource;
    procedure Clear;
    procedure Fill(const ProxySource: TProxySource);
  public
    procedure ShowModalForAdding;
    procedure ShowModalForEditing(const ProxySource: TProxySource);
  end;

var
  EditProxySourceForm: TEditProxySourceForm;

implementation

{$R *.dfm}

uses
  uDatabase;

{ TAddGrabbingSourceForm }

procedure TEditProxySourceForm.Fill(const ProxySource: TProxySource);
begin
  FProxySource := ProxySource;

  UrlEdit.Text := FProxySource.Url;
  NumberBox1.ValueInt := ProxySource.ScanDepth;
end;

procedure TEditProxySourceForm.FormCreate(Sender: TObject);
begin
  Clear;
end;

procedure TEditProxySourceForm.SaveButtonClick(Sender: TObject);
begin
  if (UrlEdit.Text = '') then
  begin
    Exit;
  end;

  FProxySource.Url := UrlEdit.Text;
  FProxySource.ScanDepth := NumberBox1.ValueInt;

  if FProxySource.Id = 0 then
  begin
    Database.ProxySourcesTable.Add(FProxySource);
  end
    else
  begin
    Database.ProxySourcesTable.Update(FProxySource);
  end;

  Close;
end;

procedure TEditProxySourceForm.Clear;
begin
  FProxySource := default(TProxySource);
  Fill(FProxySource);
end;

procedure TEditProxySourceForm.ShowModalForAdding;
begin
  Clear;
  ShowModal;
end;

procedure TEditProxySourceForm.ShowModalForEditing(const ProxySource: TProxySource);
begin
  Fill(ProxySource);
  ShowModal;
end;

end.
