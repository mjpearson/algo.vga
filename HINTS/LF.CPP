//   This prog updates the character generation tables with a pre-defined
// character set.  In this case it uses the STARTREK.BIN file to emulate
// a star trekkish type of font for normal dos use.
//
// Compile using: BCC LoadFont

#include <stdio.h>
#include <dos.h>
#include <stdlib.h>
#include <math.h>
#include <conio.h>

#define mode   13h
unsigned char old_palette[768];
unsigned char current_palette[768];

void WaitVerticalRetrace(void);
void FadeInPalette(unsigned char *,int);
void FadeOutPalette(int);
void GetPalette(unsigned char *);
void SetPalette(unsigned char *);

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

void GetPalette(unsigned char *palettebuffer)
{
	int i;

	for(i=0;i<256;i++)
	{
		outp(0x3c7,i);	// color number to get data from
		palettebuffer[i*3]   = inp(0x3c9);	// red
		palettebuffer[i*3+1] = inp(0x3c9);	// green
		palettebuffer[i*3+2] = inp(0x3c9);	// blue
	}
}

void SetPalette(unsigned char *palettebuffer)
{
	int i;

    for(i=0;i<256;i++)
	{
		outp(0x3c8,i);	// color number to set
		outp(0x3c9,palettebuffer[i*3]);		// red
		outp(0x3c9,palettebuffer[i*3+1]);	// green
		outp(0x3c9,palettebuffer[i*3+2]);	// blue
	}
}

void WaitVerticalRetrace(void)
{
	asm	mov dx,3dah

	top_of_retrace:
	asm	in	al,dx
	asm	and	al,08h
	asm	jnz	top_of_retrace

	bottom_of_retrace:
	asm	in	al,dx
	asm	and	al,08h
	asm	jz	bottom_of_retrace
}

void WhiteScreen(int speed)
{
	int i,j,k;
	unsigned char temppalette[768];

	GetPalette(temppalette);

	for(i=0;i<64;i++)
	{
        for(j=0;j<255;j++)
		{
			// do the red component
            if(temppalette[j*3] < 63)
			{
                temppalette[j*3]++;
			}
			// do the green component
            if(temppalette[j*3+1] < 63)
			{
                temppalette[j*3+1]++;
			}
			// do the blue component
            if(temppalette[j*3+2] < 63)
			{
                temppalette[j*3+2]++;
			}
		}
		for(k=0;k<speed;k++)
		{
			WaitVerticalRetrace();
		}
		SetPalette(temppalette);
	}
}

//
// Here's the problem! *******************************************
//

void White2Norm(unsigned char *palettebuffer,int speed)
{
	int i,j,k;
	unsigned char temppalette[768]={0};

    GetPalette(temppalette);

	for(i=0;i<64;i++)
	{
		for(j=0;j<256;j++)
		{
			// do the red component
            if(temppalette[j*3] > palettebuffer[j*3])
			{
                temppalette[j*3]--;
			}
			// do the green component
            if(temppalette[j*3+1] > palettebuffer[j*3+1])
			{
                temppalette[j*3+1]--;
			}
			// do the blue component
            if(temppalette[j*3+2] > palettebuffer[j*3+2])
			{
                temppalette[j*3+2]--;
			}
		}
		for(k=0;k<speed;k++)
		{
			WaitVerticalRetrace();
		}
		SetPalette(temppalette);
	}
}
void main()
{
   FILE *fp;
   char font[4096];

   fp = fopen("FONTSET1.BIN", "rb");
   fread(&font, sizeof font, 1, fp);
   fclose(fp);
 // Set the overscan (Purple)
   asm mov     ah,10h
   asm mov     al,01h
   asm mov     bh,05h
   asm int     10h
 //
   GetPalette(old_palette);
   WhiteScreen(0.7);
   clrscr();
   loadfont(font);
   printf("\n                        Proudly Brought to you by...");
   printf("\n   ú   ú     .úùÄ--ÄµThä ­¤Õ¡¤¡çî ’sçâàL Sæ¤ër™mî 1996ÆÄ--ÄÄùú.       .\n");
   White2Norm(old_palette,1);
}
