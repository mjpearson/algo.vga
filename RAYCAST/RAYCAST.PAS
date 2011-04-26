{$G+} {286 instructions}
{$S-} {No stack checking}
{$R-} {No range checking}
{$Q-} {No overflow checking}
program Pascal_Ray_Casting_Example;
uses Crt;
const
  {Values for several angles}
  ANGLE_0 = 0; ANGLE_30 = 171; ANGLE_45 = 256; ANGLE_60 = 341;
  ANGLE_90 = 512; ANGLE_180 = 1024; ANGLE_270 = 1536; ANGLE_360 = 2048;
const
  {Cursor key scancodes}
  CUp = 18432; CDown = 20480; CLeft = 19200; CRight = 19712;

var
 {maps}
  xGrid                           : Array[0..4356] of Byte;
  yGrid                           : Array[0..4356] of Byte;
  Grid                            : Array[0..4095] of Byte;
 {Tables}
  CosineTable,
  SineTable,
  TangentTable                    : Array [0..2048] of LongInt;
  NextXTable,
  NextYTable                      : Array [0..2048] of Integer;
  HeightTable                     : Array [0..3073] of Word;
  fv                              : Array [1..360] of Integer;
 {File handle}
  RayCastingFile                  : file;
 {Off-screen buffer}
  Buffer                          : Pointer;
 {Global counter}
  Counter                         : Integer;
 {Player coordinates and viewing angle}
  x, y, Angle                     : LongInt;
 {Keyboard input receiver}
  Key                             : Word;
 {Distance counters}
  xDst,yDst                       : LongInt;

{**************************************************************************
** Set to VGA 320x200 256 colours                                        **
**************************************************************************}
procedure VGAScreen; assembler;
asm
  mov ax, $13
  int $10
end;

{**************************************************************************
** Set to text mode                                                      **
**************************************************************************}
procedure TextScreen; assembler;
asm
  mov ax, $3
  int $10
end;

{**************************************************************************
** Read a key from the keyboard buffer                                   **
**************************************************************************}
function Inkey : Word;
var
  Temp : Word;

begin
  Temp := 0;

  if KeyPressed then begin
    Temp := Ord(ReadKey);
    {If extended key, read in second half}
    if Temp = 0 then Temp := Ord(ReadKey) shl 8;
  end;

  Inkey := Temp;
end;

{**************************************************************************
** Draw vertical line                                                    **
**************************************************************************}
procedure DrawLine(x, y1, y2 : Integer; c : Byte);
var
  OffSet, EndOffSet : Word;

begin
  {Clip top of screen}
  if y1 < 0 then y1 := 0;
  {Clip bottom of screen}
  if y2 > 199 then y2 := 199;
  {Offset at start of line}
  OffSet    := y1 shl 8 + y1 shl 6 + x;
  {Offset at end of line}
  EndOffSet := y2 shl 8 + y2 shl 6 + x;

  while OffSet < EndOffSet do begin
    {Set pixel}
    Mem[Seg(Buffer^):Ofs(Buffer^) + OffSet] := c;
    {Go to next scan line}
    inc(OffSet, 320);
  end;

end;

{**************************************************************************
** Load and calculate trigonometric tables.                              **
**************************************************************************}
procedure SetTables;
var
  Radians : Real;

begin
  {Display message}
  writeln('Calculating...');

  {Read field of view correction from file FOV.SSF which must be included}
  Assign    (RayCastingFile, 'FOV.SSF');
  Reset     (RayCastingFile, 1        );
  BlockRead (RayCastingFile, fv, 720  );
  Close     (RayCastingFile           );

  {Calculate other values}
  for Counter := ANGLE_0 to ANGLE_360 do begin
    {Convert angle to radians}
      Radians := (Counter * Pi) / ANGLE_180;
    {Sine}
      SineTable[Counter]   := trunc(32768 * Sin(Radians));
    {CoSine}
      CoSineTable[Counter] := trunc(32768 * Cos(Radians));

    {Tangent}
    if (Counter = ANGLE_90) or (Counter = ANGLE_270) then
      TangentTable[Counter] := MaxLongInt
    else
      TangentTable[Counter] := trunc(32768 * Sin(Radians) / Cos(Radians));

    {Next Y value}
      NextYTable[Counter] := (abs(TangentTable[Counter]) shl 6) shr 15;

    {Next X value}
      NextXTable[Counter] := 64;
    if TangentTable[Counter] <> 0 then
      NextXTable[Counter] := abs(2097152 div TangentTable[Counter]);
  end;

  {Height table}
  HeightTable[0] := 36000;
  for Counter := 1 to 3071 do
    HeightTable[Counter] := 12000 div Counter;
