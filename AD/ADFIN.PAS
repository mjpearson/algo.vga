uses {phunki,}adfutil,crt;

const gctitles : array [1..2] of string =
     ('Whats your educational background? (3 maximum)',
      'And how good are you at ');

      ADMenu : array [1..5] of string = ('New Code',
                                         'Existing',
                                         ' Setup  ',
                                         ' About  ',
                                         ' Leave  ');

    { Kbd scans }
      DownArrow  = $50;
      UpArrow    = $48;
      LeftArrow  = $4b;
      RightArrow = $4d;
      EnterKey   = $1c;

    { ASCII definitions }
      SecretBit = $7f;       { Secret bit is at Ctrl-Backspace }

    { General shieá }
      FXRATE : word = 12000;

      EscANSI : array [1..40] of char =
               ('P',#13,'r',#5,'e',#5,'s',#5,'s',#5,' ',#5,
                'E',#13,'s',#5,'c',#5,'a',#5,'p',#5,'e',#5,' ',#5,
                'T',#13,'o',#5,' ',#5,'Q',#13,'u',#5,'i',#5,'t',#5);


var Mnu_item,scan,asc : byte;
    leave : boolean;
    Vert,i : byte;
    Ansi : array [1..40] of char;

procedure GenAnsi(x,y : byte);
begin
  move(Ansi,mem[$b800:2*(x+(y*80))],sizeof(ansi));
end;

procedure KbdHandler; Assembler;
asm
  xor ah,ah
  int 16h
  mov scan,ah
  mov asc,al
end;

procedure Hilight;
var
  index : byte;
begin
  Textcolor(5);
  TextBackground(0);
  For index := 1 to 5 do
    begin
      gotoxy(66,(13+(2*index)));
      write(ADMenu[index]);
    end;
  Textcolor(13);
  gotoxy(66,(13+(2*Mnu_item)));
  write(ADMenu[Mnu_item]);
end;

procedure SuHandler;

begin
  repeat
    KbdHandler;

    case scan of
      1 : Leave:=True;
    end;

  until leave = true;
  leave:=False;
end;

Procedure MnuHandler(item : byte);
begin
  {if item = 1 then
    begin
      AnsiDisp(3);
      TitleHandler(CurrentOp);
      _GcHandler(WhichItem,1);
      hilightoc(Vert,uparrow,Vert,1);
      Fadeup(2);
      BoneHandler;
      window(1,1,80,25);
    end
  else}
  case item of
    3 :
      begin
        AnsiDisp(4);
        GenAnsi(32,21);
        Fadeup(2);
        SuHandler;
      end;
    4 :
      begin
        AnsiDisp(1);
        Fadeup(2);
        readln;
      end;
  end;
{  PlayEffect(3, FXRATE, 64);}
  AnsiDisp(2);
  Hilight;
  FadeUp(2);
end;

procedure CheckFiles;
  function Exist(FileName: string): Boolean;
      { Checks to see if filename exits or not }
  var f: file;
  begin
    {$I-}
      Assign(f, FileName);
      Reset(f);
      Close(f);
    {$I+}
    Exist := (IOResult = 0) and (FileName <> '');
  end;

  procedure Leave(FType : byte);
    begin
      case FType of
        1 : Writeln('Sound config not found (type "ADNOTI -setup")');
        2 : Writeln('ANSI Data not found!');
      end;
    halt;
    end;

begin
 if not Exist('MIDAS.CFG') then Leave(1);
 if not Exist('.\DATA\VELHEJO.DAT') then leave(2);
end;

begin
{if paramcount > 0 then
  begin
    if (Paramstr(1) = '-SETUP') or (Paramstr(1) = '-setup') then MidasConf;
  end;}
  CheckFiles;
  Mnu_item:=1; leave:=false;
  fillchar(ansi,sizeof(ansi),0);
  move(EscANSI,Ansi,sizeof(EscANSI));
{  for WhichItem:=1 to 3 do Gothique.Professions[WhichItem]:=0;}

{  imp;             { Initialise Module Player }
  LoadGothFont;     { Load the Medieval font }
  AnsiDisp(2);      { Load Main ANSI }
  HideC;            { Hide the cursor }
  Hilight;          { Set the menu status }
  Fadeup(5);
  repeat
    KbdHandler;
    case scan of
      Uparrow :
        begin
          dec(Mnu_item);
          if Mnu_item < 1 then Mnu_item := 5;
          hilight;
  {        PlayEffect(1, FXRATE, 64);}
        end;
      downarrow :
        begin
          inc(Mnu_item);
          if Mnu_item > 5 then Mnu_item := 1;
          hilight;
  {       PlayEffect(1, FXRATE, 64);}
        end;
      EnterKey  :
        begin
  {        PlayEffect(3, FXRATE, 64);}
          if Mnu_item < 5 then MnuHandler(Mnu_item)
          else
          if Mnu_item = 5 then leave:=true
        end;
    end;
  until leave=true;
{  PlayEffect(2, FXRATE, 64);}
  FadeDown(5);
  asm mov ax,3; int 10h; end;

  Blackout;
  Writeln; textcolor(13);Write('mailto : '); textcolor(5);
  Writeln('n1921380@student.fit.qut.edu.au');

  Fadeup(3);
{  unp;}
end.