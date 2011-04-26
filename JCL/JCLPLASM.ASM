; **************************************************************************
; **************************************************************************
; ****                                                                  ****
; ****  JCL-Plasma v1.3a (C) 1994 JCL-software                          ****
; ****                                                                  ****
; ****  This .asm file contains a routine to display a 'plasma' type    ****
; ****  image.  It requires at least a 386, and 486/33 is recommended.  ****
; ****  Also required is a file PLASMA.DAT, which contains image,       ****
; ****  'movement', and colour palette information pregenerated for     ****
; ****  speed by the file PLGENPLM.C                                    ****
; ****                                                                  ****
; ****  This file was compiled using TASM 2.5, and very experienced     ****
; ****  programmers might want to have a quiet laugh about how badly    ****
; ****  this is coded... however, this is BY FAR the fastest plasma     ****
; ****  I have seen, and also runs in FULL 320x200 resolution, at       ****
; ****  70 fps on my 486DX/33 (Local bus)                               ****
; ****                                                                  ****
; ****  Thanks go to Thomas Hagen, whose plasma inspired me to get one  ****
; ****  that worked full screen, and whose original function I          ****
; ****  'borrowed' until I finally got round to working one out by      ****
; ****  myself..                                                        ****
; ****                                                                  ****
; ****  Please send any (helpful) comments to me (Jeremy Longley) at    ****
; ****  jcl1008@cus.cam.ac.uk  (or Selwyn College, CAMBRIDGE, UK)       ****
; ****                                                                  ****
; ****                                Jezza (3/2/94 02:06 (groan...))   ****
; ****                                                                  ****
; **************************************************************************
; **************************************************************************




.MODEL  tiny

; ****  Macros ****

end_process macro return_code
        mov     al,return_code
        mov     ah,4ch
        int     21h
	endm

string  macro   str
        mov     ah,09h
        mov     dx,offset str
        int     21h
        endm

fopen   macro   file,attrib
        mov     ah,3dh
        mov     al,attrib
        mov     dx,offset file
        int     21h
        endm

malloc  macro   amount
        mov     ah,48h
        mov     bx,amount
        int     21h
        endm

mfree   macro   where
        mov     ah,49h
        mov     es,where
        int     21h
        endm

fread   macro   handle,bytes
        push    ax
        push    ds
        push    ax
        mov     ah,3fh
        mov     bx,[handle]
        mov     cx,bytes
        xor     dx,dx
        pop     ds
        int     21h
        pop     ds
        pop     ax
        endm

keyp    macro
        mov     ah,0bh
        int     21h
        or      al,al
        endm


; ****  static data ****

.CODE

org     100h
start:  jmp begin

headup  db 13,10,"JCLPLASM v1.3a - (C) 1994 JCL-Software (e-mail jcl1008@cus.cam.ac.uk)",13,10,"$"
noload  db 13,10,7,"Can't open file PLASMA.DAT",13,10,"$"
nomalloc db 13,10,7,"Not enough base memory",13,10,"$"
datf    db "PLASMA.DAT",0
handle  dw 0
plasma_seg  dw 0
move_seg    dw 0
colour_seg  dw 0
count   dw 0

ASSUME  DS:@code,ES:@code

; ****  Code ****

.386

begin:  ; *** Startup section ***

        mov     sp,offset tos   ; set new stack

        mov     bx,last_inst-start+100h
        shr     bx,4            ; shrink memory usage to program size
        inc     bx              ; in pages (16 bytes)
        mov     ah,4ah
        int     21h

        string  headup          ; display header message

        malloc  9600+1          ; allocate memory for plasma buffer
        jc      nomem           ; break if not enough memory
        mov     [plasma_seg],ax ; store address
        malloc  2500+1          ; allocate memory for movement buffer
        jc      nomem           ; as above...
        mov     [move_seg],ax
        malloc  1920+1          ; allocate memory for colour buffer
        jc      nomem
        mov     [colour_seg],ax
        jmp     allocok         ; skip the following
nomem:  string  nomalloc        ; tell user no memory
        end_process 255         ; and quit

allocok:
        fopen   datf,0          ; open PLASMA.DAT read only
        jnc     loadok          ; oops - not here!
        string  noload          ; so tell user
        end_process 254         ; and quit
loadok: mov     [handle],ax     ; store handle
        mov     ax,[plasma_seg] ; get load segment for plasma data
        mov     cl,4            ; load in 8 steps
loadpl: push    cx              ; store loop count
        fread   handle,9600h    ; read the data
        add     ax,960h         ; increase pointer
        pop     cx              ; restore loop count
        dec     cl              ; decrement loop count
        jnz     loadpl          ; and loop...

        mov     ax,[move_seg]   ; read movement data
        fread   handle,40000
        mov     ax,[colour_seg] ; and color data
        fread   handle,30720

        ;  *** plasma section ***

        mov     ax,13h          ; set video mode 13
        int     10h
        mov     ax,0a000h
        mov     es,ax

        xor     ax,ax           ; clear ax
        mov     [count],ax      ; store counter

mainloop:
waitfly:
        mov     dx,03dah        ; VGA input status register 1
        in      al,dx           ; load value
        test    al,08           ; vertical retrace??
        je      waitfly         ; if not, try again...

        mov     si,[count]      ; source = count *3
        shl     si,1
        add     si,[count]
        mov     dx,3c8h         ; DAC index register
        mov     al,1            ; start with reg 1
        out     dx,al           ; and load
        inc     dx              ; DAC read/write register
        mov     cx,255          ; write 255 items
        push    ds              ; store DS
        mov     ds,[colour_seg] ; address segment
        cld                     ; ensure SI is incremented
setpl:  outsb                   ; load R,G,B
        outsb                   ; Note - REP OUTSB is too fast on
        outsb                   ; some older VGA cards..
        loop    setpl           ; so loop
        pop     ds              ; and restore DS

        mov     di,[count]      ; source = count * 4
        shl     di,2
        push    ds              ; save DS (again...)
        mov     ds,[move_seg]   ; get segment address of movement data
        mov     si,[di]         ; load point 1
        mov     bx,[di+2]       ; load point 2
        pop     ds              ; restore DS

        push    ds              ; and store it ...
        mov     ds,[plasma_seg] ; get segment of start of plasma
        xor     di,di           ; DI = 0

        mov     ch,200          ; y loop = 200 pixels
pl1:    mov     cl,80           ; x loop = 80 * 4 = 320 pixels
pl2:    lodsd                   ; get 4 source pixels
        add     eax,[si+bx]     ; add 4 source pixels
        stosd                   ; and store them
        dec     cl              ; dec counter
        jnz     pl2             ; and loop..
        sub     si,320          ; reset source
        mov     dx,ds           ; add 32 to DS -
        add     dx,32           ; move 32*16 = 512 bytes down in source memory
        mov     ds,dx
        dec     ch              ; dec counter
        jnz     pl1             ; and loop..

        pop     ds              ; restore DS (again)
        inc     word ptr [count]; increase counter
        cmp     word ptr [count],10000  ; reset it at end of cycle
        jne     noreset
        mov     word ptr [count],0

noreset:
        keyp                    ; keypressed??
        jnz     closedown       ; if yes then quit..
        jmp     mainloop

closedown:
        mfree   [colour_seg]    ; free-up memory
        mfree   [move_seg]
        mfree   [plasma_seg]

        mov     ax,3h           ; set text mode...
        int     10h

        end_process 0           ; byeeeeee...


nstack  db      400 dup (?)
tos     equ     $

last_inst:

END     start
