{ Rotates a line around a point }
program rotate;


uses vidlib,crt;

var
    Points    : array [1..4,1..2] of word;
    colour,x,y,x2,y2: integer; {screen coords}
    rad,deg:real;
    i : byte;

begin
 deg:=0; rad:=45;colour:=30;
 Mode($13);
 Points[1,1]:=160;
 Points[1,2]:=10;
 Points[2,1]:=180;
 Points[2,2]:=100;

repeat
  fillchar(mem[$0a000:0],64000,0);
  for i:= 1 to 2 do
    begin
      X:=round(rad*COS(deg)+Points[i,1]);
      Y:=round(rad*sin(deg)+Points[i,2]);
      Putpixel(x,y,colour);
    end;

{  line(160,100,x,y,0);}

{  X:=round(rad*COS (deg))+160;
  Y:=round(rad*sin (deg))+100;}

{  line(160,100,x,y,colour);}
{  putpixel(x,y,colour);}
  deg:=deg+0.05;
  WaitVR;
 until keypressed;
 mode(3);
end.