//   This prog updates the character generation tables with a pre-defined
// character set.  In this case it uses the STARTREK.BIN file to emulate
// a star trekkish type of font for normal dos use.
//
// Compile using: BCC LoadFont

#include <stdio.h>
#include <dos.h>

void loadfont(char *font)
{
   unsigned int fseg = FP_SEG(font);
   unsigned int foff = FP_OFF(font);

   asm push bp
   asm mov  ax, 1110h
   asm mov  bx, 1000h
   asm mov  cx, 0ffh
   asm xor  dx, dx
   asm mov  es, fseg
   asm mov  bp, foff
   asm int  10h
   asm pop  bp
}

// below procedure clears the screen to whatever video mode the screen
// is currently set to.  *8)

void clearscreen()
{
    asm  mov        ah,0fh
    asm  int        10h
    asm  xor        ah,ah
    asm  int        10h
}

void main()
{
   FILE *fp;
   char font[4096];

   fp = fopen("FONTSET1.BIN", "rb");
   fread(&font, sizeof font, 1, fp);
   fclose(fp);
   clearscreen();
   loadfont(font);
   printf("\n                        Proudly Brought to you by...");
   printf("\n   ú   ú     .úùÄ--ÄµThä ­¤Õ¡¤¡çî ’sçâàL Sæ¤ër™mî 1996ÆÄ--ÄÄùú.       .\n");
}
