//
//  File   : KBD.CPP
//  Author : Caglios
//  Type   : Example I/O
//
//  'Kay, this prog just show basic keyboard functions.  Nothing spesh.
//

#include <bios.h>
#include <stdio.h>

// Defines...

#define SCAN_Q 16
#define CTRL    0x04
#define ALT     0x08

// Function prototypes

unsigned char Get_Ascii(void);
unsigned int Get_Control_Keys(unsigned int mask);
unsigned char Get_Scancode(void);

// functions...

unsigned char Get_Ascii(void)
{
    if (_bios_keybrd(_KEYBRD_READY))
      return(_bios_keybrd(_KEYBRD_READ));
     else return(0);
}

unsigned int Get_Control_Keys(unsigned int mask)
{
    return(mask & _bios_keybrd(_KEYBRD_SHIFTSTATUS));
}

unsigned char Get_Scancode(void)
{
    asm mov     ah,01
    asm int     16h
    asm jz      empty
    asm xor     ah,ah
    asm int     16h
    asm xchg    al,ah
    asm xor     ah,ah
    asm jmp     done
empty:
    asm xor     ax,ax
done:
}

main(void)
{
unsigned char key;
int done=0;
printf("Oi! Press a key.  Press 'Q' to quit. Yo dig.");
while (!done)
{
    if ( (key = Get_Scancode()) )
       {
        printf("\nScan code = %d ",key);
       }
    if (Get_Control_Keys(CTRL))
        printf("\nControl key pressed");

    if (Get_Control_Keys(ALT))
        printf("\nalt key pressed");

    if (key==SCAN_Q) done=1;
}
return(0);
}
