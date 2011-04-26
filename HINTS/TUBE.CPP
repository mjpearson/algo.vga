#include <stdlib.h>
#include <time.h>
#include <conio.h>
#include <math.h>

const int Max_Z      = 512;
const int Min_Z      = 2;
const int Max_X_org  = 300;
const int Min_X_org  = 20;
const int Max_Y_org  = 180;
const int Min_Y_org  = 20;
const int Max_Dz     = 64;
const int Min_Dz     = 2;
const int Factor     = 2;
const int Def_DZ	 = 8;
const int Max_Rand   = 256;
const int Step	     = 20;
const int Max_Active = Max_Z / 2 * Step;
const float PI2	     = 6.283185307;

#if Max_Rand <= 128
	typedef struct{
		int x;
		int y;
		int xc;
		int yc;
		int z;
		unsigned Old_pos;
	}Point;
#else
	typedef struct{
		long x;
		long y;
		long xc;
		int yc;
		int z;
		unsigned Old_pos;
	}Point;
#endif

Point star[Max_Active];
int Xtable[Max_Rand];
int Ytable[Max_Rand];
int Index[Max_Rand];

void setmode13(void);
void setmode03(void);
void setpal(void);
inline void waitvrt(void);

void main()
{   
	unsigned char _far *vidmem = (unsigned char _far *)0xA0000000;
	int i, Y_tmp, X_tmp, k, Randnum,tmp;
	int Num_Active			= 0;
	int dz					= Def_DZ;
	unsigned Tube_Xr		= 60;
	unsigned Tube_Yr		= 60;
	unsigned X_org			= 160;
	unsigned Y_org			= 100;
	unsigned X_choice		= 0;
	unsigned Y_choice		= 0;
	unsigned char X_count	= 64;
	unsigned char Y_count	= 0;
	unsigned char D_tube_xr = 64;
	unsigned char D_tube_yr = 0;
	unsigned char count		= 0;
	char quit				= 0;
	
	for(i=0; i < Max_Rand; i++){
		Xtable[i] = (int)(128 * cos(i * PI2 / Max_Rand) + .5); 
		Ytable[i] = (int)(128 * sin(i * PI2 / Max_Rand) + .5);
			
		Index[i]=i;
	}
	
	srand((unsigned)time(NULL));
	for(k=0; k < Max_Rand/2; k++)
		for(i=0; i < Max_Rand; i++){
			Randnum = rand() % Max_Rand;
			tmp = Index[Randnum];
			Index[Randnum] = Index[i];
			Index[i] = tmp;
		}
			
		
	setmode13();
	setpal();
				
	while(!quit){
	
		// Fill in the Field.
		for(k=0; k < Step; k++)
			if(Num_Active < Max_Active){
				for(i=0; star[i].z; i++);
				star[i].x = Tube_Xr * Xtable[Index[X_choice]];
				star[i].y = Tube_Yr * Ytable[Index[Y_choice]];
				star[i].z = Max_Z;
				star[i].xc = 160 + (120 * Xtable[X_count]) / Max_Rand;
				star[i].yc = 100 + (80 * Ytable[Y_count]) / Max_Rand;
				
				if(++X_choice > Max_Rand)
					X_choice = 0;
				if(++Y_choice > Max_Rand)
					Y_choice = 0;
				
				Num_Active++;
			}else
				break;	// No need to loop anymore.
			
		for(i=0; i < Max_Active; i++){
			// If the Star is Active.
			if(star[i].z){
				// Erase the old star.
				*(vidmem + star[i].Old_pos) = 0;
			 	
 				if(star[i].z > Min_Z){
					// Calculate the new one.
					X_tmp = star[i].x / star[i].z + star[i].xc;
				
					// If x lies within boundaries.
					if(X_tmp < 320 && X_tmp > 0){
						Y_tmp = star[i].y / star[i].z + star[i].yc;
					
						//if y lies within boundaries.
						if(Y_tmp < 200 && Y_tmp > 0){
							star[i].Old_pos = X_tmp + Y_tmp * 320;
							*(vidmem + star[i].Old_pos) = star[i].z >> 3;
							star[i].z -= dz;
						}else{
							star[i].z = 0;
							Num_Active--;
						}
					}else{
						star[i].z = 0;
						Num_Active--;
					}
				}else{
					star[i].z = 0;
					Num_Active--;
				}
			}
		}
		
		if(_kbhit())
			switch(_getch()){
				case 0x1b	:	quit = 1;
						break;
				case '+'	:	if( dz+Factor < Max_Dz) dz += Factor;
						break;
				case '-'	:	if( dz-Factor > Min_Dz) dz -= Factor;
						break;
			}
			
			X_count+=2;
			if(X_count >= Max_Rand) X_count = 0;
			Y_count++;
			if(Y_count >= Max_Rand) Y_count = 0;
			
			// This section increase the X and Y radii, giving 
			// ellipses.			
			if(count % 5){
				Tube_Xr = 20 * Xtable[D_tube_xr] / Max_Rand + 60;
				Tube_Yr = 20 * Ytable[D_tube_yr] / Max_Rand + 60;
				if(++D_tube_xr > Max_Rand) D_tube_xr = 0;
				if(++D_tube_yr > Max_Rand) D_tube_yr = 0;
			}
			
			count++;
	}
	
	setmode03();
}


void setmode13(void)
{
	__asm{
			mov		ax,13h
			int		10h
	}
}

void setmode03(void)
{
	__asm{
			mov		ax,03
			int		10h
	}
}

void waitvrt(void)
{
		__asm{
			mov	dx,3dah
	VRT:
			in		al,dx
			test	al,8
			jnz		VRT
	NoVRT:
			in		al,dx
			test	al,8
			jz		NoVRT
		}
}
    
typedef struct{
	char r;
	char g;
	char b;
}PAL;

void setpal(void)
{
	PAL colors[64];
	int i;
	unsigned tmp;
	
	for(i = 0; i < 64; i++){
		tmp = (unsigned)(pow(64,i/48.0) + .5);
		tmp = (tmp >= 64) ? 63:tmp;
		colors[i].r = tmp;
		colors[i].g = tmp;
		colors[i].b = (tmp < 15) ? 15: (tmp >= 64) ? 63: tmp;
	}
	
	_outp( 0x3c8, 1);
	for(i = 64; i > 0; i--){
		_outp(0x3c9, colors[i-1].r);
		_outp(0x3c9, colors[i-1].g);
		_outp(0x3c9, colors[i-1].b);
	}

	_outp(0x3c8,0);	
	_outp(0x3c9, 0);
	_outp(0x3c9, 0);
	_outp(0x3c9, 15);
	
}		
		
						
		
	

	
						
				
		
			
