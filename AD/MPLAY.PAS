{*      MPLAY.PAS
 *
 * Minimal Protracker module player using MIDAS Sound System
 *
 * Copyright 1995 Petteri Kangaslampi and Jarno Paananen
 *
 * This file is part of the MIDAS Sound System, and may only be
 * used, modified and distributed under the terms of the MIDAS
 * Sound System license, LICENSE.TXT. By continuing to use,
 * modify or distribute this file you indicate that you have
 * read the license and understand and accept it fully.
*}


uses midas, mfile, mplayer, modp, errors, mconfig;


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




var
    module : PmpModule;
    i, error, isConfig : integer;
    str : array [0..256] of char;


BEGIN

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

    { Convert command line argument to ASCIIZ and load module: }
    module := midasLoadModule('C:\SCREAM\ILLUMINA.MOD', @mpMOD, NIL);

    midasPlayModule(module, 0);         { start playing }

    WriteLn('Playing - press Enter to stop');
    ReadLn;

    midasStopModule(module);            { stop playing }
    midasFreeModule(module);            { deallocate module }
    midasClose;                         { uninitialize MIDAS }
END.
