{ RABEPI Labs. Entity #3.354....  VGA stuff.}

{$G+}
uses crt,vidlib;   {Cag's Rad Video utils library!!}

  function sgn(a:real):integer;
    begin
         if a>0 then sgn:=+1;
         if a<0 then sgn:=-1;
         if a=0 then sgn:=0;
    end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Circle (X,Y,rad:integer;Col:Byte);
  { This draws a circle with centre X,Y, with Rad as it's radius }
VAR deg:real;
BEGIN
  deg:=0;
  repeat
    X:=round(rad*arctan (sin(deg)) * (arctan(deg)+0.0001));
    Y:=round(rad*sin (sin(deg)) * (sin(rad)+0.000002));
    putpixel ($0a000,x+160,y+100,col);
    deg:=deg+0.01;
  until (deg>6.3);
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

var
  i : byte;

begin
i:=1;
     Directvideo:=false;
     Mode($13);
     while not (i > 200) do
       begin
         circle(100,1000,i,30);
         inc(i,8);
       end;
     Wait4Key;
     Mode(3);
end.
