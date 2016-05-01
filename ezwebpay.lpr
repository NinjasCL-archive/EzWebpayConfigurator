program ezwebpay;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, MainForm
  { you can add units after this };

{$R *.res}

begin
  Application.Title:='EzWebpay';
  Application.Initialize;
  Application.CreateForm(TMainForm, MainViewController);
  Application.Run;
end.

