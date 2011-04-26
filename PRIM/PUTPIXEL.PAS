program SetVGA_Putpixel;

begin
     asm
       mov ax,13h
       int 10h
     end;

     Mem [$0a000:160+(100*320)]:=9;
     readln;

     asm
       mov ax,3
       int 10h
     end;
end.