program Poly;

{$N+}

{ A Model of Polynomial Functions

  - To be further enhanced by such features

          - 3D Space
          - Fraction-Dimensional Geometric Sets ( FRACTALS )
          - Matrices
          - Fluid Motion and Complex Dynamic Systems


  By Michael Pearson.
  Started 2.2.99
}



{$I fdat.dat}           { Font Data }

const VGAmem   = $0a000;

      { Global Constants }

      _RBound  = 240; { Right Boundary }
      _XMax    = 319; { Self explanatory }
      _YMax    = 199;

      { Quadrant selector constants }

      _Quad1   : array [0..1] of integer = (1,1);
      _Quad2   : array [0..1] of integer = (1,-1);
      _Quad3   : array [0..1] of integer = (-1,-1);
      _Quad4   : array [0..1] of integer = (-1,1);


var   Zoom              : byte;
      _CurX, _CurY,

      incre,
      _BoundX, _BoundY  : Real;

      _Xcent, _Ycent,
      offset            : word;



Type Virtual = Array [0..63999] of byte;  { The size of our Virtual Screen }
     VirtPtr = ^Virtual;                  { Pointer to the virtual screen }

VAR Virscr : VirtPtr;                      { Our first Virtual screen }
    Vaddr  : word;                         { The segment of our virtual screen}



{*********************************************************************
       Simple Functions
 *********************************************************************}

function between(num,hi,lo : integer): boolean;
  begin
    if (num < hi) and (num > lo) then Between:=True else
    between:=False;
  end;


{*********************************************************************
       Primitives & Modes
 *********************************************************************}

procedure SetV(mode : word); Assembler;
asm
  mov ax,mode
  int 10h
end;

Procedure Putpixel (Where:word;X,Y : Integer; Col : Byte);
BEGIN
  if between(x,320,-1) and between(y,200,-1) then Mem [Where:X+(Y*320)]:=Col;
END;


{ Note : This procedure shall have to be slightly modified if ASCII
         graphical characters are added.  For the present it only
         accomodates characters 33-96 in the algorithm; All of which
         are uppercase.  ie : lowercase input is converted to an
         uppercase font. }
procedure PokeString(X,Y   : word; InString : string; Colour : byte;
                     where : word);

var offset,Index,XOrigin  : word;
    YOrigin,index2,XIndex : word;

begin
XOrigin := X;
XIndex  := Xorigin;
YOrigin := y;
offset  := 1;

for Index2 := 1 to length(InString) do
begin
{ Is the character a lowercase letter??? }
if (word(InString[Index2]) > 96) and (word(InString[Index2]) < 123) then
{ Lowercase - Uppercase }
offset:=((word(InString[Index2])-65)*(FontWidth*FontHeight))+1
else
{ Otherwise leave them alone }
offset:=((word(InString[Index2])-33)*(FontWidth*FontHeight))+1;

{ Poke 1 Character }
if word(InString[Index2]) > 0 then
  begin
    for Index := offset to (offset+((FontWidth*FontHeight)-1)) do
      begin
        inc(x);
       if Fontdata[Index] <> 0 then
          mem [where:x+(y*320)]:=Fontdata[Index]+(Colour-1);
       if x > (Xorigin + (FontWidth-1)) then
         begin
           x:=XOrigin;
           inc(y);
         end;
      end;
end;
  XIndex := XIndex + (FontWidth+1);  { Space between characters }
  Xorigin := XIndex;     { Set the new X origin }
  x := XOrigin;          { Reset new X for next character }
  y:=Yorigin;            { And align the Y co-ord to keep them in line }
end;
end;

procedure line(a,b,c,d,col:integer; wh : word);
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
          putpixel(wh,a,b,col);
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


procedure flip16(source, dest,o,numbytes : word); Assembler;
asm
  push ds
  mov  es,dest
  mov  ds,source
  mov  di,o
  xor  si,si
  mov  cx,numbytes
  rep  movsw
  pop  ds
end;

Procedure ClrBuffer(Where : word); Assembler;
asm
  push ds
  mov  es,Where
  xor  di,di
  mov  ax,di
  mov  cx,32000
  rep  stosw
  pop  ds
