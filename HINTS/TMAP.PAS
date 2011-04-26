program TextureMapping;

uses Crt;

type
  {This is the type used to store a texture. We use 64x64 textures for this
  demo}
  BitMap = Array [0..63, 0..63] of Byte;
  BitMapPtr = ^BitMap;

{Switches to VGA 320x200 256 colour}
procedure VGAScreen; assembler;
asm
  mov ax, $13
  int $10
end;

{Switches to text 80x25}
procedure TextScreen; assembler;
asm
  mov ax, $3
  int $10
end;

{Sets a on the screen to a specific colour}
procedure PutPixel (x, y : Word; c : Byte);
begin
  if (x < 320) and (y < 200) then
    Mem [$A000:y shl 8 + y shl 6 + x] := c;
end;

{This draws one scanline of the textured polygon, it expects start- and
endpoints of a horizontal line and two sets of texture coordinates. It
interpolates between them. The coordinates must be in 6:16 bit precision.
(that means, the real coordinates, with a range of 0..63, shifted 16 bits to
the left).}
procedure DrawTLine (x1, x2, y : Integer; u1, v1, u2, v2 : LongInt; Sprite : BitmapPtr);
var
  x, dx, du, dv, u, v, tu, tv : LongInt;

begin
  {Calculate the length of the line}
  dx := x2 - x1;

  {Start at the first set of texture coordinates}
  u := u1;
  v := v1;

  {Calculate the difference in the two sets of coordinates}
  du := u2 - u1;
  dv := v2 - v1;

  {If the length of the scan line is longer than 0, we can calculate the
  slope. We use this to interpolate between the first and second sets of
  texture coordinates}
  if dx > 0 then begin
    du := du div dx;
    dv := dv div dx;
  end;

  {Then, we process every pixel on the scan line}
  for x := x1 to x2 do begin
    {As we use 6:16 bit precision, we have to compensate this to get the
    real texture coordinates}
    tu := u shr 16;
    tv := v shr 16;

    {Display the correct texel (=textured pixel)}
    PutPixel (x, y, Sprite^ [tu, tv]);

    {Move on to the next set of coordinates}
    inc (u, du);
    inc (v, dv);
  end;
end;

{This is the main procedure of the texture mapping function. It interpolates
between the vertices/sides of the polygon. It gives us the start- and
endpoints of the scanlines and the appropriate texture coordinates.
The input consists of four vertices forming a four-sided polygon. Because
we work on a scanline basis, there may be no more than 2 intersection of a
scanline with a side of a polygon.}
procedure TextureMap (x1, y1, x2, y2, x3, y3, x4, y4 : LongInt; Sprite : BitmapPtr);
{Note: the sides and vertices 1, 2, 3 and 4 are arranged as follows:

          side 1
    1----------------2
    |                |
  s |  +------- u    | s
  i |  |             | i
  d |  |             | d
  e |  |             | e
    |  |             |
  4 |  v             | 2
    |                |
    4----------------3
          side 3

The texture will be mapped onto the polygon accordingly, the texture
coordinates running as shown above.}
var
  x, y, u, v,
  minx, miny, minu, minv,
  maxx, maxy, maxu, maxv,
  tx1, tx2, tx3, tx4, dx1, dx2, dx3, dx4,
  dy1, dy2, dy3, dy4,
  u1, u2, u3, u4, du1, du2, du3, du4,
  v1, v2, v3, v4, dv1, dv2, dv3, dv4 : LongInt;

{This constant is used to get the maximum offset into the texture. Since
we use 64x64 textures, the maximum offset is 63, which is shifted left by 16
bits to gain accuracy. Note: We do this for all our coordinates!!}
const
  Max = 63 shl 16;

