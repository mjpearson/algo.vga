{ Source to play Pro/FastTracker Modules using the PlayMOD units }

 program Test_MOD;

 {$M 8000,0,655360}

  uses
      Crt,Dos,SysProc,PlayMODs,Errors_E;

  var
     Cr             : char;
     I,Mode,LastBack: byte;
     CF,Min,Max     : word;
     TDir           : SearchRec;
     ModName        : string[80];

  begin
       ModName := 'surreal.mod';
       InitHardware;

       {Display error if any}
       if Err_Type>0 then
        begin
         writeln(Error_Msg(Err_Type));
         halt(Err_Type);
        end;

       Load_MODule(ModName);
       if Err_Type>0 then
         begin
           writeln(Error_Msg(Err_Type));
           halt(Err_Type);
         end
       else
        begin
          Cr:=#0;
         {set output mode}
	 {0,3 8-bit stereo, 16-bit mono
	  1   16-bit stereo
	  2   8-bit mono}
         {returns Min frequency available,
                  Max frequency available}
         Mode:=1;
         Set_Output_Mode(Mode,Min,Max);
         {set desired output frequency,
          returns closest output frequency}
         Set_Output_Freq(44100,CF);
         {enable oversampling}
         Set_LDI(true);
         {set digital amplification to 50/31}
         Set_Ampl_Num(50);
         {set module looping to 'forbidden'}
         {0 allowed}
         {1 forbidden}
         {2 forced}
         Set_Loop_Mode(1);
         {enable digital low-pass filter}
         Set_Filter(true);
         {set filter iterations to 1}
         Set_Iter_Filtre(1);
         {set default panning}
         Set_Default_Pan(42);
         {set fade out delay to 1 ms}
         Set_Fade_Out_Delay(1);
         {set master volume to maximum}
         Set_Master_Volume(64);

         Start_MODule;

         Writeln('Playing module... [',ModName,']');
         writeln('Press <ESC> to quit');

         repeat

         if Keypressed then
          begin
               Cr:=ReadKey;
          end;

         until (Cr in [#27]) or not Module_Playing;
         Stop_MODule;

       end;

       Stop_MODule;
       CloseHardware;

  end.
