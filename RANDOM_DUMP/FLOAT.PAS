PROGRAM Convert2Float;

Uses
    Crt;

Var
   decimalin : real;
   floatout  : integer;
   Mantissa: REAL;
   Exponent, Sign, IntegerMantissa: INTEGER;

PROCEDURE StandardizeNumber;
Begin
     Mantissa := ABS(mantissa);

     While Mantissa >= 1.00 do
     Begin
          Mantissa := Mantissa/10.0;
          Exponent := Exponent +1;
     end;
     While Mantissa < 0.1 do
     Begin
          Mantissa := Mantissa *10.0;
          Exponent := Exponent - 1;
     end;
     Integermantissa := round (10000.0 * mantissa)
end;

Begin
  asm
     mov        ah,0fh
     int        10h
     xor        ah,ah
     int        10h
  end;
  write('Input integer :');
  readln (decimalin);
  if decimalin = 0.0 then floatout := 0
  ELSE Begin
       If Decimalin > 0.0 then Sign := 0
       ELSE sign := 5000;
       Exponent := 50;
       StandardizeNumber;
       Floatout := Sign + Exponent * 100000 + Integermantissa
  end;
  write (Floatout);
End.