{$N+}
uses
    crt;

const
     add1: integer = -3;
     add2: integer = 1;
     add3: integer = 1;
{ try changing these consts }

var
   x, y, v, tx, ty, adr: word;
   sintable: array[0..255] of integer; { this is the whole plasma :) a
sine lookup table }
   r, rt: single;
   a1, a2, a3: word;
   maxx,maxy,l: word;
   adj: single;

begin
     asm
        mov ax, 13h
        int 10h
     end;

     rt:= (359 * 3.14) / (255 * 180);
{    since we will use 255 as a full circle, we need to do some tricks }
{    basic math }

     for x:= 0 to 255 do
     begin
          r:= x * rt;
     {    angle -> radian conversion }
          sintable[x]:= trunc(sin(r) * 127) + 128; { and here we make the sine table }
     end;

     a1:= 0;
     a2:= 0;     

     repeat
           adr:= 0;
           maxx:= 159;
           maxy:= 99;

           for y:= 0 to maxy do
           begin
                for x:= 0 to maxx do
                begin
                     ty:= byte(sintable[byte(x+a1+a3)] + sintable[byte(y-x)]);
                     tx:= byte(sintable[byte(y-a1-a2)] - sintable[byte(x+a3)]);
                {    basically, just do something that would produce a "random" frequency, 
                     try messing around with this }
                     l:= (ty + tx);

                     ty:= byte(sintable[byte(x-a1+a3)] + sintable[byte(y-x+a3)]);
                     tx:= byte(sintable[byte(y+a1)] - sintable[byte(x-a1+a3)]);

                     l:= (l + (ty + tx));
                     l:= byte(l);
                     if l > 127 then l:= 127 - (l and 127); { i use a 127 colored palette, so... }

                     mem[$a000:adr]:= l;

                     adr:= adr + 1;
                end;
                adr:= adr + 160; { since we're not doing full screen }
           end;
           a1:= (a1 + add1) and 255;
           a2:= (a2 + add2) and 255;
           if ((a1 and 1) = 0) and ((a2 and 1) = 0) then
              a3:= (a3 + add3) and 255;

      {   do some fancy stuff to update the frequency modifiers }
      {   you migth want to change the a3 part, since i used it somewhat diffrent }

     until KeyPressed;
     asm
        mov ax, 3
        int 10h
     end;
end.

Uhm, yeah, pretty :) well, it works...

This is one way to do it, but the "hart" of it is the sine lookup table,
and a handfull of
frequency modifiers

