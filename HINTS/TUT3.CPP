/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// TUTPROG3.CPP - VGA Trainer Program 3 (in Turbo C++ 3.0)                 //
//                                                                         //
// "The VGA Trainer Program" is written by Denthor of Asphyxia. However it //
// was limited to Pascal only in its first run.  All I have done is taken  //
// his original release, translated it to C++ and touched up a few things. //
// I take absolutely no credit for the concepts presented in this code and //
// am NOT the person to ask for help if you are having trouble.            //
//                                                                         //
// Program Notes : This program presents many new concepts, including:     //
//                 Cirle and Line algorithms.                              //
//                                                                         //
//                 If you are compiling this code command line, be sure to //
//                 use the "-ml" parameter (large memory model).           //
//                 Otherwise, the program will compile and link, but will  //
//                 lock up your system.                                    //
//                                                                         //
// Author        : Grant Smith (Denthor) - denthor@beastie.cs.und.ac.za    //
// Translator    : Christopher G. Mann   - r3cgm@dax.cc.uakron.edu         //
//                                                                         //
// Last Modified : December 7, 1994                                        //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

//               //
// INCLUDE FILES //
//               //

  #include <conio.h>
			  // getch(), clrscr(), kbhit()
  #include <dos.h>
			  // MK_FP, Geninterrupt()
  #include <math.h>
			  // floor(), ceil(), abs(), sin(), cos()
  #include <iostream.h>
			  // cout, endl, memset(), _fmemset()

//                     //
// FUNCTION PROTOTYPES //
//                     //

  // MODE SETTING FUNCTIONS
  void SetMCGA();
  void SetText();

  // PALLETTE FUNCTIONS
  void Pal    (unsigned char ColorNo,  unsigned char R,
	       unsigned char G,        unsigned char B);
  void PalPlay();

  // SMALL UTILITY FUNCTIONS
  int  sgn    (long a);
  int  round  (long a);

  // DRAWING FUNCTIONS
  void Putpixel (int  x, int  y, unsigned char Col);
  void Line     (int  a, int  b, int   c, int  d, int col);
  void Line2    (int x1, int y1, int  x2, int y2, int col);
  void Circle   (int  X, int  Y, int rad, int col);
  void WaitRetrace();

//                              //
// GLOBAL VARIABLE DECLARATIONS //
//                              //

  // declare a pointer to the offset of VGA memory
  unsigned char *vga = (unsigned char *) MK_FP(0xA000, 0);

  // This declares the PALL variable. 0 to 255 signifies the colors of the
  // pallette, 1 to 3 signifies the Red, Green and Blue values. I am
  // going to use this as a sort of "virtual pallette", and alter it
  // as much as I want, then suddenly bang it to screen. Pall2 is used
  // to "remember" the origional pallette so that we can restore it at
  // the end of the program. */
  unsigned char Pall[256][3], Pall2[256][3];

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                MAIN FUNCTION                              //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

