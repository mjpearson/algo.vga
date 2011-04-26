 unit NewCrt;

 interface

 var
  LowClock  : longint absolute 0:$46C; {ticks since midnight}

  Procedure ReadKeyboard(var Code : word;var Car : char);
  function  KeyEntered:boolean;
  procedure WaitPeriod(Time_Period:word);
  Function  Str_UpCase(Strg : string):string;

 implementation

  Procedure ReadKeyboard(var CODE : word;var Car : char);
   begin
        asm
           mov ah,$10        ;{read extended keyboards}
           int $16
           les di,Code
           mov es:[di],ax
           les di,Car
           mov es:[di],al
        end;
    end;

  function KeyEntered;
   begin
        KeyEntered:=(mem[0:$41A]<>mem[0:$41C]);
   end;

  procedure WaitPeriod;
   const
        Quot : word = $6100;
   begin
        asm
           mov cx,Time_Period
           jcxz @@fin

           mov ax,$40
           mov es,ax
           xor di,di
           mov bl,es:[di]

           @@repeat:

            mov ax,[Quot]
            xor dx,dx

             @@loop:

              sub ax,1
              sbb dx,0
              jb @@end_loop
              cmp bl,es:[di]

             je @@loop
             @@end_loop:

           loop @@repeat

           @@fin:
        end;
   end;

  Function Str_UpCase;
   var
      L : byte;
   begin
        for L:=1 to length(Strg) do
         Strg[L]:=upcase(Strg[L]);
        Str_UpCase:=Strg;
   end;

 end.