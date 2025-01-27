unit uAddProxies;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uProxy, uProxyList, uTypes;

type
  TAddProxiesForm = class(TForm)
    ProxiesMemo: TMemo;
    Label1: TLabel;
    ComboBox1: TComboBox;
    ClearButton: TButton;
    AddFromTextButton: TButton;
    AddFromFileButton: TButton;
    Label2: TLabel;
    procedure ClearButtonClick(Sender: TObject);
    procedure AddFromTextButtonClick(Sender: TObject);
    procedure AddFromFileButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ProxiesMemoChange(Sender: TObject);
  private
    FProxyList: TProxyList;
    FAddPlace: TAddPlace;
    function GetSelectedProtocol: TProxy.TProtocol;
    procedure Clear;
  public
    { Public declarations }
    procedure ShowModal(const AddPlace: TAddPlace);
    procedure Init(ProxyList: TProxyList);
  end;

var
  AddProxiesForm: TAddProxiesForm;

implementation

{$R *.dfm}

uses
  uMain;

procedure TAddProxiesForm.ClearButtonClick(Sender: TObject);
begin
  ProxiesMemo.Clear;
  ProxiesMemoChange(Self);
end;

procedure TAddProxiesForm.AddFromTextButtonClick(Sender: TObject);
var
  List: TProxyList;
begin
  if FAddPlace = TAddPlace.List then
  begin
    FProxyList.LoadFromText(ProxiesMemo.Text, GetSelectedProtocol);
  end
    else
  begin
    List := TProxyList.Create;
    List.LoadFromText(ProxiesMemo.Text, GetSelectedProtocol);

    MainForm.AddProxyListToTable(List, True);

    List.Free;
  end;

  Close;
end;

procedure TAddProxiesForm.AddFromFileButtonClick(Sender: TObject);
var
  OpenDialog: TFileOpenDialog;
  Item: TFileTypeItem;
  List: TProxyList;
begin
  OpenDialog := TFileOpenDialog.Create(Self);

  Item := OpenDialog.FileTypes.Add;
  Item.DisplayName := 'Text file';
  Item.FileMask := '*.txt';

  if OpenDialog.Execute then
  begin
    if FAddPlace = TAddPlace.List then
    begin
      FProxyList.LoadFromFile(OpenDialog.FileName, GetSelectedProtocol);
    end
      else
    begin
      List := TProxyList.Create;
      List.LoadFromFile(OpenDialog.FileName, GetSelectedProtocol);

      MainForm.AddProxyListToTable(List, True);

      List.Free;
    end;

    Close;
  end;

  OpenDialog.Free;
end;

procedure TAddProxiesForm.Clear;
begin
  ComboBox1.ItemIndex := 0;
  ProxiesMemo.Clear;
  ProxiesMemoChange(Self);
end;

procedure TAddProxiesForm.FormCreate(Sender: TObject);
begin
  FProxyList := nil;
  FAddPlace := TAddPlace.List;
end;

function TAddProxiesForm.GetSelectedProtocol: TProxy.TProtocol;
begin
  Result := TProxy.TProtocol(ComboBox1.ItemIndex);
end;

procedure TAddProxiesForm.Init(ProxyList: TProxyList);
begin
  FProxyList := ProxyList;
end;

procedure TAddProxiesForm.ProxiesMemoChange(Sender: TObject);
begin
  Label2.Caption := 'Count: ' + ProxiesMemo.Lines.Count.ToString;
end;

procedure TAddProxiesForm.ShowModal(const AddPlace: TAddPlace);
begin
  FAddPlace := AddPlace;

  Clear;
  inherited ShowModal;

end;

end.
