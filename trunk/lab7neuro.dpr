program lab7neuro;

uses
  Forms,
  lab7 in 'lab7.pas' {Form1},
  bkpropag in 'bkpropag.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'wneuro';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
