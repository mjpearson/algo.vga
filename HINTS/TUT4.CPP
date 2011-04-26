/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// TUTPROG4.CPP - VGA Trainer Program 4 (in Turbo C++ 3.0)                 //
//                                                                         //
// "The VGA Trainer Program" is written by Denthor of Asphyxia. However it //
// was limited to Pascal only in its first run.  All I have done is taken  //
// his original release, translated it to C++ and touched up a few things. //
// I take absolutely no credit for the concepts presented in this code and //
// am NOT the person to ask for help if you are having trouble.            //
//                                                                         //
// Program Notes : This program implements virtual screens, a great way    //
//                 to update your screen.                                  //
//                                                                         //
//                 For this particular program, I have found the compiler  //
//                 option -mc (Compact memory model) to work better than   //
//                 -ml (Large memory model).  However, you must use -mc or //
//                 greater.                                                //
//                 Also, you might want to go under "Options...Debugger"   //
//                 and increase your programs Heap size to >64k.  I don't  //
//                 know if <64k will lock your system, but I had problems. //
//                                                                         //
// Author        : Grant Smith (Denthor) - denthor@beastie.cs.und.ac.za    //
// Translator    : Christopher G. Mann   - r3cgm@dax.cc.uakron.edu         //
//                                                                         //
// Last Modified : December 23, 1994                                       //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

//               //
// INCLUDE FILES //
//               //

  #include <conio.h>
			   // clrscr(), getch(), kbhit()
  #include <dos.h>
			   // MK_FP, geninterrupt()
  #include <iostream.h>
			   // _fmemset(), cout, memset(), _fmemcpy()
  #include <stdlib.h>
			   // calloc(), exit(), free()

//                     //
// FUNCTION PROTOTYPES //
//                     //

  // MODE SETTING FUNCTIONS
  void SetMCGA();
  void SetText();

  // VIRTUAL SCREEN FUNCTIONS
  void SetUpVirtual();
  void ShutDown();
  void Flip();

  // UTILITY FUNCTIONS
  void Cls(unsigned char Col, unsigned char *Where);
  void Putpixel (int x, int y, unsigned char Col, unsigned int Where);
  void WaitRetrace();

  // MID-LEVEL FUNCTIONS
  void BlockMove();
  void PatternDraw();

//                              //
// GLOBAL VARIABLE DECLARATIONS //
//                              //

  // declare a pointer to the offset of the Virtual Screen
  unsigned char *vaddr = NULL;

  // declare a pointer to the offset of the VGA memory
  unsigned char *vga = (unsigned char *) MK_FP(0xA000, 0);

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                MAIN FUNCTION                              //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

void main() {

  clrscr();
  cout
    << "This program will demonstrate the power of virtual screens.\n"
    << "A block will firstly move across the screen, being drawn and\n"
    << "erased totally on the VGA. Then the same block will move\n"
    << "across, but will be drawn on the virtual screen and flipped\n"
    << "to the VGA screen without a retrace (see part 2). The the\n"
    << "block will go again, with flipping and a retrace.\n\n"
    << "I will then draw a pattern, flip it to VGA, draw another\n"
    << "pattern, flip it to VGA, and repeat that until a key is pressed.\n"
    << "This will demonstrate that even when I put down 10000 pixels,\n"
    << "then flip them to the VGA, it is still relatively fast.\n\n";
  cout << "Hit any key to continue ...";
  getch();
  SetMCGA();
  SetUpVirtual();
  Cls(0,vaddr);    // After you have got the memory for the virtual screen,
		   // it is usually filled with random garbage. It is always
		   // wise to clear the virtual screen directly afterwards
  BlockMove();

  do    PatternDraw();
  while (!kbhit());
  getch();         // getch() = clear keyboard buffer from kbhit()

  SetText();
  ShutDown();
  cout
    << "All done. This concludes the fourth sample program in the ASPHYXIA\n"
    << "Training series. You may reach DENTHOR under the name of GRANT\n"
    << "SMITH on the MailBox BBS, or leave a message to ASPHYXIA on the\n"
    << "ASPHYXIA BBS. Get the numbers from Roblist, or write to :\n"
    << "             Grant Smith\n"
    << "             P.O. Box 270\n"
    << "             Kloof\n"
    << "             3640\n"
    << "I hope to hear from you soon!\n\n";
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
// Cls() - This clears the screen to the specified color, on the VGA or on //
//         the Virtual screen.                                             //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void Cls(unsigned char Col, unsigned char *Where) {
  _fmemset(Where, Col, 64000);
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


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// SetUpVirtual() - This sets up the memory needed for the virtual screen. //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void SetUpVirtual() {

  vaddr = (unsigned char *) calloc(64000,1);
  if (vaddr == NULL) {
    SetText();
    cout << "Not enough memory available, exiting program...";
    exit(1);
  }
}


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// ShutDown() - This frees the memory used by the virtual screen.          //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void ShutDown() {
  free(vaddr);
}


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// Putpixel() - This puts a pixel at X,Y using color Col, on VGA or the    //
//              Virtual Screen;                                            //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void Putpixel (int x, int y, unsigned char Col, unsigned char *Where) {
  memset(Where+(x+(y*320)),Col,1);
}


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// Flip() - This flips the virtual screen to the VGA screen.               //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void Flip() {
  _fmemcpy(vga,vaddr,64000);
}


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// BlockMove() - This tests various ways of moving a block around the      //
//               screen.                                                   //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void BlockMove() {

  int loop1, loop2, loop3;

  // This draws a block directly to the VGA with no flipping
  for (loop1=1; loop1<51; loop1++) {
    for (loop2=1; loop2<51; loop2++)
      for (loop3=1; loop3<51; loop3++)
	Putpixel (loop1+loop2,loop3,32, vga);
    Cls(0,vga);
  }

  // This draws a block to the virtual screen, then flips it to the VGA
  for (loop1=1; loop1<51; loop1++) {
    for (loop2=1; loop2<51; loop2++)
      for (loop3=1; loop3<51; loop3++)
	Putpixel (loop1+loop2,loop3,32, vaddr);
    Flip();
    Cls(0,vaddr);
  }

  // This draws to the virtual screen, waits for retrace, then flips to VGA
  for (loop1=1; loop1<51; loop1++) {
    for (loop2=1; loop2<51; loop2++)
      for (loop3=1; loop3<51; loop3++)
	Putpixel (loop1+loop2,loop3,32, vaddr);
    WaitRetrace();
    Flip();
    Cls(0,vaddr);
  }

}


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// PatternDraw() - This tests the speed of flipping by drawing two         //
//                 patterns and flipping them.                             //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

void PatternDraw() {

  int loop1, loop2;

  // This draws pattern #1 to the virtual screen, then flips it to VGA
  for(loop1=1; loop1<101; loop1++)
    for(loop2=1; loop2<101; loop2++)
	Putpixel (loop1,loop2,loop1,vaddr);
  Flip();

  // This draws pattern #2 to the virtual screen, then flips it to VGA
  for(loop1=1; loop1<101; loop1++)
    for(loop2=1; loop2<101; loop2++)
	Putpixel (loop1,loop2,loop2,vaddr);
  Flip();

}
