const Up    = $48;
      down  = $50;
      left  = $4B;
      right = $4D;
      XHei  = 10;
      YHei  = 10;

var Scancode : byte;
    XOffset,YOffset : word;
    DFlag,UFlag,LFlag,RFlag : boolean;

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

procedure F_Tang; Assembler;
asm
  xor ah,ah
  int 16h
  mov scancode,ah
end;

procedure Delay(Time : word); Assembler;
asm
  mov bx,Time
@@400:
  mov cx,65535
@@500:
  loop @@500
  dec  bx
  or   bx,bx
  jnz  @@400
end;

begin
Xoffset :=100;Yoffset :=100; DFlag := true;UFlag := false;
LFlag := false;RFlag := false;

 VidMode($13);

 repeat
  Matrix(XOffset,YOffset,(XOffset+XHei),(YOffset+Yhei),10);
  F_Tang;
  if Scancode > 1 then begin
   Matrix(XOffset,YOffset,(XOffset+XHei),(YOffset+YHei),0);
   if (scancode = Up) and (DFlag <> True) then begin
      dec(YOffset);
      UFlag:=True; DFlag:=false;RFlag:=false;LFlag:=false;
   end else
   if (scancode = Down) and (UFlag <> True) then begin
      inc(YOffset);
      UFlag:=False; DFlag:=True;RFlag:=false;LFlag:=false;
   end else
   if (scancode = left) and (RFlag <> True) then begin
      dec(XOffset);
      UFlag:=False; DFlag:=False;RFlag:=false;LFlag:=True;
   end else
   if (scancode = right) and (LFlag <> True) then begin
      inc(XOffset);
      UFlag:=False; DFlag:=False;RFlag:=true;LFlag:=false;
   end;
 end;
  if UFlag = True then dec(YOffset);
  if DFlag = True then inc(YOffset);
  if LFlag = True then dec(XOffset);
  if RFlag = True then inc(XOffset);
 until scancode=1;
 VidMode(3);
 write('Normal Exit');
end.