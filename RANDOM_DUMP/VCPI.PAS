{$G+}
{ EMM Test Program.  RABEPIü Labs 1997 }
Type
   ST5  = string[5];

Type
   EMMHeader = record
       NumBytes : array [1..2] of Word;
       SType    : byte;
       SHandle  : word;
       SOffset  : Word;
       SSegment : word;
       Destype  : byte;
       DHandle  : word;
       DOffset  : word;
       DSegment : word;
   end;

var EMMS : byte;
    Avail, Total : word;
    VCPBuff : word;
    EStruct : EMMHeader;

procedure EMMStatus; assembler;
asm
  mov ax,4000h
  int 67h
  mov EMMS, ah
end;

{------------------------------------------------------------
  The function Hex_String converts an integer into a four
  character hexadecimal number (string) with leading zeros.
 ------------------------------------------------------------}
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

{ Error Exit }
procedure EExit;
begin
  Write('EMM Status Callback Error : ',hex_string(EMMS));
  if EMMS = $80 then writeln('Internal Error') else
  if EMMS = $81 then writeln('Hardware Malfunction!') else
  if EMMS = $83 then writeln('Invalid Handle') else
  if EMMS = $84 then writeln('Undefined Function');
  halt;
end;

procedure PageAlloc(var Segment:word);
var
   SegAddr : word;
   RetCode : byte;
begin
  asm
    mov ax,5a00h
    mov bx,4
    int 67h
    cmp al,0
    je  @@2000
    mov RetCode,al
  @@2000:
    mov SegAddr,dx
  end;
  if not RetCode=0 then
    begin
      writeln('Error ',hex_string(RetCode));
      writeln('Unable to allocate EMS page(s)');
    end;
  Segment:=SegAddr;
end;

procedure EMMFlip;
begin
end;
{
       NumBytes : array [1..2] of Word;
       SType    : byte;
       SHandle  : word;
       SOffset  : Word;
       SSegment : word;
       Destype  : byte;
       DHandle  : word;
       DOffset  : word;
       DSegment : word;
}

begin
EMMStatus;
if EMMS = 0 then writeln('EMM Status Callback Code : ',hex_string(EMMS),
' (Successful)') else EExit;
  asm
    mov ah,42h
    int 67h
    mov EMMS,ah
    mov Avail,bx
    mov total,dx
  end;
if EMMS <> 0 then EExit;
Writeln('Total Allocatable Memory : ',total*16,' bytes');
Writeln('Available Alloc. Memory  : ',avail*16,' bytes');
PageAlloc(VCPBuff);
Writeln('Allocated 64k buffer in EMS - Handle ',hex_string(VCPBuff));
end.