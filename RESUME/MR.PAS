{

 Um, this would be my Resume...

 .Caglios.
 n1921380@student.fit.qut.edu.au

}

{$G+}{$N+}

uses {s3mpl2,}crt;

{$I c:\tp\dev1\palette7.dat}
{$I mre.dat}
{$I c:\tp\fdat.dat}           { Font Data }

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

Type Virtual = Array [0..63999] of byte;  { The size of our Virtual Screen }
     VirtPtr = ^Virtual;                  { Pointer to the virtual screen }

const
   VGASeg : word = $0a000;  { Video segment offset }
   add1: integer = -4;   { General increment }
   add2: integer = 2;    { X Movement }
   add3: integer = 3;    { Y Movement }
   ColIndex = 45;        { How many colours per sinus curvature }
   TransParency : byte = 4; { Transparency index / lower the more colours }
   FontYoffs : byte = 50;
   DownArrow = $50;
   UpArrow   = $48;
   PageUp    = $49;
   PageDown  = $51;
   MaxRPages = 5;

var
   sintable: array[0..255] of integer;
   oldpal : array [0..255,1..3] of byte;
   x, y, v, tx, ty, adr: word;
   r, rt: single;
   a1, a2, a3: word;
   WinPres, l: word;
   maxx:integer;
   maxy:integer;
   Virscr : VirtPtr;                      { Our first Virtual screen }
   Vaddr  : word;                         { The segment of our virtual screen}
   EStruct : EMMHeader;
   EMMHandle : word;
   Rpage,Scan,EMMS : byte;
   EscFlag : boolean;

Procedure EExit(Err : byte);
Type
   ST5  = string[5];
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
begin
  asm mov ax,3; int 10h; end;
  Writeln('TIAS EMM Toolkit v1.0');
  Writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'); Writeln;
  Write('Error (',hex_string(Err),'), ');
  case err of
       $80 : Writeln('Internal Error');
       $81 : Writeln('Hardware malfunction');
       $84 : Writeln('Undefined function');
       $85 : Writeln('No more handles available');
       $86 : Writeln('Fault saving/restoring mapping context');
       $87 : Writeln('Insufficient pages in system');
       $88 : Writeln('Insufficient pages available');
       $8f : Writeln('Undefined subfunction');
       $95 : Writeln('Offset assigned exceeds page limits');
    else
       Writeln('Undocumented (ie : shouldn`t happen!)');
  end;
  halt;
end;

procedure PageAlloc(var Segment:word);
var
   SegAddr : word;
begin
  asm
    mov ah,43h
    mov bx,4
    int 67h
    mov SegAddr,dx
  end;
  Segment:=SegAddr;
end;

procedure H_Disalloc(Handle : word);
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

procedure C2EMMFlip(Source, DestHandle : word);
var
   RetCode : byte;
begin
     EStruct.Numbytes[1]:= 64000;
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

procedure EMM2CFlip(Handle,Dest : word);
var
   RetCode : byte;
begin
     EStruct.Numbytes[1]:= 64000;
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
begin
asm
  mov ax,4000h
  int 67h
  mov EMMS, ah
end;
if EMMS <> 0 then EExit(EMMS);
end;

procedure Mode(md:word);assembler;
asm
  mov ax,md
  int 10h
end;

procedure DAC(ColNum,R,G,B : byte); Assembler;
asm
  mov al,[ColNum]
  mov dx,3c8h
  out dx,al
  inc dx
  mov al,[r]
  out dx,al
  mov al,[g]
  out dx,al
  mov al,[b]
  out dx,al
end;

procedure LoadPal;
var
  colnum,I : integer;
begin
i:=0; colnum:=0;
 repeat
    DAC(colnum,ramppal[i],ramppal[i+1],ramppal[i+2]);
    i:=i+3;
    colnum:=colnum+1;
 until i=765;
end;

procedure Flip(source,dest:word);Assembler;
asm
  push ds
  mov ds,source
  mov es,dest
  xor si,si
  mov di,si
  mov cx,32000
  rep movsw
  pop ds
end;

procedure LoadPCX (fname : string; where:word);
VAR f:file;
    temp:pointer;

