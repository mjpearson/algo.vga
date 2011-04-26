{*      EFFECTS.C
 *
 * Example on how to play simultaneous music and sound effects
 * using MIDAS Sound System
 *
 * Copyright 1995 Petteri Kangaslampi and Jarno Paananen
 *
 * This file is part of the MIDAS Sound System, and may only be
 * used, modified and distributed under the terms of the MIDAS
 * Sound System license, LICENSE.TXT. By continuing to use,
 * modify or distribute this file you indicate that you have
 * read the license and understand and accept it fully.
*}


uses crt, midas, sdevice, mplayer, modp, mtm, s3m, mfile, mmem, errors,
    mconfig;


const
    { number of sound effect channels: }
    FXCHANNELS = 2;

    { maximum number of channels in music: }
    MAXMUSCHANNELS = 16;

    { sound effect playing rate: }
    FXRATE = 12090;

    usage : string =
    'Usage:  EFFECTS <module> <effect #1> <effect #2> <looping effect #3>';

    { pointers to all Module Players: }
    modulePlayers : array[0..NUMMPLAYERS-1] of PModulePlayer =
        ( @mpS3M, @mpMOD, @mpMTM );

var
    fxChannel : integer;
    MP : PModulePlayer;
    SD : PSoundDevice;




{****************************************************************************\
*
* Function:     ErrorExit(msg : string);
*
* Description:  Prints an error message, uninitializes MIDAS and exits to DOS
*
* Input:        msg : string            error message
*
\****************************************************************************}

procedure ErrorExit(msg : string);
begin
    WriteLn('Error: ', msg);
    midasClose;
    Halt;
end;




{****************************************************************************\
*
* Function:     toASCIIZ(dest : PChar; str : string) : PChar;
*
* Description:  Converts a string to ASCIIZ format. (StrPCopy is NOT available
*               in real mode!)
*
* Input:        msg : string            string to be converted
*               dest : PChar            destination buffer
*
* Returns:      Pointer to the converted string;
*
\****************************************************************************}

function toASCIIZ(dest : PChar; str : string) : PChar;
var
    spos, slen : integer;
    i : integer;

begin
    spos := 0;                          { string position = 0 }
    slen := ord(str[0]);                { string length }

    { copy string to ASCIIZ conversion buffer: }
    while spos < slen do
    begin
        dest[spos] := str[spos+1];
        spos := spos + 1;
    end;

    dest[spos] := chr(0);               { put terminating 0 to end of string }

    toASCIIZ := dest;
end;




{****************************************************************************\
*
* Function:     LoadEffect(fileName : PChar; looping : integer) : word;
*
* Description:  Loads a raw effect sample that can be used with PlayEffect().
*
* Input:        fileName : PChar        name of sample file
*               looping : integer       1 if the sample is looping, 0 if not
*
* Returns:      Instrument handle that can be used with PlayEffect() and
*               FreeEffect().
*
\****************************************************************************}

function LoadEffect(fileName : PChar; looping : integer) : word;
var
    instHandle : word;                  { Sound Device instrument handle }
    error : integer;
    f : fileHandle;
    smpLength : longint;                { sample length }
    smpBuf : ^byte;                     { sample loading buffer }
begin
    { open sound effect file: }
    error := fileOpen(fileName, fileOpenRead, @f);
    if error <> OK then
        midasError(error);

    { get file length: }
    error := fileGetSize(f, @smpLength);
    if error <> OK then
        midasError(error);

    { check that sample length is not too long: }
    if smpLength > SMPMAX then
        midasError(errInvalidInst);

    { allocate memory for sample loading buffer: }
    error := memAlloc(smpLength, @smpBuf);
    if error <> OK then
        midasError(error);

    { load sample: }
    error := fileRead(f, smpBuf, smpLength);
    if error <> OK then
        midasError(error);

    { close sample file: }
    error := fileClose(f);
    if error <> OK then
        midasError(error);

    { Add sample to Sound Device list and get instrument handle to
      instHandle: }
    if looping = 1 then
    begin
        error := SD^.AddInstrument(smpBuf, smp8bit, smpLength, 0, smpLength,
            64, 1, 1, @instHandle);
    end
    else
    begin
        error := SD^.AddInstrument(smpBuf, smp8bit, smpLength, 0, 0, 64, 0,
            1, @instHandle);
    end;

    if error <> OK then
        midasError(error);

    { deallocate sample allocation buffer: }
    error := memFree(smpBuf);
    if error <> OK then
        midasError(error);

    { return instrument handle: }
    LoadEffect := instHandle;
end;




