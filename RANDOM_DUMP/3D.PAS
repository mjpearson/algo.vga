uses vidlib,crt;

var x,y,z,xt,yt,zt:real; {virtual points, temp points}
    xan,yan,zan:real; {angles for X,Y,Z axis}
    count,sx,sy: integer; {screen coords}

begin
 mode($13);     {sets to 13h (320x200x256) mode}
 directvideo:=false;
 Count :=0;
 Zan :=  0.2; {angle for rotation about Z axis}
 Yan :=  0.1; {angle for rotation about Y axis}
 Xan :=  0.1; {angle for rotation about X axis}

 x:=10;  {coord of point on X axis}
 y:=10;  {coord of point on Y axis}
 z:=10;  {coord of point on Z axis}

 repeat
  count:=count+1;
  line(100,100,sx,sy,0);
  PUTPIXEL(SX,SY,0);
  Yt:= Y * COS(Xan) - Z * SIN(Xan); {calculates position after rotating}
  Zt:= Y * SIN(Xan) + Z * COS(Xan); {about the X axis}
  Y:= Yt;
  Z:= Zt;
  Xt:= X * COS(Yan) - Z * SIN(Xan); { '  ' about Y axis}
  Zt:= X * SIN(Yan) + Z * COS(Xan);
  X:= Xt;
  Z:= Zt;
  Xt:= X * COS(Zan) - Y * SIN(Zan); { '  ' about Z axis}
  Yt:= X * SIN(Zan) + Y * COS(Zan);
  X:= Xt;
  Y:= Yt;
  sx:=round(x)+160; {converts REAL to INTEGER,}
  sy:=round(y)+100; {160,100 is the centre of the screen}
  line(100,100,sx,sy,10);
  PUTPIXEL(SX,SY,15); {draws the point}
  {delay(100);}
  gotoxy(1,1);writeln('Number of plots : ',count);
  waitvr; {just a delay}
 until keypressed; {loops until you press a key}
 readkey;
 Mode(03); {Back to text mode}
end.
