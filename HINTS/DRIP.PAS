{$G+}
program Drip;

uses Crt;

{This sets the display to VGA 320x200 in 256 colours}
procedure VGAScreen; assembler;
asm
  mov ax, $13
  int $10
end;

{This resets the display to text mode}
procedure TextScreen; assembler;
asm
  mov ax, $3
  int $10
end;

{This sets a DAC register to a specific Red Green Blue-value}
procedure SetDAC (DAC, R, G, B : Byte);
begin
  Port [$3C8] := DAC;
  Port [$3C9] := R;
  Port [$3C9] := G;
  Port [$3C9] := B;
end;

{Sets a pixel to a specific colour}
procedure PutPixel (x, y : Word; c : Byte);
begin
  Mem [$A000 : y shl 8 + y shl 6 + x] := c;
end;


{This sets up a nice blue palette - am I obsessed with blue?}
procedure BluePalette;
var
  DAC : Byte;

begin
  for DAC := 1 to 255 do
    SetDAC (DAC,
            DAC shr 3,
            DAC shr 3,
            32 + DAC shr 3);
end;

{This rotates the palette}
procedure RotatePal;
var
  DAC, OffSet : Byte;

begin
  repeat
    {Set up the new colours}
    for DAC := 0 to 255 do
      {don't change colour 0 or the screen border would flash}
      if byte(DAC + OffSet) <> 0 then
        SetDAC (byte (DAC + OffSet), DAC shr 3, DAC shr 3, 32 + DAC shr 3);
    {Move on to the next frame}
    inc (OffSet);
  until KeyPressed;
end;

{This makes the pattern used for the "rain"}
procedure MakeDrip;
var
  x, y, r, s : Word;

begin
  for x := 0 to 319 do begin
    {For each column on screen, choose a different starting point...}
    r := Random (255) shl 8;
    {...and speed}
    s := (128 + Random (128)) shl 3;
    for y := 0 to 199 do begin
      {Set each pixel on the column, don't use colour 0}
      if hi (r) = 0 then
        PutPixel (x, y, 1)
      else
        PutPixel (x, y, hi (r));
      {Move on to the next colour}
      inc (r, s);
    end;
  end;
end;

begin
  {Switch to graphics mode}
  VGAScreen;

  {Set up a nice, blue palette}
  BluePalette;

  {Initialize random number generator}
  Randomize;

  {Make the pattern}
  MakeDrip;

  {Rotate the palette}
  RotatePal;

  {Switch back to text mode}
  TextScreen;
end.