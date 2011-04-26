program CDPlayer;

uses Dos, Crt;

{Structure used to transfer commands to the CDROM driver}
type CommandStructure = record
  Length   : Byte;                    {Length of parameter block}
  SUC      : Byte;                    {SubUnitCode of CDROM drive,
                                       MSCDEX fills this in for us}
  FNr      : Byte;                    {Function number}
  SW       : Word;                    {Driver returns: Status word}
  Unused   : Array [$5..$D] of Byte;  {Unused}
  PBOfs    : Word;                    {Pointer to control block containing}
  PBSeg    : Word;                    {data for the specific function call}
end;

{Structure to receive information on the audio CD}
type CDInfoStructure = record
  SubFNr  : Byte;              {CDROM driver subfunction}
  First   : Byte;              {First track}
  Last    : Byte;              {Last track}
  LeadOut : LongInt;           {Location of the end of the last track}
end;

{Structure used to receive info on a specific track on the CD}
type TrackInfoStructure = record
  SubFNr  : Byte;                     {SubFunction number}
  TrackNr : Byte;                     {Track number}
  Address : LongInt;                  {Driver returns: Sector address}
  Status  : Byte;                     {Driver returns: Track status}
end;

{Structure used to start playing an audio track}
type PlayStructure = record
  Length   : Byte;                    {Length of parameter block}
  SUC     : Byte;                     {SubUnitCode of CDROM drive,
                                       MSCDEX fills this in for us}
  FNr     : Byte;                     {Function number}
  SW      : Word;                     {Driver returns: Status word}
  Unused  : Array [$5..$C] of Byte;   {Unused}
  Mode    : Byte;                     {Addressing mode (Using 1, Red Book)}
  Start   : LongInt;                  {Starting sector of the track}
  Sectors : LongInt;                  {Amount of sectors to play}
  {Bear in mind that one 'sector' equals one 75th of a second}
end;

{Structure used to stop playing an audio track}
type StopStructure = record
  Length   : Byte;                    {Length of parameter block}
  SUC     : Byte;                     {SubUnitCode of CDROM drive,
                                       MSCDEX fills this in for us}
  FNr     : Byte;                     {Function number}
  SW      : Word;                     {Driver returns: Status word}
end;

var
  Number_Of_Players : Byte;           {The amount of players installed}
  Drive_Letter      : Word;           {The drive letter of the first player}
  First_Track       : Byte;           {The first track on the current disc}
  Last_Track        : Byte;           {The last track on the current disc}
  LeadOut_Track     : LongInt;        {The end of the current disc}
  StatusWord        : Word;           {The result of a function call is
                                       stored here}

  TrackToPlay       : Byte;           {Stores the track the user wants to
                                       play}
  Done              : Boolean;        {Global indicator}
  Command           : CommandStructure;

{**************************************************************************
** Check whether MSCDEX is installed and controlling at least one player **
**************************************************************************}
function Check_MSCDEX : Boolean;
var
  Regs : Registers;

begin
  Regs.AX := $1500; {Function 0 - Get number of CDROM players installed}
  Regs.BX := 0;
  Intr ($2F, Regs);
  if Regs.BX > 0 then begin
    {If BX <> 0 then at least one player has been installed}
    {Return true}
    Check_MSCDEX      := true;
    {Store the number of CDROM players}
    Number_Of_Players := Regs.BX;
    {Store the drive indication of the first player}
    Drive_Letter      := Regs.CX;
    {Note: this programme only controls the first CDROM player installed,
           in theory it is possible to control more than one player,
           however, it is unlikely that someone either *has* more than
           one player or that a programmer wishes to play music through
           more than one player}
  end else begin
    {If BX = 0 then no players have been installed}
    {Return false}
    Check_MSCDEX := false;
  end;
end;

