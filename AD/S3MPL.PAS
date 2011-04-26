{$G+}
unit s3mpl;

interface
{ Sound Shit... }
procedure ErrorExit(msg : string);
procedure unp;
procedure imp;

implementation

uses midas, sdevice, mplayer, modp, s3m, mfile, mmem, errors,
    mconfig;

const

    { pointers to all Module Players: }
    modulePlayers : array[0..1] of PModulePlayer =
        ( @mpS3M, @mpMOD);

var MP : PModulePlayer;
    SD : PSoundDevice;
    module : PmpModule;                 { current playing module }
    error, isConfig : integer;

procedure ErrorExit(msg : string);
begin
    WriteLn('Error: ', msg);
    midasClose;
    Halt;
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

        { Load module and start playing: }
     module := NewModule('c:\scream\dem\surreal.mod');
end;

procedure unp;
begin
  StopModule(module);
  midasClose;                         { uninitialize MIDAS }
end;

begin
end.