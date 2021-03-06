{ Video library... still under development...}
{ 'Caglios 1997                              }
UNIT VidLib;

INTERFACE

procedure Putpixel (X,Y:Integer; Col: Byte);
Procedure Mode (GFXMode : byte);
Procedure WaitVR;
Procedure Line(a,b,c,d,col:integer);

IMPLEMENTATION

Procedure Putpixel (X,Y : Integer; Col : Byte);
BEGIN
  Mem [$0a000:X+(Y*320)]:=Col;
END;

Procedure Mode (GFXMode : byte); assembler;
asm
  xor ah,ah
  mov al,GFXMode
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

procedure line(a,b,c,d,col:integer);
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

begin
end.