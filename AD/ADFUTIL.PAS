{$G+}
unit adfutil;

interface

Procedure GrabPallette;
Procedure FadeDown(waiting : byte);
Procedure Fadeup(waiting : byte);
procedure HideC;
procedure Blackout;
procedure LoadGothFont;
procedure AnsiDisp(screen : byte);

implementation

uses crt;

VAR
   Temppal : Array[0..255,1..3] of Byte;

const
      Ansi_Offsets : array [1..4] of word =
     (4096,8096,12096,16096);

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure PAL(Col,R,G,B : Byte); assembler;
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

procedure HideC; Assembler;
asm
  mov     ax,0100h
  mov     cx,0800h
  int     10h
end;

Procedure GetPal(Col : Byte; Var R,G,B : Byte);
  { This gets the Red, Green and Blue values of a certain color }
Var
   rr,gg,bb : Byte;
Begin
   asm
      mov    dx,3c7h
      mov    al,col
      out    dx,al

      add    dx,2

      in     al,dx
      mov    [rr],al
      in     al,dx
      mov    [gg],al
      in     al,dx
      mov    [bb],al
   end;
   r := rr;
   g := gg;
   b := bb;
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure GrabPallette;
{Grabs the entire palette }
VAR loop1:integer;
BEGIN
  For loop1:=0 to 255 do
    Getpal (loop1,temppal[loop1,1],temppal[loop1,2],temppal[loop1,3]);
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure FadeDown(waiting : byte);
VAR loop1,loop2:integer;
    Tmp : Array [1..3] of byte;
BEGIN
  For loop1:=1 to 64 do BEGIN
    For loop2:=0 to 255 do BEGIN
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      If Tmp[1]>0 then dec (Tmp[1]);
      If Tmp[2]>0 then dec (Tmp[2]);
      If Tmp[3]>0 then dec (Tmp[3]);
        { If the Red, Green or Blue values of color loop2 are not yet zero,
          then, decrease them by one. }
      Pal(loop2,Tmp[1],Tmp[2],Tmp[3]);
        { Set the new, altered pallette color. }
    END;
  delay(waiting);
  END;
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Fadeup(waiting : byte);
  { This procedure slowly fades up the new screen }
VAR loop1,loop2:integer;
    Tmp : Array [1..3] of byte;
      { This is temporary storage for the values of a color }
BEGIN
  For loop1:=0 to 63 do BEGIN
      { A color value for Red, green or blue is 0 to 63, so this loop only
        need be executed a maximum of 64 times }
    For loop2:=0 to 255 do BEGIN
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      If Tmp[1]<temppal[loop2,1] then inc (Tmp[1]);
      If Tmp[2]<temppal[loop2,2] then inc (Tmp[2]);
      If Tmp[3]<temppal[loop2,3] then inc (Tmp[3]);
        { If the Red, Green or Blue values of color loop2 are less then they
          should be, increase them by one. }
      Pal(loop2,Tmp[1],Tmp[2],Tmp[3]);
        { Set the new, altered pallette color. }
     END;
  delay(waiting);
 end;
END;

Procedure Blackout;
VAR loop1:integer;
BEGIN
  For loop1:=0 to 255 do
    Pal(loop1,0,0,0);
END;

procedure LoadGothFont;
var
  f : file;
  fseg,foff : word;
  font : array [1..4096] of byte;

begin
  assign(f,'.\data\velhejo.dat');
  reset(f,1);
  blockread(F,font,4096);
  close(f);
  fseg := seg(font);
  foff := ofs(font);
  asm
    push bp
    mov  ax, 1110h
    mov  bx, 1000h
    mov  cx, 0ffh
    xor  dx, dx
    mov  es, fseg
    mov  bp, foff
    int  10h
    pop  bp
  end;
end;

procedure AnsiDisp(screen : byte);
var
  f : file;

begin
  GrabPallette;
  fadedown(2);
  assign(f,'.\data\velhejo.dat');
  reset(f,1);
  seek(f,Ansi_Offsets[screen]);
  blockread(f,mem[$b800:0],4000);
  close(f);
end;

end.