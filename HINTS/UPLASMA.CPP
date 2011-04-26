// Transparent plasma engine
// Rex Deathstar, ???? 1994
//
// Released to the public during late-October 1995...
// (needs original PURENESS demo files to run)
#pragma inline
asm	.386P

#include <dos.h>
#include <process.h>
#include <math.h>
#include <stdio.h>
#include <conio.h>
#include <string.h>
#include "fader.h"
#include "realinit.c"


// LOADER
#define MAINDATAfilename "PURENESS.DAT"

#define MAXDATS 50

typedef struct {
	char filename[16];
	long filesize,position;
} DATINFO;

	DATINFO DATs[MAXDATS];

	char	MAINDATAfile[20];
// ------


#define		WIDTH	(640-320)/2
#define		rad	0.01745329


double	circle1,circle2,circle3,circle4;
double	c1,c2,c3,c4;

	int	x,y,a,n,index,dummy,accu,wait;
	long	x1,x2,y1,y2;

	long	plasma,backdrop,xmshandle;
unsigned char	Colors[768],buffer[640];
	long	mseed,seed=17831,nframes;
unsigned int	mbuffer1,mbuffer2,vram=0xa000;
	long	backdropfile,bitmapfile;

void    modeselect(unsigned char mode);
void	text();
void    palette();
void	setpal(char *pal);
void	load_plasma();
void	make_img();
int	random();
void	init_random();
void	load_backdrop();
void	capture_first_frame();
void	floater();
void	transparent_plasma();
void	scroll_in();
void	get_XMS();
void 	initialize_loader();
long 	search(char *filename);

void main()
{
	if(_virtual86()) { puts("Machine in V86 mode!"); exit(1); }
	INITCPU32();

	if(allocmem(4000,&mbuffer1)!=-1) exit(1);
	if(allocmem(4000,&mbuffer2)!=-1) exit(1);

	initialize_loader();
	get_XMS();
	init_random();
	load_backdrop();
	load_plasma();
	modeselect(0x13);
	palette();

	scroll_in();
	capture_first_frame();
	floater();

	nframes=1500;
	while(!kbhit() && nframes--)
	{
		if(++wait>100)
		{
			wait=0;
			c1=random()+8;
			c2=random()+8;
			c3=random()+8;
			c4=random()+8;
			accu=c1+c2+c3+c4;
			c1=(c1/accu)*0.07;
			c2=(c2/accu)*0.07;
			c3=(c3/accu)*0.07;
			c4=(c4/accu)*0.07;
		}

		transparent_plasma();

	}

	if(kbhit()) getch();
	modeselect(3);
	XMSunlock(xmshandle);
	XMSfree(xmshandle);
	puts("Transparent Plasma - Rex Deathstar/WaterLogic <deathstr@singnet.com.sg>");
}
//-----------------------
void transparent_plasma()
{
	circle1+=c1;
	circle2+=c2;
	circle3+=c3;
	circle4+=c4;

	x1=WIDTH*( sin(circle1)+1.0 );
	x2=WIDTH*( sin(circle2)+1.0 );
	y1=(400-200)/2*(cos(circle3)+1.0);
	y2=(400-200)/2*(cos(circle4)+1.0);

	y1*=640L;
	y1=y1+plasma+x1;
	y2*=640L;
	y2=y2+plasma+x2;

	make_img();
}

//-----------------------
void capture_first_frame()
{
	vram=mbuffer1;

	c1=0.005;
	c2=0.006;
	c3=0.007;
	c4=0.008;

	transparent_plasma();

	vram=0xa000;
}
//-----------------------
void floater()
{
asm xor ax,ax
asm mov es,ax
asm mov fs,[mbuffer2]
asm mov esi,dword ptr [backdrop]
asm xor di,di
asm mov cx,64000/4
xerox:
asm mov eax,es:[esi]
asm mov fs:[di],eax
asm add esi,4
asm add di,4
asm dec cx
asm jnz xerox


asm mov es,[vram]
asm mov fs,[mbuffer1]	// modified backdrop: target
asm mov gs,[mbuffer2]	// original backdrop: source

asm mov cx,80
outer_loop:
	//VRETRACE
	asm	mov	dx,0x3da
	vr1:
	asm	in	al,dx
	asm	test	al,8
	asm	jnz	vr1
	vr2:
	asm	in	al,dx
	asm	test	al,8
	asm	jz	vr2
	//-----------------
asm xor di,di
float_it:
asm mov al,fs:[di]	//target
asm mov ah,gs:[di]	//source
asm cmp ah,al
asm je  done
asm inc ah
done:
asm mov es:[di],ah
asm mov gs:[di],ah
asm inc di
asm cmp di,64000
asm jb  float_it

asm dec cx
asm jnz outer_loop
}