void main() {

  clrscr();
  cout
    << "This sample program will test out our line and circle algorithms.\n"
    << "In the first part, many circles will be draw creating (hopefully)\n"
    << "a ""tunnel"" effect. I will the rotate the pallete to make it look\n"
    << "nice. I will then draw some lines and rotate the pallette on them\n"
    << "too. Note : I am using the slower (first) line algorithm (in\n"
    << "procedure line2). Change it to Procedure Line and it will be using\n"
    << "the second line routine. NB : For descriptions on how pallette works\n"
    << "have a look at part two of this series; I won''t re-explain it here."
    << endl << endl;
  cout
    << "Remember to send me any work you have done, I am most eager to help."
    << endl << endl;
  cout
    << "Hit any key to continue ...";
  getch();
  SetMCGA();

  // This sets colors 1 to 199 to values between 33 to 63. The MOD
  // function gives you the remainder of a division, ie. 105 mod 10 = 5 }
  for (int loop1=1; loop1<200; loop1++) {
    Pall[loop1][0] = (loop1 % 30) + 33;
    Pall[loop1][1] = 0;
    Pall[loop1][2] = 0;
  }

  WaitRetrace();

  // This sets the true pallette to variable Pall
  for (loop1=1; loop1<200; loop1++)
    Pal(loop1, Pall[loop1][0], Pall[loop1][1], Pall[loop1][2]);

  // This draws 90 circles all with centers at 160,100 with increasing
  // radii and colors.
  for (loop1=1; loop1<91; loop1++)
    Circle(160, 100, loop1, loop1);

  // wait until a key is pressed
  while (!kbhit()) PalPlay();
  // make sure to clear the keyboard buffer
  getch();

  // This draws 199 lines, all starting at 0,1
  for (loop1=1; loop1<200; loop1++)
    Line2 (0,1,319,loop1,loop1);   // *** Replace Line2 with Line to use the
				   // second line algorithm ***

  while (!kbhit()) PalPlay();
  getch();

  getch();

  SetText();

  cout
    << "All done. Okay, so maybe it wasn''t a tunnel effect, but you get the\n"
    << "general idea ;-) This concludes the third sample program in the ASPHYXIA\n"
    << "Training series. You may reach DENTHOR under the name of GRANT SMITH\n"
    << "on the MailBox BBS, or leave a message to ASPHYXIA on the ASPHYXIA BBS\n"
    << "Get the numbers from Roblist, or write to :\n"
    << "             Grant Smith\n"
    << "             P.O. Box 270\n"
    << "             Kloof\n"
    << "             3640\n" << endl;
  cout << "I hope to hear from you soon!" << endl << endl;
  cout << "Hit any key to exit ...";

  getch();
}


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// SetMCGA() - This function gets you into 320x200x256 mode.               //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void SetMCGA() {
  _AX = 0x0013;
  geninterrupt (0x10);
}


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// SetText() - This function gets you into text mode.                      //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void SetText() {
  _AX = 0x0003;
  geninterrupt (0x10);
}


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// Pal() - This sets the Red, Green, and Blue values of a certain color.   //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void Pal(unsigned char ColorNo, unsigned char R,
	 unsigned char G,       unsigned char B) {

  outp (0x03C8,ColorNo); // here is the pallette color I want to set
  outp (0x03C9,R);
  outp (0x03C9,G);
  outp (0x03C9,B);

}


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// PalPlay() - This function mucks about with our "virtual pallette", then //
//             shoves it to the screen.                                    //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void PalPlay() {

unsigned char Tmp[3];

  // This copies color 199 from our virtual pallette to the Tmp variable.
  _fmemmove(Tmp,Pall[199],3);

  // This moves the entire virtual pallette up one color.
  _fmemmove(Pall[2],Pall[1],199*3);

  // This copies the Tmp variable to the bottom of the virtual pallette.
  // Don't change 0: leave this always black to not change overscan color.
  _fmemmove(Pall[1],Tmp,3);

  WaitRetrace();
  for (int loop1=0;loop1<256;loop1++)
   Pal(loop1,Pall[loop1][0], Pall[loop1][1], Pall[loop1][2]);

}


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// sgn() - This function is used by Line() to determine the sign of a long //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

int sgn (long a) {
  if (a > 0) return +1;
  else if (a < 0) return -1;
  else return 0;

}


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// round() - This function is used by Line() to round a long to the        //
//           nearest integer.                                              //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

