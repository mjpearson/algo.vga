; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;                              T¡A5 Laborotories 1997
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  TITLE  :=  COLOURS.ASM
;  AUTHOR :=  ³DarXydE³
;  DATE   :=  2-03-07
;
; This program is an example of the 'Write character and attribute' function
; 09h, using Video BIOS interrupt 10h
;
; This program could be implemented in a few different ways.  Firstly, the
; attributes for the string are embedded in the string data, which means
; that to change the attribute, you simply change the colour value inside the
; string.
;
; With this said, you can make applications seem to use ANSI displays, without
; going to all the hassle of writing escape sequence decodes and the like.
;
; To compile : Tasm colours
;              tlink /t colours        Ä Generates the file COLOURS.COM
;              colours
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;                                                               DCD/´ct¡v‚ 97
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
.MODEL small
.CODE
org 100h

begin:
    jmp     around

Column      db  01h                 ; Default column offset
attrib      db 7                    ; Default attribute (light white)
Onscreen    db 05h,'-',0dh,'=',0fh,'Gre',08,'et',05h,'in',0dh,'g',0fh,'s M',07h,'or',08h,'tal',05h,'=',0dh,'-',0

Around:
    call    ClearFast   ;  Clear screen (preserve character def. & overscan)
    lea     si,[Onscreen]
    mov     cx,1        ;  CX is unchanged, so set it's value here
                        ;  for use in the echo counter in the
                        ;  'Write character and Attribute' function
                        ;  where CX = number of times to repeat
IncPos:
    lods    byte ptr ds:[si]
    or      al,al
    je      Exit2Dos
    cmp     al,1Ah
    jg      Roundyahop
    mov     attrib,al ; We only want to set the attribute... not write
    jmp     IncPos    ; a character.

; The character has already been returned to al, so there is no need to
; include it in the function ( mov   al, char ) or whatever.

Roundyahop:
    mov     dl,Column  ; Horizontal offset
    xor     dh,dh      ; Row 0
    xor     bh,bh     ; Page 0
    call    SetXY
    mov     ah,09h    ; Function 9, Write character and attribute
    mov     bl,attrib ; Load attribute
    int     10h
    inc     Column    ; Increment horizontal offset for next char
    jmp     IncPos    ; Continue scanning the string!
Exit2Dos:
    xor     dl,dl
    mov     dh,1
    call    SetXY
    mov     ah,04ch
    mov     al,0h
    int     21h
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Set Cursor position ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetXY   Proc
    mov     ah,02h
    int     10h
    ret
Endp    SetXY

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; A high speed text screen clearing procedure.
;
; TITLE  :=  ClearFast (Also callable from TiA5 Labs Display library 'TDISP.LIB'
; DATE   :=  12-3-96
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ClearFast PROC
    mov     cx,24           ; Line counter
                            ; The below register initialisations have been
                            ; included just incase the calling program
                            ; hasn't done so first...
    xor     dx,dx           ; Row,Column for first line
    xor     bx,bx           ; Active display page 0, Attribute 0 (álack)
    xor     al,al           ; Null character to be written
rpt:
    push    cx              ; Save line counter
    mov     ah,02h          ; Set cursor position (where dh=row and dl=column)
    int     10h
    inc     dh              ; Increment row for next positioning
    mov     ah,09h          ; Write character and attribute function
    mov     cx,80           ; Character count
    int     10h
    pop     cx              ; Restore Line counter
    loop    rpt             ; Continue on until all lines have been cleared.

    xor     dx,dx           ; Position cursor to 0,0 on completion of clear
    mov     ah,02h          ;
    int     10h
    ret
EndP ClearFast
end begin
