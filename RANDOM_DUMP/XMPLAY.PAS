PROGRAM XMSPlayer; {Test Player Just for You To Test the XMS-Object !}
                   {The Player was written in Turbo Pascal !}
                   {The XMS-Object File was compiled with TASM 3.0 !}
USES CRT; {,FADE;     {Fade.TPU Is just a small Effect for the Text to Fade away}


{$F+}
{$L XMSOBJ.OBJ}    {The XMS-Object should be used is normaly set to $L+}
PROCEDURE _XMSFMPlayer; near; EXTERNAL;
PROCEDURE _StopXMSFM; near; EXTERNAL;
PROCEDURE _InitXMSFM; near; EXTERNAL;
{$F-}

type XMSFM = record
              Name   : string;
              Lenght : integer;
              OkeY   : boolean;
              Tune   : pointer;
              Buffer : pointer;
     end;

var Musik : XMSFM;


PROCEDURE LoadSong (VAR Test : XMSFM);
  VAR F : FILE;
  BEGIN
    ASSIGN (F,Test.Name);  {Here You can even put +(.xms) Then you don't need the Extension !}
    {$I-} RESET (F,1); {$I+}
    IF IORESULT <> 0
      THEN Test.OkeY := FALSE
      ELSE
        BEGIN
          Test.Lenght :=  FILESIZE (F);
          GETMEM (Test.Tune,Test.Lenght);
          GETMEM (Test.Buffer,1314);
          BLOCKREAD (F,Test.Tune^,Test.Lenght);
          Test.OkeY := TRUE;
          CLOSE (F)
        END
  END;

PROCEDURE ClearSong (VAR Test : XMSFM);  {IMPORTANT: YoU have to call these at }
  BEGIN                                  {the end of your Program to make sure }
    Test.OkeY := FALSE;                  {that the hole Buffer will be free again !}
    FREEMEM (Test.Tune,Test.Lenght);
    FREEMEM (Test.Buffer,1314);
    Test.Lenght := 0
  END;

var i : byte;

BEGIN
    BEGIN
        Musik.Name := 'C:\XMS\rainbow.XMS';
         LoadSong (Musik);
        IF Musik.OkeY
          THEN
            BEGIN
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
    END;
END.
