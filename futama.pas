Unit futama;

Interface

Uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ShellAPI, FileCtrl, XPMan, Menus, MPlayer, StdCtrls, ExtCtrls,
  ComCtrls, StrUtils, IniFiles;

Type
  TForm1 = Class(TForm)
    Panel1: TPanel;
    re: TRichEdit;
    Panel2: TPanel;
    rele: TRichEdit;
    lvlepl: TListView;
    Splitter1: TSplitter;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    mp0: TMediaPlayer;
    MainMenu1: TMainMenu;
    Project: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    Exit1: TMenuItem;
    Media1: TMenuItem;
    Load1: TMenuItem;
    odmp: TOpenDialog;
    Button4: TButton;
    Button5: TButton;
    Timer1: TTimer;
    mp1: TMediaPlayer;
    sb: TStatusBar;
    Fontation1: TMenuItem;
    N1: TMenuItem;
    IdleFont1: TMenuItem;
    PassedFont1: TMenuItem;
    EditorFont1: TMenuItem;
    dummtx1: TMenuItem;
    resync1: TMenuItem;
    Button6: TButton;
    EksporKaraSub1: TMenuItem;
    ass_x: TMemo;
    Procedure Button1Click(Sender: TObject);
    Procedure Load1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure releChange(Sender: TObject);
    Procedure Open1Click(Sender: TObject);
    Procedure midlsClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure IdleFont1Click(Sender: TObject);
    procedure PassedFont1Click(Sender: TObject);
    procedure EditorFont1Click(Sender: TObject);
    procedure resync1Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure EksporKaraSub1Click(Sender: TObject);
  Private
    { Deklarasi hanya untuk penggunaan dalam unit ini saja }
  Public
    { Deklarasi untuk penggunaan ke semua unit yang terintegerasi }
    cSeparator: char;
    sFN, sFNx, sProjectName, sProjectPath, sLastFind: String;
    cKeyCut: Char;
    iCurNu,iSecNu,iLLNu,iReIdxNu,
    iSelSS, iSelSE, iLESelSS, iLESelSE, iLastLine, iLastPos, iCurPos, iLastLen, iNit, impz, iNet, iUntitledCount, iResyncBegin, iOnResync, iLastFind: Integer;
    bOnSectionCreation, bSaved, bDebugMode, bOnMarking, KillTi, KillTo, runti, onloop: Boolean;
    tcREPrimCol, tcRESecCol: TColor;
    tfREPrimFont, tfRESecFont: TFont;
  End;

Var
  Form1: TForm1;

Implementation

{$R *.dfm} //template tweaked by : Araachmadi Putra Pambudi

Function asstolrctime(wkt: String): String;
Var
  s: String;
  r: real;
Begin
  s := Copy(wkt, 3, 5);
  r := Round(strtofloat(Copy(wkt, 9, 3)) / 10);
  result := s + ':' + floattostr(r);
End;

