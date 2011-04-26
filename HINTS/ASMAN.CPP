//.úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùú.
//      .         ø            .   An Official             ùù
//                     ÜÜ                     :
//     ,  ù          ÜßÜß   ú    ÜßßÜ      .      i     '
//                 ŞÛ Û    ù    ß²Üß         |                ì
//  é         "D    Û  Û    Ş     ùú     ..      .   .ÜÜÜÜÜÜ
//          r       Û  Û  úùÛù.úùÜßßÜ   ÜßßßßßÛ ÜßÜ..Û      ßÜ      ú
//      `          ŞÛ  Û°ÜÛÛßÛÜßß°  ŞÛ Û°   İ  Û  ÛÛÛ  ÜÛÛÜ   Û     ù
//         ù      ÜÛß  ßÛÛßß İÛÛİ   ŞÛİÛ   ÛÛ    ÛÛŞ   ÛÛÛÛ±Û Û  .  ³  .
//         |    Ûß         ÛÛ²ŞÛÛ   ŞÛİÛ  Û° Û  Û²ŞÛÛ    İŞÛÜÛÛ   \ º /
//      .      Ûß ÜßÛÜ  ÜÛÛÛÛÛŞÛÛ   ŞÛİÛ  Û  Û  Ûİ±ÛÛİ   Ü   Û úùÄÍğéğÍÄùú
//            ÛÜÛßÛÛÛÛ  Û±²ÛÛÛŞ±Û   ŞÛİÛ  °ÛÛ   °ÛŞÛ±ÛßÛÛÛÛÜ  Û   / º \
//   .ù        Û   ŞÛŞ  Û±ÛßÜÛŞ²Û    ÛİÛİ   İ   ÛÛİŞ² Ş²ÛÛ²ß  Û  ù  ³   ú
//             İ    ßÛÛ  ß  ÛİÛÛß°    ßÜÛ²Ü    Ü  ÜÛÛÛ  ßß   Û  ÜßßÜ ÄÄÄÄÄÄÄÄÄÄ
//             ù     ßÛÛ   ÜÛÛßŞÛÛÛÛÜÜÜÛÛßÛÛÛÛÛÛÛßß ßÛÜ    Üß   Û opyright 1997
//             ú     İ ßßÛßß           Ûİ            ßßßßÛß     ßÜÜß ÄÄÄÄÄÄÄÄÄÄ
//   ú         .     ù   İ             Û                ŞÛ  ù
//       ?        .  ú          o      Ş            .    İ    ¡   ú
//                                .          ù               ù
//     ø            ú                Phenomenon             ú  úù
// .úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùú.
//          Pure Will, unassuaged of purpose, delivered from lust of result
//                             is everyway perfect.
//                  (A. Crowley... Magick in Theory and Practice)
// .úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùÄÄÍÍÍÄÄùú.úùÄÄ--ÄÍ--Äùú.úùÄÄÍÍÍÄùú..
//
//  Source for ASM-MAN v1.0
//
//  Compile :  BCC ASMAN.CPP     (I use Borland C++ v4.52)
//
//  An interactive assembly language file editor
//
//  Copyright (c) Michael Pearson 1997
//  Email : n1921380@student.fit.qut.edu.au     (Michael Pearson)
//
//  The source contained herein is program property of TIAS Industries, and
//  has been released as freeware code.  This source may not be included with
//  a magazine, cd-rom archive or any other retail medium without the prior
//  notification of the author.
//
//  Help support the freeware scene!  Don't make people pay for this.  You
//  may use and distribute this code to whomever you wish, as long as the prior
//  stated conditions are met, and as long as the files contained in this
//  package remained unchanged.
//
//  Enjoy!
//
//

#include <time.h>
#include <stdio.h>
#include <conio.h>
#include <dos.h>
#include <bios.h>

// Palette Arrays

unsigned char old_palette[768];
unsigned char current_palette[768]={0};

// Defines...

#define SCAN_Q      16
#define SCAN_UP     72         // For upward   scrolls
#define SCAN_DOWN   80         // For downward scrolls
#define SCAN_ESC    1          // Escapes from current screen
#define SCAN_SPACE  57         // Screen Trans.
#define SCAN_F10    0x44
#define SCAN_F1     0x3b

