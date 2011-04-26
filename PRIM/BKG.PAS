program BackGrnd;

uses crt;

var V_Buffer : array [0..63999] of byte;
    Pall : Array[0..255,1..3] of Byte;
    loop1 : integer;

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

procedure LoadRaw (FileName : string);
type
  DACType = array [0..255,1..3] of byte;
var
  DAC : DACType;
  Fil : file of DACType;
  I : integer;
  BKG : File;
begin
  assign (Fil, FileName);
  reset (Fil);
  read (Fil, DAC);
  close (Fil);
  for I := 0 to 255 do
    pal (i,dac[i,1],dac[i,2],dac[i,3]);
  assign(BKG, FileName);
  reset(BKG,1);
  BlockRead(BKG,Pall,768);
  blockread(BKG,V_Buffer,filesize(BKG)-769);
end;

procedure VidMode(VM : byte); Assembler;
asm
  xor ah,ah
  mov al,VM
  int 10h
end;

Procedure Putpixel (X,Y : Integer; Col : Byte);
  { This puts a pixel on the screen by writing directly to memory. }
BEGIN
  Mem [$0a000:X+(Y*320)]:=Col;
END;

Procedure WaitVR; Assembler;
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

Procedure CunninglyManipulatePalette;
   { This moves up the pallette by one so that the color of the block
     being put down is always the same }
Var
   Tmp : Array[1..3] of byte;
   loop1 : integer;
Begin
   Move(Pall[254],Tmp[1],3);           { Save Last Colour             }
   Move(Pall[1],Pall[2],253*3);    { Move Rest Up one             }
   Move(Tmp,Pall[1],3);                { Put Last Colour to First pos }
  For loop1:=1 to 254 do
     pal (loop1,pall[loop1,1],pall[loop1,2],pall[loop1,3]);

End;

begin
 VidMode($13);
 LoadRaw('boot2.raw');
 Move (V_Buffer,memw [$0a000:0],64000);
 repeat
  CunninglyManipulatePalette;
  delay(25);
 until port[$60]=1;
 VidMode(3);
end.