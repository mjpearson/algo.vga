program Rodent;

uses crt;

var Init_Error,MType, Major, IRQ: byte;
    Button, MColumn, MRow : word;

procedure Holler;
begin
Sound(820);        { Beep }
Delay(300);        { For 200 ms }
NoSound;           { Relief! }
end;

Procedure DetectM; assembler;
asm
 xor ax,ax
 int 33h
 or  ax,ax
 jnz @@2000
 inc Init_Error
 jmp @@4000
@@2000:
 mov ax,0024h
 int 33h
 cmp ax,0ffffh
 jne @@3000
 mov Init_Error,2h
 jmp @@4000
@@3000:
 mov Major,bh
 mov MType, ch
 mov IRQ, cl
@@4000:

end;
Procedure FunkTrain;
begin
DetectM;
if Init_Error=1 then
  begin
    Writeln('Shçzhen! Rodentia not found'); holler; halt;
  end
else
if Init_Error=2 then
  begin
    Writeln('Driver detected.  Extended error calling driver function 0024h!');
    holler; halt;
  end
else
  begin
    Writeln('Press <ESC> to quit');writeln;
    Writeln('Mouse driver detected.'); Writeln;
    Writeln('˛ Version    : ', Major,'+');
    Write('˛ Mouse Type : ');
      if Mtype =1 then Writeln('Bus');
      if Mtype =2 then Writeln('Serial');
      if Mtype =3 then Writeln('InPort');
      if Mtype =4 then Writeln('IBM');
      if Mtype =5 then Writeln('Hewlett-Packard');
    Writeln('˛ IRQ Line   : ',IRQ);
  end;
end;

procedure Enable; assembler;
asm
   mov ax,0020h     { Enable }
   int 33h
   mov ax,000ah     { Define Text Cursor }
   mov bx,0001h     { Type 1 = hardware }
   mov cx,0
   mov dx,4
   int 33h
   mov ax,0001h     { Show Mouse Cursor }
   int 33h
end;

procedure Disable; assembler;
asm
  mov ax,0002h   { Hide Mouse cursor}
  int 33h
  xor ah,ah      { Reset Textmode cursor }
  mov al,03h
  int 10h
end;

begin
Init_Error:=0;
clrscr;
Writeln('Mouse-Tester-o-Matic v1.0');
FunkTrain;
Enable;
repeat
      asm
        mov ax,0003h
        int 33h
        and bx,3
        mov Button,bx
        mov MRow, dx
        mov MColumn, cx
      end;
until port[$60]=1;
disable;
end.
