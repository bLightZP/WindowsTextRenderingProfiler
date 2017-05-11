{$DEFINE TEXTRENDERTRACE}
unit misc_utils_unit;


     {********************************************************************
      | This Source Code is subject to the terms of the                  |
      | Mozilla Public License, v. 2.0. If a copy of the MPL was not     |
      | distributed with this file, You can obtain one at                |
      | https://mozilla.org/MPL/2.0/.                                    |
      |                                                                  |
      | Software distributed under the License is distributed on an      |
      | "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or   |
      | implied. See the License for the specific language governing     |
      | rights and limitations under the License.                        |
      ********************************************************************}

      { This sample code uses the TNT Delphi Unicode Controls (compatiable
        with the last free version) to handle a few unicode tasks. }

interface

uses
  Windows, Classes, TNTClasses, Graphics;


function  TickCount64 : Int64;

procedure DebugMsgF(FileName : WideString; Txt : WideString);
procedure DebugMsgFT(FileName : WideString; Txt : WideString);

function  IntToStrDelimiter(iSrc : Int64; dChar : Char) : String;
function  DosToAnsi(S: String): String;

function  InputComboW(ownerWindow: THandle; const ACaption, APrompt: Widestring; const AList: TTNTStrings; var AOutput : WideString) : Boolean;

procedure Split(S : String; Ch : Char; sList : TStrings); overload;
procedure Split(S : WideString; Ch : Char; sList : TTNTStrings); overload;

procedure FinalizeDebugList;
procedure RenderText(oBitmap : TBitmap; X,Y : Integer; cRect : TRect; S : WideString; testFunction : Integer; TxtEffect : Integer; EffectColor : TColor; Clipping : Boolean);

const
  {$IFDEF TEXTRENDERTRACE}
  Logfile           : WideString = 'c:\log\.TextRender.txt';
  {$ENDIF}

var
  TickCountLast    : DWORD = 0;
  TickCountBase    : Int64 = 0;
  DebugStartTime   : Int64 = -1;
  qTimer64Freq     : Int64;


implementation

uses
  SysUtils, SyncObjs, TNTSysUtils, wininet, dateutils, forms, tntforms, stdctrls, tntStdCtrls, controls;


var
  csDebug          : TCriticalSection;
  DebugList        : TTNTStringList = nil;


function TickCount64 : Int64;
begin
  Result := GetTickCount;
  If Result < TickCountLast then TickCountBase := TickCountBase+$100000000;
  TickCountLast := Result;
  Result := Result+TickCountBase;
end;


procedure DebugMsgFT(FileName : WideString; Txt : WideString);
var
  S,S1 : String;
  i64  : Int64;
begin
  If FileName <> '' then
  Begin
    QueryPerformanceCounter(i64);
    S := FloatToStrF(((i64-DebugStartTime)*1000) / qTimer64Freq,ffFixed,15,3);
    While Length(S) < 12 do S := ' '+S;
    S1 := DateToStr(Date)+' '+TimeToStr(Time);
    DebugMsgF(FileName,S1+' ['+S+'] : '+Txt);
  End;
end;


procedure DebugMsgF(FileName : WideString; Txt : WideString);
var
  fStream  : TTNTFileStream;
begin
  If csDebug <> nil then csDebug.Enter;
  Try
    If (DebugList = nil) then
    Begin
      DebugList := TTNTStringList.Create;
    End
    Else DebugList.Add(FileName+'|'+Txt);
  Finally
    If csDebug <> nil then csDebug.Leave;
  End;
end;


function IntToStrDelimiter(iSrc : Int64; dChar : Char) : String;
var
  I : Integer;
  S : String;
begin
  S      := IntToStr(iSrc);
  Result := S;
  I      := Length(S)-2;
  While I > 1 do
  Begin
    Insert(dChar,Result,I);
    Dec(I,3);
  End;
end;


function DosToAnsi(S: String): String;
begin
  SetLength(Result, Length(S));
  OEMToCharBuff(PChar(S), PChar(Result), Length(S));
end;


function InputComboW(ownerWindow: THandle; const ACaption, APrompt: Widestring; const AList: TTNTStrings; var AOutput : WideString) : Boolean;

  function GetCharSize(Canvas: TCanvas): TPoint;
  var
    I: Integer;
    Buffer: array[0..51] of Char;
  begin
    for I := 0 to 25 do Buffer[I] := Chr(I + Ord('A'));
    for I := 0 to 25 do Buffer[I + 26] := Chr(I + Ord('a'));
    GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
    Result.X := Result.X div 52;
  end;  
  
var
  Form         : TTNTForm;
  Prompt       : TTNTLabel;
  Combo        : TTNTComboBox;
  DialogUnits  : TPoint;
  ButtonTop,
  ButtonWidth,
  ButtonHeight : Integer;
  CenterOnRect : TRect;
