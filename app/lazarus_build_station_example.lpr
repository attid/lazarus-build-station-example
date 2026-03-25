program LazarusBuildStationExample;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces,
  Forms,
  MainForm;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Title := 'Lazarus Build Station Example';
  Application.Initialize;
  Application.CreateForm(TDemoMainForm, DemoMainForm);
  Application.Run;
end.
