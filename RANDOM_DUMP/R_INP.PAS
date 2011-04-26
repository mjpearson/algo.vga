program Font_And_Noise;

{

 This program tests output to soundblaster : Playing a sample when a key
 is pressed.  Works well : Only took a half hour!!!

 Caglios ú n1921380@student.fit.qut.edu.au

}

uses strings,dsp;

{$I fdat.dat}
{$I keyp.dat}         { Bongo keypress sample }
{$I barrel.dat}         { I'm having trouble with the radar sir! }

const VGAMem = $0a000;
      EnterKey = $1c;

type Sample = record
              Tune   : pointer;
     end;

var Cur_Line : string;
    asc,scan : byte;
    OldCX,CurX,CurY : word;
    F : File;
    index,offset : word;
    Samp : Sample;
    Res : boolean;

procedure VidMode(Mode:byte); Assembler;
asm
 xor ah,ah
 mov al,Mode
 int 10h
end;

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
offset:=((word(InString[Index2])-65)*(FontWidth*FontHeight))+1
{ Lowercase - Uppercase }
else
offset:=((word(InString[Index2])-33)*(FontWidth*FontHeight))+1;
{ Otherwise leave them alone }

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

function IntToStr(I: Longint): String;
{ Convert any integer type to a string }
var
 S: string[11];
begin
 Str(I, S);
 IntToStr := S;
end;

Procedure Matrix(X,Y,X2,Y2,Col:word);
var W_Index,H_Index : byte;
begin
for H_Index := y to y2 do
  begin
    for W_Index := X to X2 do
      begin
        mem[$0a000:W_Index+(H_Index*320)]:=col;
      end;
  end;
end;

procedure PalFunk(BaseX,BaseY,BlockSize : word);
var YOrigin : word;
begin
YOrigin:=BaseY;
for offset := 0 to 255 do
  begin
   Matrix(BaseX,BaseY,(BaseX + BlockSize),(BaseY + BlockSize),offset);
   BaseY:=BaseY+(BlockSize+2);
   if BaseY > (YOrigin + 80) then
     begin
       BaseY:=YOrigin;
       BaseX:=BaseX+(BlockSize+2);
     end;
  end;
end;

begin
CurX:=80;
OldCX:=CurX;
CurY:=50;

VidMode($13);
asm
  mov ax,101bh
  xor bx,bx
  mov cx,0ffh
  int 10h
end;
PalFunk(5,80,5);

PokeString(10,10,'Font-o-matic v1.0',100,VGAMem);
PokeString(10,30,'Any key for input.  ESC to exit',100,VGAMem);
PokeString(10,50,'Test Input here -> ',100,VGAMem);

for index:= 1 to 5 do
  begin
   Res:=resetdsp(index);
   if Res=True then break;
  end;

PokeString(180,100,'Soundblaster found at port 2'+Inttostr(index)+'0h'
           ,100,VGAMem);
PokeString(180,110,'Using DMA channel 1',100,VGAMem);
PokeString(0,195,'CODE : CAGLIOS',100,VGAMem);
PokeString(250,195,'TIAS 1994,1997',100,VGAMem);

If Res=True then
  begin
    SpeakerOn;
    GETMEM (Samp.Tune,sizeof(keyp));
    move(keyp,Samp.Tune^,sizeof(keyp));
  repeat
   asm
    xor ah,ah
    int 16h
    mov scan,ah
    mov asc,al
   end;
    if (asc > 32) or (asc = $20) then
      begin
        CurX:=CurX+4;
        if asc <> $20 then
          begin
            dmastop;
            Playsamp(Samp.Tune,sizeof(keyp),1210);
          end;
        PokeString(CurX,CurY,char(asc),10,VGAMem);
      end;
    if scan = EnterKey then begin CurY:=CurY + 8; CurX:=OldCX; end;
  until scan =1;
  FREEMEM (Samp.Tune,sizeof(keyp));
  GETMEM (Samp.Tune,sizeof(barrel));
  move(barrel,Samp.Tune^,sizeof(barrel));
  dmastop;
  Playsamp(Samp.Tune,sizeof(barrel),1200);
  FREEMEM (Samp.Tune,sizeof(barrel));
end;
VidMode(3);
end.
