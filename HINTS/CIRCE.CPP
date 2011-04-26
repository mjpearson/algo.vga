  #include <conio.h>
			  // getch(), clrscr(), kbhit()
  #include <math.h>
			  // floor(), ceil(), abs(), sin(), cos()
void putpixel (int  x, int  y, unsigned int Col);
void line     (int  a, int  b, int   c, int  d, int col);

float x,y,z,xt,yt,zt;
float Xan,Yan,Zan;
int   count,sx,sy;
unsigned char _far *vidmem = (unsigned char _far *)0xA0000000;
int  round  (long a);
int  sgn    (long a);
void putpixel (int x, int y, unsigned int Col) {
*(vidmem + (x+y*320)) = Col;
}

void _mode13_(void) {
 asm { mov ax,0013h
       int 10h }
}

void _mode03_(void) {
 asm { mov ax,0003h
       int 10h }
}

void Waitvr (void) {
  asm mov dx,03dh
asm {@@100:
     in  al,dx;
     and al,0x08;
     jnz @@100;
    }
asm {@@200:
     in  al,dx;
     and al,08h;
     jnz @@200;
    }
}

int sgn (long a) {
  if (a > 0) return +1;
  else if (a < 0) return -1;
  else return 0;

}
int round (long a) {
  if ( (a - (int)a) < 0.5) return floor(a);
    else return ceil(a);
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
    putpixel(a,b,col);       // plot a pixel at the original x1, y1
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

main()
{
 int k;
 _mode13_();
 Zan =  0.5;
 Yan =  0.1;
 Xan =  0.1;

 x=10;
 y=20;
 z=20;

while (!kbhit()) {
  Line(10,10,sx,sy,0);
  putpixel(sx,sy,0);
  yt= y * cos(Xan) - z * sin(Xan);
  zt= y * sin(Xan) + z * cos(Xan);
  y= yt;
  z= zt;
  xt= x * cos(Yan) - z * sin(Xan);
  zt= x * sin(Yan) + z * cos(Xan);
  x= xt;
  z= zt;
  xt= x * cos(Zan) - y * sin(Zan);
  yt= x * sin(Zan) + y * cos(Zan);
  x= xt;
  y= yt;
  sx=round(x)+160;
  sy=round(y)+100;
  putpixel(sx,sy,10);
  Line(10,10,sx,sy,10);
  Waitvr;
  for (k=0;k<10000;k++);
}
  getch();
 _mode03_();
return(0);
}
