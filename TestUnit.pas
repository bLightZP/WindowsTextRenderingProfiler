{$DEFINE TEXTRENDERTRACE}
unit TestUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TTestForm = class(TForm)
    TestImage: TImage;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure TestImageClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TestForm: TTestForm;

implementation

{$R *.dfm}

procedure TTestForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  Close;
end;

procedure TTestForm.TestImageClick(Sender: TObject);
begin
  Close;
end;

end.