end;

{**************************************************************************
** Make map            							 **
**************************************************************************}
procedure MakeMap;
var
  tx, ty, c : Byte;

begin
  for tx := 0 to 16 do
    for ty := 0 to 16 do begin
      {Select random colour}
      c := Random(16) + 1;
      {Fill the borders of a 16 by 16 block, max map size is 64 by 64}
      if (tx and 15 = 0) or (ty and 15 = 0) then
        Grid[ty shl 6 + tx] := c
      else
        Grid[ty shl 6 + tx] := 0;
    end;

  {Place a few random blocks}
  for Counter := 0 to 14 do
    Grid[(Random(16) shl 6) + Random(16)] := Random(16) + 1;

  for tx := 0 to 16 do
    for ty := 0 to 16 do begin
      {Make sure the X and Y walls are set up properly}
      c := Grid[ty shl 6 + tx];
      if c > 0 then begin
	xGrid[ty       shl 6 + tx    ] := c;
	xGrid[ty       shl 6 + tx + 1] := c;
	yGrid[ty       shl 6 + tx    ] := c;
	yGrid[(ty + 1) shl 6 + tx    ] := c;
      end;
    end;
end;

{***************************************************************************
** Check for a hit within the master grid (used during movement)	  **
***************************************************************************}
function CheckHit(CheckX, CheckY : LongInt) : Byte;
begin
{Assume nothing was hit}
CheckHit := 0;

if (CheckX < 0) or (CheckY < 0) or (CheckX > 4096) or (CheckY > 4096) then
  {If outside the map, simulate a hit...}
  CheckHit := 1
else
  {...otherwise the value at current location}
  CheckHit := Grid[CheckY and $FFC0 + CheckX shr 6];

end;

{****************************************************************************
** Cast a ray to hit Vertical walls.                                       **
****************************************************************************}
function xRay(x, y : LongInt; CurAng : Integer) : Byte;
var
  x1, y1       : LongInt;
  xStep, yStep : Integer;
  Found        : Boolean;
  c            : Byte;