begin
  {Assume extremes}
  miny := MaxLongInt;
  maxy := -MaxLongInt;

  {Find minimum and maximum y coordinates}
  if y1 < miny then miny := y1; if y1 > maxy then maxy := y1;
  if y2 < miny then miny := y2; if y2 > maxy then maxy := y2;
  if y3 < miny then miny := y3; if y3 > maxy then maxy := y3;
  if y4 < miny then miny := y4; if y4 > maxy then maxy := y4;

  {Calculate delta y and delta x for first side}
  dy1 := y2 - y1; dx1 := x2 - x1;
  {If the line is not horizontal, a slope can be calculated}
  if dy1 <> 0 then begin
    {Calculate how the x coordinate should change when moving one pixel down}
    dx1 := (dx1 shl 16) div dy1;
    {Calculate how the texture coordinates should change}
    {NOTE: Moving to the right in the bitmap, from vertex 1 to 2
      (du is positive, dv is zero)}
    du1 := (64 shl 16) div dy1;
    dv1 := 0;
  end;

  {Do the same for the other three sides}
  dy2 := y3 - y2; dx2 := x3 - x2;
  if dy2 <> 0 then begin
    dx2 := (dx2 shl 16) div dy2;
    {NOTE: Moving downwards in the bitmap, from vertex 2 to 3
      (du is zero, dv is positive)}
    du2 := 0;
    dv2 := (64 shl 16) div dy2;
  end;

  dy3 := y4 - y3; dx3 := x4 - x3;
  if dy3 <> 0 then begin
    dx3 := (dx3 shl 16) div dy3;
    {NOTE: Moving to the left in the bitmap, from vertex 3 to 4
      (du is negative, dv is zero)}
    du3 := -(64 shl 16) div dy3;
    dv3 := 0;
  end;

  dy4 := y1 - y4; dx4 := x1 - x4;
  if dy4 <> 0 then begin
    dx4 := (dx4 shl 16) div dy4;
    {NOTE: Moving upwards in the bitmap, from vertex 2 to 3
      (du is zero, dv is negative)}
    du4 := 0;
    dv4 := -(64 shl 16) div dy4;
  end;

  {Check to see whether vertex 2 is the topmost vertex of the first side}
  if y2 < y1 then begin
    {If so, start at the coordinates of vertex 2}
    u1 := Max; v1 := 0; tx1 := x2;
  end else begin
    {Otherwise, start at vertex 1}
    u1 := 0; v1 := 0;  tx1 := x1;
  end;

  {Do the same for the other sides}
  if y3 < y2 then begin
    u2 := Max; v2 := Max; tx2 := x3;
  end else begin
    u2 := Max; v2 := 0;  tx2 := x2;
  end;

  if y4 < y3 then begin
    u3 := 0; v3 := Max; tx3 := x4;
  end else begin
    u3 := Max; v3 := Max; tx3 := x3;
  end;

  if y1 < y4 then begin
    u4 := 0; v4 := 0; tx4 := x1;
  end else begin
    u4 := 0; v4 := Max; tx4 := x4;
  end;

  {Now shift the coordinates left 16 bits to gain accuracy}
  tx1 := tx1 shl 16;
  tx2 := tx2 shl 16;
  tx3 := tx3 shl 16;
  tx4 := tx4 shl 16;

  {Here we start interpolation. The following subroutine processes all the
  scan lines in the polygon}
  for y := miny to maxy do begin

    {Assume extremes}
    minx := MaxLongInt;
    maxx := -MaxLongInt;

    {Check whether y is a valid value for the first side}
    if (y >= y1) or (y >= y2) then begin
      if (y <= y1) or (y <= y2) then begin
        if tx1 < minx then begin
          {If necessary, adjust the start point of the scan line and store
          appropriate texture coordinates.}
          minx := tx1;
          minu := u1;
          minv := v1;
        end;
        if tx1 > maxx then begin
          {If necessary, adjust the end point of the scan line and store
          appropriate texture coordinates.}
          maxx := tx1;
          maxu := u1;
          maxv := v1;
        end;
        {Move on to the next pixel on this side}
        inc (tx1, dx1);
        {And its texture coordinates}
        inc (u1, du1);
        inc (v1, dv1);
      end;
    end;

    {Process the other lines in the same manner}
    if (y >= y2) or (y >= y3) then begin
      if (y <= y2) or (y <= y3) then begin
        if tx2 < minx then begin
          minx := tx2;
          minu := u2;
          minv := v2;
        end;
        if tx2 > maxx then begin
          maxx := tx2;
          maxu := u2;
          maxv := v2;
        end;
        inc (tx2, dx2);
        inc (u2, du2);
        inc (v2, dv2);
      end;
    end;

    if (y >= y3) or (y >= y4) then begin
      if (y <= y3) or (y <= y4) then begin
        if tx3 < minx then begin
          minx := tx3;
          minu := u3;
          minv := v3;
        end;
        if tx3 > maxx then begin
          maxx := tx3;
          maxu := u3;
          maxv := v3;
        end;
        inc (tx3, dx3);
        inc (u3, du3);
        inc (v3, dv3);
      end;
    end;

    if (y >= y4) or (y >= y1) then begin
      if (y <= y4) or (y <= y1) then begin
        if tx4 < minx then begin
          minx := tx4;
          minu := u4;
          minv := v4;
        end;
        if tx4 > maxx then begin
          maxx := tx4;
          maxu := u4;
          maxv := v4;
        end;
        inc (tx4, dx4);
        inc (u4, du4);
        inc (v4, dv4);
      end;
    end;

    {Now that we have the start and endpoints, Their extra precision should
    be removed. It is no longer needed. The texture coordinates, however
    shouldn't yet be changed since the "DrawTLine" function still has to
    interpolate between them}
    minx := minx shr 16;
    maxx := maxx shr 16;
    {And here we draw the line}
    DrawTLine (minx, maxx, y, minu, minv, maxu, maxv, Sprite);
  end;
end;

var
  Texture : BitMapPtr;
  p, q, c : Byte;

begin
  {Switch to VGA 320x200 256 colour}
  VGAScreen;
  {Create a new texture}
  New (Texture);
  {Fill it with a pattern and display the same pattern on the top left
  of the screen so you can see how it is mapped}
  for p := 0 to 63 do
    for q := 0 to 63 do begin
      c := ((q shr 2) shl 4) + p shr 2;
      Texture^ [p, q] := c;
      PutPixel (p, q, c);
    end;
  {Display it on the screen mapped onto a polygon}
  TextureMap (120, 20, 280, 50, 250, 170, 20, 140, Texture);
  {Wait for a key press}
  ReadKey;
  {Switch back to text mode}
  TextScreen;
end.