{ Rotates a line around a point }
program rotate;

uses vidlib,crt;

var colour,x,y,x2,y2: integer; {screen coords}
    rad,deg:real;

begin
 deg:=0; rad:=80;colour:=30;
 Mode($13);

repeat
  line(160,100,x,y,0);
  line(160,100,x2,y2,0);
  line(x,y,x2,y2,0);

  X:=round(rad*COS (deg))+160;
  Y:=round(rad*sin (deg))+110;

  X2:=round(rad*COS (deg))+120;
  Y2:=round(rad*sin (deg))+110;

  line(160,100,x,y,colour);
  line(160,100,x2,y2,colour);
  line(x,y,x2,y2,colour);

  deg:=deg+0.05;
  WaitVR;
 until keypressed;
 mode(3);
end.