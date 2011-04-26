{$G+}
uses vidlib;

{$I c:\tp\dev1\palette2.dat}

VAR Pal : Array[0..767] of Byte;

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

{Procedure SetAllPal(Var Palette : PalType); Assembler;
  { This dumps the pallette in our variable onto the screen, fast }
{Asm
   push   ds
   lds    si, Palette
   mov    dx, 3c8h
   mov    al, 0
   out    dx, al
   inc    dx
   mov    cx, 768
   rep    outsb
   pop    ds
End;}

{Procedure GenPal;
VAR loop1,r,g,b:integer;

BEGIN
    for loop1:=1 to 128 do BEGIN
      bob[loop1].r:=loop1 div 4;
      bob[loop1].g:=loop1 div 4;
      bob[loop1].b:=loop1 div 4;
    END;
    for loop1:=129 to 255 do BEGIN
      bob[loop1].r:=loop1 div 4;
      bob[loop1].g:=loop1 div 4;
      bob[loop1].b:=loop1 div 4;
    END;
    setallpal (bob);
    move(bob,pall,768);
END;}

Procedure DAC(Col,R,G,B : Byte); assembler;
{ Haha Jim! }
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

procedure LoadPal;
var
  colnum,I : integer;
begin
  for i := 0 to 255 do
    DAC(i,ramppal[i*3],ramppal[i*3+1],ramppal[i*3+2]);

end;


{Procedure SpankThePalette(Start,Fin : byte);
Var
   Tmp : Array[1..3] of byte;
   loop1 : word;
Begin
   Move(pall[Fin],Tmp[1],3);
   Move(pall[1],pall[2],((Fin-1)*3));
   Move(Tmp,pall[Start],3);
For loop1:=Start to Fin do DAC(loop1,pall[loop1*3],
                                     pall[loop1*3+1],
                                     pall[loop1*3+2]);
End;}

Procedure CunninglyManipulatePalette(Start,Fin : byte);
Var
   loop1 : byte;
   Tmp : Array[1..3] of byte;
Begin
  WaitVR;

  Move(Pal[Fin],Tmp[1],3);
  Move(Pal[Start],Pal[Start+1],((Fin-1)*3));
  Move(Tmp,Pal[Start],3);

  For loop1:=Start to Fin do
    DAC(loop1,pal[loop1*3],
              pal[loop1*3+1],
              pal[loop1*3+2]);
  WaitVR;
End;

var
   index : word;

begin

  Mode($13);
  loadpal;
  move(ramppal,pal,768);
{  GenPal;}

  for index := 1 to 260 do
    begin
      CircleMid(160,100,index,index);
    end;

  repeat
{    SpankThePalette(1,254);}
    CunninglyManipulatePalette(1,254);
  until port[$60]=1;

  Mode(3);
end.