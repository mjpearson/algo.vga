#include <bios.h>
#include <conio.h>
#include <stdio.h>
#include <dos.h>

// Defines...

#define SCAN_UP     72         // For upward   scrolls
#define SCAN_DOWN   80         // For downward scrolls
#define SCAN_LEFT   0x4B
#define SCAN_RIGHT  0x4D
#define SCAN_ESC    1          // Escapes from current screen
#define SCAN_SPACE  57         // Screen Trans.

char Nibble=233;

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

void setpos(char x, char y)
{
    asm mov     dl,x
    asm mov     dh,y
    asm mov     ah,02
    asm xor     bh,bh
    asm int     10h
}

main(void)
{
clrscr();
printf("Cag-Nibbles! v1.0");
unsigned char key;
int done=0;
int NibX, NibY,Uflag,Dflag,Lflag,Rflag;
Rflag=1; NibX=10;NibY=10;


while (!done)
{
    if ( (key = Get_Scancode()) )
    {
     if (key==SCAN_ESC) done=1;
     if (key==SCAN_LEFT) {Lflag=1;Rflag=0;Uflag=0;Dflag=0;}
     if (key==SCAN_RIGHT){Rflag=1;Lflag=0;Dflag=0;Uflag=0;}
     if (key==SCAN_DOWN) {Dflag=1; Uflag=0;Rflag=0;Lflag=0;}
     if (key==SCAN_UP)   {Uflag=1; Dflag=0;Lflag=0;Rflag=0;}
    }
     if (Lflag==1)
      {
       NibX--;
       setpos(NibX,NibY);
       printf("%c",Nibble);
       delay(70);
      }

     if (Rflag==1)
      {
       NibX++;
       setpos(NibX,NibY);
       printf("%c",Nibble);
       delay(70);
      }

    if (Uflag==1)
      {
       NibY--;
       setpos(NibX,NibY);
       printf("%c",Nibble);
       delay(140);
      }

    if (Dflag==1)
      {
       NibY++;
       setpos(NibX,NibY);
       printf("%c",Nibble);
       delay(140);
      }
}
return(0);
}
