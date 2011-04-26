{ Water Drums... just a stuff around with plasma I made because I just got
  Union Jacks : There will be no armageddon CD.  Anyhow, I like going on
  demo-induced trips with accompanying music, so... not that I'm wierd or
  anything, nice music and relaxing plasmas in a dark room is as good as
  meditating. *8)  Later.                                     Caglios 1997

  Greets to : Denthor / Asphyxia.  (I can do these from scratch, its just...}

{$G+}{$X+}
USES crt;

TYPE RGBType = Record
               R, G, B : Byte;
            End;
     PalType = Array[0..255] of RGBType;

VAR bob,bob2:paltype;  { Two pallettes, current and temporary }
    costbl : Array [0..255] of byte; { cos table lookup }
    mov1,mov2,mov3,mov4 : byte;  { current positions }
    bkg : array [1..50,1..80] of byte; { The pic in the background }
    i : byte;
    Pall,Pall2 : Array[0..255,1..3] of Byte;
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
        BEGIN
          Test.Lenght :=  FILESIZE (F);
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

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure PAL(Col,R,G,B : Byte); assembler;
   { This sets the Red, Green and Blue values of a certain color }
asm
   mov    dx,3c8h
   mov    al,[col]
   out    dx,al
   inc    dx
   mov    al,[r]
   out    dx,al
   mov    al,[g]
   out    dx,al
   mov    al,[b]
   out    dx,al
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetAllPal(Var Palette : PalType); Assembler;
  { This dumps the pallette in our variable onto the screen, fast }
Asm
   push   ds
   lds    si, Palette
   mov    dx, 3c8h
   mov    al, 0
   out    dx, al
   inc    dx
   mov    cx, 768
   rep    outsb
   pop    ds
End;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure init;
VAR loop1,loop2,r,g,b:integer;
    f:text;
    ch:char;

  Function rad (theta : real) : real; { Converts degrees to radians }
  BEGIN
    rad := theta * pi / 180
  END;

