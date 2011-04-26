{$F+}
{$L XMSOBJ.OBJ}    {The XMS-Object should be used is normaly set to $L+}
PROCEDURE _XMSFMPlayer; near; EXTERNAL;
PROCEDURE _StopXMSFM; near; EXTERNAL;
PROCEDURE _InitXMSFM; near; EXTERNAL;
{$F-}

{$I music.dat}  { Music Data }

Type Virtual = Array [0..4856] of byte;  { The size of our Virtual Screen }
     VirtPtr = ^Virtual;                 { Pointer to the virtual screen }

Type MBuffer = Array [0..1313] of byte;
     Buffer  = ^MBuffer;

VAR Virmus : VirtPtr;                      { My virtual music }
    Vaddr  : word;                         { The segment of my virtual music }
    Boffin : Buffer;                      { My virtual music }
    Baddr  : word;                         { The segment of my virtual music }

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetUpVirtual;
   { This sets up the memory needed for the virtual screen }
BEGIN
  GetMem (Virmus,4856);
  vaddr := seg (virmus^);
  GetMem (Boffin,1314);
  baddr := seg (Boffin^);

END;

Procedure ShutDown;
BEGIN
  FreeMem (VirMus,4856);
  GetMem  (Boffin,1314);
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Flip;
BEGIN
  Move (Virmus^,music,4856);
END;

begin
asm
                 push   ds
                 push   es
                 les    di,[Boffin]
                 lds    si,[Virmus]
                 xor    al,al           { IRQ-Modus it is used by _InitXMSFM ! }
                 call   _InitXMSFM
                 pop    es
                 pop    ds
              end;
end.