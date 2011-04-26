; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;                              T¡A5 Laborotories 1997
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  TITLE  : SCONE.ASM
;  AUTHOR : Don Cagliostro
;  DATE   : 14-5-1997
;  TYPE   : Procedure
;
;       Simple in theory, but the prick took me ages.  Actually it took
; about a twenty minutes to write, and it was completely fuquing up.  Wacked
; that last PUSH AX in and F'Tang!  Works fine.  I kicked myself. Literally.
;
; This procedure simply converts a 16-bit value to it's ASCII equivalent.
; Maximum is 65535 (5 digits + a string terminator).  So the buffer is only
; 6 bytes! Fantastic.
;
; The number is stored in the DX register before the call, and it uses a
; buffer (Called, for this example 'digibuffa').
; That's it.  I'm going home now.
;
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;                                                               DCD/´ct¡v‚ 97
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

.MODEL small
.CODE
org 100h

Begin:
    mov     dx,07CDh        ; 1997, This year. I want this in decimal
    call    Azz16           ; Change it to ASCII!!!

    lea     dx,digibuffa    ; The buffer has been filled and corrected
    mov     ah,09h          ; so lets get it onscreen
    int     21h
Exit2Dos:
    mov     ah,04ch         ; Oh. Erm, that's it.
    int     21h

digibuffa dw 6 dup(?)

;
; A 16-Bit number is placed in the DX register before calling this proc.
;
Azz16 PROC
    lea     di,digibuffa ; Initialise DI
Olophraggle:
    mov     ax,dx        ; Number stored in DX, we want to divide so...
    xor     dx,dx        ; place it in AX, and Zero out DX
    mov     cx,10        ; Base 10
    div     cx           ; Divide into AX
    xchg    ax,dx        ; Mix'em up a bit
    add     al,30h       ; Add 48 for the ASCII character
    mov     [di],al      ; Store it
    inc     di
    or      dx,dx        ; DX = 0?  ie : Can it be divided again??
    jnz     Olophraggle

; Now, this seemed fine; until I ran it.  You must remember that it has
; been stored in order of divisor, so I have to invert the buffer
; because it's stored back to front

    lea     di,digibuffa      ; Reset DI
Mad_SeX_Romp:
    mov     al,[di]      ; Get the character from the buffer
    cmp     al,030h      ; Check to see if character is between
    jb      Leave_Push   ; 48 & 57 (ie: 0..9)
    cmp     al,039h
    jg      Leave_Push
    xor     ah,ah        ; Zero out High-byte of AH
    push    ax           ; Push the character onto the stack
    inc     di
    loop    Mad_SeX_Romp
Leave_Push:
    lea     di,digibuffa ; Re-Reset DI
Poppie_Floppin:
    pop     ax           ; Grab the last-saved character
    cmp     al,030h      ; Do a check on its value
    jb      Done_Now     ; (As above)
    cmp     al,039h
    jg      Done_Now
    mov     [di],al      ; Store it in the buffer
    inc     di
    loop    Poppie_Floppin
Done_Now:
    push    ax         ; Take this out and see what happens... :(
                        ; This push took almost a half hour to figure out.
                        ; Do it with a debugger to see what I mean.
                        ; Damned f*&^sfcaslwrwiougrumbleuscasklj...
    mov     al,"$"      ; Add EOL to string
    add     [di],al     ;
    ret
ENDP Azz16
END Begin
