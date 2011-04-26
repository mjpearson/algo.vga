{

  Double buffering animation example (DOS Real Mode, do *not* attempt
  to run under windows)

           ú Caglios ú

  n1921380@student.fit.qut.edu.au

  This program tests a double buffering technique I was thinking of
  just this night (11th Aug '97).  Whole prog took 30 minutes to create
  and test from scratch.  Build under pure compile (no options).
  Bitmap Datafiles (Phunkimonkie & Hypertunnel) were created almost
  1 month ago, to the day.
  The main strength is the 32-bit flip procedure, as well as the dynamic
  pointers to my two virtual-screens.  Code is commented inline...

  Simple.
}

program dBL_Buffer;

{$G+}{$M 4000,0,0}    { Enables 80286+ Assembler instructions / Allocate
                        4000 byte heap }

{$I c:\tp\cachunka.dat} { Monkey bitmap data }

var
   d2,d,i,VBuff,VBuff2:word;
   cosinus:array[0..255] of byte;
   sinus:array[0..255] of byte;
   Pall : Array[0..255,1..3] of Byte;

{ Shits all over Pascal GETMEM function }
procedure SetUpBuffer(var segment:word;size:word);
var
   StartAdress:word;
begin
  asm
    mov ax,4821h      { DOS Function allocates system memory }
    mov bx,size       { * NOTE : This size is in memory paragraphs }
    int 21h
    mov dx,ax
    jnb @l1           { Fatal error, AX to return 08h [insufficient memory] }
      mov dx,0a000h   { Use DX Register to preserve reg. integrity }
      jmp @l2
    @l1:
      shl bx,2        { Multiply by number of paragraphs by 16... }
      mov cx,bx
      mov es,ax
      xor di,di
      xor ax,ax
      rep stosw       { And allocate it! }
    @l2:
    mov StartAdress,dx
  end;
  segment:=StartAdress;
  if StartAdress=$0a000 then begin
    { 0a000h is not indicative of VGA Display memory, it's just a
      scratch value... }
    Writeln('Zounds!  Out-o-memory.  (This is not a good thing...)');
    halt;
  end;
end;

{ Frees memory allocated by a call to DOS Function 4812h }
procedure FreeBuffer(segment:word);assembler;
asm
  mov ax,4921h
  mov bx,segment
  int 21h
end;

{ Direct VGA Port I/O to set 1 palette register, RGB Triad }
Procedure Pal(Col,R,G,B : Byte); assembler;
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

{ Um... Loads a raw? &8) }
procedure LoadRaw (FileName : string);
type
  DACType = array [0..255,1..3] of byte;
var
  DAC : DACType;
  Fil : file of DACType;
  BKG : File;
begin
  assign (Fil, FileName);
  reset (Fil);
  read (Fil, DAC);                         { Load the palette }
  close (Fil);
  for I := 0 to 255 do
    pal (i,dac[i,1],dac[i,2],dac[i,3]);
  assign(BKG, FileName);
  reset(BKG,1);
  BlockRead(BKG,Pall,768);                 { Make a copy of the pallete }
  blockread(BKG,mem[VBuff:0],filesize(BKG)-768); { Load the image data into
                                                   the first virtual buffer }
end;

{ BIOS Interrupt 10h : Subfunction 00h ú Set display mode }
procedure Mode(md:word);assembler;
asm
  mov ax,md
  int 10h
end;

{ Word size Flip Procedure }
procedure Flip(source,dest:word);Assembler;
asm
  push ds
  mov ds,source       { Don't really need to explain this... }
  mov es,dest         { Fairly elementary }
  mov di,si
  mov cx,32000
  rep movsw
  pop ds
end;

{ BitBlt the Phunkimonkie to the second virtual display }
procedure BitBlt(x,y,width:word);
var
    Xorigin,Xbound:word;
    col : byte;
begin
Xbound:=x+width;
Xorigin:=x;
for i := 0 to sizeof(chunky) do
  begin
    col:=chunky[i];
    if (col <> 0) then Mem [VBuff2:X+(Y*320)]:=col;
    x := x+ 1;
    if x > Xbound then
      begin
        x :=Xorigin;
        y :=y+1;
      end;
  end;
end;

{ Cycle the palette 1 rotation }
Procedure CunninglyManipulatePalette(Start,Fin : byte);
Var
  Temple : Array[1..3] of byte;
Begin
  Move(Pall[Fin],Temple[1],3);
  Move(Pall[1],Pall[2],((Fin-1)*3));
  Move(Temple,Pall[Start],3);
  For i:=Start to Fin do
    pal (i,pall[i,1],pall[i,2],pall[i,3]);
End;

begin
  { Precalc for the monkie path }
  for i:=0 to 255 do cosinus[i]:=round(cos(2*pi*i/255)*35+90);
  for i:=0 to 255 do sinus[i]:=round(sin(2*pi*i/255)*80+395);
  { Allocate those two displays... }
  SetUpBuffer(VBuff,4096);
  SetUpBuffer(VBuff2,4096);
  { Initialise 320x200x256 }
  Mode($13);
  { Load the hypertunnel Bitmap }
  LoadRaw('c:\tp\yscreen.raw');

  repeat
    { Make a copy of the background }
    Flip(VBuff,VBuff2);
    { Belt the logos. Yes, there's four of the pricks.  Good effect,
      kind of like a mirror surface }
    BitBlt(sinus[d]+cosinus[d2]+80,cosinus[d2]+400,76);
    BitBlt(sinus[d]+170,cosinus[d]+400,76);
    BitBlt(sinus[d2]+170,cosinus[d]+400,76);
    BitBlt(sinus[d2]+170,cosinus[d2]+400,76);
    { And poke the virtual to VGA display }
    Flip(VBuff2,$0a000);
    { Increment the co/sinus elements }
    d:=d+3;
    d2:=d2+5;
    if d2 > 255 then d2 :=0;
    if d > 255 then d :=0;
    { And rotate the pallete }
    CunninglyManipulatePalette(1,254);
    { Check for ESC key press }
  until port[$60]=1;
  { Reset 80x25x16 text }
  Mode(3);
  { And disallocate the two buffers used for the virutal displays }
  FreeBuffer(VBuff);
  FreeBuffer(VBuff2);
{ Yes, now we're done.  Simple, wasn't it? }
end.
