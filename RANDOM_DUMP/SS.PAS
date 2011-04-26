program SystemStatus;

uses crt,dos,cputype;

Type ST5  = string[5];

var EMMS : byte;
    Avail, Total : word;
    DosVer, dpmi, WinVer, xms: Word;
    Mirq,cpu : byte;
    mousie, button: integer;

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


begin
 ClrScr;
 TextColor(15);
 TextBackground(4);
 For Button := 1 to 80 do
 begin
  GotoXy(Button,1); Writeln('ÿ');
 end;
 Gotoxy(34,1); Write('Systatus v1.0');
 TextBackGround(0); TextColor(7);
 GotoXy(1,3);
 Writeln('þ HDD               Ä ',DiskFree(0) div 1024, 'Kb Free');
 DosVer := DosVersion;
 Writeln('þ DOS version       Ä ', Lo(DosVer), '.',Hi(DosVer));
 asm
   mov ax,1600h
   int 2fh
   mov Winver,ax
 end;
 Write('þ Windows Version   Ä ');
 if lo(Winver) <> 0 then Writeln(Lo(WinVer), '.',Hi(WinVer));
 if lo(Winver)  < 1 then Writeln('Not Resident');
 asm
   mov ax,4300h
   int 2fh
   mov cpu,al
 end;
 Writeln('þ Free Conventional Ä ',MemAvail div 1024,'Kb');
 Write('þ XMS               Ä ');
 if cpu = $80 then
   begin
     Writeln('Installed');
       asm
         mov ax,4310h
         int 2fh
         mov xms,bx
       end;
  end;
EMMStatus;
if EMMS = 0 then writeln('þ EMM Callback      Ä ',hex_string(EMMS),
' (Successful)') else EExit;
  asm
    mov ah,42h
    int 67h
    mov EMMS,ah
    mov Avail,bx
    mov total,dx
  end;
if EMMS <> 0 then EExit;
                 Writeln('þ Total Allocatable Ä ',total*16,'Kb');
                 Writeln('þ Available Memory  Ä ',avail*16,'Kb');
 Write('þ DPMI State        Ä ');
 asm
  mov ax,1687h
  int 2fh
  mov cpu,cl
  mov dpmi,ax
 end;
 if dpmi=0 then Writeln('Found');
 if dpmi <>0 then Writeln('v86 Mode');

 if Isa8088 then
    cpu := CPU_8088
  else if Isa80486 then
    cpu := CPU_80486
  else if Isa80386 then
    cpu := CPU_80386
  else if Isa80286 then
    cpu := CPU_80286
  else if Isa80186 then
    cpu := CPU_80186
  else cpu := 0;
   Writeln('þ CPU Type          Ä 80',cpu,'86');

   Write('þ Mouse             Ä ');
    asm
        xor     ax,ax
        int     33h
        mov     mousie,ax
        mov     button,bx
    end;
   if mousie <> 0 then begin
    asm mov      ax,0024h
        int      33h
        mov      MIRQ,cl
   end;
     Writeln(Button,' Buttons - Hooking IRQ',MIRQ);
   end
   Else Writeln('Not Found');
   Mousie:=Wherey+1;
   For Button := 1 to 80 do
     begin
       GotoXy(Button,Mousie); Write('Ä');
     end;
   Writeln('Caglios 1997');
end.