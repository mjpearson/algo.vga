
procedure PutPixel(x,y,col : word);
begin
  mem[$0a000:x+(y*320)]:=col;
end;

procedure lineDDA(xa,ya,xb,yb : integer);
var
   dx,dy,steps,k : integer;
   xIncrement, yIncrement, x, y : real;
begin
  dx:=xb-xa;
  dy:=yb-ya;
  if abs(dx) > abs(dy) then steps:=abs(dx)
  else steps:=abs(dy);
  xIncrement:=dx/steps;
  yIncrement:=dy/steps;
  x:=xa;
  y:=ya;
  putpixel(round(x), round(y), 10);
  for k:= 1 to steps do
    begin
      x:=x+xIncrement;
      y:=y+yIncrement;
      putpixel(round(x), round(y), 10);
    end;
end;

procedure VM(Mode : Word); Assembler;
asm
  mov ax,Mode
  int 10h
end;

begin
  VM($13);
  LineDDA(100,100,1,40);
  readln;
  VM(3);
end.