{**************************************************************************
** Converts RedBook sector notation to HSG sector number.                **
***************************************************************************
**  When calculating the amount of sectors to be played, it's nice to    **
**  have a start and end offset so we can just subtract them.            **
**  This expects a Red Book sector address in the form of                **
**    MMMMSSFF (minutes * 10000h + seconds * 100h + frames)              **
**  and returns the LSN (logical sector number)                          **
**************************************************************************}
function HSG (RedBook : LongInt) : LongInt;
var
  Frames,
  Seconds,
  Minutes : LongInt;

begin
  Frames  :=  RedBook mod $100;
  Seconds := (RedBook div $100) mod $100;
  Minutes := (RedBook div $10000);
  HSG := Frames + Seconds * 75 + Minutes * 60 * 75;
end;

{**************************************************************************
** Call MSCDEX which in turn calls the CDROM driver.                     **
***************************************************************************
**  This expects a control structure for a parameter.                    **
**************************************************************************}
procedure Call_CDROM_Driver (var DrivParms);
var
  Regs       : Registers;

begin
  {Set up for call to MSCDEX, which in turn calls the driver}
  Regs.AX := $1510;            {Function 10 - call CDROM driver}
  Regs.CX := Drive_Letter;     {Drive letter for first player}
  Regs.ES := Seg(DrivParms);   {Pointer to Parameterblock}
  Regs.BX := Ofs(DrivParms);
  Intr ($2F, Regs);            {Call MSCDEX}
end;

{**************************************************************************
** Get information regarding the current CD.                             **
***************************************************************************
**  That information consists of                                         **
**    - The number of the first track on the CD                          **
**    - The number of the last track on the CD                           **
**    - The total playing length of the CD                               **
**************************************************************************}
procedure GetAudioCDInfo;
var
  AudioCDInfo : CDInfoStructure;

begin
  Command.FNr      := 3;                {Function 3 - Direct Read}
  Command.PBOfs    := Ofs(AudioCDInfo);
  Command.PBSeg    := Seg(AudioCDInfo);
  Command.Length   := 17;

  AudioCDInfo.SubFNr := $A;             {SubFunction 10 - get audio CD info}
  Call_CDROM_Driver (Command);          {Call CDROM Driver}
  First_Track   := AudioCDInfo.First;   {Store first track number}
  Last_Track    := AudioCDInfo.Last;    {Store last track number}
  LeadOut_Track := AudioCDInfo.LeadOut; {Store end of CD}
  StatusWord    := Command.SW;
end;

{**************************************************************************
** Starts playback of a specific track on the CD.                        **
**************************************************************************}
procedure PlayTrack (Track : Byte);
var
  AudioTrackInfo : TrackInfoStructure;
  Play           : PlayStructure;

  StartOffSet    : LongInt;
  StopOffSet     : LongInt;
  SectorsToPlay  : LongInt;

