program picpal;

{$G+}{$I+}

CONST VGA = $a000;
      XSize = 77;
      YSize = 56;
TYPE
        Letter = Array[1..xsize,1..ysize] of Byte;
      {  Letters = Array[' '..']'] of Letter;}
VAR Font : ^Letter;

function VidMode (mode : byte):boolean;
begin
  asm
    mov  al,mode
    xor  ah,ah
    int  10h
  end;
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Pal(Col,R,G,B : Byte); assembler;
  { This sets the Red, Green and Blue values of a certain color }
asm
   mov    dx,3c8h
   mov    al,[col]
   out    dx,al
   inc    dx
   mov    al,[r]
   out    dx,al
   mov    al,[g]
   out    dx,al
   mov    al,[b]
   out    dx,al
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure LoadPal (FileName : string);
  { This loads .pal file and sets the pallette }
type
  DACType = array [0..255,1..3] of byte;
var
  DAC : DACType;
  Fil : file of DACType;
  I : integer;
begin
  assign (Fil, FileName);
  reset (Fil);
  read (Fil, DAC);
  close (Fil);
  for I := 0 to 255 do
    pal (i,dac[i,1],dac[i,2],dac[i,3]);
end;

Procedure Putpixel (X,Y : Integer; Col : Byte);
  { This puts a pixel on the screen by writing directly to memory. }
BEGIN
  Mem [$0a000:X+(Y*320)]:=Col;
END;

Procedure WaitVr;
begin
  asm
    mov dx,03dah
  @@1000:
    in  al,dx
    and al,08h
    jnz @@1000
  @@2000:
    in  al,dx
    and al,08h
    jnz @@2000
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

Procedure Paldisplay;
var loop1,x1,x2: integer;
begin
 x1:=40;x2:=40;
  for loop1:= 0 to 255 do begin
   line(x1,0,x2,200,loop1);
   x1:=x1+1; x2:=x2+1;
  end;
end;

procedure Wkey;
begin
  asm
    @@100:
        xor  ah,ah
        int  16h
        or   ah,ah
        jz   @@100
  end;
end;

Procedure Loaddat;
VAR f:file;
    res,loop1:word;
    temp:pointer;
    pallette: Array[0..767] Of Byte;
BEGIN
  assign (f,'OUT.PAL');
  reset (f,1);
  getmem (temp,4467);
  blockread (f,temp^,4467,res);
  freemem (temp,4467);
  close (f);
END;

begin
VidMode($13);
Paldisplay;
Writeln('      Default 320x200x256 palette...  ');
Wkey;
VidMode($13);
loadpal('OUT.PAL');
Paldisplay;
Loaddat;
Writeln('        Icon [C_DAT.DAT] palette...  ');
Wkey;
VidMode(3);
end.