// Keyboard Function prototypes

unsigned char Get_Ascii(void);
unsigned int Get_Control_Keys(unsigned int mask);
unsigned char Get_Scancode(void);

// Video manipulation Procedure prototypes...

void WaitVerticalRetrace(void);
void FadeInPalette(unsigned char *,int);
void FadeOutPalette(int);
void GetPalette(unsigned char *);
void SetPalette(unsigned char *);

// *****************  Functions...  *******************

// Keyboard functions.

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

//
//  *****************  Procedures  ********************
//

// Pelette Code for the screen transitions.

void GetPalette(unsigned char *palettebuffer)
{
	int i;

	for(i=0;i<256;i++)
	{
		outp(0x3c7,i);  // color number to get data from
		palettebuffer[i*3]   = inp(0x3c9);      // red
		palettebuffer[i*3+1] = inp(0x3c9);      // green
		palettebuffer[i*3+2] = inp(0x3c9);      // blue
	}
}

void SetPalette(unsigned char *palettebuffer)
{
	int i;

	for(i=0;i<256;i++)
	{
		outp(0x3c8,i);  // color number to set
		outp(0x3c9,palettebuffer[i*3]);         // red
		outp(0x3c9,palettebuffer[i*3+1]);       // green
		outp(0x3c9,palettebuffer[i*3+2]);       // blue
	}
}

void WaitVR(void)
{
	asm     mov dx,3dah

	top_of_retrace:
	asm     in      al,dx
	asm     and     al,08h
	asm     jnz     top_of_retrace

	bottom_of_retrace:
	asm     in      al,dx
	asm     and     al,08h
	asm     jz      bottom_of_retrace
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
            WaitVR();
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
            WaitVR();
		}
		SetPalette(temppalette);
	}
}

// ********************  Utility procedures  ******************

void loadfont()
{
   FILE *fp;
   char font[4096];
   fp = fopen("FONTSET1.BIN", "rb");
   fread(&font, sizeof font, 1, fp);
   fclose(fp);

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
    printf("³Û");
   }

 setpos(topx,boty); printf("À");
 for (width=topx+1;width<botx;width++)
   {
    setpos(width,boty);
    printf("Ä"); setpos(width+1,boty+1); printf("ÛÛ");
   }
 setpos(botx,boty); printf("ÙÛ");
}

void HelpScreen()
{
 int Horiz,Vert;
 Horiz = 32; Vert = 0;
 GetPalette(old_palette);
 FadeOutPalette(0.9);
 SetPalette(current_palette);
 _setcursortype(_NOCURSOR);
 clrscr();
 setpos(Horiz,Vert);
 printf("ASM - MAN v1.0\n\n");
 printf("Alt-L    Load File                  Alt-S       Save File\n");
 FadeInPalette(old_palette,0.9); //
}

// This proc. gets the machine's status (EMS,XMS,MSCDEX, Free Mem & disk space)
// detects a mouse driver, as well as windows.  *8)

