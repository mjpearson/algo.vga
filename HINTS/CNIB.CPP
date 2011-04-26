//
// Title : CNIB.CPP
// Autor : Caglios
// Date  : 26-4-97
//
//  Nibbles!!!  Ha ha ha!!
//
//  Cag-Nibbles! v1.0  (Complete source)
//
//  To compile : BCC CNIB
//
//  Enjoy!

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
#define Size        5          // Nibble size

// Pointer to VGA mem.
unsigned char _far *vidmem = (unsigned char _far *)0xA0000000;

// Function prototypes

unsigned char Get_Ascii(void);
unsigned int Get_Control_Keys(unsigned int mask);
unsigned char Get_Scancode(void);
int getpixel (unsigned int x, unsigned int y);

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

void putpixel (int x, int y, unsigned int Col)
{
       *(vidmem + (x+y*320)) = Col;
}

int getpixel (unsigned int x, unsigned int y)
{
       char wobble=0;
       asm mov      ah,0dh
       asm xor      bh,bh
       asm mov      cx,x
       asm mov      dx,y
       asm int      10h
       asm mov      wobble,al
       return((int)wobble);
}

void _VMode(char mode)
{
    asm mov al,mode
    asm xor ah,ah
    asm int 10h
}

void _Wkey()
{
 asm {@@1000:
      xor   ah,ah
      int   16h
      or    ah,ah
      jz    @@1000}
}

// Writes the nibble to the screen...
void Nibby(int TBoundX,int TBoundY)
{
int Newline; int length; int x=TBoundX; unsigned int col=10;
for (length=TBoundY;length<TBoundY+Size;length++)
{
 Newline=0;                    // Flag has to be set before we can proceed.
 while (Newline==0)            // I set a Newline flag if the X maximum has been
   {                           // reached, so while it's 0, do a loop.
    putpixel(x,length,col);    // Plot a pixel in the rectangle
    x++;                       // Don't want it writing ontop of itself...
    if (x==TBoundX+Size) Newline=1; // check to see if X max. has been reached.
   }                           // If so, set the flag to kill the loop.
 x=TBoundX;                    // Realign the x value.
}
}

void setpos(char x, char y)
{
    asm mov     dl,x
    asm mov     dh,y
    asm mov     ah,02
    asm xor     bh,bh
    asm int     10h
}

// ******************
// Here's the engine!
// ******************
void playit()
{
int done=0; int difficulty=80; int count=0; int ErrCode=0;
unsigned int NibX, NibY,Uflag,Dflag,Lflag,Rflag; char key;
Dflag=1; NibX=160;NibY=100;
while (!done)
{
 setpos(20,0);
 printf("%d",count);
 count++;
 setpos(0,0);
 printf("%u",NibX);
 setpos(0,1);
 printf("%u     ",NibX+NibY*320);
    if ( (key = Get_Scancode()) )
    {
     if (key==SCAN_ESC) done=1;

     if ((key==SCAN_LEFT)&(Rflag!=1))
           {
            Lflag=1;Rflag=0;Uflag=0;Dflag=0;
           }
     if ((key==SCAN_RIGHT)&(Lflag!=1))
           {
            Rflag=1;Lflag=0;Dflag=0;Uflag=0;
           }
     if ((key==SCAN_DOWN)&(Uflag!=1))
           {
            Dflag=1; Uflag=0;Rflag=0;Lflag=0;
           }
     if ((key==SCAN_UP)&(Dflag!=1))
           {
            Uflag=1; Dflag=0;Lflag=0;Rflag=0;
           }
    }
     if (Lflag==1)
      {
       NibX=NibX-Size;
       ErrCode=(getpixel(NibX,NibY));
       if (ErrCode!=0) {setpos(1,1); printf("Ah shit!"); delay(200); }
       Nibby(NibX,NibY);
       delay(difficulty);
      }

     if (Rflag==1)
      {
       NibX=NibX+Size;
       ErrCode=(getpixel(NibX,NibY));
       if (ErrCode!=0) {setpos(1,1); printf("Ah shit!"); delay(200); }
       Nibby(NibX,NibY);
       delay(difficulty);
      }

    if (Uflag==1)
      {
       NibY=NibY-Size;
       ErrCode=(getpixel(NibX,NibY));
       if (ErrCode!=0) {setpos(1,1); printf("Ah shit!"); delay(200); }
       Nibby(NibX,NibY);
       delay(difficulty);
      }

    if (Dflag==1)
      {
       NibY=NibY+Size;
       ErrCode=(getpixel(NibX,NibY));
       if (ErrCode!=0) {setpos(1,1); printf("Ah shit!"); delay(200); }
       Nibby(NibX,NibY);
       delay(difficulty);
      }
}
}

main(void)
{
 // Set the video mode to 320x200x256
 _VMode(0x13);
 playit();
 _VMode(0x03);
 return(0);
}
