unit uScheduler;

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
  Winapi.Windows, System.SysUtils, System.Classes, System.Threading, System.Diagnostics,
  System.Generics.Collections, System.SyncObjs, uProxyCheckerService, uProxyGrabberService,
  uProxy, uTypes;

type
  TScheduler = class
  strict private
    FProxyCheckerService: TProxyCheckerService;
    FProxyGrabberService: TProxyGrabberService;
    FTask: ITask;
    FStartTic: Int64;
    FStop: Boolean;
    FPeriod: Cardinal;
    FStopSignal: TEvent;
    FCheckerPreset: TCheckerPreset;
    function GetRemain: Int64;
    function GetRemainTimeStamp: string;
    procedure WaitForObject(const Handle: THandle);
  public
    property CheckerPreset: TCheckerPreset read FCheckerPreset write FCheckerPreset;
    property Period: Cardinal read FPeriod;
    property Remain: Int64 read GetRemain;
    property RemainTimeStamp: string read GetRemainTimeStamp;
    constructor Create(ProxyCheckerService: TProxyCheckerService; ProxyGrabberService: TProxyGrabberService);
    destructor Destroy; override;
    procedure Start(const Period: Cardinal; const CheckerThreadCount, GrabberThreadCount: Integer);
    procedure Stop;
    function IsRunning: Boolean;
  end;

implementation

uses
  uUtils;

{ TScheduler }

constructor TScheduler.Create(ProxyCheckerService: TProxyCheckerService; ProxyGrabberService: TProxyGrabberService);
begin
  FStop := False;
  FStartTic := 0;
  FPeriod := 0;
  FProxyCheckerService := ProxyCheckerService;
  FProxyGrabberService := ProxyGrabberService;
  FStopSignal := TEvent.Create;
  FCheckerPreset.Clear;

end;

destructor TScheduler.Destroy;
begin
  if IsRunning then
  begin
    Stop;
    FTask.Wait(50);
  end;

  FStopSignal.Free;
  inherited;
end;

function TScheduler.GetRemain: Int64;
begin
  Result := FStartTic + FPeriod - Int64(GetTickCount64);

  if Result < 0 then
    Result := 0;
end;

function TScheduler.GetRemainTimeStamp: string;
begin
  Result := FormatDateTime('hh:nn:ss', GetRemain / MSecsPerDay);
end;

function TScheduler.IsRunning: Boolean;
begin
  Result := Assigned(FTask) and (FTask.Status = TTaskStatus.Running);
end;

procedure TScheduler.Start(const Period: Cardinal; const CheckerThreadCount, GrabberThreadCount: Integer);
begin
  if (CheckerThreadCount < 1) or (GrabberThreadCount < 1) then
    raise EArgumentOutOfRangeException.Create('Thread count value must be positive.');

  if IsRunning then
    Exit;

  FStop := False;
  FStopSignal.ResetEvent;
  FPeriod := Period;
  FProxyCheckerService.Preset := FCheckerPreset;

  FTask := TTask.Run
 (procedure()
  begin
    repeat
      FStartTic := GetTickCount64;

      try
        { Grabbing }
        if not FProxyGrabberService.IsRunning then
        begin
          FProxyGrabberService.Start(GrabberThreadCount);
          WaitForObject(FProxyGrabberService.FinishEvent.Handle);

          if FStop then
            Break;

          { Checking }
          if not FProxyCheckerService.IsRunning then
          begin
            FProxyCheckerService.Proxies.Clear;
            FProxyCheckerService.Proxies.LoadFromDictionary(FProxyGrabberService.Results);
            FProxyCheckerService.Start(CheckerThreadCount);
            WaitForObject(FProxyCheckerService.FinishEvent.Handle);
          end;

        end;

        WaitForSingleObject(FStopSignal.Handle, GetRemain);
        FStopSignal.ResetEvent;

      except
        Break;
      end;

    until FStop;

  end);

end;

procedure TScheduler.Stop;
begin
  if IsRunning then
  begin
    FStop := True;
    FStopSignal.SetEvent;

    FProxyGrabberService.Stop;
    FProxyCheckerService.Stop;
  end;
end;

procedure TScheduler.WaitForObject(const Handle: THandle);
var
  Handles: Array[0 .. 1] of THandle;
begin
  Handles[0] := FStopSignal.Handle;
  Handles[1] := Handle;
  WaitForMultipleObjects(Length(Handles), @Handles, False, INFINITE);
end;

end.
