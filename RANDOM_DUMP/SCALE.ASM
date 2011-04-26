.386
jumps

Data Segment Word Use16
Extrn XArray : Word : 320
Extrn YArray : Word : 200
Data EndS

Code Segment DWord Use16

Assume CS: Code, DS: Data

Public ScaleUp,Fire,CopyDW,Dot

ScaleUp proc pascal near
arg source:word,dest:word
  mov gs,source
  mov es,dest
; xor di,di
  mov di,30*320
; mov dl,200
  mov dl,140
  xor ecx,ecx
  mov cx,offset YArray
  add cx,30*4
    l1:
    mov dh,160
    mov si,offset XArray
      l2:
      mov ebx,dword ptr ds:[ecx]
      add ebx,dword ptr ds:[si]
      mov al,byte ptr gs:[bx]
      shr ebx,16
      mov ah,byte ptr gs:[bx]
      stosw
      add si,4
      dec dh
      jnz l2
    add cx,4
    dec dl
    jnz l1
  ret
ScaleUp endp

Fire proc pascal near
arg dest:word
  mov es,dest
  mov di,30*320+1
  mov cx,320*140-1
    fl1:
    xor bx,bx
    mov bl,byte ptr es:[di]
    mov ax,bx
    mov bl,byte ptr es:[di-1]
    add ax,bx
    mov bl,byte ptr es:[di+2]
    add ax,bx
    mov bl,byte ptr es:[di+320]
    add ax,bx
    shr ax,2
    jz fl2
    dec al
    fl2:
    stosb
    dec cx
  jnz fl1
  ret
Fire endp

CopyDW proc pascal near
arg source:word, dest:word
  push ds
  mov ds,source
  mov es,dest
  mov si,30*320
  mov di,si
  mov cx,140*80
  rep movsd
  pop ds
  ret
CopyDW endp

Dot proc pascal near
arg x:word, y:word, dest:word, color:byte
  mov es,dest
  mov ax,y
  mov bx,320
  mul bx
  mov di,ax
  add di,x
  mov al,color
  mov ah,color

  shl eax,16
  mov al,color
  mov ah,color
  stosd 
  stosd 
  add di,312
  stosd 
  stosd   
  add di,312
  stosd   
  stosd 
  add di,312
  stosd   
  stosd 
  add di,312
  stosd   
  stosd 
  add di,312
  stosd   
  stosd 
  ret
Dot endp

code ends

end