BEGIN

  asm
    mov     ax,0013h
    int     10h                     { Enter mode 13 }
{    cli
    mov     dx,3c4h
    mov     ax,604h                 { Enter unchained mode }
{    out     dx,ax
    mov     ax,0F02h                { All planes}
{    out     dx,ax

    mov     dx,3D4h
    mov     ax,14h                  { Disable dword mode}
{    out     dx,ax
    mov     ax,0E317h               { Enable byte mode.}
{    out     dx,ax
    mov     al,9
    out     dx,al
    inc     dx
    in      al,dx
    and     al,0b0h                 { Set the pixel size... this    }
{    add     al,7                    { gives a nice TV-Close up feel.}
{    out     dx,al}
  end;
  setallpal (bob2);
    for loop1:=1 to 128 do BEGIN
      bob[loop1].r:=0;
      bob[loop1].g:=loop1 div 4;
      bob[loop1].b:=loop1 div 4;
    END;
    for loop1:=129 to 255 do BEGIN
      bob[loop1].r:=0;
      bob[loop1].g:=63-loop1 div 4;
      bob[loop1].b:=63-loop1 div 4;
    end;
  { Precalc the look up table}
  For loop1:=0 to 255 do
    costbl[loop1]:=round (cos (rad (loop1/360*255*2))*31)+32;
  { And off we go!}
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure DrawPlasma;
  { This procedure draws the plasma onto the screen }
VAR loop1,loop2:integer;
    tmov1,tmov2,tmov3,tmov4:byte; { Temporary variables, so we dont destroy
                                    the values of our main variables }
    col:byte;
    where:word;
BEGIN
  tmov3:=mov3;
  tmov4:=mov4;
  where:=0;
  asm
    mov   ax,0a000h
    mov   es,ax        { In the two loops that follow, ES is not altered so
                         we just set it once, now }
  end;
  For loop1:=1 to 50 do BEGIN   { Fifty rows down }
    tmov1:=mov1;
    tmov2:=mov2;
    for loop2:=1 to 80 do BEGIN { Eighty columns across }
        col:=costbl[tmov1]+costbl[tmov2]+costbl[tmov3]+costbl[tmov4]+costbl[loop1]+costbl[loop2];
      { col = Intersection of numerous cos waves }
      asm
        mov    di,where   { di is killed elsewhere, so we need to restore it}
        mov    al,col
        mov    es:[di],al { Place col at ES:DI ... sequential across the screen}
      end;
      where:=where+1;  { Inc the place to put the pixel }
      tmov1:=tmov1+4;
      tmov2:=tmov2+3;  { Arb numbers ... replace to zoom in/out }
    END;
    tmov3:=tmov3+2;  {Size.... zoom...}
    tmov4:=tmov4+3;    { Arb numbers ... replace to zoom in/out }
  END;
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure MovePlasma;
  { This procedure moves the plasma left/right/up/down }
BEGIN
  mov1:=mov1-1;   {Speed of Plas}
  mov3:=mov3+1;   {Here too...}
  mov1:=mov1+random (3);
  mov2:=mov2+random (3);
  mov3:=mov3+random (3);
  mov4:=mov4-random (3);
END;

{ Should I bother explaining??}
procedure WaitRetrace; assembler;
label
  l1, l2;
asm
    mov   dx,3DAh
l1:
    in    al,dx
    test  al,8
    jnz   l1
l2:
    in    al,dx
    test  al,8
    jz    l2
end;
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
Procedure GrabPallette;
VAR loop1:integer;
BEGIN
  For loop1:=0 to 255 do
    Getpal (loop1,pall2[loop1,1],pall2[loop1,2],pall2[loop1,3]);
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

Procedure fadeupone (stage:integer);
VAR loop1:integer;
    temp:rgbtype;
BEGIN
  move (bob[0],temp,3);
  move (bob[1],bob[0],765);
    move (temp,bob[255],3);
  for loop1:=0 to 255 do BEGIN
    bob2[loop1].r:=integer(bob[loop1].r*stage div 64);
    bob2[loop1].g:=integer(bob[loop1].g*stage div 64);
    bob2[loop1].b:=integer(bob[loop1].b*stage div 64);
  END; { Fade up the pallette }
  setallpal (bob2);
END;


Procedure Shiftpallette;
VAR loop1:  integer;
    temp:   rgbtype;
BEGIN
  move (bob2[0],temp,3);
  move (bob2[1],bob2[0],765);
  move (temp,bob2[255],3);
  setallpal (bob2);
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Play;
VAR loop1:integer;
BEGIN
  for loop1:=1 to 64 do BEGIN
    fadeupone(loop1);
    drawplasma;
    moveplasma;
  END; { Fade up the plasma }
{   asm
      push   ds
      push   es
      les    di,Musik.Buffer
      lds    si,Musik.Tune
      xor    al,al           { IRQ-Modus it is used by _InitXMSFM ! }
{      call   _InitXMSFM
      pop    es
      pop    ds
    end;
}
 REPEAT
 {   shiftpallette;}
    drawplasma;
    moveplasma;
 until port[$60]=1;  {Just ESC-Key !}

  move (bob2,bob,768);
  for loop1:=1 to 64 do BEGIN
    fadeupone(64-loop1);
    drawplasma;
    moveplasma;
  END; { fade down the plasma }
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

BEGIN
Musik.Name := '.\MOOZ.DAT';
LoadSong (Musik);
 IF Musik.OkeY then begin
  fadedown;
  init;
  play;
  asm
    mov  ax,0003h
    int  10h
  end;
 end;
  GrabPallette;
  Blackout;
Writeln('Ailixyuz.... Coded by Caglios');Writeln;
Writeln('TIAS (c) Industries 1997');
fadeup;
asm
    call   _StopXMSFM   {Need to Stop Playing the Song !}
end;
ClearSong (Musik);
END.
