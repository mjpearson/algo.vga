{
  Expanded Memory Interface : Caglios '97
}
unit
    emm;

interface

Type
   ST5  = string[5];

procedure E2CFlip(Handle, Dest, amt : word);
procedure C2EFlip(Source, DestHandle, Amt : word);
procedure Free_Handle(Handle : word);
procedure PageAlloc(var Segment:word; NumPages : word);
procedure EMMStatus;

Function Get_EMM(Free : Boolean) : word;
Function Get_EMM_Ver(Hi : Boolean) : byte;
Function Hex_String (Number: Integer): ST5;

Implementation

{ EMM Memory Move Parameter Block Structure }
Type
   EMMHeader = record
       NumBytes : array [1..2] of word;
       SType    : byte;
       SHandle  : word;
       SOffset  : Word;
       SSegment : word;
       Destype  : byte;
       DHandle  : word;
       DOffset  : word;
       DSegment : word;
   end;

var
   EStruct : EMMHeader;

Function Hex_String (Number: Integer): ST5;
  Function Hex_Char (Number: Integer): Char;
   Begin
     If Number < 10 then
        Hex_Char := Char (Number + 48)
     else
        Hex_Char := Char (Number + 55);
     end; { Function Hex_char }

   Var
     S: ST5;

     Begin
       S := '';
       S := Hex_Char ((Number shr 1) div 2048);
       Number := (((Number shr 1) mod 2048) shl 1) + (Number and 1);
       S := S + Hex_Char (Number div 256);
       Number := Number mod 256;
       S := S + Hex_Char (Number div 16);
       Number := Number mod 16;
       S := S + Hex_Char (Number);
       Hex_String := S + 'h';
 end; { Function Hex_String }

Procedure EExit(Err : byte);
var
   ErrString : string;
begin
  Write('EMM Failure - ',hex_string(Err),' - ');
  case err of
       $80 : ErrString := 'Internal Error';
       $81 : ErrString := 'Hardware malfunction';
       $84 : ErrString := 'Undefined function';
       $83 : ErrString := 'Invalid Handle';
       $85 : ErrString := 'No more handles available';
       $86 : ErrString := 'Error saving/restoring of mapping context';
       $87 : ErrString := 'Insufficient pages in system';
       $88 : ErrString := 'Insufficient pages available';
       $8f : ErrString := 'Undefined subfunction';
       $9e : ErrString := 'Dedicated DMA Channels not supported';
       $a3 : ErrString := 'Source array corrupted';
       else ErrString := 'Unknown';
  end;
  WriteLn(ErrString);
  halt;
end;

procedure PageAlloc(var Segment:word; NumPages : word);
var
   SegAddr : word;
begin
  asm
    mov ah,43h         { Get handle and allocate memory }
    mov bx,NumPages
    int 67h
    mov SegAddr,dx
  end;
  Segment:=SegAddr;
end;

procedure Free_Handle(Handle : word);
var
   RetCode : byte;
begin
  asm
     mov ah,45h
     mov dx,Handle
     int 67h
     mov RetCode,ah
  end;
  if RetCode <> 0 then EExit(RetCode);
end;

procedure C2EFlip(Source, DestHandle, Amt : word);
var
   RetCode : byte;
begin
     EStruct.Numbytes[1]:= Amt;
     EStruct.SType:=0;
     EStruct.SHandle:=0;
     EStruct.SOffset:=0;
     EStruct.SSegment:=Source;
     EStruct.Destype:=1;
     EStruct.DHandle:=DestHandle;
     EStruct.DOffset:=0;
     EStruct.DSegment:=0;
     asm
       mov ax,5700h
       lea si,[EStruct]
       int 67h
       mov RetCode,ah
     end;
  if RetCode <> 0 then EExit(RetCode);
end;

procedure E2CFlip(Handle, Dest, amt : word);
var
   RetCode : byte;
begin
     EStruct.Numbytes[1]:= Amt;
     EStruct.SType:=1;
     EStruct.SHandle:=Handle;
     EStruct.SOffset:=0;
     EStruct.SSegment:=0;
     EStruct.Destype:=0;
     EStruct.DHandle:=0;
     EStruct.DOffset:=0;
     EStruct.DSegment:=Dest;
     asm
       mov ax,5700h
       lea si,[EStruct]
       int 67h
       mov RetCode,ah
     end;
  if RetCode <> 0 then EExit(RetCode);
end;

procedure EMMStatus;
var
   EMMS : byte;
begin
asm
  mov ax,4000h
  int 67h
  mov EMMS, ah
end;
if EMMS <> 0 then EExit(EMMS);
end;

Function Get_EMM(Free : Boolean) : word;
var
   avail,total : word;
   EMMS : byte;
Begin
  asm
    mov ah,42h
    int 67h
    mov avail,bx
    mov total,dx
    mov EMMS, ah
  end;
  if EMMS <> 0 then EExit(EMMS)
    else
  if Free then Get_Emm:=(Avail*16) else Get_Emm:=(Total*16);
end;

Function Get_EMM_Ver(Hi : Boolean) : byte;
var
   Tempver : byte;
   EMMS : byte;
begin
  asm
    mov ah,46h
    int 67h
    mov TempVer,al
    mov EMMS, ah
  end;
  if EMMS <> 0 then EExit(EMMS)
    else
  if Hi then Get_Emm_Ver:= (TempVer shr 4)
  else       Get_Emm_Ver:= ((TempVer shl 4));
end;

end.