void MachStatus()
{
 GetPalette(old_palette);
 FadeOutPalette(0.9);
 SetPalette(current_palette);
 _setcursortype(_NOCURSOR);
 clrscr();
    int Horiz,Vert;
    Horiz=17; Vert=0;
    setpos(Horiz,Vert);
    printf(". ú ù ÄÄÄÍÍÄÍµ[Machine Status]ÆÍÄÍÍÄÄÄ ù ú .\n");

 // Get DOS Version...
    char HiDos;char LoDos;
    int  Hi; int Lo;
    asm mov     ah,30h
    asm int     21h
    asm mov     LoDos, ah
    asm mov     HiDos, al
    Hi=(int)HiDos; Lo=(int)LoDos;
    Vert=Vert+2;Horiz=7; setpos(Horiz,Vert);
    printf("DOS Version       : %d.%d",Hi,Lo);

 // Get Base Memory
    int Base_Mem;
    Base_Mem=biosmemory();
    Vert++; setpos(Horiz,Vert);
    printf("Total Memory      : %dK",Base_Mem);

 // *************   XMS Utils   ***************

 // XMS Installation check
    unsigned char status;
    int XMS_Entrypoint;
    asm mov     ax,4300h
    asm int     2fh
    asm mov     status,al
    Vert++;setpos(Horiz,Vert);
    printf("XMS               : ");
    if (status==0x80) printf("Installed.");
    else printf("Not resident");

 // Get Disk space
    struct dfree df;
    long   f_disk;
    getdfree(3,&df);
    f_disk=(long)df.df_avail*(long)df.df_bsec*(long)df.df_sclus;
    Vert++; setpos(Horiz,Vert);
    printf("Free Disk Space   : %ld Mb (Approx)",f_disk/1000000);

 // Check for MSCDEX
    status=0;
    asm mov     ax,1100h
    asm push    0dadah
    asm int     2fh
    asm mov     status,al
    Vert++; setpos(Horiz,Vert);
    printf("MSCDEX            : ");
    if (status==1) printf("Not found (Not OK to install)");
    if (status==0) printf("Not found");
    if (status==255) printf("Installed");

 // Windows Installation check
    asm mov     ax,1600h
    asm int     2fh
    asm mov     LoDos,ah
    asm mov     HiDos,al
    Vert++; setpos(Horiz,Vert);
    printf("Windows Version   : ");
    Hi=(int)HiDos; Lo=(int)LoDos;
     if (Hi!=0)
      {
       printf("%d.%d",Hi,Lo);
      }
     else printf("Not found");

 // Mouse
    int mousie=0; int button;
    asm xor     ax,ax
    asm int     33h
    asm mov     mousie,ax
    asm mov     button,bx
    Vert++; setpos(Horiz,Vert);
    printf("Mouse"); Horiz=25;
    if (mousie!=0)
      {
       char MIRQ;
       asm mov      ax,0024h
       asm int      33h
       asm mov      MIRQ,cl
       int aMIRQ=(int)MIRQ;
       setpos(Horiz,Vert);
       printf(": Detected,"); Vert++; setpos(Horiz,Vert);
       printf(": %d button(s)",button); Vert++; setpos(Horiz,Vert);
       printf(": Hooking IRQ %d", aMIRQ);
      }
    else
      {
       setpos(Horiz,Vert);
       printf(": Not found");
      }
 // Current Directory

    char Directory[64];      // 64 byte buffer for directory info.
    asm mov ah,47h           // Function 47h : Get current directory
    asm xor dl,dl            // Default drive is set in dl (0=Default)
    asm lea si,[Directory]   // Function returns info to the buffer
    asm int 21h
    Horiz=7;Vert++;setpos(Horiz,Vert);
    printf("Current directory : .\\%s",Directory);

 // Current Time & Date

    time_t longtime;
    time(&longtime);
    Vert++; setpos(Horiz,Vert);
    printf("Date/Time         : %s",ctime(&longtime));
 BoxGen(3,1,77,Vert+1);
 FadeInPalette(old_palette,0.9); //
}

void MainScreen()
{
 GetPalette(old_palette);
 FadeOutPalette(0.9);
 SetPalette(current_palette);
 _setcursortype(_NOCURSOR);
 clrscr();
 printf("  File               Options          Program          Nibbles        Help     \n\n");
 printf("\nPress F10 for Machine Status, F1 for Help, space to return");
 printf("\nto this screen... and Q to load the scrawl font...");

 FadeInPalette(old_palette,0.9);
}

// It starts....

void main()
{
// Initialise for program...
  unsigned char key;
  int done=0;

  MainScreen();

// Main key loop
  while (!done)
{
    if ( (key = Get_Scancode()) )
     {
      if (key==SCAN_UP) printf("\n Up key pressed  ");
      if (key==SCAN_F1) HelpScreen();
      if (key==SCAN_F10) MachStatus();
      if (key==SCAN_DOWN) printf("\n Down Key pressed");
      if (key==SCAN_SPACE) MainScreen();
      if (key==SCAN_Q) loadfont();
      done=0;
      if (key==SCAN_ESC) done=1;
    }
}
 FadeOutPalette(0.9);
 clrscr();
 SetPalette(old_palette);
}
