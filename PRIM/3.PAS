{
 X/Y Scaling example...
}

TYPE Virtual = Array [1..64000] of byte;
     VirtPtr = ^Virtual;

{$I ..\fdat.dat}           { Font Data }

      CubeOBJ   : array [0..3,0..1] of integer = (
                  (-1,-1),
                  ( 1,-1),
                  ( 1, 1),
                  (-1, 1));

      LineArr   : array [0..3,0..1] of byte = (
                  (0,1),(1,2),(2,3),(3,0));

      NumPoints : byte = 3;       { -1  because of zero indexes }

      XWinMax   = 320;
      XWinMin   : word = 0;

      YWinMax   = 180;
      YWinMin   : word = 0;

      XMid      : word = XWinMax div 2;
      YMid      : word = YWinMax div 2;

var
      Virscr    : VirtPtr;
      bseg      : word;
      zind      : byte;
      d_Flag    : boolean;
      de        : real;

Procedure _Malloc;
BEGIN
  GetMem (VirScr,64000);
  bseg := seg (virscr^);   {The segment for page 1}
END;

Procedure _MDealloc;
BEGIN
  FreeMem (VirScr,64000);
END;

procedure PokeString(X, Y  : word; InString : string; Size, Colour : byte;
                     where : word);

var i,offset,Index,XOrigin : word;
    YOrigin,index2,XIndex  : word;
    oldcol : byte;
begin
XOrigin := X;
XIndex  := Xorigin;
YOrigin := y;
offset  := 1;
OldCol := Colour;

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
end;
  XIndex := Xorigin+(FontWidth+(2*size));  { Space between characters }
  Xorigin := XIndex;     { Set the new X origin }
  x := XOrigin;          { Reset new X for next character }
  y:= Yorigin;            { And align the Y co-ord to keep them in line }
  colour:= oldcol;
end;
end;


Procedure Putpixel (Where, x, y :word; Col : Byte);
  function between(num,hi,lo : word): boolean;
    begin
      if (num < hi) and (num > lo) then Between:=True else
      between:=False;
    end;

BEGIN
  if (between(x,XWinMax,XWinMin) and
      between(y,YWinMax,YWinMin)) then
      Mem [Where:X+(Y*320)]:=Col;
END;

Procedure line(buff : word; x1, y1, x2, y2 : integer; col : byte);

{ Bresenham's Line Method }
  function sgn( a : real) : integer;
    begin
         if a>0 then sgn:=+1;
         if a<0 then sgn:=-1;
         if a=0 then sgn:=0;
    end;

var
    u, s, v, d1x,
    d1y, d2x, d2y,
    m, n           : real;
    i              : integer;

begin
     u:= x2 - x1;
     v:= y2 - y1;
     d1x:= SGN(u);
     d1y:= SGN(v);
     d2x:= SGN(u);
     d2y:= 0;
     m:= ABS(u);
     n := ABS(v);
     IF NOT (M>N) then
     BEGIN
          d2x := 0 ;
          d2y := SGN(v);
          m := ABS(v);
          n := ABS(u);
     END;
     s := INT(m / 2);
     FOR i := 0 TO round(m) DO
     BEGIN
          putpixel(buff,x1,y1,col);
          s := s + n;
          IF not (s<m) THEN
          BEGIN
               s := s - m;
               x1:= x1 + round(d1x);
               y1 := y1 + round(d1y);
          END
          ELSE
          BEGIN
               x1 := x1 + round(d2x);
               y1 := y1 + round(d2y);
          END;
     end;
END;

procedure VM(Mode : Word); Assembler;
asm
  mov ax,Mode
  int 10h
end;

procedure DrawOBJ( ZoomIndex, col : byte; Buffer : word; deg : real);
var
   lindex : word;
   ax, ay, bx, by : word;

begin
   putpixel(Buffer,XMid,YMid,col);

   for lindex := 0 to NumPoints do
     begin
       ax := word((CubeOBJ[Linearr[Lindex,0],0]*zoomindex)+XMid);
       ay := word((CubeOBJ[linearr[Lindex,1],1]*zoomindex)+YMid);
       bx := word((CubeOBJ[Linearr[Lindex,0],1]*zoomindex)+XMid);
       by := word((CubeOBJ[linearr[Lindex,1],0]*zoomindex)+YMid);
       Line(buffer,ax,ay,bx,by,col);
       Line(buffer,XMid,YMid,bx,by,col);
       Line(buffer,bx,ay,XMid,YMid,col);
     end;
end;

function ESC : Byte; Assembler;
asm
  in al,60h
  xor ah,ah
end;

procedure VidSync; Assembler;
asm
  mov dx,3dah
@@1000:
  in  al,dx
  and al,8
  jnz  @@1000
@@2000:
  in  al,dx
  and al,8
  jz @@2000
end;

procedure FLip16(source, dest : word); Assembler;
asm
  push  ds
  mov   cx,32000
  mov   es,dest
  xor   si,si
  mov   di,si
  mov   ds,source
  rep   movsw
  pop   ds
end;

function IntToStr(I: Longint): String;
var
 S: string[11];
begin
 Str(I, S);
 IntToStr := S;
end;

Procedure CLRBuff( buf : word); Assembler;
asm
  push  es
  mov   es, buf
  xor   ax,ax
  mov   cx,32000
  xor   di,di
  mov   si,di
  rep   stosw
  pop   es
end;

begin
  d_Flag := false;
  zind   := 165;

  _Malloc;
  VM($13);

asm
  mov ax,101bh   { Set palette 256 greyscale }
  xor bx,bx
  mov cx,0ffh
  int 10h
end;

repeat

  CLRBuff(bseg);
  if D_Flag then
    begin
      inc(zind,3);
      if zind > 165 then D_Flag := False;
    end
  else
    begin
      dec(zind,3);
      if zind < 1 then D_Flag:=True;
    end;
  DrawOBJ(Zind, 30, bseg,de);
  PokeString(0,185,'C',2,100,bseg);
  PokeString(6,188,'urrent zoom : '+inttostr(zind),1,100,bseg);
  Flip16(bseg,$0a000);
  VidSync;

until ESC = 1 ;

  VM(3);
  _MDealloc;
end.