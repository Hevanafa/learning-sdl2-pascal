program project;
// Using Lazarus IDE v3.4

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp, main_unit
  { you can add units after this };

type

  { TSDLDemo }

  TSDLDemo = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ TSDLDemo }

procedure TSDLDemo.DoRun;
var
  ErrorMsg: String;
  game: TGameClass;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h', 'help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }
  game := TGameClass.new;

  // stop program loop
  Terminate;
end;

constructor TSDLDemo.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TSDLDemo.Destroy;
begin
  inherited Destroy;
end;

procedure TSDLDemo.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;


var
  Application: TSDLDemo;
begin
  Application:=TSDLDemo.Create(nil);
  Application.Title:='SDLDemo';
  Application.Run;
  Application.Free;
end.

