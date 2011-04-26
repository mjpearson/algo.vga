Unit DSP;

Interface

function ResetDSP(base : word) : boolean;

procedure WriteDAC(level : byte);

function ReadDAC : byte;
function SpeakerOn: byte;
function SpeakerOff: byte;

procedure DMAStop;
procedure DMAContinue;
procedure Playsamp(sound : Pointer; size : word; frequency : word);
procedure SetVol(VolPart,volset : byte);

Implementation

Uses Crt;

var      DSP_RESET : word;
     DSP_READ_DATA : word;
    DSP_WRITE_DATA : word;
  DSP_WRITE_STATUS : word;
    DSP_DATA_AVAIL : word;

function ResetDSP(base : word) : boolean;
begin

  base := base * $10;

  { Calculate the port addresses }
  DSP_RESET := base + $206;
  DSP_READ_DATA := base + $20A;
  DSP_WRITE_DATA := base + $20C;
  DSP_WRITE_STATUS := base + $20C;
  DSP_DATA_AVAIL := base + $20E;

  { Reset the DSP, and give some nice long delays just to be safe }
  Port[DSP_RESET] := 1;
  Delay(10);
  Port[DSP_RESET] := 0;
  Delay(10);
  if (Port[DSP_DATA_AVAIL] And $80 = $80) And
     (Port[DSP_READ_DATA] = $AA) then
    ResetDSP := true
  else
    ResetDSP := false;
end;

procedure WriteDSP(value : byte);
begin
  while Port[DSP_WRITE_STATUS] And $80 <> 0 do;
  Port[DSP_WRITE_DATA] := value;
end;

function ReadDSP : byte;
begin
  while Port[DSP_DATA_AVAIL] and $80 = 0 do;
  ReadDSP := Port[DSP_READ_DATA];
end;

procedure WriteDAC(level : byte);
begin
  WriteDSP($10);
  WriteDSP(level);
end;

function ReadDAC : byte;
begin
  WriteDSP($20);
  ReadDAC := ReadDSP;
end;

function SpeakerOn: byte;
begin
  WriteDSP($D1);
end;

function SpeakerOff: byte;
begin
  WriteDSP($D3);
end;

procedure DMAContinue;
begin
  WriteDSP($D4);
end;

procedure DMAStop;
begin
  WriteDSP($D0);
end;

procedure Playsamp(sound : Pointer; size : word; frequency : word);
var time_constant : word;
     page, offset : word;
begin

  SpeakerOn;

  size := size - 1;

  { Set up the DMA chip }
  offset := Seg(sound^) Shl 4 + Ofs(sound^);
  page := (Seg(sound^) + Ofs(sound^) shr 4) shr 12;
  Port[$0A] := 5;
  Port[$0C] := 0;
  Port[$0B] := $49;
  Port[$02] := Lo(offset);
  Port[$02] := Hi(offset);
  Port[$83] := page;
  Port[$03] := Lo(size);
  Port[$03] := Hi(size);
  Port[$0A] := 1;

  { Set the playback frequency }
  time_constant := 256 - 1000000 div frequency;
  WriteDSP($40);
  WriteDSP(time_constant);

  { Set the playback type (8-bit) }
  WriteDSP($14);
  WriteDSP(Lo(size));
  WriteDSP(Hi(size));
end;

procedure SetVol(VolPart,volset : byte);
var
   index : byte;
begin
  case VolPart of
    1 :  index := $22;
    2 :  index := $04;
    3 :  index := $26;
    4 :  index := $28;
    5 :  index := $2e;
    6 :  index := $0a;
  end;

  asm
    mov dx,220h
    add dl,index
    mov al,volset
    out dx,al
  end;

end;

end.