int round (long a) {
  if ( (a - (int)a) < 0.5) return floor(a);
    else return ceil(a);
}


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// Putpixel() - This puts a pixel on the screen by writing directly to     //
//              memory.                                                    //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void Putpixel (int x, int y, unsigned char Col) {
  memset(vga+(x+(y*320)),Col,1);
}


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// Line() - This draws a line from a,b to c,d of color col.                //
//          This function will be explained in more detail in tut3new.zip  //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void Line(int a, int b, int c, int d, int col) {

  long u,s,v,d1x,d1y,d2x,d2y,m,n;
  int  i;

  u   = c-a;      // x2-x1
  v   = d-b;      // y2-y1
  d1x = sgn(u);   // d1x is the sign of u (x2-x1) (VALUE -1,0,1)
  d1y = sgn(v);   // d1y is the sign of v (y2-y1) (VALUE -1,0,1)
  d2x = sgn(u);   // d2x is the sign of u (x2-x1) (VALUE -1,0,1)
  d2y = 0;
  m   = abs(u);   // m is the distance between x1 and x2
  n   = abs(v);   // n is the distance between y1 and y2

  if (m<=n) {     // if the x distance is greater than the y distance
    d2x = 0;
    d2y = sgn(v); // d2y is the sign of v (x2-x1) (VALUE -1,0,1)
    m   = abs(v); // m is the distance between y1 and y2
    n   = abs(u); // n is the distance between x1 and x2
  }

  s = (int)(m / 2); // s is the m distance (either x or y) divided by 2

  for (i=0;i<round(m);i++) { // repeat this loop until it
			     // is = to m (y or x distance)
    Putpixel(a,b,col);       // plot a pixel at the original x1, y1
    s += n;                  // add n (dis of x or y) to s (dis of x of y)
    if (s >= m) {            // if s is >= m (distance between y1 and y2)
      s -= m;
      a += d1x;
      b += d1y;
    }
    else {
      a += d2x;
      b += d2y;
    }
  }

}


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// Line2() - This function draws a line from x1,y1 to x2,y2 using the      //
//           first method.                                                 //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void Line2(int x1, int y1, int x2, int y2, int col) {

  int   x, y, xlength, ylength, dx, dy;
  float xslope, yslope;

  xlength = abs(x1-x2);
  if ((x1-x2)  < 0) dx = -1;
  if ((x1-x2) == 0) dx =  0;
  if ((x1-x2)  > 0) dx = +1;

  ylength = abs(y1-y2);
  if ((y1-y2)  < 0) dy = -1;
  if ((y1-y2) == 0) dy =  0;
  if ((y1-y2)  > 0) dy = +1;

  if (dy == 0) {
    if (dx < 0)
      for (x=x1; x<x2+1; x++)
	Putpixel (x,y1,col);
    if (dx > 0)
      for (x=x2; x<x1+1; x++)
	Putpixel (x,y1,col);
  }

  if (dx == 0) {
    if (dy < 0)
      for (y=y1; y<y2+1; y++)
	Putpixel (x1,y,col);
    if (dy > 0)
      for (y=y2; y<y1+1; y++)
	Putpixel (x1,y,col);
  }

  if ((xlength != 0) && (ylength != 0)) {
    xslope = (float)xlength/(float)ylength;
    yslope = (float)ylength/(float)xlength;
  }
  else {
    xslope = 0.0;
    yslope = 0.0;
  }

  if ((xslope != 0) && (yslope != 0) &&
      (yslope/xslope < 1) && (yslope/xslope > -1)) {
    if (dx < 0)
      for (x=x1; x<x2+1; x++) {
	y = round (yslope*x);
	Putpixel (x,y,col);
      }
    if (dx > 0)
      for (x=x2; x<x1+1; x++) {
	y = round (yslope*x);
	Putpixel (x,y,col);
      }
  }
  else {
    if (dy < 0)
      for (y=x1; y<x2+1; y++) {
	x = round (xslope*y);
	Putpixel (x,y,col);
      }
    if (dy > 0)
      for (y=x2; y<x1+1; y++) {
	x = round (xslope*y);
	Putpixel (x,y,col);
      }
  }

}

/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// Circle() - This draws a circle with center X,Y, with Rad as its radius. //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void Circle(int X, int Y, int rad, int col) {

  float deg = 0;

  do {
    X = round(rad * cos(deg));
    Y = round(rad * sin(deg));
    Putpixel (X+160, Y+100, col);
    deg += 0.005;
  }
  while (deg <= 6.4);

}

/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// WaitRetrace() - This waits until you are in a Verticle Retrace.         //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void WaitRetrace() {

  _DX = 0x03DA;

  l1: asm {
	in  al,dx;
	and al,0x08;
	jnz l1;
      }

  l2: asm {
	in  al,dx;
	and al,0x08;
	jz  l2;
      }
}