{****************************************************************************\
*
* Function:     FreeEffect(instHandle : word);
*
* Description:  Deallocates a sound effect
*
* Input:        instHandle : word       effect instrument handle returned by
*                                       LoadEffect()
*
\****************************************************************************}

procedure FreeEffect(instHandle : word);
var
    error : integer;
begin
    { remove instrument from Sound Device list: }
    error := SD^.RemInstrument(instHandle);
    if error <> OK then
        midasError(error);
end;




{****************************************************************************\
*
* Function:     PlayEffect(instHandle : word; rate : longint; volume : word;
*                   panning : integer);
*
* Description:  Plays a sound effect
*
* Input:        instHandle : word       effect instrument handle, returned by
*                                           LoadEffect().
*               rate : longint          effect sampling rate, in Hz
*               volume : word           effect playing volume, 0-64
*               panning : integer       effect panning (see enum sdPanning in
*                                           SDEVICE.H)
*
\****************************************************************************}

procedure PlayEffect(instHandle : word; rate : longint; volume : word;
    panning : integer);
var
    error : integer;
begin
    { set effect instrument to current effect channel: }
    error := SD^.SetInstrument(fxChannel, instHandle);
    if error <> OK then
        midasError(error);

    { set effect volume: }
    error := SD^.SetVolume(fxChannel, volume);
    if error <> OK then
        midasError(error);

    { set effect panning: }
    error := SD^.SetPanning(fxChannel, panning);
    if error <> OK then
        midasError(error);

    { start playing effect: }
    error := SD^.PlaySound(fxChannel, rate);
    if error <> OK then
        midasError(error);

    fxChannel := fxChannel + 1;         { channel for next effect }
    if fxChannel >= FXCHANNELS then
        fxChannel := 0;
end;




{****************************************************************************\
*
* Function:     NewModule(fileName : PChar) : PmpModule;
*
* Description:  Detects the type of a module and starts playing it
*
* Input:        fileName : PChar        module file name
*
\****************************************************************************}

function NewModule(fileName : PChar) : PmpModule;
var
    header : ^byte;
    f : fileHandle;
    module : PmpModule;
    error, mpNum, recognized : integer;

begin
    { allocate memory for module header: }
    error := memAlloc(MPHDRSIZE, @header);
    if error <> OK then
        midasError(error);

    { open module file: }
    error := fileOpen(fileName, fileOpenRead, @f);
    if error <> OK then
        midasError(error);

    { read MPHDRSIZE bytes of module header: }
    error := fileRead(f, header, MPHDRSIZE);
    if error <> OK then
        midasError(error);

    error := fileClose(f);
    if error <> OK then
        midasError(error);

    { Search through all Module Players to find one that recognizes the
      file header: }
    mpNum := 0; MP := NIL;

    while (mpNum < NUMMPLAYERS) and (MP = NIL) do
    begin
        error := modulePlayers[mpNum]^.Identify(header, @recognized);
        if error <> OK then
            midasError(error);

        if recognized = 1 then
            MP :=modulePlayers[mpNum];
        mpNum := mpNum + 1;
    end;

    { deallocate module header: }
    error := memFree(header);
    if error <> OK then
        midasError(error);

    if MP = NIL then
        ErrorExit('Unknown module format');

    { load the module file using correct Module Player: }
    module := midasLoadModule(fileName, MP, NIL);

    { check that the module does not have too many channels: }
    if module^.numChans > MAXMUSCHANNELS then
        ErrorExit('Too many channels in module');

    { start playing the module: }
    midasPlayModule(module, 0);

    NewModule := module;
end;




{****************************************************************************\
*
* Function:     StopModule(module : PmpModule);
*
* Description:  Stops playing a module and deallocates it
*
* Input:        module : PmpModule      pointer to module structure
*
\****************************************************************************}

procedure StopModule(module : PmpModule);
begin
    midasStopModule(module);
    midasFreeModule(module);
end;



var
    module : PmpModule;                 { current playing module }
    effect1, effect2, effect3 : word;   { sound effect handles }
    quit, error, i, isConfig : integer;
    masterVolume : word;                { music master volume }
    defAmplify : word;                  { default amplification }
    amplification : word;               { current amplification }
    fileName : string;
    str : array[0..256] of char;
    free1 : longint;



