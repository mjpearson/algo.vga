var
   font : array [0..4095] of byte;

procedure Loadfont;
var
  fseg,foff : word;
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

procedure LoadGothFont;
var
  f : file;
begin
  assign(f,'.\data\medieval.fnt');
  reset(f,1);
  loadfont;
  blockread(F,font,filesize(f));
  close(f);
end;

begin
  LoadGothFont;
  Writeln('Testing...');
  readln;
  asm mov ax,3; int 10h; end;
end.