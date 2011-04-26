Uses Crt,Mcga;
{$I C:\tp\Fonts.Fnt}  {Hand Drawn Font File Done By Fonted Ver 1.1}
Type
    Star = Record
         X,
         Y,           {Easiest Way To Create 300 Stars}
         Z : Integer;
end;


Var
   Stars : Array[1..300] Of Star;
   X,Y,Loop,Ypos,Ypos1 : Word;
   Pos : Array[1..300] Of Star;
   Time : Byte;

Procedure Setup;
Begin
     For Loop := 1 To 300 Do
     Begin
          Stars[Loop].X := Random(320)-160; {Values Of -160 To +160}
          Stars[Loop].Y := Random(200)-100; {Values Of -100 To +100}
          Stars[Loop].Z := Loop;
     end;
end;

Procedure Calc;
Begin
     For Loop := 1 To 300 Do
     Begin
          Pos[Loop].X := Stars[Loop].X * 100 Div Stars[Loop].Z+160;
          Pos[Loop].Y := Stars[Loop].Y * 100 Div Stars[Loop].Z+100;
     end;
end;

Procedure MoveStars;
Begin
     For Loop := 1 To 300 Do
     Begin
          Dec(Stars[Loop].Z,4);
          If Stars[Loop].Z < 1 Then Inc(Stars[Loop].Z,Loop+4);
     end;
end;

Procedure Border; {Draws 2 Lines}
Var Loop,Loop1,Col : Word;
Begin
         For Loop := 1 To 319 Do
         PutPixel(Loop,Ypos,100,VirAddr);

         For Loop := 1 To 319 Do
         PutPixel(Loop,Ypos1,100,VirAddr);

         {Slow But Not As Slow As Last Time - Just Draws A Line}
         {Instead Of Drawing Black Border To Line}
         {This Sets A Sort Of Drawing Window Frame}

         Flip;

end;

Procedure Logo;
Begin
     {Sloppy But Hey It Works}

     Inc(Time);
     If Time < 63 Then SetPal(1,0,0,Time);
     If Time < 63 Then PutMsg(78,70,'A STARFIELD');
     If Time = 63 Then SetPal(1,0,0,0);
     If (Time > 63) And (Time <126) Then PutMsg(78,138,'BY');
     If (Time > 63) And (Time < 126) Then SetPal(1,0,0,Time-62);
     If (Time > 126) And (Time <180) Then SetPal(1,0,0,Time-125);
     If (Time > 126) And (Time <280) Then PutMsg(78,64,'THE DARKMAN');
end;


Procedure DrawStars;
Begin
     For Loop := 1 To 300 Do
     Begin
          X := Pos[Loop].X;
          Y := Pos[Loop].Y;

          If (X>1) And (X<320) And (Y>1) And (Y<Ypos1) And (Y>Ypos) Then Begin
          {Only Draws Within The Current Ypos/Ypos1 Window}
          If Pos[Loop].X <1 Then Inc(Pos[Loop].X,160);
          If Pos[Loop].X > 320 Then Dec(Pos[Loop].X,160);
          If Pos[Loop].Y <1 Then Inc(Pos[Loop].Y,100);
          If Pos[Loop].Y >200 Then Dec(Pos[Loop].Y,100);
          {Different Star Shades}
          If Stars[Loop].Z > 400 Then PutPixel(X,Y,1,VirAddr) else
          If Stars[Loop].Z > 300 Then PutPixel(X,Y,2,VirAddr) else
          If Stars[Loop].Z > 200 Then PutPixel(X,Y,3,VirAddr) else
          If Stars[Loop].Z > 100 Then PutPixel(X,Y,4,VirAddr) else
          PutPixel(X,Y,5,VirAddr);
     end;
end;
     {Flip;}
end;

Begin
     Ypos := 100; Ypos1 := 100;
     ClrScr;
     Writeln('Darius Sutherland / The Darkman Presents A 3D StarField With Various Affects');
     Writeln('Main Coder - Darius The Darkman Sutherland');
     Writeln('GFX        - Darius The Darkman Sutherland');
     Writeln('Sound      - N/A');
     Writeln;
     Writeln('Old Versin      10 12.95');
     Writeln('Updated Version 22.12.95');
     Readkey;

     Gmode;
     setpal(100,40,50,60);
     {SetPal(1,5,5,15);} SetPal(2,10,10,20);
     SetPal(3,20,20,30); SetPal(4,30,30,50);
     SetPal(5,50,50,60);
     SetPal(1,0,0,0);

     Border;
     Delay(700);

     Setup;
     DrawStars;
     Calc;

     REPEAT
     Calc;
     If Time < 280 Then Logo;
     DrawStars;
     MoveStars;
     If Ypos > 10 Then Dec(Ypos,5);
     If Ypos1 < 190 Then Inc(Ypos1,5);
     Border;
     Clscr(0);
     UNTIL KeyPressed;

     REPEAT                                     {^Long Winded Way Of Doing It}
     Calc;
     If Ypos < 100 Then Inc(Ypos,6);
     If Ypos1 > 100 Then Dec(Ypos1,6);
     DrawStars;
     MoveStars;
     Border;
     Clscr(0);
     UNTIL Ypos >= 100;

     Tmode;
     Writeln('Greetz Go To : ');
     Writeln;
     Writeln('Mathew Nemesis Thomas');
     Writeln('Grant Smith / Denthor');
     Writeln('Alex Evans / Statix');
     Writeln;
     Writeln('Fonts Drawn By Darius Sutherland Using Fonted Beta Version By Him');
     Writeln('Fonted Should Be Available On Ftp.Cdrom.Com /Pub/Demos/Incoming');
end.


