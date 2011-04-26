var
  r, g, b, coln : byte;

procedure WaitVR; Assembler;
asm
    push    dx
    mov     dx,03dah
@@1000:
    in      al,dx
    and     al,08
    jnz     @@1000
@@2000:
    in      al,dx
    and     al,08
    jz      @@2000
    pop     dx
end;

procedure SetPal_El; Assembler;
asm
    mov     dx,3c8h
    mov     al,Coln
{    mov     al,cl}
    out     dx,al
    inc     dx
    mov     al,[r]
    out     dx,al
    mov     al,[g]
    out     dx,al
    mov     al,[b]
    out     dx,al
end;

procedure FadeDisp; Assembler;
asm
    mov     cx,0ffh
@@ud:
    mov     dx,03c7h
    mov     [Coln],cl
    mov     al,cl

    out     dx,al
    mov     dx,03c9h
    in      al,dx
    mov     [r],al
    in      al,dx
    mov     [g],al
    in      al,dx
    mov     [b],al

    cmp     [r],0
    je      @@Green
    dec     [r]
@@Green:
    cmp     [g],0
    je      @@Blue
    dec     [g]
@@Blue:
    cmp     [b],0
    je      @@SetPal
    dec     [b]

@@SetPal:
    call    SetPal_El
{    call    WaitVR}
    loop    @@ud
end;


begin
  FadeDisp;
end.