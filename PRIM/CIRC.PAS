{$G+}
uses vidlib;

TYPE RGBType = Record
               R, G, B : Byte;
            End;
    PalType = Array[0..255] of RGBType;

VAR bob:paltype;

procedure CircleMid ( xCenter, yCenter, radius : integer; col : byte);
var
   p, x, y : integer;
   procedure plotpoints;
   begin
     putpixel($0a000,XCenter + x, YCenter + y, col);
     putpixel($0a000,XCenter - x, YCenter + y, col);
     putpixel($0a000,XCenter + x, YCenter - y, col);
     putpixel($0a000,XCenter - x, YCenter - y, col);
     putpixel($0a000,XCenter + y, YCenter + x, col);
     putpixel($0a000,XCenter - y, YCenter + x, col);
     putpixel($0a000,XCenter + y, YCenter - x, col);
     putpixel($0a000,XCenter - y, YCenter - x, col);
   end;
begin
  x:=0;
  y:=radius;
  PlotPoints;
  p:=1-radius;
  while x < y do
    begin
      if p < 0 then
        inc(x)
      else
        begin
          x:=x+1;
          y:=y-1;
        end;
      if p < 0 then
        p:=p+2*x+1
      else
        p:=p+2*(x-y)+1;
      plotpoints;
    end;
end;

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

Procedure GenPal;
VAR loop1,r,g,b:integer;

BEGIN
    for loop1:=0 to 255 do BEGIN
      bob[loop1].r:=loop1 div 4;
      bob[loop1].g:=loop1 div 4;
      bob[loop1].b:=loop1 div 4;
    END;
    setallpal (bob);
END;

var
   index : word;

begin

  Mode($13);
  GenPal;
  for index := 1 to 260 do
    begin
      CircleMid(160,100,index,index);
    end;
  readln;
  Mode(3);
end.