begin
  AOutput := '';
  Result  := False;
  Form    := TTNTForm.Create(nil);
  with Form do
    try
      Canvas.Font := Font;
      DialogUnits := GetCharSize(Canvas);
      BorderStyle := bsDialog;
      Caption     := ACaption;
      ClientWidth := MulDiv(180, DialogUnits.X, 4);
      Prompt      := TTNTLabel.Create(Form);
      with Prompt do
      begin
        Parent   := Form;
        Caption  := APrompt;
        Left     := MulDiv(8, DialogUnits.X, 4);
        Top      := MulDiv(8, DialogUnits.Y, 8);
        Constraints.MaxWidth := MulDiv(164, DialogUnits.X, 4);
        WordWrap := True;
      end;
      Combo := TTNTComboBox.Create(Form);
      with Combo do
      begin
        Parent     := Form;
        Style      := csDropDownList;
        Items.Assign(AList);
        ItemIndex  := 0;
        Left       := Prompt.Left;
        Top        := Prompt.Top + Prompt.Height + 5;
        Width      := MulDiv(164, DialogUnits.X, 4);
      end;
      ButtonTop    := Combo.Top + Combo.Height + 15;
      ButtonWidth  := MulDiv(50, DialogUnits.X, 4);
      ButtonHeight := MulDiv(14, DialogUnits.Y, 8);
      with TTNTButton.Create(Form) do
      begin
        Parent      := Form;
        Caption     := 'OK';
        ModalResult := mrOk;
        default     := True;
        SetBounds(MulDiv(38, DialogUnits.X, 4), ButtonTop, ButtonWidth, ButtonHeight);
      end;
      with TTNTButton.Create(Form) do
      begin
        Parent      := Form;
        Caption     := 'Cancel';
        ModalResult := mrCancel;
        Cancel      := True;
        SetBounds(MulDiv(92, DialogUnits.X, 4), Combo.Top + Combo.Height + 15, ButtonWidth, ButtonHeight);
        Form.ClientHeight := Top + Height + 13;
      end;

      If GetWindowRect(ownerWindow,CenterOnRect) = False then
        GetWindowRect(0,CenterOnRect); // Can't find window, center on screen

      SetBounds(CenterOnRect.Left+(((CenterOnRect.Right-CenterOnRect.Left)-Width) div 2),CenterOnRect.Top+(((CenterOnRect.Bottom-CenterOnRect.Top)-Height) div 2),Width,Height);

      if ShowModal = mrOk then
      begin
        AOutput := Combo.Text;
        Result  := True;
      end;
    finally
      Form.Free;
    end;
end;

procedure Split(S : String; Ch : Char; sList : TStrings); overload;
var
  I : Integer;
begin
  While Pos(Ch,S) > 0 do
  Begin
    I := Pos(Ch,S);
    sList.Add(Copy(S,1,I-1));
    Delete(S,1,I);
  End;
  If Length(S) > 0 then sList.Add(S);
end;


procedure Split(S : WideString; Ch : Char; sList : TTNTStrings); overload;
var
  I : Integer;
begin
  While Pos(Ch,S) > 0 do
  Begin
    I := Pos(Ch,S);
    sList.Add(Copy(S,1,I-1));
    Delete(S,1,I);
  End;
  If Length(S) > 0 then sList.Add(S);
end;


Procedure RenderText(oBitmap : TBitmap; X,Y : Integer; cRect : TRect; S : WideString; testFunction : Integer; TxtEffect : Integer; EffectColor : TColor; Clipping : Boolean);
var
  srcColor : TColor;
  I        : Integer;
  iShadow  : Integer;
  iFlags   : Integer;
