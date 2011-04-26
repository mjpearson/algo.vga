{*      MSETUP.C
 *
 * MIDAS Sound System configuration program
 *
 * Copyright 1995 Petteri Kangaslampi and Jarno Paananen
 *
 * This file is part of the MIDAS Sound System, and may only be
 * used, modified and distributed under the terms of the MIDAS
 * Sound System license, LICENSE.TXT. By continuing to use,
 * modify or distribute this file you indicate that you have
 * read the license and understand and accept it fully.
*}


uses midas, mconfig, vgatext;


var
    configured : integer;


BEGIN
    midasSetDefaults;                   { set MIDAS defaults }

    { Run MIDAS Sound System configuration: }
    configured := midasConfig;

    { Reset display mode: }
    vgaSetMode($03);

    if configured = 1 then
    begin
        { Configuration succesful - save configuration file: }
        midasSaveConfig('MIDAS.CFG');
        WriteLn('Configuration written to MIDAS.CFG');
    end
    else
    begin
        { Configuration unsuccessful: }
        WriteLn('Configuration NOT saved');
    end;
END.
