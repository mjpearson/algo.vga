#*      PM_EXP.MAK
#*
#* Make script for MIDAS Sound System Borland Pascal protected mode examples
#*
#* Copyright 1995 Petteri Kangaslampi and Jarno Paananen
#*
#* This file is part of the MIDAS Sound System, and may only be
#* used, modified and distributed under the terms of the MIDAS
#* Sound System license, LICENSE.TXT. By continuing to use,
#* modify or distribute this file you indicate that you have
#* read the license and understand and accept it fully.
#*


# Directories:

MIDASDIR = c:\midas


# Compilers and options:

PC = bpc
PCOPTS = /$G+ /$X+ /GS /Q /CP /D__BPPROT__ /U$(MIDASDIR)


MIDASTPU = $(MIDASDIR)\midas.tpp


all : msetup.exe mplay.exe effects.exe


msetup.exe : msetup.pas $(MIDASTPU)
        $(PC) $(PCOPTS) msetup.pas

mplay.exe : mplay.pas $(MIDASTPU)
        $(PC) $(PCOPTS) mplay.pas

effects.exe : effects.pas $(MIDASTPU)
        $(PC) $(PCOPTS) effects.pas