begin
  {$IFDEF TEXTRENDERTRACE}
  DebugMsgFT(LogFile,CRLF+CRLF+
                     'Rect   : X='+IntToStr(X)+', Y='+IntToStr(Y)+', Left='+IntToStr(cRect.Left)+', Top='+IntToStr(cRect.Top)+', Right='+IntToStr(cRect.Right)+', Bottom='+IntToStr(cRect.Bottom)+CRLF+
                     'Font   : Height='+IntToStr(oBitmap.Canvas.Font.Height)+', Clipping='+BoolToStr(Clipping,True)+', Function='+IntToStr(testFunction)+CRLF+
                     'Bitmap : Width='+IntToStr(oBitmap.Width)+', Height='+IntToStr(oBitmap.Height)+CRLF);
  {$ENDIF}
  I := Length(S);
  SetBkMode(oBitmap.Canvas.Handle, TRANSPARENT);

  Case testFunction of
    0  : If Clipping = True then iFlags := ETO_CLIPPED else iFlags := 0;
    1  : If Clipping = True then iFlags := DT_NOCLIP or DT_NOPREFIX or DT_SINGLELINE else iFlags := DT_NOPREFIX or DT_SINGLELINE; 
    else iFlags := 0;
  End;

  Case TxtEffect of
    0 :
    Begin
      {$IFDEF TEXTRENDERTRACE}DebugMsgFT(LogFile,'Render Text "'+S+'"');{$ENDIF}
      Case testFunction of
        0 : Windows.ExtTextOutW(oBitmap.Canvas.Handle,X  ,Y  ,iFlags,@cRect,@S[1],I,nil);
        1 : Windows.DrawTextExW(oBitmap.Canvas.Handle,@S[1],I,cRect,DT_NOPREFIX	or DT_SINGLELINE,nil);
      End;
    End;
    1 : // Outline
    Begin
      srcColor := oBitmap.Canvas.Font.Color;
      oBitmap.Canvas.Font.Color  := EffectColor;
      Case testFunction of
        0 :
        Begin
           {$IFDEF TEXTRENDERTRACE}DebugMsgFT(LogFile,'Render Text Outline');{$ENDIF}
          Windows.ExtTextOutW(oBitmap.Canvas.Handle,X+1,Y  ,iFlags,@cRect,@S[1],I,nil);
          Windows.ExtTextOutW(oBitmap.Canvas.Handle,X-1,Y  ,iFlags,@cRect,@S[1],I,nil);
          Windows.ExtTextOutW(oBitmap.Canvas.Handle,X  ,Y+1,iFlags,@cRect,@S[1],I,nil);
          Windows.ExtTextOutW(oBitmap.Canvas.Handle,X  ,Y-1,iFlags,@cRect,@S[1],I,nil);
          oBitmap.Canvas.Font.Color := srcColor;
          {$IFDEF TEXTRENDERTRACE}DebugMsgFT(LogFile,'Render Text "'+S+'"');{$ENDIF}
          Windows.ExtTextOutW(oBitmap.Canvas.Handle,X  ,Y  ,iFlags,@cRect,@S[1],I,nil);
        End;
        1 : // Incomplete
        Begin
          {$IFDEF TEXTRENDERTRACE}DebugMsgFT(LogFile,'Not implemented');{$ENDIF}
        End;
      End;
    End;
    2 : // Drop Shadow
    Begin
      {$IFDEF TEXTRENDERTRACE}DebugMsgFT(LogFile,'Calculate Shadow');{$ENDIF}
      iShadow  := (oBitmap.Height div 540);
      If iShadow = 0 then iShadow := 1;
      {$IFDEF TEXTRENDERTRACE}DebugMsgFT(LogFile,'Set Shadow Color');{$ENDIF}
      srcColor := oBitmap.Canvas.Font.Color;
      oBitmap.Canvas.Font.Color := EffectColor;
      Case testFunction of
        0 :
        Begin
          {$IFDEF TEXTRENDERTRACE}DebugMsgFT(LogFile,'Render Text Shadow');{$ENDIF}
          Windows.ExtTextOutW(oBitmap.Canvas.Handle,X  ,Y+iShadow,iFlags,@cRect,@S[1],I,nil);
          oBitmap.Canvas.Font.Color := srcColor;
          Windows.ExtTextOutW(oBitmap.Canvas.Handle,X  ,Y        ,iFlags,@cRect,@S[1],I,nil);
        End;
        1 :
        Begin
          {$IFDEF TEXTRENDERTRACE}DebugMsgFT(LogFile,'Render Text Shadow');{$ENDIF}
          Inc(cRect.Top,iShadow);
          Windows.DrawTextExW(oBitmap.Canvas.Handle,@S[1],I,cRect,iFlags,nil);
          Dec(cRect.Top,iShadow);
          oBitmap.Canvas.Font.Color := srcColor;
          {$IFDEF TEXTRENDERTRACE}DebugMsgFT(LogFile,'Render Text "'+S+'"');{$ENDIF}
          Windows.DrawTextExW(oBitmap.Canvas.Handle,@S[1],I,cRect,iFlags,nil);
        End;
      End;
    End;
  End;
  {$IFDEF TEXTRENDERTRACE}DebugMsgFT(LogFile,'Rendering complete'+CRLF);{$ENDIF}
end;


procedure FinalizeDebugList;
var
  I,iPos    : Integer;
  FileName  : WideString;
  Txt       : WideString;
  sList     : TTNTStringList;
  fStream   : TTNTFileStream;
  S         : String;
begin
  If DebugList <> nil then
  Begin
    sList := TTNTStringList.Create;
    For I := 0 to DebugList.Count-1 do
    Begin
      sList.Clear;
      Split(DebugList[I],'|',sList);
      FileName := sList[0];
      If sList.Count > 1 then Txt := sList[1] else Txt := '';

      If WideFileExists(FileName) = True then
      Begin
        Try
          fStream := TTNTFileStream.Create(FileName,fmOpenWrite);
        Except
          fStream := nil;
        End;
      End
        else
      Begin
        Try
          fStream := TTNTFileStream.Create(FileName,fmCreate);
        Except
          fStream := nil;
        End;
      End;
      If fStream <> nil then
      Begin
        S := UTF8Encode(Txt)+CRLF;
        fStream.Seek(0,soFromEnd);
        fStream.Write(S[1],Length(S));
        fStream.Free;
      End;
    End;
    sList.Free;
    FreeAndNil(DebugList);
  End;
end;


initialization
  QueryPerformanceFrequency(qTimer64Freq);
  QueryPerformanceCounter(DebugStartTime);
  csDebug := TCriticalSection.Create;

finalization
  csDebug.Free;

end.