Program A20_Line_Handler;

uses crt;

var XMSControl : longint;
    Init_Error, Switch, Handler : byte;
    Avail, Free : word;


Procedure XMSInit; Assembler;
asm
  mov ax,4300h
  int 2fh
  cmp al,80h
  je @@2000
  inc Init_Error
  jmp @@3000
@@2000:
  mov ax,4310h
  int 2fh
  mov word ptr [XMSControl],bx
  mov word ptr [XMSControl+2],es
@@3000:
end;

Procedure QueryFree; Assembler;
asm
  mov ax,08h
  xor bl,bl
  call [XMSControl]
  mov Avail,ax
  mov Free,dx
end;

Procedure A20; Assembler;
asm
  mov ax,4308h
  int 2fh
  cmp al,43h
  je  @@3100
  inc Init_Error;
  jmp @@4000
@@3100:
  mov Switch,bh
  mov Handler,bl
@@4000:
end;

begin
Init_Error:=0;
clrscr;
XMSInit;
if Init_Error =1 then begin Writeln('XMS Not found.'); halt; end;
Writeln('XMS Driver found.');
QueryFree;
Writeln('Largest available block : ',avail,' bytes');
Writeln('Free Memory : ',free);

Writeln('Querying A20 Handler...'); A20;
if Init_Error =1 then begin Writeln('Unsupported function (4308h)'); halt; end;
Writeln;Writeln('Success!');Writeln; Write('A20 Switch time : ');
if Switch =0 then Writeln('Medium')
else
if Switch =1 then Writeln('Fast')
else
if Switch =2 then Writeln('Slow');
Writeln('Handler : ', handler);

repeat until port[$60]=1;
end.