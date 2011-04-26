{$A+,B-,D+,E+,F-,G+,I-,L+,N+,O-,P+,Q-,R-,S-,T-,V-,X+,Y+}
{$M 16384,0,655360}

{

Hi guys, try this, use it in your code, but please credit

Frank Jan Sorensen Alias:Frank Patxi (fjs@lab.jt.dk) for the
fireroutine.

}


Program Burn;
uses
  Dos,Crt;

Const
  RootRand     =  20;   { Max/Min decrease of the root of the flames }
  Decay        =  10;   { How far should the flames go up on the screen? }
  MinY         = 100;   { Startingline of the flame routine.
                          (should be adjusted along with MinY above) }
  Smooth       =   1;   { How descrete can the flames be?}
  MinFire      =  50;   { limit between the "starting to burn" and
                          the "is burning" routines }
  XStart       =  90;   { Startingpos on the screen }
  XEnd         = 210;   { Guess! }
  Width        = XEnd-XStart; {Well- }
  MaxColor     = 110;   { Constant for the MakePal procedure }
  FireIncrease : Byte =   3;  {3 = Wood, 90 = Gazolin}

Var
  Scr : Array[0..199,0..319] Of Byte Absolute $A000:$0000;

Type
  ColorValue     = record
                     R, G, B : byte;
                   end;
  VGAPaletteType = array[0..255] of ColorValue;


procedure ReadPal(var Pal);
var
  K    : VGAPaletteType Absolute Pal;
  Regs : Registers;
begin
  with Regs do
  begin
    AX := $1017;
    BX := 0;
    CX := 256;
    ES := Seg(K);
    DX := Ofs(K);
    Repeat Until Port[$03DA] And $08 = $08; {Wait for rescan}
    Intr($10,Regs);
  end;
end;

procedure WritePal(var Pal);
Var
  K : VGAPaletteType Absolute Pal;
  Regs : Registers;
begin
  with Regs do
  begin
    AX := $1012;
    BX := 0;
    CX := 256;
    ES := Seg(K);
    DX := Ofs(K);
    Repeat Until Port[$03DA] And $08 = $08; {Wait for rescan}
    Intr($10,Regs);
  end;
end;

Procedure Hsi2Rgb(H, S, I : Real; var C : ColorValue);
{Convert (Hue, Saturation, Intensity) -> (RGB)}
var
  T : Real;
  Rv, Gv, Bv : Real;
begin
  T := H;
  Rv := 1 + S * Sin(T - 2 * Pi / 3);
  Gv := 1 + S * Sin(T);
  Bv := 1 + S * Sin(T + 2 * Pi / 3);
  T := 63.999 * I / 2;
  with C do
  begin
    R := trunc(Rv * T);
    G := trunc(Gv * T);
    B := trunc(Bv * T);
  end;
end; { Hsi2Rgb }

