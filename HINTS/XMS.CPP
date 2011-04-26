//  Ack!  Why doesn't this work!!!
//  Works perfectly in TASM *and* Pascal.

#include <stdio.h>

unsigned int check=0;

// Declare...
unsigned int EMMCheck();

// Functions...
unsigned int EMMCheck()
{
unsigned int cf=0;
 asm mov ax,4300h
 asm int 2fh
 asm cmp ax,845ah
 asm jne @@100
 asm inc [cf]
 asm @@100:
 return(cf);
}

// Right... here we go then...
main(void)
{
 check=EMMCheck();
 if (check==1) printf("EMM386 is installed");
 else if (check==0) printf("EMM386 not installed");
 return(0);
}
