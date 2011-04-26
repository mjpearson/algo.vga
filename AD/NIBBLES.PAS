{
.úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùú.
     .         ø            .                           ùù
                     ÜÜ                     :
     ,  ù          ÜßÜß   ú    ÜßßÜ      .      i     '
                  ŞÛ Û    ù    ß²Üß         |                ì
  é         "D    Û  Û    Ş     ùú     ..      .   .ÜÜÜÜÜÜ
          r       Û  Û  úùÛù.úùÜßßÜ   ÜßßßßßÛ ÜßÜ..Û      ßÜ      ú
      `          ŞÛ  Û°ÜÛÛßÛÜßß°  ŞÛ Û°   İ  Û  ÛÛÛ  ÜÛÛÜ   Û     ù
         ù      ÜÛß  ßÛÛßß İÛÛİ   ŞÛİÛ   ÛÛ    ÛÛŞ   ÛÛÛÛ±Û Û  .  ³  .
         |    Ûß         ÛÛ²ŞÛÛ   ŞÛİÛ  Û° Û  Û²ŞÛÛ    İŞÛÜÛÛ   \ º /
      .      Ûß ÜßÛÜ  ÜÛÛÛÛÛŞÛÛ   ŞÛİÛ  Û  Û  Ûİ±ÛÛİ   Ü   Û úùÄÍğéğÍÄùú
            ÛÜÛßÛÛÛÛ  Û±²ÛÛÛŞ±Û   ŞÛİÛ  °ÛÛ   °ÛŞÛ±ÛßÛÛÛÛÜ  Û   / º \
   .ù        Û   ŞÛŞ  Û±ÛßÜÛŞ²Û    ÛİÛİ   İ   ÛÛİŞ² Ş²ÛÛ²ß  Û  ù  ³   ú
             İ    ßÛÛ  ß  ÛİÛÛß°    ßÜÛ²Ü    Ü  ÜÛÛÛ  ßß   Û  ÜßßÜ ÄÄÄÄÄÄÄÄÄÄ
             ù     ßÛÛ   ÜÛÛßŞÛÛÛÛÜÜÜÛÛßÛÛÛÛÛÛÛßß ßÛÜ    Üß   Û opyright 1997
             ú     İ ßßÛßß           Ûİ            ßßßßÛß     ßÜÜß ÄÄÄÄÄÄÄÄÄÄ
   ú         .     ù   İ             Û                ŞÛ  ù
       ?        .  ú          o      Ş            .    İ    ¡   ú
                                .          ù               ù
     ø            ú                                       ú  úù
 .úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùú.
          Pure Will, unassuaged of purpose, delivered from lust of result
                             is everyway perfect.
                  (A. Crowley... Magick in Theory and Practice)
 .úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùú..

                                  ù Goth.Nibbles ù
                          An Non-officially sanctioned program
                     Complete Source for Adfinis Notaem, Liber Unus

                    A.N version features two players / music & SFX
                            ie : This is a bare bones proggy.

   This hack is extrememly simple.  Took me a total of 4 hours on/off with
   dinner, telly and phonecalls in between.  Decent speed, tho the keyboard
   was shitting me off quite allot; It handled fairly sporatically and using
   interrupts just won't do so I can safely say that I was stuck. *8)
   Final port to TASM 3.2 a week after the stamp on this file.

   Use, abuse, rip, strip, I don't really care. As long as you learn from it.

   Michael Pearson
    (aka Caglios)

   No email at the mo : I just quit my CS course so no .edu account anymore.
                        so sad :(
   but you can ring   : +61 07 32812955

   or snail me if
   you like at        : 5 Park St, Ipswich Qld, Australia, 4305
}

{$M 16384, 0, 32768}
uses crt;

const
     xmin : word = 0;
     xmax : word = 320;
     ymin : word = 0;
     ymax : word = 200;

    _left  = 1;   { Flag Values }
    _right = 2;
    _up    = 3;
    _down  = 4;

    NibPath : array [1..50,1..2] of word = (

             (160,100),(165,100),(170,100),(175,100),(180,100),
             (185,100),(190,100),(195,100),(200,100),(205,100),

             (0,0),(0,0),(0,0),(0,0),(0,0),
             (0,0),(0,0),(0,0),(0,0),(0,0),
             (0,0),(0,0),(0,0),(0,0),(0,0),
             (0,0),(0,0),(0,0),(0,0),(0,0),
             (0,0),(0,0),(0,0),(0,0),(0,0),
             (0,0),(0,0),(0,0),(0,0),(0,0),
             (0,0),(0,0),(0,0),(0,0),(0,0),
             (0,0),(0,0),(0,0),(0,0),(0,0));

    NibSize : byte = 50;  { Maximum Path Size }

  { Kbd scans }
    DownArrow  = $50;
    UpArrow    = $48;
    LeftArrow  = $4b;
    RightArrow = $4d;
    Escape     = $1;

var
   leave : boolean;
   NumX,NumY,Vaddr,NibX,NibY,xoffs,yoffs : word;
   currnum,scan,direction : byte;
   CurNumOrds : array [1..2] of word;

{$I d:\tp\dev1\palette7.dat}
{$I d:\tp\fdat.dat}

procedure LoadPal;
  procedure DAC(ColNum,R,G,B : byte); Assembler;
  asm
    mov al,[ColNum]
    mov dx,3c8h
    out dx,al
    inc dx
    mov al,[r]
    out dx,al
    mov al,[g]
    out dx,al
    mov al,[b]
    out dx,al
  end;

var
  I : word;
begin
  for i := 0 to 255 do
     dac(i,ramppal[i*3],ramppal[i*3+1],ramppal[i*3+2]);
end;

procedure Grid(where : word; col : byte);
var
  y,ind : word;

begin
ind:=40;
  while ind < 180 do
    begin
      fillchar(mem[where:22+(ind*320)],277,col);
      inc(ind,6);
    end;
  for y:= 40 to 178 do
    for ind:= 3 to 49 do mem[where:(6*ind)+(y*320)+4]:=col;
end;

Procedure Malloc(var segment : word);
{ Getmem really does nothing for me... }
var
   Addr : word;
begin
  asm
    mov   ah,48h
    mov   bx,1000h
    int   21h
    jnc   @@Nerror
    xor   ax,ax
@@Nerror:
    mov   Addr,ax
 end;
   If Addr=0 then
     begin
       Writeln('Error : Coultn`t hog memory');
       Halt;
     end;
Segment := Addr;
end;

procedure FreeBuffer(segment:word);assembler;
{ Hey, i'm doing this in asm anyway, why use a library? }
asm
  mov ax,4921h
  mov bx,segment
  int 21h
end;

procedure FlipW(source, dest : word); Assembler;
{ Word-Size flip }
asm
  push  ds
  mov   es,dest
  mov   ds,source
  xor   di,di
  mov   si,di
  mov   cx,32000
  rep   movsw
  pop   ds
end;

procedure VidMode(Mode : word); Assembler;
asm
  mov ax,Mode
  int 10h
end;

function KeyP:byte;assembler;
asm
  in al,$60
  xor ah,ah
end;

procedure PutPixel(x,y : word; col : byte; Where : word);
  function Between(num,lo,hi : word) : boolean;
    begin
      if ((num < hi) and (num > lo)) then Between:=True
      else Between:=False;
    end;
begin
  if (Between(x,xmin,xmax) and between(y,ymin,ymax)) then
    mem[Where:x+(y*320)]:=col;
end;

procedure Matrix(where,x,y : word; size,col : byte);
var
   xindex,yindex : byte;
begin
  for xindex:=1 to size do
    for yindex:=1 to size do
      putpixel(x+xindex,y+yindex,col,where);
end;

procedure WriteNib(NibX,NibY : word);
var
   NibIndex : byte;
begin
  { Update the 'front' of the worm to the current ords }
  NibPath[1,1]:=NibX; NibPath[1,2]:=NibY;
  { Move all co-ordinates in the path array up by one... }
  for nibindex:= NibSize downto 2 do
      if ((NibPath[NibIndex,1] <> 0) AND (NibPath[NibIndex,2] <> 0)) then
        begin
          NibPath[nibindex,1]:=NibPath[NibIndex-1,1];
          NibPath[nibindex,2]:=NibPath[NibIndex-1,2];
        end;
  { Write the cells to the virtual display }
  for nibindex := 1 to NibSize do
    if ((NibPath[NibIndex,1] <> 0) AND (NibPath[NibIndex,2] <> 0)) then
         matrix(vaddr,NibPath[NibIndex,1],
                      NibPath[Nibindex,2],5,70+(2*NibIndex));
  { And flip it to the VGA Segment }
  FlipW(Vaddr,$0a000);
end;

{ Note : This procedure shall have to be slightly modified if ASCII
         graphical characters are added.  For the present it only
         accomodates characters 33-96 in the algorithm; All of which
         are uppercase.  ie : lowercase input is converted to an
         uppercase font. }
procedure PokeString(X, Y  : word; InString : string; Size, Colour : byte;
                     where : word);

var i,offset,Index,XOrigin : word;
    YOrigin,index2,XIndex  : word;

begin
XOrigin := X;
XIndex  := Xorigin;
YOrigin := y;
offset  := 1;

for Index2 := 1 to length(InString) do
begin
{ Is the character a lowercase letter??? }
if (word(InString[Index2]) > 96) and (word(InString[Index2]) < 123) then
{ Lowercase - Uppercase }
offset:=((word(InString[Index2])-65)*(FontWidth*FontHeight))+1
else
{ Otherwise leave them alone }
offset:=((word(InString[Index2])-33)*(FontWidth*FontHeight))+1;

{ Poke 1 Character }
if word(InString[Index2]) > 0 then
  begin
    for Index := offset to (offset+((FontWidth*FontHeight)-1)) do
      begin
        inc(x);
       if Fontdata[Index] <> 0 then
           for i:=1 to size do
                   mem [where:x+((y+i)*320)]:=Fontdata[Index]+(Colour-1);
       if x > (Xorigin + (FontWidth-1)) then
         begin
           x:=XOrigin;
           inc(y,size);
         end;
      end;
  inc(colour,4);
end;
  XIndex := Xorigin+(FontWidth+(2*size));  { Space between characters }
  Xorigin := XIndex;     { Set the new X origin }
  x := XOrigin;          { Reset new X for next character }
  y:= Yorigin;            { And align the Y co-ord to keep them in line }
end;
end;

function IntToStr(I: Longint): String;
{ Convert any integer type to a string }
var
 S: string[11];
begin
 Str(I, S);
 IntToStr := S;
end;

{
 Here it is, the main program
}
begin
leave:=False; Direction:=_Left; NibX := 160; NibY:=100;
CurrNum:=1;

Randomize;
NumY := (random(23)*6)+28;
NumX := (random(47)*5)+11;

CurNumOrds[1]:=NumX;
CurNumOrds[2]:=NumY;

Malloc(Vaddr);
VidMode($13); LoadPal;

 while not leave do
    begin
     fillchar(mem[vaddr:0],64000,0);
     scan:=Keyp;
      case scan of
        Escape     : Leave:=True;
        DownArrow  : if Direction <> _Up then Direction:=_Down;
        UpArrow    : if Direction <> _Down then Direction:=_Up;
        LeftArrow  : if Direction <> _Right then Direction:=_Left;
        RightArrow : if Direction <> _Left then Direction:=_Right;
      end;
      case direction of
        _left  : dec(NibX,6);
        _Right : inc(NibX,6);
        _Up    : dec(NibY,6);
        _Down  : inc(NibY,6);
      end;
      if NibX < 18 then NibX:=292 else
      if NibX > 292 then NibX:=22 else
      if NibY > 175 then NibY:=40 else
      if NibY < 36 then NibY:=172;

      Grid(vaddr,20);
      PokeString(125,10,'nibbles',5,104,Vaddr);
      PokeString(1,190,'Press <esc> to quit',1,104,Vaddr);
      PokeString(1,180,'Use arrow keys to navigate...',1,40,Vaddr);
      PokeString(NumX,NumY,inttostr(CurrNum),1,120,Vaddr);
      WriteNib(NibX,NibY);
      delay(50);  { Wait for a bit }
      asm
        mov ah,6  { Purge the keyboard }
        int 21h
      end;
    end;
  VidMode(3);
  FreeBuffer(Vaddr);
end.