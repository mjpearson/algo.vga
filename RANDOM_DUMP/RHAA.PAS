{ Yay.  A five minute program.  RHAA v1.0 }

program Rhaa;

var
  FromF, ToF: file;
  NumRead, NumWritten: Word;
  Buf: array[1..2048] of Char;
  Source : string;

procedure errormsg;
begin
Writeln;Writeln('Your argument needs some consideration.');
Writeln;Writeln('ie : RHAA infile  (Auto .RAW Extension)');
halt;
end;

procedure NExist;
begin
writeln;
writeln('File :',Source,' is bogus');
halt;
end;

begin
Writeln('     RHAA v1.0');
Writeln('컴컴컴컴컴컴컴컴컴컴');
Writeln('RAW Palette stripper.');

Source:=ParamStr(1)+'.raw';

if paramcount=0 then errormsg;          {not enough parameters}
  Assign(FromF, Source); { Open input file }
  Reset(FromF, 1);  { Record size = 1 }
  Assign(ToF, 'out.raw'); { Open output file }
  Rewrite(ToF, 1);  { Record size = 1 }
  if IOresult <> 0 then NExist;
  Writeln('Copying ', FileSize(FromF) - 768, ' bytes...');
  Seek(FromF,768);
  repeat
    BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
    BlockWrite(ToF, Buf, NumRead, NumWritten);
  until (NumRead = 0) or (NumWritten <> NumRead);
  Close(FromF);
  Close(ToF);
end.

