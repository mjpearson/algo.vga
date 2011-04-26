type
    FileInfoBlock = record
      Reserved : array [1..21] of byte;
      Attrib   : byte;
      Time     : word;
      Date     : word;
      FileSize : array [1..2] of word;
      FileName : array [1..13] of char;
    end;

const
     StarDotStar : string[3] = '*.*';

var
   DriveBuff : array [1..64] of char;
   Drive     : char;
   DTA       : FileInfoBlock;
   ErrorCode : word;

procedure GetDirectory; Assembler;
  asm
    mov ah,47h
    xor dl,dl
    lea si,[DriveBuff]
    int 21h
    mov ah,19h
    int 21h
    add al,41h
    mov [Drive],al
  end;

procedure FindFirst;
var
   DTAddress : word;
begin
DTAddress:=Seg(DTA)+ofs(DTA);
  asm
    mov ah,1ah
    mov dx,offset DTAddress
    int 21h

    mov ah,4eh
    xor cx,cx
    lea dx,[StarDotStar]
    int 21h
    mov ErrorCode,ax
  end;
Writeln(DTA.FileName);
end;

begin
  asm
    mov ax,3
    int 10h
  end;
  GetDirectory;
  writeln('Files for directory : '+drive+':\'+DriveBuff);
  FindFirst;
  Case ErrorCode of
    2 : Writeln('File not found');
    3 : Writeln('Path not found');
  $12 : Writeln('No more files');
  end;
  readln;
end.