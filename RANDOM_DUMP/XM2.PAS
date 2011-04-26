PROGRAM XMSPlayer; {Test Player Just for You To Test the XMS-Object !}
                   {The Player was written in Turbo Pascal !}
                   {The XMS-Object File was compiled with TASM 3.0 !}
USES CRT;

{$F+}
{$I music.dat}
{$L XMSOBJ.OBJ}    {The XMS-Object should be used is normaly set to $L+}
PROCEDURE _XMSFMPlayer; near; EXTERNAL;
PROCEDURE _StopXMSFM; near; EXTERNAL;
PROCEDURE _InitXMSFM; near; EXTERNAL;

type XMSFM = record
              Tune   : pointer;
              Buffer : pointer;
     end;

var Musik : XMSFM;


PROCEDURE LoadSong (VAR Test : XMSFM);
  VAR F : FILE;
  BEGIN
    ASSIGN (F,'c:\xms\sumerfun.xms');  {Here You can even put +(.xms) Then you don't need the Extension !}
    RESET (F,1);
        BEGIN
          GETMEM (Test.Tune,4857);
          GETMEM (Test.Buffer,1314);
          move (music,Test.Tune^,4857);
          CLOSE (F)
        END
  END;

PROCEDURE ClearSong (VAR Test : XMSFM);  {IMPORTANT: YoU have to call these at }
  BEGIN                                  {the end of your Program to make sure }
    FREEMEM (Test.Tune,4857);
    FREEMEM (Test.Buffer,1314);
  END;

var i : byte;


BEGIN
    BEGIN
         LoadSong (Musik);
              asm
                 push   ds
                 push   es
                 les    di,Musik.Buffer
                 lds    si,Musik.Tune
                 xor    al,al           { IRQ-Modus it is used by _InitXMSFM ! }
                 call   _InitXMSFM
                 pop    es
                 pop    ds
              end;
              repeat           until port[$60]=1;  {Just ESC-Key !}
              asm
                 call   _StopXMSFM   {Need to Stop Playing the Song !}
              end;

              ClearSong (Musik);
            END
END.