//-----------------------
void	make_img()
{
	asm	align	2


	//VRETRACE
	asm	mov	dx,0x3da
	vr1:
	asm	in	al,dx
	asm	test	al,8
	asm	jnz	vr1
	vr2:
	asm	in	al,dx
	asm	test	al,8
	asm	jz	vr2
	//-----------------

	asm	mov	es,[vram]
	asm	xor	di,di

	asm	mov	ebx,dword ptr [y1]
	asm	mov	esi,dword ptr [y2]
	asm	mov	edx,dword ptr [backdrop]


	asm	push	ds
	asm 	xor	ax,ax
	asm	mov	ds,ax

	asm	mov	ch,200
y_ing:

	asm	mov	cl,320/4/4
x_ing:

	//UNROLLED #1
	asm	mov	eax,[esi]
	asm	add	eax,[ebx]
	asm	add	eax,[edx]
	asm	stosd

	//UNROLLED #2
	asm	mov	eax,[esi+4]
	asm	add	eax,[ebx+4]
	asm	add	eax,[edx+4]
	asm	stosd

	//UNROLLED #3
	asm	mov	eax,[esi+8]
	asm	add	eax,[ebx+8]
	asm	add	eax,[edx+8]
	asm	stosd

	//UNROLLED #4
	asm	mov	eax,[esi+12]
	asm	add	eax,[ebx+12]
	asm	add	eax,[edx+12]
	asm	stosd

	asm	add	esi,16
	asm	add	ebx,16
	asm	add	edx,16

	asm	dec	cl
	asm	jnz	x_ing


	asm	add	ebx,320
	asm	add	esi,320

	asm	dec	ch
	asm	jnz	y_ing

	asm	pop	ds

}


//------------------------------------------------------------------------

void    modeselect(unsigned char mode)
{
	asm     mov     al,mode
	asm     xor     ah,ah
	asm     int     0x10

}
//------------------------------------------------------------------------
void palette()
{
	FILE *f;
	f=fopen(MAINDATAfile,"rb");
	fseek(f,search("UPLASMA.PAL"),SEEK_SET);
	fread(Colors,1,768,f);
	fclose(f);

	VGADAC(Colors);
}
//------------------------------------------------------------------------
void	load_plasma()
{
	asm xor ax,ax
	asm mov es,ax

	asm mov	ax,0x3d00
	asm lea	dx,[MAINDATAfile]
	asm int	0x21
	asm mov	bp,ax

	asm mov bx,bp
	asm mov ax,0x4200
	asm mov cx,word ptr [bitmapfile+2]
	asm mov dx,word ptr [bitmapfile]
	asm int 0x21


	asm mov	[index],0
	load_scanline:
	asm mov	bx,bp
	asm mov	cx,640
	asm mov	ah,0x3f
	asm lea	dx,[buffer]
	asm int	0x21

	asm movzx edi,word ptr [index]
	asm mov eax,640
	asm imul edi,eax
	asm add edi,dword ptr [plasma]

	asm lea si,[buffer]
	asm mov cx,640
	asm mov dx,1
	post_process:
	asm movzx ax,byte ptr [si]
	asm imul ax,dx
	asm shr ax,2

	asm mov es:[edi],al
	asm inc si
	asm inc edi
	asm dec cx
	asm jnz post_process

	asm inc [index]
	asm cmp [index],400
	asm jl  load_scanline



	asm mov	bx,bp
	asm mov	ah,0x3e
	asm int	0x21

}
//----------------------------------------------------------------------
void	load_backdrop()
{

	asm xor ax,ax
	asm mov es,ax

	asm mov	ax,0x3d00
	asm lea	dx,[MAINDATAfile]
	asm int	0x21
	asm mov	bp,ax

	asm mov bx,bp
	asm mov ax,0x4200
	asm add dword ptr [backdropfile],1078
	asm mov cx,word ptr [backdropfile+2]
	asm mov dx,word ptr [backdropfile]
	asm int 0x21


	asm mov	[index],0
	load_scanline:
	asm mov	bx,bp
	asm mov	cx,320
	asm mov	ah,0x3f
	asm lea	dx,[buffer]
	asm int	0x21

	asm movzx edi,word ptr [index]
	asm mov eax,320
	asm imul edi,eax
	asm add edi,dword ptr [backdrop]

	asm lea si,[buffer]
	asm mov cx,320
	post_process:
	asm movzx ax,byte ptr [si]
	//asm shr ax,1
	asm mov es:[edi],al
	asm inc si
	asm inc edi
	asm dec cx
	asm jnz post_process

	asm inc [index]
	asm cmp [index],200
	asm jl  load_scanline


	asm mov	bx,bp
	asm mov	ah,0x3e
	asm int	0x21

}
//---------------------------------------------------------------------
int	random()
{
	int	result;

	asm	mov     eax,dword ptr [mseed]
	asm	mul     dword ptr [seed]
	asm	not     eax
	asm	mov     dword ptr [seed],eax
	asm	ror     eax,10
	asm	add     dword ptr [mseed],eax

	asm	and	ax,1023
	asm	mov	[result],ax

	return(result);
}

