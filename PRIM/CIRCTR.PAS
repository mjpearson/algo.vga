{ RABEPI Labs. Entity #3.354....  VGA stuff.}

{$G+}
uses crt,vidlib;   {Cag's Rad Video utils library!!}

var
  i : word;
  circ : array [1..630,1..2] of word;

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
    X:=round(rad*cos(deg));
    Y:=round(rad*sin(deg));
   { if ((deg < 1.6) or (deg > 4.7)) then {line(x+160,y+100,320,y+100,col)}
{     else} putpixel ($0a000,x+160,y+100,col);{}
{    else line(x+160,y+100,0,y+100,col);}
    gotoxy(10,10); Write(Deg);
    inc(i);
    circ[i,1]:=x+160;
    circ[i,2]:=y+100;
    deg:=deg+0.01;
  until ((deg>6.3) or (port[$60]=1));
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

procedure CI(col : word);
var
   yind : word;
begin
  for yind := 1 to 630 do
     if circ[yind,1] > 160 then
       line(circ[yind,1],circ[yind,2],320,circ[yind,2],col)
       else line(circ[yind,1],circ[yind,2],0,circ[yind,2],col)
end;

begin
i:=0;
     Directvideo:=false;
     Mode($13);
{     while not (i > 200) do
       begin
         circle(100,1000,i,30);
         inc(i,8);
       end;}
     circle(100,1000,80,30);
     Wait4Key;
     ci(10);
     Wait4Key;
     Mode(3);
     write(i);
end.
