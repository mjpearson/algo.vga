var offset : word;

function Inp : byte;
var Scan : byte;
begin
 asm
  xor ah,ah
  int 16h
  mov scan,ah
 end;
inp:=scan;
end;

procedure VidMode(Mode : byte); Assembler;
asm
  xor ah,ah
  mov al,Mode
  int 10h
end;

Procedure Matrix(X,Y,X2,Y2,Col:word);
var W_Index,H_Index : byte;
begin
for H_Index := y to y2 do
  begin
    for W_Index := X to X2 do
      begin
        mem[$0a000:W_Index+(H_Index*320)]:=col;
      end;
  end;
end;

procedure PalFunk(BaseX,BaseY,BlockSize : word);
var YOrigin : word;
begin
YOrigin:=BaseY;
for offset := 0 to 255 do

 begin
   Matrix(BaseX,BaseY,(BaseX + BlockSize),(BaseY + BlockSize),offset);
   BaseY:=BaseY+(BlockSize+2);
   if BaseY > (YOrigin + (16*BlockSize)+20) then
     begin
       BaseY:=YOrigin;
       BaseX:=BaseX+(BlockSize+2);
     end;
  end;
end;

begin
VidMode($13);
PalFunk(5,5,10);
repeat
until Inp = 1;
VidMode(3);
end.
