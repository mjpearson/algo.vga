const left  = $4B;
      right = $4D;
      FontStr : ARRAY [1..14] OF STRING =
                ('ANTIQUE', 'BLOCK', 'BOLD','BROADWAY','COMPUTER','COURIER',
                 'DECO','HOLLOW','MEDIEVAL','ROM16','SCRAWL','SCRIPT',
                 'SMALCAPS','STARTREK');

var font : array [0..4095] of byte;
    f : file;
    C_Hi,C_Lo,Index, scancode : byte;
    offs : word;


procedure Loadfont;
var fseg,foff : word;
begin
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

procedure VidMode(Mode : byte); Assembler;
asm
  xor ah,ah
  mov al,Mode
  int 10h
end;

procedure F_Tang; Assembler;
asm
  xor ah,ah
  int 16h
  mov scancode,ah
end;

procedure FRead(offset : word);
begin
  seek(f,offset);
  blockread(F,font,sizeof(font));
  loadfont;
  asm
    mov ah,2
    xor bh,bh
    mov dh,3
    xor dl,dl
    int 10h
  end;
  write('Font : [',FontStr[Index],']    ');
end;

begin
  offs:=0; Index:=1;
  VidMode(3);
  assign(f,'fonts.dat');
  reset(f,1);
  writeln('Left or Right to select font.  ESC to quit');
  writeln('Sample Text');
  FRead(offs);

while scancode <> 1 do
begin
  F_Tang;
   if scancode = left then begin
      dec(Index); if Index < 1 then Index := 14;
      offs := offs - 4096;
      if offs > Filesize(f) then offs := (FileSize(f) - 4096);
      FRead(offs);
      end;
    if scancode = right then begin
      inc(Index); if Index > 14 then Index := 1;
      offs := offs + 4096;
      if offs > (FileSize(f)-sizeof(font)) then offs := 0;
      FRead(offs);
      end;
end;

  close(f);
end.