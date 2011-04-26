uses dsp;

type Sample = record
              SData   : pointer;
     end;

var
    Samp : Sample;
    Res : boolean;
    f : file;
    index : byte;
    playrate,sampsize : word;
    code : integer;

function Exist(FileName: string): Boolean;
      { Checks to see if filename exits or not }
  var f: file;
  begin
    {$I-}
    Assign(f, FileName);
    Reset(f);
    Close(f);
    {$I+}
    Exist := (IOResult = 0) and
    (FileName <> '');
 end;

procedure Lve(w : byte);
begin
  Writeln;
  case w of
    1 :
      Writeln('File [',paramstr(1),'] not found.');
    2 :
      Writeln(' þ  sampplay {filename.ext} {rate in hz}');
    3 :
      Writeln('DSP Chip could not be found/initialised');
  end;

  halt;
end;

begin

  if NOT ((paramstr(3) = '/S') or (paramstr(3) = '/s'))
  then Writeln('Samplay v1.0');

  if not (ParamCount = 3) then lve(2);
  if not exist(paramstr(1)) then lve(1);

for index:= 1 to 5 do
  begin
   Res:=resetdsp(index);
   if Res=True then break;
  end;

  if not Res then lve(3);

    SpeakerOn;
    val(paramstr(2),playrate,code);
    assign(f,paramstr(1));
    reset(f,1);
    seek(f,300);
    sampsize:=filesize(f)-500;
    GETMEM (Samp.SData,sampsize);
    blockread(f,Samp.SData^,sampsize);
    if NOT ((paramstr(3) = '/S') or (paramstr(3) = '/s')) then
      begin
        Writeln;
        Writeln('Playing sample - ',paramstr(1));
        Writeln('at ',playrate,' hz');
      end;
    Playsamp(Samp.Sdata,sampsize,playrate);
    freemem(Samp.SData,sampsize);
    close(f);

end.

