uses dsp;

{$I kpress.dat}

type Sample = record
              Tune   : pointer;
     end;

var Samp : Sample;
    Res : boolean;
    f : file;
{    temp : array [1..13013] of byte;}
    index,freq : word;
    scancode : byte;

Procedure VidMode(Mode:byte); Assembler;
asm
 xor ah,ah
 mov al,Mode
 int 10h
end;

function in_Kbd : byte;
var scan : byte;
begin
  asm
    xor ah,ah
    int 16h
    mov scan,ah
  end;
in_kbd:=scan;
end;

procedure gotoxy(x,y:byte); Assembler;
asm
  mov dl,x
  mov dh,y
  mov ah,2
  xor bh,bh
  int 10h
end;

begin
Res:=False;
freq:=1200;
VidMode(3);
for index:= 1 to 5 do
  begin
   Res:=resetdsp(index);
   if Res=True then break;
  end;

If Res=True then
  begin
    writeln('Soundblaster found at : 0x2',index,'0h');writeln;
    writeln('  P    þ Play sample');
    writeln(' -,+   þ Decrease/Increase frequency');
    writeln(' ESC   þ Quit');writeln;
    writeln('Current frequency : ',freq,' hz');
{ Bottom Line... }
asm
  mov ax,0AC4h
  xor bh,bh
  mov cx,80
  int 10h
end;
writeln;writeln('TIASü 1994,1997');
    SpeakerOn;
{    WriteDAC(1);}
{    assign(f,'renlaugh.wav');
    reset(f,1);}
    GETMEM (Samp.Tune,sizeof(K_SFX));
  {  blockread(f,temp,filesize(f));}
    move(K_SFX,Samp.Tune^,sizeof(K_SFX));
  repeat
   asm
     xor ah,ah
     int 16h
     mov scancode,ah
   end;
   if scancode=$19 then Playsamp(Samp.Tune,sizeof(K_SFX),freq) else
   if scancode=$4e then begin
     freq:=freq+5;
     if freq > 1290 then freq:=100;
     gotoxy(20,6); Write(freq,' hz  ');
   end
   else
   if scancode=$4a then begin
     freq:=freq-10;
     if freq < 100 then freq:=1200;
     gotoxy(20,6); Write(freq,' hz  ');
   end;
  until scancode = 1;
{  CLOSE (F)}
  end
else if Res=false then writeln('Soundblaster not found...');
end.
