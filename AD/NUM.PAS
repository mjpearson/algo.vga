{$M 16384, 0, 32768}

{$I c:\tp\dev1\palette7.dat}
{$I c:\tp\fdat.dat}

     xmin   : word = 0;
     xmax   : word = 320;
     ymin   : word = 0;
     ymax   : word = 200;

     G_Xmin : word = 3;
     G_Xmax : word = 49;
     G_Ymin : word = 40;
     G_Ymax : word = 178;

var
   leave : boolean;
   NumX, NumY, Vaddr : word;
   Currnum : byte;

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
  x,y : word;

begin
x:=40;
  while x < 180 do
    begin
      fillchar(mem[where:22+(x*320)],277,col);
      inc(x,6);
    end;
  for y:= G_Ymin to G_Ymax do
    for x:= G_Xmin to G_Xmax do mem[where:(6*x)+(y*320)+4]:=col;

end;

Procedure Malloc(var segment : word; Size : word);
{ Getmem really does nothing for me... }
var
   Addr : word;
begin
  asm
    mov   ah,48h
    mov   bx,Size
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

procedure FreeM(segment:word);assembler;
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

begin
leave:=False;

CurrNum:=1;

Randomize;
NumY := (random(23)*6)+28;
NumX :=(random(47)*5)+11;

  Malloc(Vaddr,$1000); fillchar(mem[vaddr:0],64000,0);
  VidMode($13); LoadPal;

      Grid(vaddr,20);
      PokeString(125,10,'N',5,104,Vaddr);
      PokeString(135,15,'ibbles',4,104,Vaddr);
      PokeString(1,190,'Press <esc> to quit',1,104,Vaddr);
      PokeString(1,180,'Use arrow keys to navigate...',1,40,Vaddr);
      PokeString(NumX,NumY,inttostr(CurrNum),1,120,Vaddr);
      FlipW(Vaddr,$0a000);
      readln;
      asm
        mov ah,6  { Purge the keyboard }
        int 21h
      end;
  VidMode(3);
  FreeM(Vaddr);
end.