BEGIN
    quit := 0;
    masterVolume := 64;

    free1 := MaxAvail;

    { ParamStr(1) is the module filename, ParamStr(2), (3) and (4) are the
      effect file names. }

    { Check that there are exactly four arguments: }
{    if ParamCount <> 4 then
    begin
        WriteLn(usage);
        halt;
    end;
}
    { Check that the configuration file exists: }
    error := fileExists('MIDAS.CFG', @isConfig);
    if error <> OK then
        midasError(error);
    if isConfig <> 1 then
    begin
        WriteLn('Configuration file not found - run MSETUP.EXE');
        Halt;
    end;

    midasSetDefaults;                   { set MIDAS defaults }
    midasLoadConfig('MIDAS.CFG');       { load configuration }

    midasInit;                          { initialize MIDAS Sound System }
    SD := midasSD;                      { copy Sound Device pointer }

    { Open channels for music and sound effects. The first FXCHANNELS
      channels will always be free for playing effects: }
    midasOpenChannels(FXCHANNELS + MAXMUSCHANNELS);

    { Get Sound Device default amplification value: }
    error := SD^.GetAmplification(@defAmplify);
    if error <> OK then
        midasError(error);
    amplification := defAmplify;

    { Load module and start playing: }
 {   module := NewModule(toASCIIZ(str, ParamStr(1)));}
     module := NewModule('C:\SCREAM\DEM\AFFINITY.MOD');

    { Load sound effect samples and store the instrument handles: }
  {  effect1 := LoadEffect(toASCIIZ(str, ParamStr(2)), 0);
    effect2 := LoadEffect(toASCIIZ(str, ParamStr(3)), 0);
    effect3 := LoadEffect(toASCIIZ(str, ParamStr(4)), 1);}
    effect1 := LoadEffect('UD.SMP',0);
    effect2 := LoadEffect('side.SMP',0);
    effect3 := LoadEffect('port.SMP',0);

    fxChannel := 0;

    WriteLn('Keys:');
    WriteLn('        1,2,3   Play effect');
    WriteLn('        Enter   New module');
    WriteLn('        +,-     Adjust music volume');
    WriteLn('        Esc     Exit');
    Writeln('Mem total   : ',MaxAvail,' bytes');
    WriteLn('Memory Used : ', free1 - MaxAvail, ' bytes');

    while quit = 0 do
    begin
        case ReadKey of
            chr(27):    { Escape - quit }
                quit := 1;

            chr(13):    { Enter - new module }
                begin
                    WriteLn('Enter new module file name:');
                    ReadLn(fileName);
                    StopModule(module);
                    module := NewModule(toASCIIZ(str, fileName));
                    WriteLn('Memory Used: ', free1 - MaxAvail, ' bytes');
                end;

            '1':        { '1' - play first effect }
                PlayEffect(effect1, FXRATE, 64, panMiddle{-40});

            '2':        { '2' - play second effect }
                PlayEffect(effect2, FXRATE+1800, 64, panMiddle{40});

            '3':        { '3' - play third effect }
                PlayEffect(effect3, FXRATE, 64, panMiddle);

            '+':        { '+' - increase music volume }
                begin
                    if masterVolume < 64 then
                    begin
                        masterVolume := masterVolume + 4;
                        error := MP^.SetMasterVolume(masterVolume);
                        if error <> OK then
                            midasError(error);
                    end;

                    { Calculate the amplification value that corresponds to
                      the current decrease in volume (in respect to the Sound
                      Device default amplification value): }
                    amplification := word(longint(defAmplify) * longint(64) *
                        longint(MAXMUSCHANNELS+FXCHANNELS) div
                        longint(MAXMUSCHANNELS * masterVolume +
                        FXCHANNELS * 64));

                    error := SD^.SetAmplification(amplification);
                    if error <> OK then
                        midasError(error);

                    WriteLn('Music volume: ', masterVolume,
                        ', amplification: ', amplification);
                end;


            '-':        { '-' - decrease music volume }
                begin
                    if masterVolume > 8 then
                    begin
                        masterVolume := masterVolume - 4;
                        error := MP^.SetMasterVolume(masterVolume);
                        if error <> OK then
                            midasError(error);
                    end;

                    { Calculate the amplification value that corresponds to
                      the current decrease in volume (in respect to the Sound
                      Device default amplification value): }
                    amplification := word(longint(defAmplify) * longint(64) *
                        longint(MAXMUSCHANNELS+FXCHANNELS) div
                        longint(MAXMUSCHANNELS * masterVolume +
                        FXCHANNELS * 64));

                    error := SD^.SetAmplification(amplification);
                    if error <> OK then
                        midasError(error);

                    WriteLn('Music volume: ', masterVolume,
                        ', amplification: ', amplification);
                end;
        end;
    end;

    StopModule(module);
    FreeEffect(effect1);                { deallocate effect #1 }
    FreeEffect(effect2);                { deallocate effect #2 }
    FreeEffect(effect3);                { deallocate effect #3 }
    midasClose;                         { uninitialize MIDAS }

    WriteLn('Memory Used: ', free1 - MaxAvail, ' bytes');
END.
