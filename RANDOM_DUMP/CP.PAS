uses cputype;

begin

  if Isa8088 then
    cpu := CPU_8088
  else if Isa80486 then
    cpu := CPU_80486
  else if Isa80386 then
    cpu := CPU_80386
  else if Isa80286 then
    cpu := CPU_80286
  else if Isa80186 then
    cpu := CPU_80186
  else
    cpu := CPU_UNKNOWN;
writeln('Cpu Type : 80',cpu,'86');
end.