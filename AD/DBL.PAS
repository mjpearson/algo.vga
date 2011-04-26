{ Double buffering example }
program dBL_Buffer;
{$G+}{$M 4000,0,65000}


{$I c:\tp\dev1\mooz6.dat}      { Music data }
{$I c:\tp\cachunka.dat}
{$I c:\tp\dev1\tlogo.dat}

{$L XMSOBJ.OBJ}

{$F+}
PROCEDURE _XMSFMPlayer; near; EXTERNAL;
PROCEDURE _StopXMSFM; near; EXTERNAL;
PROCEDURE _InitXMSFM; near; EXTERNAL;
{$F-}

type XMSFM = record
              Tune   : pointer;
              Buffer : pointer;
end;

var
   Musik : XMSFM;
   d2,d,i,VBuff,VBuff2:word;
   cosinus:array[0..255] of byte;
   sinus:array[0..255] of byte;
   Pall : Array[0..255,1..3] of Byte;

PROCEDURE LoadSong (VAR Test : XMSFM);
   BEGIN
      GETMEM (Test.Tune,sizeof(music));
      GETMEM (Test.Buffer,1314);           { Temp Instrument/pattern buffer }
      move (music,Test.Tune^,sizeof(music)); { Copy the data from the array
                                               into the tune buffer }
   END;

PROCEDURE ClearSong (VAR Test : XMSFM);  { Do I need to explain this? }
  BEGIN
    FREEMEM (Test.Tune,sizeof(music));
    FREEMEM (Test.Buffer,1314);
  END;

procedure SetUpBuffer(var segment:word;size:word);
var StartAdress:word;
begin
  asm
    mov ax,4821h
    mov bx,size
    int 21h
    mov dx,ax
    jnb @l1
      mov dx,0a000h
      jmp @l2
    @l1:
      shl bx,2
      mov cx,bx
      mov es,ax
      xor di,di
      xor ax,ax
      rep stosw
    @l2:
    mov StartAdress,dx
  end;
  segment:=StartAdress;
  if StartAdress=$0a000 then begin
    Writeln('Zounds!  Out-o-memory.  (This is not a good thing...)');
    halt;
  end;
end;

procedure FreeBuffer(segment:word);assembler;
asm
  mov ax,4921h
  mov bx,segment
  int 21h
end;

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
  read (Fil, DAC);
  close (Fil);
  for I := 0 to 255 do
    pal (i,dac[i,1],dac[i,2],dac[i,3]);
  assign(BKG, FileName);
  reset(BKG,1);
  BlockRead(BKG,Pall,768);
  blockread(BKG,mem[VBuff:0],filesize(BKG)-768);
end;

procedure Mode(md:word);assembler;
asm
  mov ax,md
  int 10h
end;

procedure Flip(source,dest:word);Assembler;
{ Word size Flip Procedure }
asm
  push ds
  mov ds,source
  mov es,dest
  mov di,si
  mov cx,32000
  rep movsw
  pop ds
end;

procedure BitBlt(BMP_ID,x,y:word; BMPSize, Origin, width:integer);
var
    Xorigin,Xbound:word;
    col : byte;
begin
Xbound:=x+width;
Xorigin:=x;
for i := origin to (BMPSize-1) do
  begin
    if BMP_Id = 1 then
      begin
        col:=chunky[i];
        if col = 255 then col:=1;
       if (col <> 0) then Mem [VBuff2:X+(Y*320)]:=col;
      end
    else
    if BMP_Id = 2 then
      begin
        col:=tlogo[i];
        if (col <> 255) then Mem [VBuff2:X+(Y*320)]:=col;
      end;

    x := x+ 1;
    if x > Xbound then
      begin
        x :=Xorigin;
        y :=y+1;
      end;
  end;
end;

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


Procedure GrooveitnStakeit;
begin
  Flip(VBuff,VBuff2);
  BitBlt(1,sinus[d]+cosinus[d2]+80,cosinus[d2]+400,sizeof(chunky),0,76);
  BitBlt(1,sinus[d]+170,cosinus[d]+400,sizeof(chunky),0,76);
  BitBlt(1,sinus[d2]+170,cosinus[d]+400,sizeof(chunky),0,76);
  BitBlt(1,sinus[d2]+170,cosinus[d2]+400,sizeof(chunky),0,76);
  BitBlt(2,90,50,sizeof(tlogo),0,126);
  Flip(VBuff2,$0a000);
  d:=d+3;
  d2:=d2+5;
  if d2 > 255 then d2 :=0;
  if d > 255 then d :=0;
end;

Procedure GetPal(ColorNo : Byte; Var R,G,B : Byte);
Begin
   Port[$3c7] := ColorNo;
   R := Port[$3c9];
   G := Port[$3c9];
   B := Port[$3c9];
End;

procedure Dalassen;
var Fade : byte;
    Tmp  : array [1..3] of byte;
begin
fade:=0;
repeat
  begin
    inc(FADE);           {Increment palete element}
     GrooveitnStakeit;
    For i:=0 to 255 do BEGIN
        Getpal (i,Tmp[1],Tmp[2],Tmp[3]);
        If Tmp[1]>1 then dec (Tmp[1]);
        If Tmp[2]>1 then dec (Tmp[2]);
        If Tmp[3]>1 then dec (Tmp[3]);
        pal(i,Tmp[1],Tmp[2],Tmp[3]);
    END;
  end;
until Fade > 62;
FreeBuffer(VBuff);
FreeBuffer(VBuff2);
end;

begin
  for i:=0 to 255 do cosinus[i]:=round(cos(2*pi*i/255)*35+90);
  for i:=0 to 255 do sinus[i]:=round(sin(2*pi*i/255)*80+395);
  LoadSong (Musik);

  asm push ds; push es; les di,Musik.Buffer; lds si,Musik.Tune;
      xor    al,al           { IRQ-Modus it is used by _InitXMSFM ! }
      call   _InitXMSFM; pop  es; pop  ds; end;
  Mode($13);
  SetUpBuffer(VBuff,4096);
  SetUpBuffer(VBuff2,4096);

  LoadRaw('c:\tp\ad\yscreen.raw');
  repeat
    GrooveitnStakeit;
    CunninglyManipulatePalette(1,254);
  until port[$60]=1;
  Dalassen;
  Mode(3);
  asm
    call   _StopXMSFM   {Need to Stop Playing the Song !}
  end;
  ClearSong (Musik);
end.