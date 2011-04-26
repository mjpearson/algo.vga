PROGRAM APPGEN;

uses
    crt, dos, graph;

const
     Fonts : array[0..3] of string[13] = ('Defaultfont','triplexfont',
     'smallfont','gothicfont');
     Linestyles : array[0..4] of string[9] = ('Solidln','dottedln','Centerln',
     'dashedln','Userbitln');
     Fillstyles : array[0..11] of string[14]= ('Emptyfill','solidfill',
     'linefill','ltslashfill','slashfill','bkslashfill','ltbkslashfill',
     'hatchfill','xhatchfill','Interleavefill','widedotfill','closedotfill');
     Textdirect : array[0..1] of string[8] = ('Horizdir','Vertdir');
     Horizjust  : array[0..2] of string[10] = ('Lefttext','Centertext',
     'Righttext');
     Vertjust   : array[0..2] of string[10] = ('Bottomtext','Centertext',
     'toptext');

var
   K : char;
   r,g,b    : array[1..256] of integer;
   counter,lhole,noiken,a,j,rr,gg,bb,i: integer;
   width : integer;

procedure Initialise;
var
   gd,ec,gm : integer;
begin
     gd:=detect;
     gd := detect;
     initgraph(gd,gm,'c:\tp\bgi');
     ec := GraphResult;
       if ec <> grOK then
end; {Initialise procedure}

PROCEDURE Getarray;
begin
j:=0;
rr:=0;
bb:=64;
gg:=0;
for j := 1 to 64 do
    begin
         rr:=rr+1;
         bb:=bb-1;
         gg:=gg+0;
         r[j]:=rr;
         b[j]:=bb;
         g[j]:=gg;
    end;
rr:=64;
bb:=0;
gg:=0;
for j:=65 to 128 do
    begin
         rr:=rr-1;
         bb:=bb+0;
         gg:=gg+1;
         r[j]:=rr;
         b[j]:=bb;
         g[j]:=gg;
    end;
RR:=0;
BB:=0;
gg:=0;
for j := 129 to 192 do
    begin
         rr:=rr+0;
         bb:=bb+1;
         gg:=gg-1;
         r[j]:=rr;
         b[j]:=bb;
         g[j]:=gg;
    end;
end;


procedure up;
begin
     for i:= 0 to 63 do
         setrgbpalette(1,i,i,63-i);
end;

Procedure down;
begin
     for i:= 0 to 63 do
         setrgbpalette(1,63-i,63-i,i);
end;

Begin
noiken:=500;
lhole:=1;
     initialise;
     getarray;
     asm
        mov     ah,10h
        mov     al,01h
        mov     bh,04h
        int     10h
     end;
     setcolor(2);
     outtextxy(100,100,'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
     outtextxy(100,108,'³                                       ³');
     outtextxy(100,116,'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
     setcolor(7);
     settextstyle(smallfont,horizdir,4);
     outtextxy(110,105,'Handle / Alias :');

     {set cursor position}
     asm
        mov     ah,02h
        mov     bh,0
        mov     dl,10
        mov     dh,10
        int     10h
     end;

     settextstyle(triplexfont,vertdir,1);
     while not keypressed do
     begin
        setcolor(0);
          outtextxy(560,noiken,'Coded by Caglios 1996');
        setcolor(lhole);
         noiken:=noiken +1;
          outtextxy(560,noiken,'Coded by Caglios 1996');
       {Pause for Horizontal retrace}
       asm
          mov   dx,03dah
       @@narky:
          in    al,dx
          and   al,08
          jne   @@narky
       end;
           setrgbpalette(1,r[j],g[j],b[j]);
           setrgbpalette(2,r[j],0,0);
           setrgbpalette(3,0,g[j],0);
           setrgbpalette(4,0,0,b[j]);
           j:=j+2;
           if j > 191 then j:=1;
           if noiken > 500 then noiken:=-250;
     end;
     k:= readkey;
    {Set video mode 02h (alphanumeric, 16 colours. *8)}
     asm
        mov     ah,0h
        mov     al,03h
        int     10h
     end;
     writeln('                    Ä--Äùú.úùÄÍÍÍÄÄµ Cartel 1996ÆÄÄÍÍÍÄùú.úùÄ--ÄÄ');
end.







