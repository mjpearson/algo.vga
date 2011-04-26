#include <stdio.h>
#include <conio.h>
#include "gfx.cpp"

byte flames[325][70];
// For those who don't understand this.
// In Phobos' Pascal code he uses:
// VAR flames : ARRAY [-5..325,130..200] OF BYTE;
// The 200 - 130 gives us 70. understand?
// We will not be using 0 to 130 so we just allocate the space needed.
byte col;

void palette();
void fire();

void palette() {
 byte loop, r, g, b;
  r = 0; g = 0; b = 0;
   for (loop=0;loop<201;loop++) pal(loop,0,0,0);
    for (loop=50;loop<100;loop++) {
      pal(loop,r,g,b);
       r++;
     }
     for (loop=100;loop<149;loop++) {
       pal(loop,r,g,0);
	g++;
      }
     for (loop=150;loop<200;loop++) {
      pal(loop,r,g,b);
       b++;
     }
 }

void fire() {
  int x,y,loop;
   for (x=0;x<325;x++) {
    for (y=130;y<200;y++) { // 130 to 200! Total of 70.
      col=(flames[x-1][y+1] + flames[x][y+1] + flames[x+1][y+1] +
	flames[x][y+2]) / 4;
	 if (y == 199) col = (rand() % 126) + 75; // Remember random?
	  if (col != 0) col--; // Not zero, decrement colour
	   flames[x][y] = col; // store colour in flame buffer
	    if ((x-5 > 0) && (x < 319) && (y < 199)) putpixel(x-5,y,col,vga);
	    // since we can't create an array starting at -5, we simply
	    // deduct 5 from the position we draw at.
	 }
     }
 }

void main() {
  randomize(); // Rand-seed
  setmcga();
  palette();
   do {
	fire();
      } while (!kbhit());
   settext(); // All done!
 }
