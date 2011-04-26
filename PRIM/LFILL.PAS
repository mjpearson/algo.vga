{ RABEPI Labs. Entity #3.354....  VGA stuff.}

{$G+}
uses vidlib;   {Cag's Rad Video utils library!!}

  function sgn(a:real):integer;
    begin
         if a>0 then sgn:=+1;
         if a<0 then sgn:=-1;
         if a=0 then sgn:=0;
    end;

procedure DrawLine(x, y1, y2 : Integer; c : Byte);
var
  OffSet, EndOffSet : Word;

begin
  {Clip top of screen}
  if y1 < 0 then y1 := 0;
  {Clip bottom of screen}
  if y2 > 199 then y2 := 199;
  {Offset at start of line}
  OffSet    := y1 shl 8 + y1 shl 6 + x;
  {Offset at end of line}
  EndOffSet := y2 shl 8 + y2 shl 6 + x;

  while OffSet < EndOffSet do begin
    {Set pixel}
    Mem[$0a000:OffSet] := c;
    {Go to next scan line}
    inc(OffSet, 320);
  end;

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
          drawline(x1,y1,y2,col);
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

{ Waits for a key to be entered at standard input }
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
     Mode($13);

     line(101,10,39,19,10);

     Wait4Key;
     Mode(3);
end.