BEGIN
  assign (f,fname);
  reset (f,1);
  seek (f,128);
  getmem (temp,65535);
  blockread (f,temp^,fileSize(f)-128);
  asm
    push ds
    mov  ax,where
    mov  es,ax
    xor  di,di
    xor  ch,ch
    lds  si,temp

@Loop1 :
    lodsb
    mov  bl,al
    and  bl,$c0
    cmp  bl,$c0
    jne  @Single

    mov  cl,al
    and  cl,$3f
    lodsb
    rep  stosb
    jmp  @Fin
@Single :
    stosb
@Fin :
    cmp  di,63999
    jbe  @Loop1
    pop  ds
  end;
  freemem (temp,65535);
  close (f);
END;

procedure Blit(BMPSize,x,y,BMPWidth:word);
var
    loop1,XBound,Xorigin:word;
    col : byte;

begin
Xorigin:=x;          { Save the original X value, coz it's gonna change }
XBound:=x+BMPWidth;
for loop1 := 0 to (BMPSize-1) do { Take 1 because I am starting at offset 0 }
  begin
   col:=mre[loop1];
   if col = 0 then col:=mem[vaddr:x+(y*320)] - 10;  { logo shadow }
   if col <> 255 then Mem [vaddr:X+(Y*320)]:=col; { To Virtual display }
   inc(x);
    if x > XBound then
       begin
         x :=Xorigin;
         inc(y);
       end;
    end;
end;

{ Note : This procedure shall have to be slightly modified if ASCII
         graphical characters are added.  For the present it only
         accomodates characters 33-96 in the algorithm; All of which
         are uppercase.  ie : lowercase input is converted to an
         uppercase font. }
procedure PokeString(X,Y   : word; InString : string; Colour : byte;
                     where : word);

var offset,Index,XOrigin  : word;
    YOrigin,index2,XIndex : word;

begin
XOrigin := X;
XIndex  := Xorigin;
YOrigin := y;
offset  := 1;

for Index2 := 1 to length(InString) do
begin
{ Is the character a lowercase letter??? }
if (word(InString[Index2]) > 96) and (word(InString[Index2]) < 123) then
{ Lowercase - Uppercase }
offset:=((word(InString[Index2])-65)*(FontWidth*FontHeight))+1
else
{ Otherwise leave them alone }
offset:=((word(InString[Index2])-33)*(FontWidth*FontHeight))+1;

{ Poke 1 Character }
if word(InString[Index2]) > 0 then
  begin
    for Index := offset to (offset+((FontWidth*FontHeight)-1)) do
      begin
        inc(x);
       if Fontdata[Index] <> 0 then
          mem [where:x+(y*320)]:=Fontdata[Index]+(Colour-1);
       if x > (Xorigin + (FontWidth-1)) then
         begin
           x:=XOrigin;
           inc(y);
         end;
      end;
end;
  XIndex := XIndex + (FontWidth+1);  { Space between characters }
  Xorigin := XIndex;     { Set the new X origin }
  x := XOrigin;          { Reset new X for next character }
  y:=Yorigin;            { And align the Y co-ord to keep them in line }
end;
end;

Procedure SetUpVirtual;
BEGIN
  GetMem (VirScr,64000);
  vaddr := seg (virscr^);
END;

Procedure ShutDown;
BEGIN
  FreeMem (VirScr,64000);
END;

function IntToStr(I: Longint): String;
var
 S: string[11];
begin
 Str(I, S);
 IntToStr := S;
end;

procedure ResPage(Page : byte);
const
     TxtCol : byte = 102;
begin
PokeString(270,194,'Page '+inttostr(Page)+' of '+inttostr(MaxRPages),150,vaddr);
  case Page of
    1 :
       begin
         PokeString(105,FontYoffs-15,'- Personal Particulars -',TxtCol,vaddr);
         PokeString(10,FontYOffs,'Name        : Michael Pearson',TxtCol,vaddr);
         PokeString(10,FontYOffs+10,'Address     : 5 Park st, Ipswich Qld, 4305',TxtCol,vaddr);
         PokeString(10,FontYOffs+20,'Phone       : (07) 32812955',TxtCol,vaddr);
         PokeString(10,FontYOffs+30,'DOB         : 12th of July, 1978',TxtCol,vaddr);
         PokeString(10,FontYOffs+40,'NATIONALITY : Australian',TxtCol,vaddr);
         PokeString(10,FontYOffs+50,'STATUS      : Single',TxtCol,vaddr);
         PokeString(95,FontYoffs+70,'- Education Qualifications -',TxtCol,vaddr);
         PokeString(10,FontYoffs+80,'Secondary   : Ipswich Grammar School (1991-1993)',TxtCol,vaddr);
         PokeString(66,FontYoffs+90,'Matthew Flinders Anglican College (1993-1995)',TxtCol,vaddr);
         PokeString(10,FontYoffs+100,'Tertiary    : Currently studying bachelor of Information technology',TxtCol,vaddr);
         PokeString(66,FontYoffs+110,'at QUT (Gardens Point)',TxtCol,vaddr);
         PokeString(10,FontYoffs+120,'Subjects    : English, Maths B, Maths C, Physics, Graphics & IPT',TxtCol,vaddr);
         PokeString(10,FontYoffs+130,'OP          : 10',TxtCol,vaddr);
       end;
    2 :
       begin
         PokeString(105,FontYoffs-15,'- Special Achievements -',TxtCol,vaddr);
         PokeString(10,FontYoffs,'Sporting    : IGS Volleyball U15 Team 1991 - 1993',TxtCol,vaddr);
         PokeString(66,FontYoffs+10,'IGS Track & Field Team 1991 - 1993 (GPS)',TxtCol,vaddr);
         PokeString(66,FontYoffs+20,'IGS Hawthorne House Rep, 800m & 1500m',TxtCol,vaddr);
         PokeString(66,FontYoffs+30,'IGS Cricket Team II 1991',TxtCol,vaddr);
         PokeString(66,FontYoffs+40,'IGS High\Long Jump rep U14 1992 (GPS)',TxtCol,vaddr);
         PokeString(66,FontYoffs+50,'IGS U13-U15 relay teams 1991-1993 (GPS)',TxtCol,vaddr);
         PokeString(10,FontYoffs+60,'Academic    : Credit 1991 Westpac Maths Competition. (Junior Division)',TxtCol,vaddr);
         PokeString(66,FontYoffs+70,'Credit 1993 Westpac Maths Competition. (Intermediate Division)',TxtCol,vaddr);
         PokeString(66,FontYoffs+80,'Credit 1994 Westpac Maths Competition. (Senior Division)',TxtCol,vaddr);
         PokeString(66,FontYoffs+90,'Distinction 1994 ESSO Australia Science Comp.',TxtCol,vaddr);
         PokeString(66,FontYoffs+100,'Merit 1991 Chemistry Quiz. (Junior Div)',TxtCol,vaddr);
         PokeString(66,FontYoffs+110,'Credit 1991 ESSO Australia Science Comp.',TxtCol,vaddr);
         PokeString(66,FontYoffs+120,'Hawthorne House Captain (IGS) 1993',TxtCol,vaddr);
         PokeString(66,FontYoffs+130,'IGS Debating Team A, 1992 - 1993',TxtCol,vaddr);
         PokeString(66,FontYoffs+140,'House Student Staff Council rep. 1995',TxtCol,vaddr);
       end;
    3 :
       begin
         PokeString(115,FontYoffs-15,'- Computer Skills -',TxtCol,vaddr);
         PokeString(10,FontYoffs,'Touch typing 92wpm, 98% accuracy',TxtCol,vaddr);
         PokeString(10,FontYoffs+20,'Knowledge of 9 generic programming languages including Turbo Assembler,',TxtCol,vaddr);
         PokeString(10,FontYoffs+30,'Borland C, C++ (DOS & Unix) and Turbo Pascal, Access SQL, as well as ',TxtCol,vaddr);
         PokeString(10,FontYoffs+40,'Unix scripting and technical familiarity with Novell Ethernet (802.3),',TxtCol,vaddr);
         PokeString(10,FontYoffs+50,'Token Ring (802.5) and TCP/IP networks.',TxtCol,vaddr);
         PokeString(10,FontYoffs+70,'I have released many utilities both on share, free and begware basis',TxtCol,vaddr);
         PokeString(10,FontYoffs+80,'which include Integrated Development Environments, Device Drivers,',TxtCol,vaddr);
         PokeString(10,FontYoffs+90,'Stream & Text Editors and graphical demonstrations for competition',TxtCol,vaddr);
         PokeString(10,FontYoffs+100,'purposes...',TxtCol,vaddr);
       end;
    4 :
       Begin
         PokeString(125,FontYoffs-15,'- Work History -',TxtCol,vaddr);
         PokeString(10,FontYoffs,'* Software Development / Computer Assembly',TxtCol,vaddr);
         PokeString(10,FontYoffs+10,'  Comscan Electronics Pty Ltd',TxtCol,vaddr);
         PokeString(10,FontYoffs+20,'  6th-12th July 1995 (Work Exp. Refs available)',TxtCol,vaddr);

         PokeString(10,FontYoffs+40,'* Kitchenhand',TxtCol,vaddr);
         PokeString(10,FontYoffs+50,'  Dec 94 - Nov 96',TxtCol,vaddr);
         PokeString(10,FontYoffs+60,'  Patrice Garden Restaurant',TxtCol,vaddr);
         PokeString(10,FontYoffs+70,'  Tanawha, Sunshine Coast',TxtCol,vaddr);
         PokeString(10,FontYoffs+80,'  Phone (07) 54454242',TxtCol,vaddr);

         PokeString(10,FontYoffs+100,'* Assistant Publisher, Data Entry & Telephonist',TxtCol,vaddr);
         PokeString(10,FontYoffs+110,'  April 96 - Jan 97',TxtCol,vaddr);
         PokeString(10,FontYoffs+120,'  Local Sellers Trader Magazine (Sunshine Coast)',TxtCol,vaddr);
         PokeString(10,FontYoffs+130,'  Phone (07) 54443255 ',TxtCol,vaddr);
       end;
    5 :
       begin
         PokeString(120,FontYoffs-15,'- A bit about me -',TxtCol,vaddr);
         PokeString(10,FontYoffs,'Personal Qualities : Trustworthy',TxtCol,vaddr);
         PokeString(95,FontYoffs+10,'Reliable',TxtCol,vaddr);
         PokeString(95,FontYoffs+20,'Team Worker',TxtCol,vaddr);
         PokeString(95,FontYoffs+30,'Intelligent, eager to learn',TxtCol,vaddr);

         PokeString(10,FontYoffs+50,'Interests          : Reading',TxtCol,vaddr);
         PokeString(95,FontYoffs+60,'Story Writing',TxtCol,vaddr);
         PokeString(95,FontYoffs+70,'Computer Programming / Art / Music composition',TxtCol,vaddr);
         PokeString(95,FontYoffs+80,'Philosophy / Psychology and History',TxtCol,vaddr);

         PokeString(10,FontYoffs+100,'Referees           : Mr J. Jowett             Mr William J. Const',TxtCol,vaddr);
         PokeString(95,FontYoffs+110,'39 Illuka St,            PO Box 128, Rowan Lane',TxtCol,vaddr);
         PokeString(95,FontYoffs+120,'Buderim Meadows          Maleney, Qld, 4552',TxtCol,vaddr);
         PokeString(95,FontYoffs+130,'Buderim, Qld, 4556       Phone (07) 54921042',TxtCol,vaddr);
         PokeString(95,FontYoffs+140,'Ph (07) 54782362',TxtCol,vaddr);
       end;
  end;
end;

procedure Fire(Dest : word); Assembler;
asm
  push es
  push ds
  mov es,dest
  xor di,di
  mov cx,64000
  @@fl1:
    xor bx,bx
    mov bl,byte ptr es:[di]
    mov ax,bx
    mov bl,byte ptr es:[di-1]
    add ax,bx
    mov bl,byte ptr es:[di+1]
    add ax,bx
    mov bl,byte ptr es:[di]
    add ax,bx
    shr ax,2
    jz @@fl2
    dec al
  @@fl2:
    stosb
    dec cx
  jnz @@fl1
  pop ds
  pop es
end;

procedure EroticallyGirateTheDisplay;
    begin
       EMM2CFlip(EMMHandle,vaddr);
       adr:= 0;
       maxx:= 320;
       maxy:= 200;
       for y:= 1 to maxy do
       begin
         for x:= 1 to maxx do
         begin
           { Create some semblance of randomness }
           ty:= byte(sintable[byte(x-a1+a3)] + sintable[byte(y+x)]);
           tx:= byte(sintable[byte(y-a1-a2)] - sintable[byte(x+a3)]);

           l:= (ty + tx+50);

           ty:= byte(sintable[byte(x-a1+a3)] + sintable[byte(y-x+a3)]);
           tx:= byte(sintable[byte(y+a1)] - sintable[byte(x-a1+a3)]);

           l:= (l + (ty + tx));
           l:= byte(l);
           if l > 255 then l:= 255 - (l and 255);

           { Scale the 'Wednesday' background against it }
           l:=mem[vaddr:adr] + (l div TransParency);
           if l = 0 then l:=1;
           mem[vaddr:adr]:=l;
           inc(adr);
           end;
         end;
         a1:= (a2 + add1) and 255;
         a2:= (a1 + add2) and 255;
         if ((a1 and 1) = 1) and ((a2 and 1) = 1) then
         a3:= (a3 + add3) and 255;
         Blit(sizeof(mre),100,3,103);
         ResPage(RPage);
         Flip(vaddr,VGASeg);  { Virtual all set... wack it to video }
         asm
           in  al,60h
           mov scan,al
         end;
         case Scan of
            UpArrow :   begin
                          inc(RPage);
                          if RPage > MaxRPages then RPage:=1;
                        end;
            PageUp :    begin
                          inc(RPage);
                          if RPage > MaxRPages then RPage:=1;
                        end;

            DownArrow : begin
                          dec(RPage);
                          if RPage < 1 then RPage:=MaxRPages;
                        end;

            PageDown  : begin
                          dec(RPage);
                          if RPage < 1 then RPage:=MaxRPages;
                        end;

         end;
    end;


procedure WaitRetrace; assembler;
asm
    mov dx,3DAh
@@1000:
    in al,dx
    and al,08h
    jnz @@1000
@@2000:
    in al,dx
    and al,08h
    jz  @@2000
end;

Procedure GetPal(ColorNo : Byte; Var R,G,B : Byte);
Begin
   Port[$3c7] := ColorNo;
   R := Port[$3c9];
   G := Port[$3c9];
   B := Port[$3c9];
End;

Procedure GrabPallette;
var
   loop1 : byte;
BEGIN
  For loop1:=0 to 255 do
    Getpal (loop1,oldpal[loop1,1],oldpal[loop1,2],oldpal[loop1,3]);
END;

Procedure Verblassen(VidM : boolean);
var
   loop1,loop2 : byte;
   tmp : array [1..3] of byte;

BEGIN
  For loop1:=1 to 64 do BEGIN
   if VidM then
     begin
       fire(vaddr);
       Flip(vaddr,VGASeg);  { Virtual all set... wack it to video }
     end;
{   WaitRetrace;}
    For loop2:=0 to 255 do BEGIN
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      If Tmp[1]>0 then dec (Tmp[1]);
      If Tmp[2]>0 then dec (Tmp[2]);
      If Tmp[3]>0 then dec (Tmp[3]);
      DAC(loop2,Tmp[1],Tmp[2],Tmp[3]);
    END;
  END;
END;

procedure CheckFiles;
  function Exist(FileName: string): Boolean;
      { Checks to see if filename exits or not }
  var f: file;
  begin
    {$I-}
    Assign(f, FileName);
    Reset(f);
    Close(f);
    {$I+}
    Exist := (IOResult = 0) and
    (FileName <> '');
  end;

  procedure Leave(FType : byte);
    begin
      case FType of
        1 : Writeln('Graphics [WEDNESD.DAT] not found!');
        2 : Writeln('Music module [MOOZ.DAT] not found! ');
        3 : Writeln('Sound config not found (type "MRESUME -setup")');
      end;
    halt;
    end;

begin
 If not Exist('WEDNESD.DAT') then Leave(1);
 if not Exist('MOOZ.DAT') then Leave(2);
 if not Exist('MIDAS.CFG') then Leave(3);
end;


Procedure Austellen;
var
   loop1,loop2 : byte;
   tmp : array [1..3] of byte;
BEGIN
  For loop1:=0 to 62 do BEGIN
    WaitRetrace;
    For loop2:=0 to 255 do BEGIN
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      If Tmp[1]<oldPal[loop2,1] then inc (Tmp[1]);
      If Tmp[2]<oldPal[loop2,2] then inc (Tmp[2]);
      If Tmp[3]<oldPal[loop2,3] then inc (Tmp[3]);
      DAC(loop2,Tmp[1],Tmp[2],Tmp[3]);
    END;
 end;
END;


procedure Wpal;
var
   loop1 : byte;
begin
  For loop1:=0 to 255 do
    DAC(loop1,0,0,0);
end;

begin
{
  Check for the presence of Windoze. It's an evil, evil weird!!
}
asm
 mov ax,1600h
 int 2fh
 mov WinPres,ax
end;
if lo(WinPres) <> 0 then
   begin
     Writeln('MRESUME requires pure DOS (Mode)...');
     halt;
   end;
{  if paramcount > 0 then
    begin
      if (Paramstr(1) = '-SETUP') or (Paramstr(1) = '-setup') then MidasConf;
    end;}
  EMMStatus;
  CheckFiles;
  PageAlloc(EMMHandle);
  SetupVirtual;
  loadpcx('wednesd.dat',vaddr);
{  checkmusic;}
  RPage:=1; a1:= 1; a2:= 1;
  Writeln('Hello there.  What you are about to see is my curriculum vitae in ');
  writeln('multimedia form.  It represents 4 hours solid programming work using');
  writeln('combined Borland Turbo Pascal with both inline and precompiled assembly');
  writeln('languages.  MRESUME uses direct port IO for keyboard, video and sound');
  writeln('routines and is an adequate (if not funky) representation of my');
  writeln('familiarity with PC Hardware and programming thereof.');
  writeln;
  Writeln(' / Pgup  ù  Use the up and down arrow or page keys to scroll through the');
  Writeln(' / PgDn     sections of my resume, and use the <ESC> key to quit.');
  writeln; Writeln('Press <ENTER> to continue.');
  readln;
{  plays3m('mooz.dat');}
  GrabPallette;
  Verblassen(False);

  Mode($13);  { yeah yeah... }
  C2EMMFlip(vaddr, EMMHandle);
  LoadPal;

  rt:= (360 * 3.14) / (255 * 360);
  for x:= 1 to 255 do
    begin
      r:= x * rt;
{      sintable[x]:= round(cos(r)+sin(r+2)* sin(r)* ColIndex);}
      sintable[x]:= round(cos(r)-sin(r-2)*
                         (cos(x+r))+sin(x-2-r)
                          -sin(r*2)
                          *ColIndex);

    end;

  EscFlag := False;

  while not EscFlag do
    begin
      EroticallyGirateTheDisplay;
      if Scan = 1 then break;
      if keypressed then
        asm
          xor ah,ah
          int 16h
        end;
    end;


  if keypressed then
    asm
    @@1000:
      xor ah,ah
      int 16h
      or  ah,ah
      jz @@1000
    end;

  GrabPallette;
  VerBlassen(True);
  Mode(3);
  GrabPallette;
  Wpal;
  Writeln('     .Thanks for watching.');
  Writeln;
  Writeln('Ú                              ¿');
  Writeln('  Grafics    ú Haplo (Orange)');
  Writeln('  Code/Music ú Michael Pearson ');
  Writeln('À                              Ù');
  Austellen;
{  checkmusic;}
  h_Disalloc(EMMHandle);
  ShutDown;
end.