{ RABEPI Labs. Entity #3.354....  VGA stuff.}

{$G+}
uses crt,vidlib;   {Cag's Rad Video utils library!!}

TYPE RGBType = Record
               R, G, B : Byte;
            End;
    PalType = Array[0..255] of RGBType;

VAR bob:paltype;


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

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
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
{    for loop1:=1 to 128 do BEGIN
      bob[loop1].r:=0;
      bob[loop1].g:=loop1 div 4;
      bob[loop1].b:=loop1 div 4;
    END;
    for loop1:=129 to 255 do BEGIN
      bob[loop1].r:=0;
      bob[loop1].g:=63-loop1 div 4;
      bob[loop1].b:=63-loop1 div 4;
    END;}

    for loop1:=1 to 128 do BEGIN
      bob[loop1].r:=63-loop1 div 4;
      bob[loop1].g:=0;
      bob[loop1].b:=loop1 div 4;
    END;
    for loop1:=129 to 255 do BEGIN
      bob[loop1].r:=loop1 div 4;
      bob[loop1].g:=0;
      bob[loop1].b:=63-loop1 div 4;
    END;
    setallpal (bob);
END;

Procedure Paldisplay;
var loop1,x1,x2: integer;
begin
 x1:=40;x2:=40;
  for loop1:= 1 to 255 do begin
   line(x1,0,x2,200,loop1);
   x1:=x1+1; x2:=x2+1;
  end;
end;

Procedure Clear;
begin
  asm
    mov     ah,07h
    mov     al,25  {Number of lines to clear...}
    xor     bh,bh  {Background colour}
    xor     cx,cx  {Column, Row for top left hand corner = 0,0}
    mov     dh,25  {Bottom corner row...}
    mov     dl,79  {Bottom corner column...}
    int     10h
    sub     dx,dx  {Set cursor position to 0,0}
    mov     ah,02h
    int     10h
  end;
end;

Procedure RandPP;
var loop1,loop2:integer;
begin
  For loop1:=0 to 319 do
    For loop2:=0 to 199 do
      Putpixel (loop1,loop2,Random (256));
end;

begin
     Directvideo:=false;
     Mode($13);
     PalDisplay;
     gotoxy(13,12);
     Writeln('Default Pallette');
     Wait4Key;
     RandPP;
     readkey;
     clear;
     GenPal;
     PalDisplay;
     gotoxy(13,12);
     writeln('Generated Palette');
     Wait4Key;
     RandPP;
     Wait4Key;
     Mode(3);
end.
