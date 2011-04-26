const vidseg:word=$a000;

var stab1,stab2:array[0..255+80] of byte;Count:word;

procedure setrgb(c,r,g,b:byte); assembler;
{This Procedure set up RGB color..Thru BASM...much faster}
asm;mov dx,3c8h;mov al,[c];out dx,al;inc dx;mov al,[r];out dx,al;
    mov al,[g];out dx,al;mov al,[b]+122;out dx,al;end;

Procedure SecretPart;
begin
  asm;mov ax,0013h;int 10h;mov dx,03c4h;mov ax,0604h;out dx,ax
     mov dx,03d4h;mov ax,4609h;out dx,ax;mov ax,0014h;out dx,ax
     mov ax,0e317h;out dx,ax;mov es,vidseg;xor di,di;xor ax,ax
     mov cx,16100;rep stosw
  end;
  for count:=0 to 255 do begin                        {set up plasma}
    setrgb(count,count div 4,count div 1,count);      {    CoLoRs   }
    setrgb(127-count,count div 4,count div 1,count);
    setrgb(127+count,20+count div 4,count div 2,count);
    setrgb(254-count,20+count div 4,count div 2,count);
  end;
  for count:=0 to 255+80 do begin
    stab1[count]:=round(sin(2*pi*count/255)*128)+18;
    stab2[count]:=round(cos(2*pi*count/255)*128)+128;
  end;
  asm
     mov cl,10;mov ch,10;mov es,vidseg;push bp;@main:

     {Vertical Raytrace}
   mov dx,3dah;@vert1:;in al,dx;test al,8;jz @vert1
   @vert2:;in al,dx;test al,8;jnz @vert2

     {2nd Vertical Raytrace}
   mov dx,3dah;@vert3:;in al,dx;test al,8;jz @vert3
   @vert4:;in al,dx;test al,8;jnz @vert4

                         {Yeap Double inc on Ch and Cl to }
                         {Increase the Plasma Speed       }
                         {So to run Fast on 386DX PCs.... }
     add cx,2          {So must use CX segment ! :)     }
     xor di,di;mov bp,di;@loooooop:;mov si,offset stab1
     mov bx,bp;add bl,cl;mov dl,[si+bx];xor dh,dh
     mov al,dh;mov al,[si+bx];add si,dx;mov bx,bp
     add bl,al;mov bl,[bx+offset stab2];mov bh,bl
     mov dx,40;@again:;lodsw;add ax,bx;stosw
     dec dx;jnz @again;cmp si,offset stab1[256]
     jb @1;sub si,256
   {Start Loop And Check If ESC Pressed}
   @1:;inc bp;cmp bp,58;jne @loooooop;in al,60h
   cmp al,1;jne @main;pop ax;end;
   asm;mov ax,03h;int 10h;end;
end;

begin
secretpart;
end.
