program ReadGDat;

uses
    crt;

type
    Goffy = record
      Code : string[2];
      Header : string[35];
      trailer : string[60];
    end;

var
   Gothique : Goffy;
   CurrBuffer : array [1..36,1..3] of string;
   f : file of Goffy;
   index : byte;

procedure LoadNewData(Lo,Hi : byte);
begin
    seek(f,lo);
for index := 1 to hi do
  begin
    read(f,Gothique);
    CurrBuffer[index,1]:=Gothique.Code;
    CurrBuffer[index,2]:=Gothique.Header;
    CurrBuffer[index,3]:=Gothique.Trailer;
  end;
for index := 1 to hi do
  begin
    writeln(CurrBuffer[index,1]);
    writeln(CurrBuffer[index,2]);
    writeln(CurrBuffer[index,3]);
    readln;
  end;
end;

begin
  assign(f,'gofdat');
  reset(f);
  clrscr;
  Writeln('There are ',filesize(f),' records'); readln;
  LoadNewData(0,35);
  Writeln(Filepos(f)); readln;
  reset(f);
  LoadNewData(36,44);
  close(f);
end.