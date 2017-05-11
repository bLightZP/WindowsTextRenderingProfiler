{$DEFINE TEXTRENDERTRACE}
unit setupunit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, misc_utils_unit;

type
  TSetupForm = class(TForm)
    FontButton: TButton;
    TestButton: TButton;
    TextRenderEdit: TEdit;
    LabelTextToRender: TLabel;
    FunctionRG: TRadioGroup;
    ClippingCB: TCheckBox;
    FontDialog: TFontDialog;
    IterationEdit: TEdit;
    Label1: TLabel;
    SaveLogButton: TButton;
    procedure TestButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FontButtonClick(Sender: TObject);
    procedure SaveLogButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SetupForm: TSetupForm;

implementation

{$R *.dfm}

uses testunit;


procedure TSetupForm.TestButtonClick(Sender: TObject);
var
  I              : Integer;
  iterationCount : Integer;
  cRect          : TRect;
  iHeight        : Integer;
  iLines         : Integer;
  iFunction      : Integer;
  bClipping      : Boolean;
  sText          : WideString;
  testBitmap     : TBitmap;
  i64start       : Int64;
  i64end         : Int64;
  dDuration      : Double;
  dRenderSpeed   : Double;
begin
  TestForm.TestImage.Picture.Bitmap.PixelFormat := pf32bit;
  TestForm.TestImage.Picture.Bitmap.Canvas.Brush.Color := clBlack;
  TestForm.SetBounds(0,0,SetupForm.Monitor.Width,SetupForm.Monitor.Height);
  TestForm.TestImage.Picture.Bitmap.Width  := SetupForm.Monitor.Width;
  TestForm.TestImage.Picture.Bitmap.Height := SetupForm.Monitor.Height;
  TestForm.TestImage.Picture.Bitmap.Canvas.Font.Assign(FontDialog.Font);
  TestForm.Show;

  iterationCount := StrToIntDef(IterationEdit.Text,100);
  iHeight    := Abs(FontDialog.Font.Height);
  iLines     := SetupForm.Monitor.Height div iHeight;
  sText      := TextRenderEdit.Text;
  iFunction  := FunctionRG.ItemIndex;
  bClipping  := ClippingCB.Checked;
  testBitmap := TestForm.TestImage.Picture.Bitmap;
  cRect      := Rect(0,0,testBitmap.Width,testBitmap.Height);
  testBitmap.Canvas.FillRect(cRect);

  {$IFDEF TEXTRENDERTRACE}DebugMsgFT(LogFile,'Begin Test');{$ENDIF}
  QueryPerformanceCounter(i64start);
  For I := 0 to iterationCount-1 do
  Begin
    RenderText(TestBitmap,50,(I mod iLines)*iHeight,cRect,sText,iFunction,0,0,bClipping);
    TestForm.TestImage.Refresh;
  End;
  QueryPerformanceCounter(i64End);
  dDuration    := ((i64end-i64start)*1000) / qTimer64Freq;
  dRenderSpeed := dDuration / iterationCount;
  ShowMessage('Test took '+FloatToStrF(dDuration,ffFixed,15,3)+'ms over '+IntToStr(iterationCount)+' iterations, Average render speed '+FloatToStrF(dRenderSpeed,ffFixed,15,3)+'ms');
  TestForm.Close;
  {$IFDEF TEXTRENDERTRACE}DebugMsgFT(LogFile,'Test Ended');{$ENDIF}
end;


procedure TSetupForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FinalizeDebugList;
end;


procedure TSetupForm.FontButtonClick(Sender: TObject);
begin
  FontDialog.Execute;
end;


procedure TSetupForm.SaveLogButtonClick(Sender: TObject);
begin
  FinalizeDebugList;
end;


end.
