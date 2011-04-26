{ RABEPI Labs. Entity #3.357....  PolyGons }

{$G+}

uses crt,vidlib;   {Cag's Rad Video utils library!!}

const Bowtie : array [0..13] of byte =
               (10,10,30,20,50,10,50,50,30,30,10,50,10,10);

var NumVerts,loop:integer;

function sgn(a:real):integer;
begin
  if a>0 then sgn:=+1;
  if a<0 then sgn:=-1;
  if a=0 then sgn:=0;
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure line(x1,y1,x2,y2,col:integer);
{ Bresenham's Line Method }

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
          putpixel(x1,y1,col);
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


{Waits for a key to be entered at standard keyboard}
procedure Wait4Key;
begin
  asm
    @@100:
      xor  ah,ah
      int  16h
      or   ah,ah
      jz   @@100
  end;
end;

begin
     Loop:=0; NumVerts:=14;
     Directvideo:=false;
     Mode($13);

repeat
  Line(Bowtie[loop],BowTie[Loop+1],BowTie[loop+2],BowTie[loop+3],10);
  loop:=loop+2;
until loop=(NumVerts-2);

 textcolor(9);gotoxy(10,4); write('Plotted BowTie Polygon');
     Wait4Key;
     Mode(3);
end.