Function goodfn(fn: String): String;
Const
  badchar: Array[0..8] Of Char = (':', '<', '>', '?', '/', '\', '|', '*', '"');
Var
  i: Integer;
Begin
  result := fn;
  For i := 0 To Length(badchar) - 1 Do
    result := StringReplace(result, badchar[i], '-', [rfreplaceall]);
End;

Procedure saveklp(saveas: Boolean);
Var
  tsd: TSaveDialog;
  tif: TIniFile;
  i: Integer;
  bOnMP, bTimerOn: Boolean;
  iMPv: Integer;
Begin
  With futama.Form1 Do
  Begin

    iMPv := 0;

    If mp0.Mode = mpPlaying Then
    Begin
      mp0.Pause;
      bOnMP := True;
      iMPv := 1;
    End;

    If mp1.Mode = mpPlaying Then
    Begin
      mp1.Pause;
      bOnMP := True;
      iMPv := 2;
    End;

    If Not saveas Then
    Begin
      tsd := TSaveDialog.Create(nil);
      tsd.Title := 'Save Project';
      tsd.Filter := 'Karaz Project|*.klp';
      If Length(sProjectName) = 0 Then
        sProjectName := ChangeFileExt(sFN, '');
      tsd.FileName := ChangeFileExt(goodfn(sProjectName), '.klp');
      tsd.Options := tsd.Options + [ofOverwritePrompt];

      If Not tsd.Execute Then
      Begin
        tsd.Free;
        Exit;
      End;
      sProjectPath := tsd.FileName;
    End;
    sb.Panels.Items[0].Text := 'Saving Project -> settings...';
    Application.ProcessMessages;
    tif := TIniFile.Create(sProjectPath);
    tif.WriteString('settings', 'name', sProjectName);
    tif.WriteString('settings', 'file', sFN);
    tif.WriteString('settings', 'keycut', cKeyCut);
    tif.WriteString('settings', 'refontprimname', tfREPrimFont.Name);
    tif.WriteInteger('settings', 'refontprimsize', tfREPrimFont.Size);
    tif.WriteInteger('settings', 'refontprimcolor', tfREPrimFont.Color);
    tif.WriteBool('settings', 'refontprimb', tfREPrimFont.Style = [fsBold]);
    tif.WriteBool('settings', 'refontprimi', tfREPrimFont.Style = [fsItalic]);
    tif.WriteBool('settings', 'refontprimu', tfREPrimFont.Style = [fsUnderline]);
    tif.WriteBool('settings', 'refontprims', tfREPrimFont.Style = [fsStrikeOut]);
    tif.WriteString('settings', 'refontsecname', tfRESecFont.Name);
    tif.WriteInteger('settings', 'refontsecsize', tfRESecFont.Size);
    tif.WriteInteger('settings', 'refontseccolor', tfRESecFont.Color);
    tif.WriteBool('settings', 'refontsecb', tfRESecFont.Style = [fsBold]);
    tif.WriteBool('settings', 'refontseci', tfRESecFont.Style = [fsItalic]);
    tif.WriteBool('settings', 'refontsecu', tfRESecFont.Style = [fsUnderline]);
    tif.WriteBool('settings', 'refontsecs', tfRESecFont.Style = [fsStrikeOut]);

    sb.Panels.Items[0].Text := 'Saving Project : text and reels...';
    Application.ProcessMessages;
    tif.WriteInteger('text', 'row', rele.Lines.Count);
    For i := 0 To rele.Lines.Count - 1 Do
      tif.WriteString('text', IntToStr(i), rele.Lines.Strings[i]);

    tif.WriteInteger('reel', 'row', lvlepl.Items.Count);
    For i := 0 To lvlepl.Items.Count - 1 Do
    Begin
      tif.WriteString('reel', 'st' + IntToStr(i), lvlepl.Items.Item[i].Caption);
      tif.WriteString('reel', 'sy' + IntToStr(i), StringReplace(lvlepl.Items.Item[i].SubItems.Strings[0],' ',#27,[rfReplaceAll]));
      tif.WriteString('reel', 'se' + IntToStr(i), lvlepl.Items.Item[i].SubItems.Strings[1]);
      tif.WriteString('reel', 'li' + IntToStr(i), lvlepl.Items.Item[i].SubItems.Strings[2]);
      tif.WriteString('reel', 'cs' + IntToStr(i), lvlepl.Items.Item[i].SubItems.Strings[3]);
      tif.WriteString('reel', 'ce' + IntToStr(i), lvlepl.Items.Item[i].SubItems.Strings[4]);
      tif.WriteString('reel', 'du' + IntToStr(i), lvlepl.Items.Item[i].SubItems.Strings[5]);
      Application.ProcessMessages;
    End;

    bSaved := True;
    Application.ProcessMessages;
    Case iMPv Of

      1:
        Begin
          mp0.Play;
        End;

      2:
        Begin
          mp1.Play;
        End;

    End;

    sb.Panels.Items[0].Text := 'Ready';
    Application.ProcessMessages;
  End;
End;

Procedure TForm1.Button1Click(Sender: TObject);
Begin
  mp0.Close;
  mp0.Open;
  mp0.Play;
End;

Procedure TForm1.Load1Click(Sender: TObject);
Begin
  If Not odmp.Execute Then
    Exit
  Else
    mp0.FileName := odmp.FileName;
    sFN := odmp.FileName;
End;

Procedure TForm1.Button2Click(Sender: TObject);
Begin
  mp0.Pause;
End;

Procedure TForm1.Button4Click(Sender: TObject);
Var
  c: String;
  i: Integer;
Begin
  c := cKeyCut;
  If Not InputQuery('Splitter', 'Please specify a character for splitting each syllable'#13#13'Note : always to use special character which never used on lyric you work in', c) Then
    cKeyCut := '/'
  Else If Length(c) <> 1 Then
    cKeyCut := '/'
  Else
    cKeyCut := c[1];

  For i := rele.Lines.Count - 1 Downto 0 Do
    If Length(rele.Lines.Strings[i]) <= 0 Then
      rele.Lines.Delete(i);

  rele.Text := StringReplace(rele.Text, '’', '''', [rfreplaceall]);

  Repeat
    rele.Text := StringReplace(rele.Text, '  ', ' ', [rfreplaceall])
  Until Pos('  ', rele.Text) = 0;
End;

Function SecondToTime(Const Seconds: Cardinal): String;
Const
  SecPerDay = 86400;
  SecPerHour = 3600;
  SecPerMinute = 60;
  SecPermSec = 0.001;
Var
  ss, mm, hh, dd, se: Cardinal;
  ms, me, zs, zm, zh: String;
Begin
  se := Seconds Div 1000;
  me := IntToStr(Seconds);
  // dd := Se div SecPerDay;
  hh := (se Mod SecPerDay) Div SecPerHour;
  mm := ((se Mod SecPerDay) Mod SecPerHour) Div SecPerMinute;
  ss := ((se Mod SecPerDay) Mod SecPerHour) Mod SecPerMinute; // 999.999
  ms := Copy(me, Length(me) - 3, 3);
  if StrToInt(Copy(ms,2,1)) >=5 then
  ms := Copy(IntToStr(StrToInt(ms)+5),0,2)
  else
  ms := Copy(ms,0,2);
  zh := IntToStr(hh);
  If mm < 10 Then
    zm := '0' + IntToStr(mm)
  Else
    zm := IntToStr(mm);
  If ss < 10 Then
    zs := '0' + IntToStr(ss)
  Else
    zs := IntToStr(ss);
  result := zh + #13 + zm + #13 + zs + '.' + ms;
End;

Procedure TForm1.Button3Click(Sender: TObject);
Label
  X;
Var
  iCutPos, i, ier: Integer;
  tli: TListItem;
Begin
  bOnMarking := true;
    // if mp0.Mode <> mpOpen then Exit;
  rele.SetFocus;
  If iCurPos <= 0 Then
    iCurPos := rele.Perform(EM_LINEFROMCHAR, rele.SelStart + rele.SelLength, 0);
 // If midls.Checked Then
  //mp0.Pause;
  For i := iLastPos To Length(rele.Lines.Strings[iCurPos]) Do
  Begin
    If rele.Lines.Strings[iCurPos][i] = cKeyCut Then
    Begin
      rele.SelStart := rele.Perform(EM_LINEINDEX, iCurPos, 0) + iLastPos - 1;
      rele.SelLength := i - iLastPos;
      ier := i - iLastPos;
      tli := lvlepl.Items.Add;
      tli.Caption := StringReplace(SecondToTime(mp0.Position), #13, ':', [rfreplaceall]);
      tli.SubItems.Add(rele.SelText);
      tli.SubItems.Add(IntToStr(mp0.Position));
      tli.SubItems.Add(IntToStr(iCurPos));
      If iLastPos - 1 = 0 Then
        tli.SubItems.Add('0')
      Else
        tli.SubItems.Add(IntToStr(iLastLen));
      tli.SubItems.Add(IntToStr(ier));
      tli.SubItems.Add('unset');
      iLastLen := iLastLen + ier;
      iLastPos := i + 1;
      If (i >= Length(rele.Lines.Strings[iCurPos])) And (iCurPos < rele.Lines.Count - 1) Then
      Begin
X:
        Inc(iCurPos);
        rele.SelStart := rele.Perform(EM_LINEINDEX, iCurPos, 0);
        rele.Perform(EM_SCROLLCARET, 0, 0);
        iLastPos := 1;
        iLastLen := 0;
        If (Length(rele.Lines.Strings[iCurPos]) <= 0) Then
          Goto X;
      End;
     // If midls.Checked Then
     // mp0.Play;
      Exit;
    End;

  End;
End;

Procedure TForm1.FormCreate(Sender: TObject);
Begin
  iLastPos := 1;
  iCurPos := 0;
  iCurNu := 0;
  iLLNu := -1;
  iReIdxNu := 0;
  iSecNu := 0;
  lvlepl.DoubleBuffered := True;
  cKeyCut := '\';
  tfRESecFont := TFont.Create;
  tfRESecFont.Name := 'Segoe UI';
  tfRESecFont.Color := clred;
  tfRESecFont.Size := 20;
  tfREPrimFont := TFont.Create;
  tfREPrimFont.Name := 'Segoe UI';
  tfREPrimFont.Color := clblack;
  tfREPrimFont.Size := 20;
  re.Font := tfREPrimFont;
End;

Procedure TForm1.releChange(Sender: TObject);
Begin
  bSaved := false;
End;

Procedure TForm1.Open1Click(Sender: TObject);
Var
  tod: TOpenDialog;
  tif: TIniFile;
  i, j: Integer;
  tli: TListItem;
  tl: TLabel;
Begin

  tod := TOpenDialog.Create(nil);
  tod.Title := 'Load Project';
  tod.Filter := 'Karaz Project|*.klp';

  If Not tod.Execute Then
  Begin
    tod.Free;
    Exit;
  End
  Else

   iLastPos := 1;
  iCurPos := 0;
  iCurNu := 0;
  iLLNu := -1;
  iReIdxNu := 0;
  iSecNu := 0;

  sProjectPath := tod.FileName;
  tif := TIniFile.Create(tod.FileName);

  mp0.FileName := '';

  sProjectName := tif.ReadString('settings', 'name', ChangeFileExt(ExtractFileName(tod.FileName), ''));

  Caption := 'Karaz - ' + sProjectName;

  If FileExists(tif.ReadString('settings', 'file', '')) Then
  Begin
    sFN := tif.ReadString('settings', 'file', '');
  End;
  Application.ProcessMessages;
  cKeyCut := tif.ReadString('settings', 'keycut', '\')[1];
  Application.ProcessMessages;
  //primary / idle
  tfREPrimFont.Name := tif.ReadString('settings', 'refontprimname', 'Segoe UI');
  tfREPrimFont.Size := tif.ReadInteger('settings', 'refontprimsize', 20);
  tfREPrimFont.Color := tif.ReadInteger('settings', 'refontprimcolor', clblack);
  If tif.ReadBool('settings', 'refontprimb', false) Then
    tfREPrimFont.Style := tfREPrimFont.Style + [fsbold]
  Else
    tfREPrimFont.Style := tfREPrimFont.Style - [fsbold];
  If tif.ReadBool('settings', 'refontprimi', false) Then
    tfREPrimFont.Style := tfREPrimFont.Style + [fsItalic]
  Else
    tfREPrimFont.Style := tfREPrimFont.Style - [fsItalic];
  If tif.ReadBool('settings', 'refontprimu', false) Then
    tfREPrimFont.Style := tfREPrimFont.Style + [fsUnderline]
  Else
    tfREPrimFont.Style := tfREPrimFont.Style - [fsUnderline];
  If tif.ReadBool('settings', 'refontprims', false) Then
    tfREPrimFont.Style := tfREPrimFont.Style + [fsStrikeout]
  Else
    tfREPrimFont.Style := tfREPrimFont.Style - [fsStrikeout];
  Application.ProcessMessages;
  //seconndary / passed
  tfRESecFont.Name := tif.ReadString('settings', 'refontsecname', 'Segoe UI');
  tfRESecFont.Size := tif.ReadInteger('settings', 'refontsecsize', 20);
  tfRESecFont.Color := tif.ReadInteger('settings', 'refontseccolor', clRed);
  If tif.ReadBool('settings', 'refontsecb', false) Then
    tfRESecFont.Style := tfRESecFont.Style + [fsbold]
  Else
    tfRESecFont.Style := tfRESecFont.Style - [fsbold];
  If tif.ReadBool('settings', 'refontseci', false) Then
    tfRESecFont.Style := tfRESecFont.Style + [fsItalic]
  Else
    tfRESecFont.Style := tfRESecFont.Style - [fsItalic];
  If tif.ReadBool('settings', 'refontsecu', false) Then
    tfRESecFont.Style := tfRESecFont.Style + [fsUnderline]
  Else
    tfRESecFont.Style := tfRESecFont.Style - [fsUnderline];
  If tif.ReadBool('settings', 'refontsecs', false) Then
    tfRESecFont.Style := tfRESecFont.Style + [fsStrikeout]
  Else
    tfRESecFont.Style := tfRESecFont.Style - [fsStrikeout];
  Application.ProcessMessages;
  re.Font := tfREPrimFont;
  i := tif.ReadInteger('text', 'row', 0);
  rele.Clear;
  For j := 0 To i - 1 Do
    rele.Lines.Add(tif.ReadString('text', IntToStr(j), '~'));
  Application.ProcessMessages;
  i := tif.ReadInteger('reel', 'row', 0);
  lvlepl.Items.Clear;
  For j := 0 To i - 1 Do
  Begin
    tli := lvlepl.Items.Add;
    tli.Caption := tif.ReadString('reel', 'st' + IntToStr(j), '0:00:00.00');
    tli.SubItems.Add(StringReplace(tif.ReadString('reel', 'sy' + IntToStr(j), '-'),#27,' ',[rfReplaceAll]));
    tli.SubItems.Add(tif.ReadString('reel', 'se' + IntToStr(j), '0'));
    tli.SubItems.Add(tif.ReadString('reel', 'li' + IntToStr(j), '0'));
    tli.SubItems.Add(tif.ReadString('reel', 'cs' + IntToStr(j), '0'));
    tli.SubItems.Add(tif.ReadString('reel', 'ce' + IntToStr(j), '0'));
    tli.SubItems.Add(tif.ReadString('reel', 'du' + IntToStr(j), 'unset'));
    Application.ProcessMessages;
  End;

  If Length(StringReplace(rele.Lines.Strings[0], cKeyCut, '', [rfreplaceall])) > 1 Then
    re.Text := StringReplace(rele.Lines.Strings[0], cKeyCut, '', [rfreplaceall]);

  Application.ProcessMessages;

End;

Procedure TForm1.midlsClick(Sender: TObject);
Begin
  Project.Checked := Not Project.Checked;
End;

procedure TForm1.Button5Click(Sender: TObject);

begin
if mp0.Mode = mpPlaying then mp0.Stop;
mp1.FileName := mp0.FileName;
mp1.Close;
mp1.Open;
    iLastPos := 1;
  iCurPos := 0;
  iCurNu := 0;
  iLLNu := -1;
  iReIdxNu := 0;
  iSecNu := 0;
timer1.Enabled := true;
iSecNu := StrToInt(lvlepl.Items.Item[0].SubItems.Strings[1]);
iLLNu := 0;
mp1.Play;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
if (mp1.Position div 100) = (iSecNu div 100) then
begin

 if iLLNu <> StrToInt(lvlepl.Items.Item[iCurNu].SubItems.Strings[2]) then
 begin
  re.SelectAll;
  re.SelAttributes.Assign(tfREPrimFont);
  iLLNu := strtoint(lvlepl.Items.Item[iCurNu].SubItems.Strings[2]);
  re.Text := StringReplace(rele.Lines.Strings[iLLNu],cKeyCut,'',[rfReplaceAll]);
  iReIdxNu := 0;
 end;
  re.SelStart := StrToInt(lvlepl.Items.Item[iCurNu].SubItems.Strings[3]);
  re.SelLength := StrToInt(lvlepl.Items.Item[iCurNu].SubItems.Strings[4]);
  //iReIdxNu := iReIdxNu + re.SelLength;
  re.SelAttributes.Assign(tfRESecFont);
  if mp1.Position >= mp1.Length then
  begin
      iLastPos := 1;
  iCurPos := 0;
  iCurNu := 0;
  iLLNu := -1;
  iReIdxNu := 0;
  iSecNu := 0;
  end;
  if iCurNu < lvlepl.Items.Count-1 then
  Inc(iCurNu)
  else
  Timer1.Enabled := false;
  iSecNu := StrToInt(lvlepl.Items.Item[iCurNu].SubItems.Strings[1]);

  //lvlepl.Items.Item[iCurNu].Selected := True;

end;
end;

procedure TForm1.Save1Click(Sender: TObject);
begin
saveklp(true);
end;

procedure TForm1.SaveAs1Click(Sender: TObject);
begin
saveklp(false);
end;

procedure TForm1.IdleFont1Click(Sender: TObject);
Var
  tfd: TFontDialog;
Begin
  tfd := TFontDialog.Create(nil);
  tfd.Font := tfREPrimFont;
  If Not tfd.Execute Then
  Begin
    tfd.Free;
    Exit;
  End
  Else
  Begin
    tfREPrimFont := tfd.Font;
  End;
end;

procedure TForm1.PassedFont1Click(Sender: TObject);
Var
  tfd: TFontDialog;
Begin
  tfd := TFontDialog.Create(nil);
  tfd.Font := tfRESecFont;
  If Not tfd.Execute Then
  Begin
    tfd.Free;
    Exit;
  End
  Else
  Begin
    tfRESecFont := tfd.Font;
  End;

End;

procedure TForm1.EditorFont1Click(Sender: TObject);
Var
  tfd: TFontDialog;
Begin
  tfd := TFontDialog.Create(nil);

  tfd.Font := rele.Font;
  If Not tfd.Execute Then
  Begin
    tfd.Free;
    Exit;
  End
  Else
  Begin
    rele.Font := tfd.Font;
  End;

End;
procedure TForm1.resync1Click(Sender: TObject);
begin
Button3.Click;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
mp1.Pause;
end;

procedure TForm1.EksporKaraSub1Click(Sender: TObject);
Var
  sd: TSaveDialog;
  i, iCurLine, iAdd, iTimeStart, j, k: Integer;
  sXFN, sFont, sAdd, sTimeStart, sTimeEnd: String;
  tsl: TStringList;
Begin

  If (mp0.Mode = mpPlaying) Then
  Begin
    MessageBox(Handle, 'Please make sure the playback is not running, then try the export again', 'Export Error', 16);
    Exit;
  End;

  sd := TSaveDialog.Create(nil);
  sd.Title := 'Export to... ';
  sd.Filter := 'Advanced Substation Alpha (*.ass)|*.ass';
  sd.Options := sd.Options + [ofOverwritePrompt];
  If Not sd.Execute Then
  Begin
    sd.Free;
    Exit;
  End;
  sXFN := sd.FileName;
  Application.ProcessMessages;
  // kalkulasi durasi untuk per suku kata
  For i := lvlepl.Items.Count - 2 Downto 0 Do
  Begin
    lvlepl.Items.BeginUpdate;
    lvlepl.Items.Item[i].SubItems.Strings[5] := IntToStr(StrToInt(lvlepl.Items.Item[i + 1].SubItems.Strings[1]) - StrToInt(lvlepl.Items.Item[i].SubItems.Strings[1]));
    // IntToStr(round(StrToInt(lvlepl.Items.Item[i+1].SubItems.Strings[1]) / 10)-round(StrToInt(lvlepl.Items.Item[i].SubItems.Strings[1]) / 10));
    lvlepl.Items.EndUpdate;
    Application.ProcessMessages;
  End;
  lvlepl.Items.BeginUpdate;
  lvlepl.Items.Item[lvlepl.Items.Count - 1].SubItems.Strings[5] := '0';
  lvlepl.Items.EndUpdate;
  Application.ProcessMessages;

  // Dialogue: 0,0:00:00.00,0:00:00.00,Default,,0,0,0,,{\k0}ku {\k0}li{\k0}hat {\k0}pera{\k0}hu {\k0}la{\k0}ju
  // gabungan suku kata menjadi kalimat per baris
  tsl := TStringList.Create;
  For i := 0 To lvlepl.Items.Count - 1 Do
  Begin
    If iCurLine <> StrToInt(lvlepl.Items.Item[i].SubItems.Strings[2]) Then
    Begin
      iCurLine := StrToInt(lvlepl.Items.Item[i].SubItems.Strings[2]);
      sTimeEnd := StringReplace(SecondToTime(iTimeStart + iAdd), #13, ':', [rfreplaceall]);

      tsl.Add('Dialogue: 0,' + sTimeStart + ',' + sTimeEnd + ',Default,,0,0,0,,' + sAdd);
      sAdd := '';
      iAdd := 0;
      Application.ProcessMessages;
    End;
    If sAdd = '' Then
    Begin
      sTimeStart := lvlepl.Items.Item[i].Caption;
      iTimeStart := StrToInt(lvlepl.Items.Item[i].SubItems.Strings[1]);
    End;
    sAdd := sAdd + '{\k' + IntToStr(StrToInt(lvlepl.Items.Item[i].SubItems.Strings[5]) Div 10) + '}' + lvlepl.Items.Item[i].SubItems.Strings[0];
    iAdd := iAdd + StrToInt(lvlepl.Items.Item[i].SubItems.Strings[5]);
    Application.ProcessMessages;
  End;

  // mempersiapkan header untuk digabung
  // Sunday, February 19 2017 at 14:26
  ass_x.Text := StringReplace(ass_x.Text, '{dt}', FormatDateTime('dddd, mmmm dd yyyy @ t', Now), [rfreplaceall]);
  ass_x.Text := StringReplace(ass_x.Text, '{audio_file}', mp0.FileName, [rfreplaceall]);
  ass_x.Text := StringReplace(ass_x.Text, '{font_name}', re.font.Name, [rfreplaceall]);
  ass_x.Text := StringReplace(ass_x.Text, '{font_size}', IntToStr(re.font.Size), [rfreplaceall]);
  If re.font.Style = [fsBold] Then
    sFont := '1'
  Else
    sFont := '0';
  ass_x.Text := StringReplace(ass_x.Text, '{font_b}', sFont, [rfreplaceall]);
  If re.font.Style = [fsItalic] Then
    sFont := '1'
  Else
    sFont := '0';
  ass_x.Text := StringReplace(ass_x.Text, '{font_i}', sFont, [rfreplaceall]);
  If re.font.Style = [fsUnderline] Then
    sFont := '1'
  Else
    sFont := '0';
  ass_x.Text := StringReplace(ass_x.Text, '{font_u}', sFont, [rfreplaceall]);
  If re.font.Style = [fsStrikeOut] Then
    sFont := '1'
  Else
    sFont := '0';
  ass_x.Text := StringReplace(ass_x.Text, '{font_s}', sFont, [rfreplaceall]);
  tsl.Text := ass_x.Text + #13#10 + tsl.Text;
  tsl.SaveToFile(ChangeFileExt(sXFN, '.ass'));
  tsl.Free;
  sd.Free;
  Application.ProcessMessages;end;

End.

