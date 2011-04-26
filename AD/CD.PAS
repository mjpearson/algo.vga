{$G+}{$X+}
uses midas, mfile, mplayer, modp, errors, mconfig,crt;

{$I c:\tp\dev1\cachunka.dat}       { Picture Data }

TYPE RGBType = Record
               R, G, B : Byte;
            End;
     PalType = Array[0..255] of RGBType;

Type Virtual = Array [0..63999] of byte;  { The size of our Virtual Screen }
     VirtPtr = ^Virtual;                  { Pointer to the virtual screen }

CONST VGA = $0a000;

VAR bob,bob2:paltype;  { Two pallettes, current and temporary }
    costbl : Array [0..255] of byte; { cos table lookup }
    mov1,mov2,mov3,mov4 : byte;  { current positions }
    bkg : array [1..50,1..80] of byte; { The pic in the background }
    Virscr : VirtPtr;                      { Our first Virtual screen }
    Vaddr  : word;                         { The segment of our virtual screen}
    v,d,dfl : integer;
    cosinus:array[0..255] of byte;
    sinus:array[0..255] of byte;

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
Procedure PutPixel (X,Y : Integer; Col : Byte; Where : Word);
   { This puts a pixel at X,Y using color col, on VGA or the Virtual Screen}
BEGIN
  Mem [Where:X+(Y*320)]:=col;
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Flip;
   { This flips the virtual screen to the VGA screen. }
BEGIN
  Move (Virscr^,mem [VGA:0],64000);
END;

{ Wack in the TIAS logo at location x,y}
procedure Scoppy(x,y:word; BMPSize, Origin, width:integer);
var
    Xorigin,Xbound:word;
    i : integer;
    col : byte;
begin
Xbound:=x+width;
Xorigin:=x;
for i := origin to (BMPSize-1) do
begin
  col:=chunky[i];
  if col <> 0 then putpixel(x,y,col,vaddr);

  x := x+ 1;
  if x > Xbound then
       begin
         x :=Xorigin;
         y :=y+1;
       end;
end;
end;

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
    cli
    mov     dx,3c4h
    mov     ax,604h                 { Enter unchained mode }
    out     dx,ax
    mov     ax,0F02h                { All planes}
    out     dx,ax

    mov     dx,3D4h
    mov     ax,14h                  { Disable dword mode}
    out     dx,ax
    mov     ax,0E317h               { Enable byte mode.}
    out     dx,ax
    mov     al,9
    out     dx,al
    inc     dx
    in      al,dx
    and     al,0b0h                 { Set the pixel size... this    }
    add     al,7                    { gives a nice TV-Close up feel.}
    out     dx,al
  end;
    for loop1:=1 to 128 do BEGIN
      bob[loop1].r:=0;
      bob[loop1].g:=0;{loop1 div 4;}
      bob[loop1].b:=loop1 div 4;
    END;
    for loop1:=129 to 255 do BEGIN
      bob[loop1].r:=0;
      bob[loop1].g:=0;{63-loop1 div 4;}
      bob[loop1].b:=63-loop1 div 4;
    end;
  setallpal (bob);
  { Precalc the look up table}
  For loop1:=0 to 255 do
    costbl[loop1]:=round (sin (rad (loop1/360*255*2))*31)+12; {32}
  { And off we go!}
  for v:=0 to 255 do cosinus[v]:=round(cos(2*pi*v/255)*35+90);
  for v:=0 to 255 do sinus[v]:=round(sin(2*pi*v/255)*80+395);

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
  mov1:=mov1-2;   {Speed of Plas}
  mov3:=mov3+3;   {Here too...}
  mov1:=mov1+random (1);
  mov2:=mov2+random (2);
  mov3:=mov3+random (1);
  mov4:=mov4-random (2);
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
VAR loop1:integer;
    temp:rgbtype;
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
  while keypressed do readkey;
  Repeat
    shiftpallette;
    drawplasma;
    moveplasma;
{    Scoppy(sinus[d]+170,cosinus[d]+400,4466,0,76);   { x,y, BMPSize, origin, width}
{    d:=d+3;
    if d = 255 then d :=0;
    Flip;}
  Until keypressed; { Do the plasma }
  move (bob2,bob,768);
  for loop1:=1 to 64 do BEGIN
    fadeupone(64-loop1);
    drawplasma;
    moveplasma;
  END; { fade down the plasma }

  while keypressed do readkey;
END;


{****************************************************************************\
*
* Function:     toASCIIZ(dest : PChar; str : string) : PChar;
*
* Description:  Converts a string to ASCIIZ format. (StrPCopy is NOT available
*               in real mode!)
*
* Input:        msg : string            string to be converted
*               dest : PChar            destination buffer
*
* Returns:      Pointer to the converted string;
*
\****************************************************************************}

function toASCIIZ(dest : PChar; str : string) : PChar;
var
    spos, slen : integer;
    i : integer;

begin
    spos := 0;                          { string position = 0 }
    slen := ord(str[0]);                { string length }

    { copy string to ASCIIZ conversion buffer: }
    while spos < slen do
    begin
        dest[spos] := str[spos+1];
        spos := spos + 1;
    end;

    dest[spos] := chr(0);               { put terminating 0 to end of string }

    toASCIIZ := dest;
end;

var
    module : PmpModule;
    i, error, isConfig : integer;
    str : array [0..256] of char;


BEGIN

    { Check that the configuration file exists: }
    error := fileExists('MIDAS.CFG', @isConfig);
    if error <> OK then
        midasError(error);
    if isConfig <> 1 then
    begin
        WriteLn('Configuration file not found - run MSETUP.EXE');
        Halt;
    end;

    midasSetDefaults;                   { set MIDAS defaults }
    midasLoadConfig('MIDAS.CFG');       { load configuration }
    midasInit;                          { initialize MIDAS Sound System }

    { Convert command line argument to ASCIIZ and load module: }
    module := midasLoadModule('.\MOOZ.MOD', @mpMOD, NIL);

    midasPlayModule(module, 0);         { start playing }

  init;
  play;
    midasStopModule(module);            { stop playing }
    midasFreeModule(module);            { deallocate module }
    midasClose;                         { uninitialize MIDAS }
    asm
    mov  ax,0003h
    int  10h
  end;
Writeln('Space Caress');
Writeln('Music & Code....... WaterDrum 97');
END.
