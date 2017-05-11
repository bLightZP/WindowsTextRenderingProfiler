program WinTextRendererProfiler;

uses
  Forms,
  setupunit in 'setupunit.pas' {SetupForm},
  TestUnit in 'TestUnit.pas' {TestForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TSetupForm, SetupForm);
  Application.CreateForm(TTestForm, TestForm);
  Application.Run;
end.
