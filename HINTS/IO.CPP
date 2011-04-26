//  Nothing special.  Just palette stuff..
//

#include <stdio.h>
#include <conio.h>

unsigned char old_palette[768];
unsigned char current_palette[768]={0};

void WaitVerticalRetrace(void);
void FadeInPalette(unsigned char *,int);
void FadeOutPalette(int);
void GetPalette(unsigned char *);
void SetPalette(unsigned char *);

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

void FadeOutPalette(int speed)
{
	int i,j,k;
	unsigned char temppalette[768];

	GetPalette(temppalette);

	for(i=0;i<64;i++)
	{
		for(j=0;j<256;j++)
		{
			// do the red component
			if(temppalette[j*3] > 0)
			{
				temppalette[j*3]--;
			}
			// do the green component
			if(temppalette[j*3+1] > 0)
			{
				temppalette[j*3+1]--;
			}
			// do the blue component
			if(temppalette[j*3+2] > 0)
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

void FadeInPalette(unsigned char *palettebuffer,int speed)
{
	int i,j,k;
	unsigned char temppalette[768]={0};

	for(i=0;i<64;i++)
	{
		for(j=0;j<256;j++)
		{
			// do the red component
			if(temppalette[j*3] < palettebuffer[j*3])
			{
				temppalette[j*3]++;
			}
			// do the green component
			if(temppalette[j*3+1] < palettebuffer[j*3+1])
			{
				temppalette[j*3+1]++;
			}
			// do the blue component
			if(temppalette[j*3+2] < palettebuffer[j*3+2])
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

// *******************************
// Yoikes!  A tias fade!
// *******************************
main()
{
    GetPalette(old_palette);
    FadeOutPalette(1);
	SetPalette(current_palette);
	_setcursortype(_NOCURSOR);
	clrscr();
    printf(" å  úù.    .                       @                      .\n");
    printf("  .           ù        .úù°ßùú.úùú.!úùúùúù.².úù²±°ß.   è             §  ú\n");
    printf("     .    ¦        ú     ²      ú  ­    ²± ²  ²    ú         |\n");
    printf("               ú  ù    ß°²²±°ß     °   ²  ²°   °°       ù Äù-éÄúÄ      ù\n");
    printf("          :               ±   ù    ²   ²  ²² ù   ²   ù.   .  |\n");
    printf("                    ù      ²      ±  ù  ±² ß     ²       úú  ù\n");
    printf("  ÷    ù     |         .úùú.²±°ß.úùø`ùú.úùú.úß°±².úù          ¦    ÷      •\n\n");
    printf("    ú   ú     .úùÄ--ÄµThä ­¤Õ¡¤¡çî ’sçâàL Sæ¤ër™mî 1996ÆÄ--ÄÄùú.       .\n");
    printf("               è\n");
    printf(" è    ù    úúùÄ--ÄµWho Hath the How is Careless of the WhyÆÄ--ÄÄùúú.§ ù\n\n");
    printf(".úù'`ùú.úù'`ùú.úù'`ùú.úù'`ùú.úù'`ùú.úù'`ùú.úù'`ùú.úù'`ùú.úù'`ùú.úù'`ùú.úù'`ùúú.\n\n");
    printf("                cUrReNtlY âuNNiNg Ms-dOs v6.22  *8)  Joyous!\n\n");
    FadeInPalette(old_palette,2);
    return(0);
}
