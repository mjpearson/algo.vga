// Get current directory (on default drive) example.
// Simple!!
// You may notice the adjustment to ascii.  Obviously this will only
// work if the default drive is between A and I
//
// To compile : BCC GDIR
//
// #pragma inline
// asm .286

#include <stdio.h>

main(void)
{
  char Directory[64];      // 64 byte buffer for directory info.
  char Drive[1];           // The ASM call doesn't work properly if
                           // the [1] isn't set.  Must be the code.
  asm mov ah,47h           // Function 47h : Get current directory
  asm xor dl,dl            // Default drive is set in dl (0=Default)
  asm lea si,[Directory]   // Function returns info to the buffer
  asm int 21h
  asm mov ah,19h           // Get default drive
  asm int 21h
  asm add al,41h           // Adjust to Ascii conversion
  asm mov [Drive],al
  printf("Current directory : %s:\\%s\n",Drive,Directory);
  return(0);
}
