{ Ronnie Comattie source code}
{X$+}{$G+}{$M 5000,0,70000}
const factor=2;

type palette=array[0..768] of byte;

VAR Pall,Pall2 : Array[0..255,1..3] of Byte;
    bseg,bseg2:word;
    colorval,q,cometspeed,flag:integer;
    xarray:array[0..319] of word;
    yarray:array[0..399] of word;
    cosinus:array[0..255] of byte;
    sinus:array[0..255] of byte;
    Tmp : Array [1..3] of byte;
    pal:palette;
    palset,x,y:byte;
    i:word;
    wgvish:real;
    updatecount,loop1,count,baseflag,max:integer;
    counter,dflag,gordan,t,chad,chad2,loop2,Fade:integer;

{$l scale.obj}
procedure ScaleUp(source,dest:word);External; { This is where the stuff goes }
procedure Fire(dest:word);External;           { Standard blur }
procedure CopyDW(source,dest:word);External;  { 32-bit copy }
procedure Dot(x,y,where:word;c:byte);External;{ No circle :-( }

{$F+}
{$L XMSOBJ.OBJ}    {The XMS-Object should be used is normaly set to $L+}
PROCEDURE _XMSFMPlayer; near; EXTERNAL;
PROCEDURE _StopXMSFM; near; EXTERNAL;
PROCEDURE _InitXMSFM; near; EXTERNAL;
{$F-}


type XMSFM = record
              Name   : string;
              Lenght : integer;
              OkeY   : boolean;
              Tune   : pointer;
              Buffer : pointer;
     end;

var Musik : XMSFM;


PROCEDURE LoadSong (VAR Test : XMSFM);
  VAR F : FILE;
  BEGIN
    ASSIGN (F,Test.Name);  {Here You can even put +(.xms) Then you don't need the Extension !}
    {$I-} RESET (F,1); {$I+}
    IF IORESULT <> 0
      THEN Test.OkeY := FALSE
      ELSE
        BEGIN             {14832 = yaetzu}
          Test.Lenght :=4857;
          GETMEM (Test.Tune,Test.Lenght);
          GETMEM (Test.Buffer,1314);
          BLOCKREAD (F,Test.Tune^,Test.Lenght);
          Test.OkeY := TRUE;
          CLOSE (F)
        END
  END;

PROCEDURE ClearSong (VAR Test : XMSFM);  {IMPORTANT: YoU have to call these at }
  BEGIN                                  {the end of your Program to make sure }
    Test.OkeY := FALSE;                  {that the hole Buffer will be free again !}
    FREEMEM (Test.Tune,Test.Lenght);
    FREEMEM (Test.Buffer,1314);
    Test.Lenght := 0
  END;

{ This procedure uses assembly function 07.. interrupt 10h to scroll the
  screen down 25 rows...}
procedure clear;
begin
 asm
    mov     ah,07h
    mov     al,25  {Number of lines to clear...}
    xor     bh,bh  {Active page... just to be sure}
    xor     cx,cx  {Column, Row for top left hand corner = 0,0}
    mov     dh,25  {Bottom corner row...}
    mov     dl,79  {Bottom corner column...}
    int     10h
    sub     dx,dx  {Set cursor position to 0,0}
    mov     ah,02h
    int     10h
 end;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure WaitRetrace; assembler;
  { This waits until you are in a Verticle Retrace ... this means that all
    screen manipulation you do only appears on screen in the next verticle
    retrace ... this removes most of the "fuzz" that you see on the screen
    when changing the pallette. It unfortunately slows down your program
    by "synching" your program with your monitor card ... it does mean
    that the program will run at almost the same speed on different
    speeds of computers which have similar monitors.}

label
  l1, l2;
asm
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure GetPal(ColorNo : Byte; Var R,G,B : Byte);
  { This reads the values of the Red, Green and Blue values of a certain
    color and returns them to you. }
Begin
   Port[$3c7] := ColorNo;
   R := Port[$3c9];
   G := Port[$3c9];
   B := Port[$3c9];
End;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure PalUP(ColorNo : Byte; R,G,B : Byte);
  { This sets the Red, Green and Blue values of a certain color }
Begin
  { The following ASM statement can be written as such :

   Port[$3c8] := ColorNo;
   Port[$3c9] := R;
   Port[$3c9] := G;
   Port[$3c9] := B;}
   asm
     mov al,ColorNo
     mov dx,03c8h
     out dx,al
     inc dx
     mov al,R
     out dx,al
     mov al,G
     out dx,al
     mov al,B
     out dx,al
   end;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Wpal;
  { This procedure blackens the screen by setting the pallette values of
    all the colors to zero.}
VAR loop1:integer;
BEGIN
  For loop1:=0 to 255 do
    PalUP(loop1,63,63,63);
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Blackout;
  { This procedure blackens the screen by setting the pallette values of
    all the colors to zero.}
VAR loop1:integer;
BEGIN
  For loop1:=0 to 255 do
    PalUP(loop1,0,0,0);
END;

Procedure FadeDown;
  { This procedure fades the screen out to black. }
VAR loop1,loop2:integer;
    Tmp : Array [1..3] of byte;
      { This is temporary storage for the values of a color }
BEGIN
  For loop1:=1 to 64 do BEGIN
   WaitRetrace;
    For loop2:=0 to 255 do BEGIN
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      If Tmp[1]>0 then dec (Tmp[1]);
      If Tmp[2]>0 then dec (Tmp[2]);
      If Tmp[3]>0 then dec (Tmp[3]);
        { If the Red, Green or Blue values of color loop2 are not yet zero,
          then, decrease them by one. }
      PalUP(loop2,Tmp[1],Tmp[2],Tmp[3]);
        { Set the new, altered pallette color. }
    END;
  END;
END;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Whitedown;
  { This procedure slowly fades up the new screen }
VAR loop1,loop2:integer;
    Tmp : Array [1..3] of byte;
      { This is temporary storage for the values of a color }
BEGIN
  For loop1:=0 to 63 do BEGIN
      { A color value for Red, green or blue is 0 to 63, so this loop only
        need be executed a maximum of 64 times }
    WaitRetrace;
    For loop2:=0 to 255 do BEGIN
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      If Tmp[1]>Pall2[loop2,1] then dec (Tmp[1]);
      If Tmp[2]>Pall2[loop2,2] then dec (Tmp[2]);
      If Tmp[3]>Pall2[loop2,3] then dec (Tmp[3]);
        { If the Red, Green or Blue values of color loop2 are less then they
          should be, increase them by one. }
      Palup(loop2,Tmp[1],Tmp[2],Tmp[3]);
        { Set the new, altered pallette color. }
    END;
 end;
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Fadeup;
  { This procedure slowly fades up the new screen }
VAR loop1,loop2:integer;
    Tmp : Array [1..3] of byte;
      { This is temporary storage for the values of a color }
BEGIN
  For loop1:=0 to 63 do BEGIN
      { A color value for Red, green or blue is 0 to 63, so this loop only
        need be executed a maximum of 64 times }
    WaitRetrace;
    For loop2:=0 to 255 do BEGIN
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      If Tmp[1]<Pall2[loop2,1] then inc (Tmp[1]);
      If Tmp[2]<Pall2[loop2,2] then inc (Tmp[2]);
      If Tmp[3]<Pall2[loop2,3] then inc (Tmp[3]);
        { If the Red, Green or Blue values of color loop2 are less then they
          should be, increase them by one. }
      Palup(loop2,Tmp[1],Tmp[2],Tmp[3]);
        { Set the new, altered pallette color. }
    END;
 end;
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure GrabPallette;
VAR loop1:integer;
BEGIN
  For loop1:=0 to 255 do
    Getpal (loop1,pall2[loop1,1],pall2[loop1,2],pall2[loop1,3]);
END;

procedure Mode(md:word);assembler;
asm
  mov ax,md
  int 10h
end;

function KeyPressed:byte;assembler;
{Mmmhh, faster ?}
asm
  in al,$60
  xor ah,ah
end;

procedure SetPal;assembler;
asm
  cli
  mov si,offset pal
  mov DX,3dah
  @l1:
  in AL,DX
  test AL,8d
  jnz @l1
  @l2:
  in AL,DX
  test AL,8d
  jz @l2
  mov cx,768
  mov dx,3C8h
  xor al,al
  out dx,al
  inc dx
  rep outsb
  sti
END;

procedure ramp(scol,r1,g1,b1,ecol,r2,g2,b2:byte;var p:palette);
{ramp colors}
var i:word;
    r,g,b:real;
begin
  i:=scol;
  r:=(r2-r1)/(ecol-scol);
  g:=(g2-g1)/(ecol-scol);
  b:=(b2-b1)/(ecol-scol);
  repeat
    p[i*3]  :=r1+round(r*(i-scol));
    p[i*3+1]:=g1+round(g*(i-scol));
    p[i*3+2]:=b1+round(b*(i-scol));
    inc(i);
  until i=ecol+1;
end;

procedure SetUpBuffer(var segment:word;size:word);
{I HATE GETMEM}
var StartAdress:word;
begin
  asm
    mov ax,4821h
    mov bx,size
    int 21h
    mov dx,ax
    jnb @l1
      mov dx,0a000h
      jmp @l2
    @l1:
      shl bx,2
      mov cx,bx
      mov es,ax
      xor di,di
      xor ax,ax
      rep stosw
    @l2:
    mov StartAdress,dx
  end;
  segment:=StartAdress;
  if StartAdress=$0a000 then begin
    asm mov ax,3h;int 10h;end;
    Writeln('Oh shit... this isn`t supposed to happen... out of memory!');
    halt;
  end;
end;

procedure FreeBuffer(segment:word);assembler;
{I HATE FREEMEM, TOO}
asm
  mov ax,4921h
  mov bx,segment
  int 21h
end;

procedure init;
var i:word;
begin
  SetUpBuffer(bseg,4096);
  SetUpBuffer(bseg2,4096);
  {Just a few precalcs to gain speed}
  for i:=0 to 255 do cosinus[i]:=round(cos(2*pi*i/255)*35+90);
  for i:=0 to 255 do
           sinus[i]:=round(sin(2*pi*i/255)*80+395);
  for i:=0 to 198 do begin
                       yarray[2*i]:=  round(i/199*(199-(2*factor))+factor)*320;
                       yarray[2*i+1]:=round(i/199*(199-(2*factor))+factor)*320;
                     end;
{            r  g  b      r  g   b}
  ramp(  0,  0, 0, 18,  33,6, 3,  28,pal);  {0,r,g,b of background, Outer tail}
  ramp( 32, 6,3,34, 63,15,39,63,pal);       {   tail outer-1}
  ramp( 64,15,39,63, 95,63,63,63,pal);
  ramp( 96,63,63,63,111,63,63, 3,pal);
  ramp(112,63,63,3,130,63, 3,27,pal);
  mode($13);setpal;
  grabpallette;
end;

procedure ScreenUpdate;
var
   Nest : byte;
begin
   for i:=0 to 319 do xarray[i]:=round(i/319*(319-(wgvish*factor)))+factor;
  {The next set of booleans is used to determine the comets speed
   as it travels about the screen, as well as where it's going and
   its size.  The size shrinks, to make it pull away from the screen,
   and grows when the out flag is set.  The colour changes also,
   the 'closer' to the screen it gets.  I'm still to work out how
   to get the TIAS logo up infront of it.... *sigh*.  It will completely
   kick arse then.}
  if flag=1 then {Out flag set}
    begin
         t:=t+1;   {Delay before starts shoot in}
      if t=70 then  {Do it now!!}
        begin
         chad:=320;
         chad2:=140;
        end;
         q:= q - 1;
         gordan:=gordan-5;
      if gordan<1 then gordan:=1;
         colorval:= colorval - 1;
      if colorval < 128 then colorval :=128;
         cometspeed := cometspeed - 1;
      if cometspeed < 1 then cometspeed := 1;
      if q < 7 then flag :=0;
    end;
   if flag=0 then
     begin
          gordan:=gordan+1;   {Amount of starbursts}
       if gordan>200 then gordan:=200;
          colorval:= colorval + 1;  {Cycle colours}
       if colorval > 132 then colorval :=132;
          q := q + 1;
          cometspeed := cometspeed + 1;
       if cometspeed > 5 then cometspeed := 5;
       if q > 79 then flag:=1;
     end;
  {Comet}
    For Nest := 1 to 5 do
      for i:=1 to 10 do dot(sinus[x]+nest,cosinus[i],bseg,colorval);

    inc(x,cometspeed);
    fire(bseg);
    ScaleUp(bseg,bseg2);
    CopyDW(bseg2,$0a000);

  {Starburst....}
{    for i:=1 to gordan do dot(random(chad),random(chad2),bseg2,90);}
    fire(bseg2);
    ScaleUp(bseg2,bseg);
    CopyDW(bseg,$0a000);
end;

procedure leave;
  VAR Tmp : Array [1..3] of byte;
begin
{repeat
  begin
  FADE:=Fade+1;           {Increment palete element}
{  WgVish:=Wgvish -0.1;    {Slowly shift focus to extreme right}
{  if WgVish=-2.5 then WgVish:=-2.5;  {Maximum shift}
{  ScreenUpdate;
{  WaitRetrace;}
{  For loop2:=0 to 255 do BEGIN
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      If Tmp[1]<63 then inc (Tmp[1]);
      If Tmp[2]<63 then inc (Tmp[2]);
      If Tmp[3]<63 then inc (Tmp[3]);
      PalUP(loop2,Tmp[1],Tmp[2],Tmp[3]);
  END;
 end;
until Fade > 62;}
  FreeBuffer(bseg);
  FreeBuffer(bseg2);
end;

{Purges the Keyboard buffer}
procedure NoEcho;
begin
     asm
     @@1000:
       xor  ah,ah
       int  16h
       or   ah,ah
       jz   @@1000
     end;
end;

{             It starts!!!!!!!!!!!!!!!!!!! }
Begin
  updatecount:=0;counter:=0;dflag:=0;flag:=0;        {In flag set}
  colorval:=120;  {Default pallette offset}
  cometspeed:=5; wgvish:=3;
  gordan:=20;t:=0; chad:=0;chad2:=0;

    Musik.Name := 'c:\xms\skym.xms';
{     Musik.Name := 'yaetzu.exe';}
         LoadSong (Musik);
    IF Musik.OkeY THEN
            BEGIN
              asm
                 push   ds
                 push   es
                 les    di,Musik.Buffer
                 lds    si,Musik.Tune
                 xor    al,al           { IRQ-Modus it is used by _InitXMSFM ! }
                 call   _InitXMSFM
                 pop    es
                 pop    ds
              end;

           GrabPallette;
   fadedown;
  init;

  while keypressed <>1 do
  begin

  if dflag=1 then  {1 = left focus}
   begin
     counter:=counter+1;
     if counter < 88 then
     begin
          wgvish:=wgvish+0.2;
          if wgvish > 15 then wgvish:=15;
          {dflag:=0;}
     end;
     if counter=88 then dflag:=0;
   end;
  if dflag=0 then  {Mid focus}
    begin
     counter:=counter-1;
     if counter > -88 then
     begin
          wgvish:=wgvish-0.2;
          if wgvish < 3 then wgvish:=3;
     end;
     if counter=-88 then dflag:=1;
    end;
   ScreenUpdate;
  end;
 end;
  leave;
  noecho;
  fadedown;
  MODE(3);
{  GrabPallette;
  Blackout;
Writeln('.鋏컴袴羔蝦켐袴컴沆.鋏컴--켐--퀘�.鋏컴袴羔蝦켐袴컴沆.鋏컴--켐--퀘�.鋏컴袴羔沆.');
Writeln('     .         �            .   An Official             桁                    ');
Writeln('                        �                     :                               ');
Writeln('       ,  �          輻輻   �    輻霜      .      i     `                     ');
Writeln('                    査 �    �    三輻         |                �              ');
Writeln('    �         "D    �  �    �     沆     ..      .   .複複複                  ');
Writeln('            r       �  �  鋏劈.鋏輻霜   輻賽賽� 輻�..�      霜      �         ');
Writeln(' .      `          査  方蔔幡白賽�  査 方   �  �  栢�  蔔白   � 1   �         ');
Writeln('           �      蔔�  賞幡� 朋百   査朋   栢    栢�   栢栢글 �  .  �  .      ');
Writeln(' .         |    幡         栢꿈栢   査朋  方 �  昉査�    繃白栢 9 \ � /       ');
Writeln('        .      幡 輻白  蔔栢栢査�   査朋  �  �  百글百   �   �  鋏켐于퀘�     ');
Writeln('              白幡栢栢  旁꾼栢檳�   査朋  겡�   겡査글賞栢白  � 9 / � \       ');
Writeln('     .�        �   査�  旁幡蔔殯�    百百   �   栢繃� 殯栢꿉  �  �  �   �     ');
Writeln('               �    賞�  �  百栢煞    霜昉�    �  蔔栢  賽   �  7   �         ');
Writeln(' �             �     賞�   蔔幡賞栢白複栢栢栢栢栢賽 賞�    輻       �         ');
Writeln('               �     �  賞�             栢    O      賽賞幡          �        ');
Writeln('     �         .     �   �               �              査  �                 ');
Writeln('         ?        .  �          o        �          .    �    �   �           ');
Writeln('                              .          �               �                    ');
Writeln('   �            �                Phenomenon         �    �  鋏                ');
Writeln('.鋏컴袴羔蝦켐袴컴沆.鋏컴--켐--퀘�.鋏컴袴羔蝦켐袴컴沆.鋏컴--켐--퀘�.鋏컴袴羔沆.');

fadeup;}
    asm
      call   _StopXMSFM   {Need to Stop Playing the Song !}
    end;
ClearSong (Musik);
end.


