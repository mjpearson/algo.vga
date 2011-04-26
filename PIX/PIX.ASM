; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;                              T¡A5 Laborotories 1997
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  Name   : PIX.ASM
;  Author : Don Cagliostro
;  Date   : 16/04/97
;
; This simply puts a single pixel onscreen.  Ever heard the Demo makers
; saying??  "When you learn to plot a pixel, the rest is easy..."
;
; For the purpose of this example, the X and Y co-ordinates have been declared
; in the data segment.  You will notice that the prog plots a pixel in the
; centre of the screen in high green (10).
;
; Not much else to tell, except use in good health.
;
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;                                                               DCD/´ct¡v‚ 97
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

.MODEL tiny
.CODE
org 100h

DATASEG
x           dw 00a0h         ; 160   (320/2)
y           dw 64h           ; 100   (200/2) duh! <G>
picdata     db 0ah           ; Colour value

CODESEG
Begin:
    mov     al,13h           ; Set up AL for the video mode
    Call    SetVid           ; Do it. Set the mode
    mov     bx,x             ; Just some parameters passed to these
    mov     cx,y             ; registers so that the procedure
    mov     al,picdata       ; can use them.
    push    0a000h           ; Set up ES:0A000h for Video mem. address
    pop     es
    call    Putpixel         ; Now plot that pixel!!
    call    Wkey             ; Waiting...
    mov     al,3h            ; Set back to text mode
    call    SetVid
Exit2dos:
    mov     ah,04ch          ; And leave
    int     21h

SetVid   PROC
    xor     ah,ah              ; Are comments necessary?
    int     10h
    ret
ENDP     SetVid

Putpixel PROC
    add     bh,cl              ; All this prog does is : (X+(y*320))
    shl     cx,6               ; to determine the offset into display
    add     bx,cx              ; memory to write.
    mov     es:[bx],al         ; Have the address... let's write!
    ret
ENDP Putpixel

Wkey  PROC                     ; Waits for a key to be pressed
@@1000:
    xor     ah,ah
    int     16h
    or      ah,ah              ; Check AH because it checks the Scan-code,
    jz      @@1000             ; better than just finding the key
    ret
ENDP  Wkey
end Begin