begin
  {Can't hit parallel walls}
  if (CurAng = ANGLE_90) or (CurAng = ANGLE_270) then exit;

  {Make sure we step in the correct direction}
  if (CurAng > ANGLE_90) and (CurAng < ANGLE_270) then begin
    xStep := -64;
    x1    :=  x       and $FFC0;
  end else begin
    xStep :=  64;
    x1    := (x + 64) and $FFC0;
  end;

  {Make sure we step in the correct direction}
  if (CurAng > ANGLE_180) then
    yStep := -NextYTable[CurAng]
  else
    yStep :=  NextYTable[CurAng];

  {Setup Y location}
  y1 := (y shl 15 + (x1 - x) * TangentTable[CurAng]) shr 15;

  {Nothing found yet}
  Found := false;

  while Found = false do begin
    {If outside the map, stop looking}
    if (x1 < 0) or (y1 < 0) or (x1 > 4096) or (y1 > 4096) then exit;

    {Read map at current location}
    c := xGrid[y1 and $FFC0 + x1 shr 6];
    {If it contains a value...}
    if c > 0 then begin
      {...calculate the distance and...}
      xDst := (x1 - x) shl 15 div CosineTable[CurAng];
      {...end the loop}
      Found := true;
    end;
    {Adjust current location}
    inc(x1, xStep);
    inc(y1, yStep);
  end;

  {Return colour found}
  xRay := c;
end;

{****************************************************************************
** Cast a ray to hit Horizontal walls.                                     **
****************************************************************************}
function yRay(x, y : LongInt; CurAng : Integer) : Byte;
var
  x1, y1       : LongInt;
  xStep, yStep : Integer;
  Found        : Boolean;
  c            : Byte;

begin
  {Can't hit parallel walls}
  if (CurAng = 0) or (CurAng = ANGLE_180) then exit;

  {Make sure we step in the correct direction}
  if (CurAng < ANGLE_180) then begin
    y1    := (y + 64) and $FFC0;
    yStep :=  64;
  end else begin
    y1    :=  y       and $FFC0;
    yStep := -64;
  end;

  {Make sure we step in the correct direction}
  if (CurAng > ANGLE_90) and (CurAng < ANGLE_270) then
    xStep := -NextXTable[CurAng]
  else
    xStep :=  NextXTable[CurAng];

  {Setup Y location}
  x1 := x + (y1 - y) shl 15 div TangentTable[CurAng];

  {Nothing found yet}
  Found := false;

  while Found = false do begin
    {If outside the map, stop looking}
    if (x1 < 0) or (y1 < 0) or (x1 > 4096) or (y1 > 4096) then exit;
    {Read map at current location}
    c := yGrid[y1 and $FFC0 + x1 shr 6];
    {If it contains a value...}
    if c > 0 then begin
      {...calculate the distance and...}
      yDst := (y1 - y) shl 15 div SineTable[CurAng];
      {...end the loop}
      Found := true;
    end;
    {Adjust current location}
    inc(x1, xStep);
    inc(y1, yStep);
  end;

  {Return colour found}
  yRay := c;
end;

{****************************************************************************
** Display an entire screen worth of walls.				   **
****************************************************************************}
procedure DrawView(x, y, Angle : LongInt);
var
  ScreenColumn, CurAng, CalcAng,
  Height, TopY, BottomY         : Integer;
  Color, XColor, YColor         : Byte;
  Distance                      : LongInt;

begin

  {Clear background by writing 0 to the buffer}
  FillChar(Mem[Seg(Buffer^):Ofs(Buffer^)], 64000, 0);

  for ScreenColumn := 0 to 319 do begin

    {Set angles and keep them within the range of ANGLE_0 through ANGLE_360}
    CurAng  := (ANGLE_360 + Angle + fv[ScreenColumn + 20]) and (ANGLE_360 - 1);
    CalcAng := (ANGLE_360 + Angle - CurAng)                and (ANGLE_360 - 1);
    {Set distances to a ridiculously long distance}
    xDst := MaxLongInt;
    yDst := MaxLongInt;

    {Check X walls}
    XColor := xRay(x, y, CurAng);
    {Check Y walls}
    YColor := yRay(x, y, CurAng);

    {If a wall was found}
    if (XColor > 0) or (YColor > 0) then begin

      Distance := MaxLongInt;
      {Assume X wall}
      if XColor > 0 then begin
        Distance := xDst;
        Color := XColor;
      end;
      {But then again, it could have been an Y wall}
      if YColor > 0 then begin
        if Distance > yDst then begin
          Distance := yDst;
          Color := YColor;
        end;
      end;

      {Compensate for fish eye effect}
      Distance := (Distance * CosineTable[CalcAng]) shr 15;
      {Limit distance}
      if Distance > 3071 then Distance := 3071;
      {Read height from table}
      Height := HeightTable[Distance];
      {Set top and bottom coordinates}
      TopY    := 100 - (Height shr 1);
      BottomY := TopY + Height;

      {Draw wall slice}
      DrawLine(ScreenColumn, TopY, BottomY, Color);
    end;
  end;

  {Copy Buffer to screen}
  Move(Mem[Seg(Buffer^):Ofs(Buffer^)], Mem[$A000:0000], 64000);
end;


{****************************************************************************
** Main programme.                                                         **
****************************************************************************}
begin
  {Calculate tables}
  SetTables;
  {Make map}
  MakeMap;

  {Set to VGA 320x200x256}
  VGAScreen;

  {Allocate memory for screen buffer}
  GetMem(Buffer, 64000);

  {Set location at 128,128}
  x := 128;
  y := 128;

  while True do begin

    {Read key from buffer}
    Key := Inkey;

      {turn right}
      if (Key = CRight) then begin
	Angle := (Angle + 32) and (ANGLE_360 - 1);
      end;

      {turn left}
      if (Key = CLeft) then begin
	Angle := (Angle + 2016) and (ANGLE_360 - 1);
      end;

      {move forward}
      if (Key = CUp) then begin
        {check to see if new location is empty}
        if CheckHit(x + CosineTable[Angle] div 5000,
                    y + SineTable[Angle] div 5000) = 0
        then begin
          {if so, move player}
          inc(x, CosineTable[Angle] div 5000);
          inc(y, SineTable[Angle]   div 5000);
        end;
      end;

      {move backward}
      if (Key = CDown) then begin
        {check to see if new location is empty}
        if CheckHit(x - CosineTable[Angle] div 5000,
                    y - SineTable[Angle] div 5000) = 0
        then begin
          {if so, move player}
          dec(x, CosineTable[Angle] div 5000);
          dec(y, SineTable[Angle]   div 5000);
        end;
      end;

    {ESCAPE = quit}
    if Key = 27 then break;

    {Display view}
    DrawView(x, y, Angle);
  end;

  {Return to text mode}
  TextScreen;
end.
