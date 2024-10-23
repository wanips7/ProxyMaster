program ProxyMaster;

uses
  Winapi.Windows,
  System.SysUtils,
  Vcl.Forms,
  uMain in 'uMain.pas' {MainForm},
  uProxyParser in 'uProxyParser.pas',
  uAddProxies in 'uAddProxies.pas' {AddProxiesForm},
  uConst in 'uConst.pas',
  uEditProxySource in 'uEditProxySource.pas' {EditProxySourceForm},
  uEditCheckerPreset in 'uEditCheckerPreset.pas' {EditCheckerPresetForm},
  uProxyChecker in 'uProxyChecker.pas',
  uHttpClient in 'uHttpClient.pas',
  uProxyGeo in 'uProxyGeo.pas',
  uScheduler in 'uScheduler.pas',
  uProxyGrabberService in 'uProxyGrabberService.pas',
  uClientIp in 'uClientIp.pas',
  uUrlParser in 'uUrlParser.pas',
  uUtils in 'uUtils.pas';

{$R *.res}

var
  AppMutex: THandle;
begin
  AppMutex := CreateMutex(nil, False, '{179B5662-42D7-4E73-B5F9-918EB8A806A0}');
  if AppMutex = 0 then
    RaiseLastOSError;

  if GetLastError = ERROR_ALREADY_EXISTS then
    Exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAddProxiesForm, AddProxiesForm);
  Application.CreateForm(TEditProxySourceForm, EditProxySourceForm);
  Application.CreateForm(TEditCheckerPresetForm, EditCheckerPresetForm);
  MainForm.Prepare;

  Application.Run;

  CloseHandle(AppMutex);
end.