begin
  Command.FNr      := 3;                {Function 3 - Direct Read}
  Command.PBOfs    := Ofs(AudioTrackInfo);
  Command.PBSeg    := Seg(AudioTrackInfo);
  Command.Length   := 17;

  AudioTrackInfo.SubFNr  := $B;    {Function 11 - Get audio track info}
  AudioTrackInfo.TrackNr := Track; {Number of the track}
  Call_CDROM_Driver(Command);

  {Check to see whether the track is indeed an audio track}
  if AudioTrackInfo.Status and $40 = $40 then begin
    {If not, display error message and don't try to start playing}
    writeln ('Can''t play data track!');
    exit;
  end;

  StartOffSet := AudioTrackInfo.Address; {Start of the track}

  {End of the track}
  if Track = Last_Track then begin
    {If it is the last, track, the end of the track is the LeadOut}
    StopOffSet := LeadOut_Track;
  end else begin
    {Otherwise, the end of this track is the start of the following track}
    Command.FNr      := 3;                {Function 3 - Direct Read}
    Command.PBOfs    := Ofs(AudioTrackInfo);
    Command.PBSeg    := Seg(AudioTrackInfo);
    Command.Length   := 17;

    AudioTrackInfo.SubFNr  := $B;        {Function 11 - Get audio track info}
    AudioTrackInfo.TrackNr := Track + 1; {Number of the next track}
    Call_CDROM_Driver(Command);
    StopOffSet := AudioTrackInfo.Address;
  end;

  {Calculate the amount of sectors to be played}
  SectorsToPlay := HSG (StopOffSet) - HSG (StartOffSet);

  {All right! That set up the start and end offsets of the track. Now we
  start the actual playing.}
  Play.FNr     := $84;                    {Function 84h - play audio track}
  Play.Mode    := 1;                      {Select Red Book addressing mode}
  Play.Start   := StartOffSet;            {Start of track}
  Play.Sectors := SectorsToPlay;          {Amount of sectors to play}
  Play.Length  := 21;
  Call_CDROM_Driver (Play);               {Call MSCDEX}
  StatusWord := Play.SW;                  {Return status word}
end;

{**************************************************************************
** Stops audio playback.                                                 **
**************************************************************************}
procedure StopPlaying;
var
  Stop           : StopStructure;

begin
  Stop.FNr     := $85;                    {Function 85h - stop playback}
  Stop.Length  := 5;
  Call_CDROM_Driver (Stop);               {Call MSCDEX}
  StatusWord := Stop.SW;       {Return status word}
end;

{**************************************************************************
** Check the statusword to see if any errors have occurred.              **
***************************************************************************
**  This should be called after any function call                        **
**  Returns the number of the error                                      **
**************************************************************************}
function CheckForErrors : Byte;
begin
  CheckForErrors := 0;
  {Check to see whether there was an error}
  if (StatusWord and $8000) > 0 then begin
    CheckForErrors := lo(StatusWord);
    case lo(StatusWord) of
      0 : Writeln ('Can''t write.');
      1 : Writeln ('Unknown player.');
      2 : Writeln ('No CD in player.');
      3 : Writeln ('Unknown function.');
      4 : Writeln ('CRC Error.');
      5 : Writeln ('Error in parameterblock.');
      6 : Writeln ('Seek fault.');
      7 : Writeln ('Unknown mediatype.');
      8 : Writeln ('Sector not found.');
      9 : Writeln ('Reserved.');
     10 : Writeln ('Write fault.');
     11 : Writeln ('Read fault.');
     12 : Writeln ('General failure error.');
     13 : Writeln ('Reserved');
     14 : Writeln ('Reserved');
     15 : Writeln ('Invalid CD Change.');
    end;
  end;
end;

begin
  ClrScr;
  {Check to see whether MSCDEX and at least one CDROM player are installed}
  if Check_MSCDEX = false then begin
    {If not, display error message and end programme}
    Writeln ('MSCDEX not installed or no CDROM drive available.');
    Halt;
  end else begin
    {If installed, display letter of first CDROM drive}
    Writeln ('CDROM installed as drive '+Chr(Drive_Letter + 65)+':');
  end;

  repeat
    {Get information on the number of tracks on the CD}
    GetAudioCDInfo;

    if CheckForErrors = 0 then begin
      {Ask the user which track to play}
      Writeln;
      Writeln ('Tracks on CD are ' , First_Track , ' through ' , Last_Track);
      Writeln ('Total playing time: ',
         LeadOut_Track shr 16              , 'm ',
        (LeadOut_Track and $FF00) shr 8    , '.',
        (100*LeadOut_Track and $FF) div 75 , 's');
      Writeln ('Choose 0 to end programme.');
      Write   ('Please choose a track to play: ');
      Readln  (TrackToPlay);

      {Stop audio playback}
      StopPlaying;
      CheckForErrors;
    end;

    {Check user input}
    if TrackToPlay = 0 then
      {If user has chosen to quit, set quit flag}
      Done := true
    else begin
      {otherwise, play the chosen track}
      PlayTrack (TrackToPlay);
      CheckForErrors;
    end;

  until Done = true;
end.