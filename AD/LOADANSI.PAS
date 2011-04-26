{ Velhejo.dat, bout,crow,bkansi }

const
     Ansi_Offsets : array [1..3] of word = (4096,8096,12096);
     Base_Offs = 2;

var
   f : file;

begin
  assign(f,'velhejo.dat');
  reset(f,1);
  seek(f,Ansi_Offsets[Base_Offs]);
  blockread(f,mem[$b800:0],4000);
  close(f);
end.