program Sprites;

uses Crt;

type BufferType = Array [0..63999] of Byte;

type SpriteRec = record
  {These indicate the dimensions of the sprite}
  Width, Height, Total : Word;
  {This points to the actual sprite data, it may occupy 64000 bytes, which
  is the same size as the buffer.}
  Data : ^BufferType;

  {NOTE: The following values are optional}

  {These indicate the location of the sprite on screen}
  X, Y : Word;
  {These indicate the direction of the sprite movement}
  Xdir, Ydir : ShortInt;
end;

var
  {An offscreen buffer}
  Buffer  : ^BufferType;
  {The sprites themselves}
  Sprite1 : SpriteRec;
  Sprite2 : SpriteRec;
  tX, tY  : Word;

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

{Sets a pixel in the buffer to a specific colour}
procedure PutPixel (x, y : Word; c : Byte);
begin
  if (x < 320) and (y < 200) then
    Buffer^ [y shl 8 + y shl 6 + x] := c;
end;

{Reads the colour value of a pixel from the buffer}
function ReadPixel (x, y : Word) : Byte;
begin
  if (x < 320) and (y < 200) then
    ReadPixel := Buffer^ [y shl 8 + y shl 6 + x];
end;

{Assigns memory for a buffer}
function MakeBuffer : Boolean;
begin
  {Check if enough memory is available}
  if MaxAvail < 64000 then begin
    {If not, return false}
    MakeBuffer := false;
    exit;
  end;
  New (Buffer);
end;

{Clears the buffer}
procedure ClearBuffer;
begin
  fillchar (Buffer^, 64000, 0);
end;

{Displays the buffer}
procedure DisplayBuffer;
begin
  move (Buffer^,          {from buffer}
        Mem [$A000:0000], {to screen}
        64000);           {64000 pixels}
end;

function MakeSprite (var Sprite : SpriteRec; x1, y1, x2, y2 : Word) : Boolean;
var
  Size, x, y   : Word;
  CurrentPixel : Word;
  SpriteMem    : Pointer;

begin
  {Calculate amount of memory needed for sprite}
  Size := (y2 - y1 + 1) * (x2 - x1 + 1) - 1;
  {Check if enough memory is available}
  if MaxAvail < Size then begin
    {If not, return false}
    MakeSprite := false;
    exit;
  end;
  {Assign memory}
  GetMem (Sprite.Data, Size);
  {Set dimensions}
  Sprite.Width   := x2 - x1;
  Sprite.Height  := y2 - y1;
  Sprite.Total   := Size;
  {Read sprite from the screen buffer}
  CurrentPixel := 0;
  for y := y1 to y2 do begin
    for x := x1 to x2 do begin
      Sprite.Data^ [CurrentPixel] := ReadPixel (x, y);
      inc (CurrentPixel);
    end;
  end;
  {Return true}
  MakeSprite := true;
end;

procedure PutSprite (Sprite : SpriteRec; x, y : Word);
var
  XOfs, YOfs, CurrentPixel : Word;
  DataByte                 : Byte;

begin
  {Set location to top left corner of the sprite}
  XOfs := 0; YOfs := 0;
  {Proces the entire sprite}
  for CurrentPixel := 0 to Sprite.Total do begin
    {Read pixel from sprite}
    DataByte := Sprite.Data^ [CurrentPixel];
    {Check to see whether the pixel is transparent}
    if DataByte > 0 then PutPixel (XOfs + x, YOfs + y, DataByte);
    {Set pointers to next position}
    inc (XOfs);
    {Switch to next line if the end of the current line has been reached}
    if XOfs > Sprite.Width then begin
      XOfs := 0;
      inc (YOfs);
    end;
  end;
end;

begin
  {Switch to graphics mode}
  VGAScreen;

  {Assign memory to buffer}
  if not MakeBuffer then begin
    {If there wasn't enough memory, quit}
    TextScreen;
    Writeln ('Not enough memory for frame buffer!');
    Halt;
  end;

  {Clear the buffer}
  ClearBuffer;

  {Set up a sprite consisting of a blue block}
  for tX := 0 to 15 do begin
    for tY := 0 to 15 do begin
      PutPixel (tX, tY, 1);
    end;
  end;
  {Get the sprite}
  if not MakeSprite (Sprite1, 0, 0, 15, 15) then begin
    {If there wasn't enough memory, quit}
    TextScreen;
    Writeln ('Not enough memory to create sprite!');
    Halt;
  end;

  {Set up a sprite consisting of a red rectangle}
  for tX := 0 to 15 do begin
    PutPixel (16 + tX,  0, 4);
    PutPixel (16 + tX, 15, 4);
    PutPixel (16 +  0, tX, 4);
    PutPixel (16 + 15, tX, 4);
  end;
  {Get the sprite}
  if not MakeSprite (Sprite2, 16 + 0, 0, 16 + 15, 16 + 15) then begin
    {If there wasn't enough memory, quit}
    TextScreen;
    Writeln ('Not enough memory to create sprite!');
    Halt;
  end;

  {Set up sprite1 coordinates at top left of the screen}
  Sprite1.X := 0;
  Sprite1.Y := 0;
  {Set direction down right}
  Sprite1.Xdir := 1;
  Sprite1.Ydir := 1;

  {Set up sprite2 coordinates at bottom left of the screen}
  Sprite2.X := 0;
  Sprite2.Y := 184;
  {Set direction up right}
  Sprite2.Xdir := 1;
  Sprite2.Ydir := -1;

  while not KeyPressed do begin
    {Clear the buffer - if you leave this out, the sprites will leave trails}
    ClearBuffer;

    {Put the first sprite in the buffer}
    PutSprite (Sprite1, Sprite1.X, Sprite1.Y);
    {Put the second sprite in the buffer}
    PutSprite (Sprite2, Sprite2.X, Sprite2.Y);

    {Display the buffer - if you leave this out, you won't see a thing}
    DisplayBuffer;

    {Update first sprite location}
    inc (Sprite1.X, Sprite1.Xdir);
    inc (Sprite1.Y, Sprite1.Ydir);
    {Bounce off the sides}
    if Sprite1.X < 1 then Sprite1.Xdir := 1;
    if Sprite1.X > 304 then Sprite1.Xdir := -1;
    if Sprite1.Y < 1 then Sprite1.Ydir := 1;
    if Sprite1.Y > 184 then Sprite1.Ydir := -1;

    {Update second sprite location}
    inc (Sprite2.X, Sprite2.Xdir);
    inc (Sprite2.Y, Sprite2.Ydir);
    {Bounce off the sides}
    if Sprite2.X < 1 then Sprite2.Xdir := 1;
    if Sprite2.X > 304 then Sprite2.Xdir := -1;
    if Sprite2.Y < 1 then Sprite2.Ydir := 1;
    if Sprite2.Y > 184 then Sprite2.Ydir := -1;
  end;
  ReadKey;
end.