//----------------------------------------------------------------------
void	init_random()
{
	asm	xor	ax,ax
	asm	mov	es,ax
	asm	mov	eax,es:[0070h]
	asm	mov	dword ptr [mseed],eax
}
//----------------------------------------------------------------------
void	scroll_in()
{
	fade(Colors,0);

asm mov es,[vram]
asm xor ax,ax
asm mov fs,ax
asm xor di,di
asm mov cx,64000/2
asm rep stosw

/*asm mov bp,64000
oloop:
	//VRETRACE
	asm	mov	dx,0x3da
	vr1:
	asm	in	al,dx
	asm	test	al,8
	asm	jnz	vr1
	vr2:
	asm	in	al,dx
	asm	test	al,8
	asm	jz	vr2
	//-----------------

asm mov cx,64000
asm sub cx,bp
asm shr cx,2	//(no.of pixels to copy)/4

asm mov di,bp
asm mov esi,dword ptr [backdrop]
iloop:
asm mov eax,fs:[esi]
asm mov es:[di],eax
asm add esi,4
asm add di,4
asm dec cx
asm jnz iloop

asm sub bp,320
asm jnz oloop*/

asm mov cx,64000/4
asm xor di,di
asm mov esi,dword ptr [backdrop]
iloop:
asm mov eax,fs:[esi]
asm mov es:[di],eax
asm add esi,4
asm add di,4
asm dec cx
asm jnz iloop

	for(a=0; a<64; a++)
	fade(Colors,a);

}
//---------------------
void	get_XMS()
{
	if(XMSinit()) {puts("XMS-driver not found or too old");exit(1);}
	if(XMSqueryfree()<400) {puts("Not enough free XMS-memory");exit(1);}
	XMSlocal_enable_A20();
	xmshandle=XMSalloc(400);
	plasma=XMSlock(xmshandle);
	backdrop=plasma+(256*1024L);
}
//-------------------
void initialize_loader()
{
	FILE *f;
	long size;

	sprintf(MAINDATAfile,MAINDATAfilename+NULL);


	if((f=fopen(MAINDATAfile,"rb"))==NULL)
	{
	text();
	printf("Cannot open %s!",MAINDATAfile);
	exit(1);
	}
	 
	size=sizeof(DATINFO)*MAXDATS;

	fseek(f,-size,SEEK_END);
	fread(DATs,1,size,f);
	fclose(f);

	backdropfile=search("UPLASMA.BMP");
	bitmapfile=search("UPLASMA.DAT");

	/*for(a=0; a<MAXDATS; a++)
	printf("Entry #%2d : NAME: %12s, SIZE: %6ld, POSITION: %8ld\n"
	,a,DATs[a].filename,DATs[a].filesize,DATs[a].position);

	getch();*/
}
//---------------
long search(char *filename)
{
	// search thru list for program
	for(n=0; n<MAXDATS; n++)
	if(strcmp(DATs[n].filename,filename)==NULL)
	break; //if found, get out of loop!

	// program not in list if loop terminates
	if(n==MAXDATS)
	{
	text();
	puts("Error searching PURENESS.DAT!");
	exit(1);
	}

	return(DATs[n].position);
}

//-----------------
void text()
{
asm mov ax,3
asm int 0x10
}
