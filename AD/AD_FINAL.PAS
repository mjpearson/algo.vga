uses adfutil,crt;

{$I crowans.dat}     { The Crow Ansi.  by me!1 }
{$I bout2.dat}       { Disclaimer... 'about }

const ADMenu : array [1..4] of string = ('New Code',
                                         'Existing',
                                         ' About  ',
                                         ' Leave  ');
    { Kbd scans }
      DownArrow = $50;
      UpArrow   = $48;
      EnterKey  = $1c;

    { ASCII definitions }
      SecretBit = $7f;       { Secret bit is at Ctrl-Backspace }

    { General shieá }
      FXRATE = 12000;

var Mnu_item,scan,asc : byte;
    leave : boolean;

procedure AnsiDisp(screen : byte);
var
  AnsOfs,AnsSeg : word;
begin
  GrabPallette;
  fadedown(2);
  if screen = 1 then
    begin
      AnsOfs:=Ofs(imagedata);
      AnsSeg:=Seg(imagedata);
    end
   else
  if screen = 2 then
    begin
      AnsOfs:=Ofs(BoutIMG);
      AnsSeg:=Seg(BoutIMG);
    end;
 Move(Mem[AnsSeg:AnsOfs],Mem[$B800:0],4000);
end;

procedure Restore;
var
  index : byte;
begin
  Textcolor(5);
  TextBackground(0);
  For index := 1 to 4 do
    begin
      gotoxy(66,(14+(2*index))); write(ADMenu[index]);
    end;
end;

procedure Hilight;
begin
  Restore;
  Textcolor(13);
  gotoxy(66,(14+(2*Mnu_item)));
  write(ADMenu[Mnu_item]);
end;

Procedure MnuHandler(item : byte);
begin
  if item = 3 then
    begin
      AnsiDisp(2);
      Fadeup(2);
      readln;
    end;
  PlayEffect(3, FXRATE, 64);
  AnsiDisp(1);
  Hilight;
  FadeUp(2);
end;

procedure KbdHandler; Assembler;
asm
  xor ah,ah
  int 16h
  mov scan,ah
  mov asc,al
end;

begin
  Mnu_item:=1;leave:=false;

  imp;             { Initialise Module Player }
  LoadTXTFont;     { Load the Medieval font }
  AnsiDisp(1);     { Load Main ANSI }
  Hilight;         { Set the menu status }
  Fadeup(2);
  repeat
    KbdHandler;
    if scan = Uparrow then
      begin
        dec(Mnu_item);
        if Mnu_item < 1 then Mnu_item := 4;
        hilight;
        PlayEffect(1, FXRATE, 64{-40});
      end;
    if scan = downarrow then
      begin
        inc(Mnu_item);
        if Mnu_item > 4 then Mnu_item := 1;
        hilight;
       PlayEffect(1, FXRATE, 64{-40});
      end;
    if asc = SecretBit then
      Begin
        PlayEffect(3, FXRATE, 64);
        Plonk;
        AnsiDisp(1);
        Hilight;
        FadeUp(2);
      end;
    if scan = EnterKey then
      begin
         PlayEffect(3, FXRATE, 64);
        if Mnu_item < 4 then MnuHandler(Mnu_item)
      else
        if Mnu_item = 4 then leave:=true
      end;
  until leave=true;
  PlayEffect(2, FXRATE, 64{-40});
  FadeDown(2);
  asm mov ax,3; int 10h; end;

  Blackout;
  Writeln; textcolor(13);Write('mailto : '); textcolor(5);
  Writeln('n1921380@student.fit.qut.edu.au');

  Fadeup(3);
  unp;
end.