{ Faster put'n get pixel routines!  }

procedure put(x,y : integer; c : byte); assembler;
{ Written by Matt Sottile }
 asm
  mov ax,y
  mov bx,ax
  shl ax,8
  shl bx,6
  add bx,ax
  add bx,x
  mov ax,0a000h
  mov es,ax
  mov al,c
  mov es:[bx],al
 end;

Function get(x,y : integer):byte;
{ Put Modified by me }
begin
 asm
  mov ax,y
  mov bx,ax
  shl ax,8
  shl bx,6
  add bx,ax
  add bx,x
  mov ax,0a000h
  mov es,ax
  mov al,es:[bx]
  mov @result,al
 end;
end;

Procedure MakePal;
Var
  I : Byte;
  Pal   : VGAPaletteType;

begin
  FillChar(Pal,SizeOf(Pal),0);
  For I:=1 To MaxColor Do
    HSI2RGB(4.6-1.5*I/MaxColor,I/MaxColor,I/MaxColor,Pal[I]);
  For I:=MaxColor To 255 Do
  begin
    Pal[I]:=Pal[I-1];
    With Pal[I] Do
    begin
      If R<63 Then Inc(R);
      If R<63 Then Inc(R);
      If (I Mod 2=0) And (G<53)  Then Inc(G);
      If (I Mod 2=0) And (B<63) Then Inc(B);
    end;
  end;

  WritePal(Pal);

end;


Function Rand(R:Integer):Integer;{ Return a random number between -R And R}
begin
  Rand:=Random(R*2+1)-R;
end;

Procedure Help;
Var
  Mode : Byte;
  R    : Registers;
begin
  R.Ax:=$0F00;
  Intr($10,R);
  Mode:=R.Al;
  R.Ax:=$0003;  {TextMode}
  Intr($10,R);

  ClrScr;
  WriteLn('Burn version 1.00');
  WriteLn;
  WriteLn('Light''n''play');
  WriteLn;
  WriteLn('Keys : ');
  WriteLn('<space> : Throw in a match');
  WriteLn('<W>     : Water');
  WriteLn('<+>     : Increase intensity');
  WriteLn('<->     : Decrease intensity');
  WriteLn('<C>     : Initialize fire');
  WriteLn('<1>..<9>: Burnability (1=Wood, 9=Gaz)');
  WriteLn('<?>     : This help');
  WriteLn;
  Write('Hit any key kid >');
  ReadKey;
  R.Ax:=$0000+Mode;
  Intr($10,R);
  If Mode = $13 Then MakePal;
end;

Var
  FlameArray : Array[XStart..XEnd] Of Byte;
  LastMode : Byte;
  I,J : Integer;
  X,P : Integer;
  MoreFire,
  V   : Integer;
  R   : Registers;
  Ch  : Char;
begin

  Help;
  RandomIze;
  R.Ax:=$0F00;
  Intr($10,R);
  LastMode:=R.Al;
  R.Ax:=$0013;
  Intr($10,R);

  MoreFire:=1;
  MakePal;

{
  (* Use this if you want to view the palette *)
  For I:=0 To 255 Do
  For J:=0 To 20 Do
    Put(I,J,I);
  ReadKey;
{}
  { Initialize FlameArray }
  For I:=XStart To XEnd Do
    FlameArray[I]:=0;

  FillChar(Scr,SizeOf(Scr),0); { Clear Screen }

  repeat
    If KeyPressed Then Ch:=ReadKey Else Ch:='.'; {'.' = Nothing (Dummy)}

    While KeyPressed Do ReadKey;  { Empty Keyboard buffer }

    { Put the values from FlameArray on the bottom line of the screen }
    For I:=XStart To XEnd Do
      Put(I,199,FlameArray[I]);

    { This loop makes the actual flames }

    For I:=XStart To XEnd Do
    For J:=MinY To 199 Do
    begin
      V:=Get(I,J);
      If (V=0) Or
         (V<Decay) Or
         (I<=XStart) Or
         (I>=XEnd) Then
        Put(I,Pred(J),0)
      else
        Put(I-Pred(Random(3)),Pred(J),V-Random(Decay));
    end;

    {Match?}
    If (Random(150)=0) Or (Ch=' ') Then
      FillChar(FlameArray[XStart+Random(XEnd-XStart-5)],5,255);

    {In-/Decrease?}
    If (Ch='-') Then If MoreFire >-2 Then Dec(MoreFire);
    If (Ch='+') Then If MoreFire < 4 Then Inc(MoreFire);

    {!!}
    If UpCase(Ch) = 'C' Then FillChar(FlameArray,SizeOf(FlameArray),0);
    If UpCase(Ch) = 'W' Then
      for I:=1 To 10 Do FlameArray[XStart+Random(Width)]:=0;

    If Ch = '?' Then Help;

    if Ch in ['1'..'9'] Then FireIncrease:=3+Sqr(Ord(Ch)-Ord('1'));

    {This loop controls the "root" of the
     flames ie. the values in FlameArray.}
    For I:=XStart To XEnd Do
    begin
      X:=FlameArray[I];

      If X<MinFire Then { Increase by the "burnability"}
      begin
        {Starting to burn:}
        If X>10 Then Inc(X,Random(FireIncrease));
      end
      else
      { Otherwise randomize and increase by intensity (is burning)}
        Inc(X,Rand(RootRand)+MoreFire);
      If X>255 Then X:=255; { X Too large ?}
      FlameArray[I]:=X;
    end;


    { Pour a little water on both sides of
      the fire to make it look nice on the sides}
    For I:=1 To Width Div 8 Do
    begin
      X:=Trunc(Sqr(Random)*Width/8);
      FlameArray[XStart+X]:=0;
      FlameArray[XEnd-X]:=0;
    end;

    {Smoothen the values of FrameArray to avoid "descrete" flames}
    P:=0;
    For I:=XStart+Smooth To XEnd-Smooth Do
    begin
      X:=0;
      For J:=-Smooth To Smooth Do Inc(X,FlameArray[I+J]);
      FlameArray[I]:=X Div (2*Smooth+1);
    end;
  Until Ch=#27;
  {Restore video mode}
  R.Ax:=$0000+LastMode;
  Intr($10,R);
  {Good bye}
end.