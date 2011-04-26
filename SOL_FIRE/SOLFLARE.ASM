;.úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùú.
;       .         ø            .   An Official             ùù
;                     ÜÜ                     :
;     ,  ù          ÜßÜß   ú    ÜßßÜ      .      i     '
;                  ŞÛ Û    ù    ß²Üß         |                ì
;  é         "D    Û  Û    Ş     ùú     ..      .   .ÜÜÜÜÜÜ
;          r       Û  Û  úùÛù.úùÜßßÜ   ÜßßßßßÛ ÜßÜ..Û      ßÜ      ú
;      `          ŞÛ  Û°ÜÛÛßÛÜßß°  ŞÛ Û°   İ  Û  ÛÛÛ  ÜÛÛÜ   Û     ù
;         ù      ÜÛß  ßÛÛßß İÛÛİ   ŞÛİÛ   ÛÛ    ÛÛŞ   ÛÛÛÛ±Û Û  .  ³  .
;         |    Ûß         ÛÛ²ŞÛÛ   ŞÛİÛ  Û° Û  Û²ŞÛÛ    İŞÛÜÛÛ   \ º /
;      .      Ûß ÜßÛÜ  ÜÛÛÛÛÛŞÛÛ   ŞÛİÛ  Û  Û  Ûİ±ÛÛİ   Ü   Û úùÄÍğéğÍÄùú
;            ÛÜÛßÛÛÛÛ  Û±²ÛÛÛŞ±Û   ŞÛİÛ  °ÛÛ   °ÛŞÛ±ÛßÛÛÛÛÜ  Û   / º \
;   .ù        Û   ŞÛŞ  Û±ÛßÜÛŞ²Û    ÛİÛİ   İ   ÛÛİŞ² Ş²ÛÛ²ß  Û  ù  ³   ú
;             İ    ßÛÛ  ß  ÛİÛÛß°    ßÜÛ²Ü    Ü  ÜÛÛÛ  ßß   Û  ÜßßÜ ÄÄÄÄÄÄÄÄÄÄ
;             ù     ßÛÛ   ÜÛÛßŞÛÛÛÛÜÜÜÛÛßÛÛÛÛÛÛÛßß ßÛÜ    Üß   Û opyright 1996
;             ú     İ ßßÛßß           Ûİ            ßßßßÛß     ßÜÜß ÄÄÄÄÄÄÄÄÄÄ
;   ú         .     ù   İ             Û                ŞÛ  ù
;       ?        .  ú          o      Ş            .    İ    ¡   ú
;                                .          ù               ù
;     ø            ú                Phenomenon             ú  úù
; .úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùú.
;          Pure Will, unassuaged of purpose, delivered from lust of result
;                             is everyway perfect.
;                  (A. Crowley... Magick in Theory and Practice)
; .úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùú..
;
; Solarflare : My first drunken programming effort
;
; Started 1ú13 am - Finished 4ú42 am 7ù9ù96
;
; Comments added 2ú25 pm 7ù9ù96
;
; Well, i've always liked firewalls & plasmas, and now that I know how to do
; a backfeed... code herein has been based on Pascals (Cubic Team) Lasse
; Reinbong feed effect.  There's nothing like a hi-res fire routine...
;
; Comments, questions??
; Mail me : Caglios  (n1921380@student.fit.qut.edu.au)
;
;

.MODEL small
.CODE
.386
jumps

org 100h

begin:

    jmp     InitStuff
;
; I usually don't comment macros out of principle : personally I hate
; them.  But just for this exercise I will.  But just this once... &8)
;

malloc   macro NumParagraphs
    mov     ah,48h                    ; DOS Allocate block function 48h
    mov     bx,NumParagraphs          ; Size of block (in paragraphs)
    int     21h                       ; If you didn't know, a paragraph is
endm                                  ; 16 bytes contiguous

mdealloc macro where                  ; Um, anti this  one...
    mov     ah,49h
    mov     es,where
    int     21h
endm

VidMode  macro Mode                   ; Now, I just have to say this, but if
    mov     ax,Mode                   ; you don't know how to set mode 13h
    int     10h                       ; before reading this proggy, you
endm                                  ; shouldn't be reading at all. *8)

Source         dw  ?
Dest           dw  ?
Virt1          dw  ?
Virt2          dw  ?
VGASeg         dw  0a000h
ConvError      db  "Error : Couldn't hog memory.",0dh,0ah,"$"
x              dw  ?

Include        FIREPAL.DAT   ; Generated in C++
Include        XARRAY.INC    ; Generated in C++
Include        YARRAY.INC    ; Um, do I really need to tell you?

Initstuff:
    lea     sp,[TopOfStack]  ; Set stack pointer to end of proggy
    mov     bx,End_Seg-begin+100h
    shr     bx,4            ; gimme as much memory as possible
    inc     bx              ; ie : shrink memory usage
    mov     ah,4ah          ; function 4ah : Set memory block size
    int     21h

    malloc  4096            ; Gimme a 64k segment please...
    jc      nomem
    mov     [Virt1],ax

    malloc  4096            ; Aah, make that two!
    jc      NoMem
    mov     [Virt2],ax

Pass2:
    VidMode 13h             ; Set Video 320x200x256

    mov     ax,1012h        ; Set the palette registers : I know, interrupts
    mov     bx,0            ; are *slooow* but it reduces code size somewhat...
    mov     cx,255
    mov     dx,offset palette
    int     10h

    push    [Virt1]         ; Initialise first virtual display : ie get
    pop     es              ; rid of the junk so the wall can go *Fwoomp!*
    xor     al,al           ; Store 0's
    xor     di,di           ; Starting offset 0
    mov     cx,16000        ; 16000 bytes * 4 = 64Kb = Size of virtual display
    rep     stosd           ; And that would be because i'm assigning
                            ; doublewords
;
; Yes, and here it is... the main engine (if you could call it that)
;

_EroticallyGirateTheDisplay:

    call    Smoothe          ; Um... call the smoothe proc
    call    FireGen          ; Look up there  you twit (maha! got ya!)

    mov     dx,[Virt1]       ; Use DX as a scratch-register
    mov     [source],dx      ; as I'm scaling the first virtual against
    mov     dx,[Virt2]       ; the second
    mov     [Dest],dx        ;
    call    SegScaler        ;

    mov     dx,[Virt2]       ;
    mov     [Source],dx      ; and now the second against the first
    mov     dx,[Virt1]       ;
    mov     [dest],dx        ;
    call    SegScaler        ;

    call    WideScreen       ; It's a screen... and it's wide...

    in      al,60h      ; Take a looksie to see if any keys have been pressed
    cmp     al,1        ; ESC? Yes? No?
    jne     _EroticallyGirateTheDisplay

    call    PurgeKBD    ; I'm sure the keyboard port has been stuffed full
    VidMode 03h         ; of characters with the user goin "How do I get out
                        ; of this zany thing!"
    mdealloc [Virt1]    ; free the two segments I allocated earlier
    mdealloc [Virt2]
    jmp     Exit2Dos

NoMem    :
    lea     dx,[ConvError]  ;  This will probably happen under a DOS shell
    mov     ah,09           ;  or EXEC function, or windoze or something...
    int     21h             ;

Exit2Dos :
    mov     ah,04ch         ; Leave.  Hey, if you want to save yerself 2
    int     21h             ; bytes you could just do an int 20h

PurgeKBD PROC
  @@9000:
    xor  ah,ah                 ; Function 00h : Get console status
    int  16h                   ; is a bios routine...
    or   ah,ah                 ; scancode returned to AH register,
    jz   @@9000                ; so, if anything is in there, still more
  ret                          ; characters to come.
PurgeKBD ENDP

FireGen PROC
    mov     cx,320            ; mode 13h screen width is 320
IfItAintBroke:
    push    cx                ; save the counter
    mov     [x],cx            ; adjust the new x value accordingly
    call    PokeV1Pix         ; poke a random pixel
    pop     cx
    loop    IfItAintBroke     ; Don't fix it...
    ret
FireGen ENDP

Smoothe PROC
   push     [Virt1]           ; I seem to be repeating myself allot with
   pop      es                ; these few instructions so I won't explain
   xor      di,di             ; them
   mov      cx,64000
fl1:
   xor      bx,bx                         ;
   mov      bl,byte ptr es:[di]           ; Basically what this does
   mov      ax,bx                         ; is scan the virtual display
   mov      bl,byte ptr es:[di-1]         ; from bottom right to top
   add      ax,bx                         ; left.
   mov      bl,byte ptr es:[di+1]         ; The new pixel colour is computed
   add      ax,bx                         ; by obtaining the average of
   mov      bl,byte ptr es:[di+320]       ; the three intensities around it.
   add      ax,bx                         ;     Pixel being computed
   shr      ax,2                          ;              
   jz       fl2                           ;           -1 P +1
   dec      al                            ;            + 320
 fl2:                                     ;
   stosb                                  ;
   dec      cx                            ;
   jnz      fl1                           ;
   ret                                    ;
Smoothe ENDP

;
; Poke a 3 random pixel triad
;

PokeV1Pix PROC
    mov     cx,3                ; CX obviously the counter
PixIteration:
    push    [Virt1]             ; I'm poking these pixels to the virt1 segment
    pop     es
    mov     bx,x
    mov     dx,cx               ; save counter to DX reg.
    push    cx                  ; save counter to stack
    mov     cx,175              ; initialise for y-offset in display
    add     cx,dx               ; Add the counter
    call    RandPixel           ; generate a random value between 0..255
    xchg    al,ah               ; AL stores pixel colour
    add     bh,cl               ;
    shl     cx,6                ; Col:=x+(y*320)
    add     bx,cx               ;
    mov     es:[bx],al          ; Put the pixel at the calculated offset
    pop     cx                  ; restore the counter
    loop    PixIteration
    ret
PokeV1Pix ENDP

;
; Random # generator based on code by Tenie Remmel posted to alt.lang.asm
;

RandPixel PROC
    mov     ah,2               ; Two timing iterations
    cli                        ; Can't have any interrupts...
tr_loop:
    mov     al,06h             ; Set timer
    out     43h,al
    jmp     $+2
    in      al,40h             ; Read LSB of timer port
    xor     dl,al              ; XOR it against dl
    jmp     $+2
    in      al,40h             ; Read MSB of timer
    xor     dl,al
    shl     dx,7               ; colour range (higher shift, more colours)
    dec     ah
    jnz     tr_loop            ; loop back for the second iterate.
    sti                        ; Make sure ints are restored
    xchg    ax,dx              ; AX now stores the resulting random number
    ret
RandPixel ENDP

WideScreen PROC
    push    ds                 ; Better save the seg before we stuff around
    mov     ds,Virt2           ; with it : ie allocate the virt2 pointer to it
    mov     es,VGASeg          ; Um, this would be the destination
    mov     si,30*320          ; 30 rows down
    mov     di,si              ; No need to copy what I don't need to...
    mov     cx,140*80          ; 30 rows up...
    rep     movsd              ; Simple as that.
    pop     ds                 ; Better not forget this
    ret
WideScreen ENDP

SegScaler PROC
    mov     gs,source              ; Use lower reserved segment
    mov     es,dest                ; for an itch
    xor     di,di                  ; Um, offset 0 (duh!)
    mov     dl,200                 ; Y array is scaled for full resolution
                                   ; (200 pixels)
    xor     ecx,ecx
    mov     cx,offset YArray
l1:
    mov     dh,160                 ; Scale every 2nd X co-ordinate
    mov     si,offset XArray
l2:
    mov     ebx,dword ptr ds:[ecx] ; Take a copy of what's in GS
    add     ebx,dword ptr ds:[si]  ; and store.  Scale it with
    mov     al,byte ptr gs:[bx]    ; the generated (Y) array...
    shr     ebx,16                 ; Store the resulting value in bx
    mov     ah,byte ptr gs:[bx]    ; Can't do anything with bx, wack it in al
    stosw                          ; Word store (2*160=320=XMaximum)
    add     si,4                   ;
    dec     dh                     ; Onto the next pixel...
    jnz     l2
    add     cx,4                   ; yes yes, read above ùù
    dec     dl
    jnz l1
    ret
SegScaler ENDP

newstack    db      256 dup (?)    ; Allocate 256 dynamic bytes for the stack
topofstack  equ     $              ; End-of segment marker for the block size
                                   ; function
End_Seg:

end begin
