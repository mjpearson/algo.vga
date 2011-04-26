unit Phunki;

interface

{ Sound Shit... }
procedure ErrorExit(msg : string);
function  LoadEffect(fileName : PChar; looping : integer) : word;
procedure FreeEffect(instHandle : word);
procedure PlayEffect(w_handle : byte; rate : longint; volume : word);
procedure MidasConf;
procedure imp;
procedure unp;

implementation

uses midas, sdevice, mplayer, modp, mtm, s3m, mfile, mmem, errors,
    mconfig, crt,Dos;

const
    { pointers to all Module Players: }
    modulePlayers : array[0..NUMMPLAYERS-1] of PModulePlayer =
        ( @mpS3M, @mpMOD, @mpMTM );

var    fxChannel : integer;
    MP : PModulePlayer;
    SD : PSoundDevice;
    module : PmpModule;                 { current playing module }
    effect1, effect2, effect3 : word;   { sound effect handles }
    error, isConfig : integer;
    masterVolume : word;                { music master volume }
    defAmplify : word;                  { default amplification }
    amplification : word;               { current amplification }
    free1 : longint;
   reg : Registers;

procedure ErrorExit(msg : string);
begin
    WriteLn('Error: ', msg);
    midasClose;
    Halt;
end;

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

procedure FreeEffect(instHandle : word);
var
    error : integer;
begin
    { remove instrument from Sound Device list: }
    error := SD^.RemInstrument(instHandle);
    if error <> OK then
        midasError(error);
end;

procedure PlayEffect(w_handle : byte; rate : longint; volume : word);

var
    error : integer;
    instHandle : word;
begin
 if w_handle = 1 then insthandle:=effect1
 else if w_handle = 2 then insthandle:=effect2
 else if w_handle = 3 then insthandle:=effect3;
    { set effect instrument to current effect channel: }
    error := SD^.SetInstrument(fxChannel, instHandle);
    if error <> OK then
        midasError(error);

    { set effect volume: }
    error := SD^.SetVolume(fxChannel, volume);
    if error <> OK then
        midasError(error);

    { set effect panning: }
    error := SD^.SetPanning(fxChannel, panMiddle);
    if error <> OK then
        midasError(error);

    { start playing effect: }
    error := SD^.PlaySound(fxChannel, rate);
    if error <> OK then
        midasError(error);

    fxChannel := fxChannel + 1;         { channel for next effect }
    if fxChannel >= 2 then
        fxChannel := 0;
end;

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
    if module^.numChans > 16 then
        ErrorExit('Too many channels in module');

    { start playing the module: }
    midasPlayModule(module, 0);

    NewModule := module;
end;

procedure StopModule(module : PmpModule);
begin
    midasStopModule(module);
    midasFreeModule(module);
end;

procedure imp;
begin
  masterVolume := 64;
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
    midasOpenChannels(18);

    { Get Sound Device default amplification value: }
    error := SD^.GetAmplification(@defAmplify);
    if error <> OK then
        midasError(error);
    amplification := defAmplify;

    { Load module and start playing: }
     module := NewModule('.\data\vampyra3.s3m');

    { Load sound effect samples and store the instrument handles: }
    effect1 := LoadEffect('.\data\UD.SMP',0);
    effect2 := LoadEffect('.\data\pop.SMP',0);
    effect3 := LoadEffect('.\data\port.SMP',0);

    fxChannel := 0;

end;

procedure MidasConf;
var
    configured : integer;


BEGIN
    midasSetDefaults;                   { set MIDAS defaults }

    { Run MIDAS Sound System configuration: }
    configured := midasConfig;

    { Reset display mode: }
    asm mov ax,3; int 10h; end;

    if configured = 1 then
    begin
        { Configuration succesful - save configuration file: }
        midasSaveConfig('MIDAS.CFG');
        WriteLn('Configuration written to MIDAS.CFG');
        halt;
    end
    else
    begin
        { Configuration unsuccessful: }
        WriteLn('Configuration NOT saved');
        halt;
    end;
end;

procedure unp;
begin
  StopModule(module);
  FreeEffect(effect1);                { deallocate effect #1 }
  FreeEffect(effect2);                { deallocate effect #2 }
  FreeEffect(effect3);                { deallocate effect #3 }
  midasClose;                         { uninitialize MIDAS }
end;

end.
