//
// Title  : Text box generator
// File   : BOXGEN.CPP
// Author : Caglios
// Date   : 25-04-97
//
// This procedure generates a box, given the co-ordinates in the procedure
// call.  This proc. is stand-alone, it can be cut directly from this file
// and placed into your own program.
//
// Nothing special with the code, but it does need both setpos (or someting
// similar) as well as BoxGen to run.
//
// Stay gravy. \:)<=
//
#include <stdio.h>

void setpos(char x, char y)
{
    asm mov     dl,x
    asm mov     dh,y
    asm mov     ah,02
    asm xor     bh,bh
    asm int     10h
}

void BoxGen(int topx, int topy, int botx, int boty)
{
 int width, length;
 setpos(topx,topy); printf("Ú");
 for (width=topx+1;width<botx;width++)
   {
    setpos(width,topy);
    printf("Ä");
   }
 setpos(botx,topy); printf("¿");

 for (length=topy+1;length<boty;length++)
   {
    setpos(topx,length);
    printf("³");
    setpos(botx,length);
    printf("³");
   }

 setpos(topx,boty); printf("À");
 for (width=topx+1;width<botx;width++)
   {
    setpos(width,boty);
    printf("Ä");
   }
 setpos(botx,boty); printf("Ù");
}

main()
{
 BoxGen(5,5,25,20);
 return(0);
}