end;


{*********************************************************************
       String Functions
 *********************************************************************}

function IntToStr(I: Longint): String;
{ Convert any integer type to a string }
var
 S: string[11];
begin
 Str(I, S);
 IntToStr := S;
end;

function RealToStr(I: Real): String;
{ Convert any integer type to a string }
var
 S: string[11];
begin
 Str(I, S);
 RealToStr := S;
end;




{*********************************************************************
       General Procedures - Screen Maintenance
 *********************************************************************}

procedure _Rside;
  var
     DepthL : word;
  begin
    For Depthl := 137 to _YMax do
       Line(_RBound,DepthL, _XMax, DepthL,26,Vaddr);
  end;

procedure _XYgrid;
  const
     Depth = 20;
     Xdep  = 10;
  begin
       { Horizontal }
       Line(0,_YCent,Depth,_YCent,2,Vaddr);
       Line(_Rbound-Depth,_YCent,_RBound,_YCent,2,Vaddr);
       { Vertical }
       Line(_XCent,0,_XCent,XDep,2,Vaddr);
       Line(_XCent,_Ymax-Xdep,_XCent,_YMax,2,Vaddr);
  end;

procedure GridSet;
var
  C, Nux, Nuy : word;
  LVar : Integer;

  begin
    Nux := _RBound div 21; { 12 }
    Nuy := 200 div 21;
    C   := 0;

   FOR lvar := 0 to 21 do
     begin
       C := lvar * Nux;
       Putpixel(Vaddr,C-1,_YCent,10);
       C := lvar * Nuy;
       Putpixel(Vaddr,_XCent,C,10);
     end;
  end;


procedure UD;
  begin

    ClrBuffer(Vaddr);

{    _Rside;
    _XYgrid;}

{    PokeString(_Rbound+2,142,char(39)+'X :' + RealToStr(_BoundX),255,Vaddr);
    PokeString(_Rbound+2,150,char(39)+'Y :' + RealToStr(_BoundY),255,Vaddr);
}
    PokeString(_Rbound+2,166,'_X :' + RealToStr(_CurX),255,Vaddr);
    PokeString(_Rbound+2,174,'_Y :' + RealToStr(_CurY),255,Vaddr);

{    PokeString(_Rbound+2,190,'Zm : ' + IntToStr(Zoom),255,Vaddr);

{    gridset;}
    PutPixel(vaddr,_Xcent,_YCent,15);
{    flip16(Vaddr, VGAMem,0,64000);}

 end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}

Procedure SetUpVirtual;
   { This sets up the memory needed for the virtual screen }
BEGIN
  GetMem (VirScr,64000);
  vaddr := seg (virscr^);
END;

Procedure ShutDown;
   { This frees the memory used by the virtual screen }
BEGIN
  FreeMem (VirScr,64000);
END;


procedure plot(incr : real);
{ Test procedure for Y = (x+1) }
var
   loopvar : integer;
   x,y     : real;
   SizeX,
   SizeY   : integer;

begin
   SizeX := _Rbound div 21;
   SizeY := 200 div 21;
   x:=-10;
   y:=0;
{   for x := 1 to 5 do}
   repeat
   {  begin}

{       y:=cos((x+incre)/1);}
        y:=x/2 * cos(x+incre);

       PutPixel(Vaddr,_xCent+round((x*SizeX)),_yCent+round((y*SizeY)),10);
{        y:=0.5 + x - (0.5*sqr(x));}
{       y:=cos((x-incre)/5);
{     end;}
      x:=x+0.1;
      _curx := x;
      _cury := y;
   until x > 20;

     flip16(Vaddr, VGAMem,0,64000);
end;



{*********************************************************************
       Utility Engine
 *********************************************************************}

begin
   SetUpVirtual;

   _Xcent := _Rbound div 2;
   _Ycent := 99;
   _CurX  := 0;
   _CurY  := 0;
   incre  := 0.000001;
   SetV($13);

  repeat
    UD;
    plot(incre);
    incre := incre + 0.5;
{    readln;}
  until port[$60]=1;

   SetV(3);
   ShutDown;
end.