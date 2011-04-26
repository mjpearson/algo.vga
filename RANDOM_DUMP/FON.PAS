program VGA_Font;
{

 Caglios ú n1921380@student.fit.qut.edu.au

}

{$I fdat.dat}           { Font Data }

const VGAMem = $0a000;
      EnterKey = $1c;

var Cur_Line : string;
    asc,scan : byte;
    OldCX,CurX,CurY : word;
    offset : word;

procedure VidMode(Mode:word); Assembler;
asm
 mov ax,Mode
 int 10h
end;

{ Note : This procedure shall have to be slightly modified if ASCII
         graphical characters are added.  For the present it only
         accomodates characters 33-96 in the algorithm; All of which
         are uppercase.  ie : lowercase input is converted to an
         uppercase font. }
procedure PokeString(X,Y   : word; InString : string; Colour : byte;
                     where : word);

var offset,Index,XOrigin  : word;
    YOrigin,index2,XIndex : word;

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
          mem [where:x+(y*320)]:=Fontdata[Index]+(Colour-1);
       if x > (Xorigin + (FontWidth-1)) then
         begin
           x:=XOrigin;
           inc(y);
         end;
      end;
end;
  XIndex := XIndex + (FontWidth+1);  { Space between characters }
  Xorigin := XIndex;     { Set the new X origin }
  x := XOrigin;          { Reset new X for next character }
  y:=Yorigin;            { And align the Y co-ord to keep them in line }
end;
end;

Procedure RectBlt(X,Y,X2,Y2,Col,where:word);
var W_Index,H_Index : byte;
begin
for H_Index := y to y2 do
  begin
    for W_Index := X to X2 do
      begin
        mem[where:W_Index+(H_Index*320)]:=col;
      end;
  end;
end;

procedure PalFunk(BaseX,BaseY,BlockSize : word);
var YOrigin : word;
begin
YOrigin:=BaseY;
for offset := 0 to 255 do
  begin
   RectBlt(BaseX,BaseY,(BaseX + BlockSize),(BaseY + BlockSize),offset,VGAmem);
   BaseY:=BaseY+(BlockSize+2);
   if BaseY > (YOrigin + (16*BlockSize)+(Sqr(Blocksize))) then
     begin
       BaseY:=YOrigin;
       BaseX:=BaseX+(BlockSize+2);
     end;
  end;
end;

begin
  CurX:=80;OldCX:=CurX;CurY:=50;
  VidMode($13);
{asm
  mov ax,101bh   { Set palette 256-grey }
{  xor bx,bx
  mov cx,0ffh
  int 10h
end;}
  PalFunk(5,70,5);
  PokeString(10,10,'Font-o-matic v1.0',100,VGAMem);
  PokeString(10,30,'Any key for input.  ESC to exit',100,VGAMem);
  PokeString(10,50,'Test Input here -> ',100,VGAMem);
  PokeString(0,195,'CODE : CAGLIOS',100,VGAMem);
  PokeString(250,195,'TIAS 1994,1997',100,VGAMem);
  repeat
   asm
    xor ah,ah
    int 16h
    mov scan,ah
    mov asc,al
   end;
    if (asc > 32) or (asc = $20) then
      begin
        CurX:=CurX+4;
        PokeString(CurX,CurY,char(asc),10,VGAMem);
      end;
    if scan = EnterKey then begin CurY:=CurY + 8; CurX:=OldCX; end;
  until scan =1;
VidMode(3);
end.
