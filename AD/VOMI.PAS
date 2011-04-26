{
 Want comments? write 'em.

 n1921380@student.fit.qut.edu.au
}
{$G+}

USES Dos;

TYPE RGBType = Record
               R, G, B : Byte;
            End;
     PalType = Array[0..255] of RGBType;
VAR
   reg : Registers;
   bob:paltype;  { Two pallettes, current and temporary }
FUNCTION GetKey: WORD;
BEGIN
   reg.AH := 0;
   Intr($16, reg);
   GetKey := reg.AX
END;

FUNCTION TestKey: BOOLEAN;
BEGIN
   reg.AH := 1;
   Intr($16, reg);
   TestKey := (reg.Flags AND FZero) = 0
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure PAL(Col,R,G,B : Byte); assembler;
   { This sets the Red, Green and Blue values of a certain color }
asm
   mov    dx,3c8h
   mov    al,[col]
   out    dx,al
   inc    dx
   mov    al,[r]
   out    dx,al
   mov    al,[g]
   out    dx,al
   mov    al,[b]
   out    dx,al
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetAllPal(Var Palette : PalType); Assembler;
  { This dumps the pallette in our variable onto the screen, fast }
Asm
   push   ds
   lds    si, Palette
   mov    dx, 3c8h
   mov    al, 0
   out    dx, al
   inc    dx
   mov    cx, 768
   rep    outsb
   pop    ds
End;

Function rad (theta : real) : real; { Converts degrees to radians }
  BEGIN
    rad := theta * pi / 180
  END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure init;
VAR loop1,loop2,r,g,b:integer;
    f:text;
    ch:char;
BEGIN
    for loop1:=1 to 128 do BEGIN
      bob[loop1].r:=0;
      bob[loop1].g:=loop1 div 4;
      bob[loop1].b:=loop1 div 4;
    END;
    for loop1:=129 to 255 do BEGIN
      bob[loop1].r:=0;
      bob[loop1].g:=63-loop1 div 4;
      bob[loop1].b:=63-loop1 div 4;
    end;
    setallpal (bob);
END;

PROCEDURE VSync;
BEGIN
   WHILE (Port[$3DA] AND 8) =  8 DO;
   WHILE (Port[$3DA] AND 8) <> 8 DO;
END;

  (* -------------------- *)

TYPE
   tScrBuf = ARRAY [0..200-1,0..320-1] OF BYTE;
   tScrWBuf = ARRAY [0..200-1,0..160-1] OF WORD;
VAR
   VGABuf : TScrBuf ABSOLUTE $A000:0000;
   VGAWBuf : TScrWBuf ABSOLUTE $A000:0000;

VAR
   i, j, k, n : INTEGER;   { Shitty global vars. This is just a prototype! }
   r, d, v, a : REAL;
   c, lasth, limit : WORD;
   highest : ARRAY [0..159] OF BYTE;

TYPE
   TWavBuf = ARRAY [0..63, 0..127] OF BYTE;
   TLandBuf = ARRAY [0..31, 0..159] OF BYTE;

VAR
   Wb : TWavBuf;
   fw : FILE OF TWavBuf;
   lb : TLandBuf;
   fl : FILE OF TLandBuf;

CONST
   MaxRadius = 159.0*159.0 + 31.0*31.0;
   s159       = 159.0*159.0;
   s31       = 31.0*31.0;

PROCEDURE GenerateLand;
   BEGIN
     FOR i := 0 TO 31 DO
        FOR j := 0 TO 159 DO BEGIN
           lb[i,j] := ROUND(SQRT((i+0.0)*i/s31 + (j+0.0)*j/s159)*160/SQRT(2));
           IF lb[i,j] > 127 THEN
              lb[i,j] := 127
        END;
     Assign(fl, 'land.dat');             { Escritura de la tabla. }
     ReWrite(fl);
     Write(fl, lb);
     Close(fl)
   END;

PROCEDURE GenerateWav;
  BEGIN
    FOR j := 0 TO 63 DO                  { Generacion de la tabla. }
        FOR i := 0 TO 127{319} DO BEGIN
           r := (i+1) * 5.0 * PI / 320.0;
           d := j * PI / 32.0;
           v := ((sin(r - d)-Sin(-d)) / r )
                - (cos(r-d)/2);
           a := Cos(i*PI/2/128);
           k := 100 + ROUND(100.0 * a * a * v);
           Wb[j, i] := BYTE(k);
           VGABuf[k,i] := 150 + j
        END;
     Assign(fw, 'waves.dat');            { Grabaci줻 de la tabla. }
     ReWrite(fw);
     Write(fw, wb);
     Close(fw)
  END;

VAR
   par, pcod : INTEGER;

BEGIN
      ASM
         MOV AX,13h
         INT 10h
      END;

   Assign(fl, 'land.dat');             { Lectura de la tabla. }
   ReSet(fl);
   Read(fl, lb);
   Close(fl);

   Assign(fw, 'waves.dat');             { Lectura de la tabla. }
   ReSet(fw);
   Read(fw, wb);
   Close(fw);
   FillChar(VGABuf,  32000, 0);
   FillChar(highest, 160, 199);

   WHILE TestKey DO
      GetKey;

   ASM
      MOV  CX,64
      MOV  DX,03C8h
      MOV  AL,64
      OUT  DX,AL
      INC  DX
      XOR  AL,AL
     @@l:
       OUT DX,AL
       OUT DX,AL
       OUT DX,AL
       INC AL
       LOOP @@l
   END;
   init;
   k := 0;
   REPEAT
      n := (k + 1) MOD 64;
      FOR j := 0 TO 159 DO BEGIN
         c := 0+80;
         lasth := 199;
         FOR i := 31 DOWNTO 0 DO BEGIN
            limit := 65+i+Wb[n,Lb[i,j]];
            WHILE lasth > limit DO BEGIN
               VGABuf[lasth,j+160] := c;
               VGABuf[lasth,159-j] := c;
               DEC(lasth)
            END;
            DEC(c)
         END;
         FOR i := 0 TO 31 DO BEGIN
            limit := 55-i+Wb[n,Lb[i,j]];
            WHILE lasth > limit DO BEGIN
               VGABuf[lasth,j+160] := c;
               VGABuf[lasth,159-j] := c;
               DEC(lasth)
            END;
            DEC(c)
         END;
         FOR i := lasth DOWNTO highest[j] DO BEGIN
            VGABuf[i, j+160] := 0;
            VGABuf[i, 159-j] := 0
         END;
         highest[j] := lasth
      END;
      VSync;
      k := n
   UNTIL TestKey;

   GetKey;
   ASM
      MOV AX,3h
      INT 10h
   END
END.
