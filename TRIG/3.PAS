program v;

Procedure Putpixel (Where:word;X,Y : Integer; Col : Byte);
  function between(num,hi,lo : word): boolean;
    begin
      if (num < hi) and (num > lo) then Between:=True else
      between:=False;
    end;

BEGIN
  if between(x,320,0) and between(y,200,0) then
    Mem [Where:X+(Y*320)]:=Col;
END;

procedure line(where : word;x1,y1,x2,y2,col:integer);
  function sgn(a:real):integer;
    begin
         if a>0 then sgn:=+1;
         if a<0 then sgn:=-1;
         if a=0 then sgn:=0;
    end;

var u,s,v,d1x,d1y,d2x,d2y,m,n:real;
    i:integer;
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
          putpixel(where,x1,y1,col);
          s := s + n;
          IF not (s<m) THEN
          BEGIN
               s := s - m;
               x1:= x1 +round(d1x);
               y1 := y1 + round(d1y);
          END
          ELSE
          BEGIN
               x1 := x1 + round(d2x);
               y1 := y1 + round(d2y);
          END;
     end;
END;

procedure SetM(m : word);  Assembler;
asm
   mov ax,m
   int 10h
end;

procedure WaitVR; assembler;
asm
    mov dx,3DAh
@@scanhi:
    in al,dx
    and al,08h
    jnz @@scanhi
@@scanlo:
    in al,dx
    and al,08h
    jz  @@scanlo
end;

const
     Center : array [1..2] of word = (160,100);
     Point  : array [1..4,1..2] of integer = (
                                   (20,-20),(20,20),(-20,20),(-20,-20));

var
     newp  : array [1..4,1..2] of integer;
     rad, index : byte;
     deg   : real;

begin
  SetM($13);
  rad:=80;
  for index := 1 to 4 do
    begin
      writeln(Point[index,1],',',Point[Index,2]);
    end;
  move(Point,newp,sizeof(Point));
  writeln;
  for index := 1 to 4 do
    begin
      writeln(NewP[index,1],',',NewP[Index,2]);
    end;

{  for index := 1 to 4 do
    Putpixel ($0a000,Center[1]+NewP[index,1],Center[2]+NewP[index,2],10);}

  repeat
  for index := 1 to 4 do
    begin
      Putpixel ($0a000,Center[1]+round(round(sqrt(sqr(Newp[index,1])+sqr(Newp[index,2])))*cos(deg)),
                       Center[2]+round(round(sqrt(sqr(Newp[index,1])+sqr(Newp[index,2])))*sin(deg)),0);
    end;
  deg:=deg+0.01;
  for index := 1 to 4 do
    begin
{      Newp[index,1]:=round(Newp[index,1]*cos(deg));
      Newp[index,2]:=round(Newp[index,2]*sin(deg));
      rad:=round(sqrt(sqr(Newp[index,1])+sqr(Newp[index,2])));}
      Putpixel ($0a000,Center[1]+round((sqrt(sqr(Newp[index,1])+sqr(Newp[index,2])))*cos(deg)),
                       Center[2]+round((sqrt(sqr(Newp[index,1])+sqr(Newp[index,2])))*sin(deg)),10);
    end;
      waitvr;
  until port[$60]=1;

  SetM($3);
end.