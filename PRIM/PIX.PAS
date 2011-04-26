{ RABEPI Labs. Entity #3....  VGA stuff.}
CONST VGA = $a000;

var
   block,loop1:integer;

procedure WVRet; assembler;
label
  l1, l2;
asm
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
end;

Procedure Putpixel (X,Y : Integer; Col : Byte);
  { This puts a pixel on the screen by writing directly to memory. }
BEGIN
  Mem [VGA:X+(Y*320)]:=Col;
END;

{ This procedure uses assembly function 07.. interrupt 10h to scroll the
  screen down 25 rows...}
procedure clear;
begin
 asm
    mov     ah,07h
    mov     al,25  {Number of lines to clear...}
    xor     bh,bh  {Active page... just to be sure}
    xor     cx,cx  {Column, Row for top left hand corner = 0,0}
    mov     dh,25  {Bottom corner row...}
    mov     dl,79  {Bottom corner column...}
    int     10h
    sub     dx,dx  {Set cursor position to 0,0}
    mov     ah,02h
    int     10h
 end;
end;

procedure _Mode3;
begin
  asm
     mov ax,0003h
     int 10h
  end;
end;

procedure _Mode13;
begin
  asm
     mov ax,0013h
     int 10h
  end;
end;

Procedure _Wkey;
begin
  asm
     @@100:
       xor  ah,ah
       int  16h
       or   ah,ah
       jz   @@100
  end;
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure line(a,b,c,d,col:integer);
  { This draws a line from x1,y1 to x2,y2 using the first method }

    function sgn(a:real):integer;
    begin
         if a>0 then sgn:=+1;
         if a<0 then sgn:=-1;
         if a=0 then sgn:=0;
    end;

var u,s,v,d1x,d1y,d2x,d2y,m,n:real;
    i:integer;
begin
     u:= c - a;
     v:= d - b;
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
          putpixel(a,b,col);
          s := s + n;
          IF not (s<m) THEN
          BEGIN
               s := s - m;
               a:= a +round(d1x);
               b := b + round(d1y);
          END
          ELSE
          BEGIN
               a := a + round(d2x);
               b := b + round(d2y);
          END;
     end;
END;


BEGIN
_Mode3;
Writeln('Mode_3');
_Wkey;
_Mode13;
Writeln('Mode_13');
for block:=10 to 200 do
begin
 for loop1 := 0 to 255 do
   begin
     Putpixel(loop1,block,loop1);
   end;
end;
_Wkey;
_Mode3;
END.