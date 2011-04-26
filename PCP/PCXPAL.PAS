var
  i,o:file;
  loop:word;
  outfile:string;
  palette:array[0..767] of byte;

procedure errormsg;
begin
writeln;
writeln('Usage: pcxpal infile.pcx outfile.ext');
writeln('Default name for outfile is out.pal');
halt;
end;

procedure doesntxst;
begin
writeln;
writeln('No such file.');
halt;
end;

begin
writeln('PCXPAL - extracts palette from 256c pcx-image');
writeln('Copyright 1996 Juri Vainonen - all rights trashed');
if paramcount=0 then errormsg;          {not enough parameters}
assign(i,paramstr(1));
if paramcount=1 then outfile:='out.pal' {our default outfilename}
	else outfile:=paramstr(2);
assign(o,outfile);
{$I-}
reset(i,1);
{$I+}
if IOresult <> 0 then doesntxst;      {let's see if input file exists..}
seek(i,filesize(i)-768);              {locate the palette}
blockread(i,palette,sizeof(palette)); {and read it}
close(i);

rewrite(o,1);
for loop:=0 to 767 do palette[loop]:=palette[loop] shr 2;{divide pal. values}
blockwrite(o,palette,sizeof(palette));                   {and write 'em}
close(o);
writeln('done');                                         {done.}
end.
