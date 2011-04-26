{
   Unit MIDILIB supporting seq.pas
   and MIDICMF.PAS
   }

Unit MIDILIB;

Interface

const
port     = $220;
reset    = port+$06;
readdata = port+$0a;
writecom = port+$0c;
writebuf = port+$0c;
dataavail= port+$0e;
Oldtimv  = 103;

TYPE
version=record
              high : byte;
              low  : byte;
end;

procedure resetDSP;
procedure writeday( n : byte);
function readdat : byte;
function polreaddat : byte;
procedure settimspeed( freq : word);
procedure settimer(freq : word; Rout : pointer);
procedure resettimer;
procedure get_version_number( var number : version);

implementation
uses dos,crt;

procedure resetDSP;
var
b: word;
begin
     port[reset]:=1;
     reset:=1;
     for b:=3 downto 0 do;
         port[reset]:=0;
         while (port[dataavail] and 128)=0 do;
         while not(port[readdata]=$aa) do;
         writeln('Reset DSP OK.');
     end;

procedure writedat(n: byte);
begin
     while (port[writebuf] and 128) <>0 do;
           port[writecom]:=n;
end;

function readdat : byte;
begin
     while (port[dataavail] and 128)<>0 do;
     readdat:=port[readdata];
end;

function polreaddat : byte;
begin
     while (((port[dataavail] and 128)=0) and not
              keypressed) do;
     polreaddat:=port[readdata];
end;

procedure settimspeed(freq : word);
var
   ICnt : longint;
begin
     inline($FA);
     ICnt:=1193180 div freq;
     port[$43]:=$36;
     port[$40]:=lo(ICnt);
     port[$40]:=hi(ICnt);
     inline($FB);
     writeln('Clock tik = ',freq);
end;

procedure settimer(freq : word; Rout : pointer);
var
   oldv : pointer;
begin
     inline($FA);
     getintvec(8,oldv);
     setomtvec(oldtimv,oldv);
setintvec(8,rout);
settimspeed(freq);
     inline($FB);
end;

procedure resettimer;
var
   oldv : pointer;
begin
     inline($FA);
     port[$43]:=$36;
     port[$40]:=$0
     port[$40]:=$0;
     getintvec(oldtimv,oldv);
     setintvec(8,oldv);
     inline($FB);
end;

procedure get_version_number(var number : version);
begin
     writedat($e1);
     number.high:=readdat;
     number.low:=readdat;
end;
end.


