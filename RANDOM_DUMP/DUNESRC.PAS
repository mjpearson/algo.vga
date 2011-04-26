{I downloaded the DUNE! BBStro from CDROM.COM incoming/code-section,
 and wondered that there  was no source. Mmmmmhhhhh? Thanx to Niklas
 Beisert/pascal (CubicTeam) for his help, he used this effect before
 me in Lasse Reinbíng (and also Nooon in their great ASSEMBLY#1-demo
 Stars). So if you intend to rip the code,  please greet me,  or one
 of those groups mentioned before.  The source is not commented very
 well, but: REAL CODERS DON'T NEED COMMENTS

 (C) 1995 by QuoVadis}

{$G+}{$M 5000,0,40000}
const factor=7;
type palette=array[0..767] of byte;
var bseg,bseg2:word;
    xarray:array[0..319] of word;
    yarray:array[0..399] of word;
    cosinus:array[0..255] of byte;
    sinus:array[0..255] of byte;
    pal:palette;
    x,y:byte;
    i:word;

{$l scale.obj}
procedure ScaleUp(source,dest:word);External; { This is where the stuff goes }
procedure Fire(dest:word);External;           { Standard blur }
procedure CopyDW(source,dest:word);External;  { 32-bit copy }
procedure Dot(x,y,where:word;c:byte);External;{ No circle :-( }

procedure Mode(md:word);assembler;
asm
  mov ax,md
  int 10h
end;

function KeyPressed:byte;assembler;
{Mmmhh, faster ?}
asm
  in al,$60
  xor ah,ah
end;

procedure SetPal;assembler;
asm
  cli
  mov si,offset pal
  mov DX,3dah
  @l1:
  in AL,DX
  test AL,8d
  jnz @l1
  @l2:
  in AL,DX
  test AL,8d
  jz @l2
  mov cx,768
  mov dx,3C8h
  xor al,al
  out dx,al
  inc dx
  rep outsb
  sti
END;

procedure ramp(scol,r1,g1,b1,ecol,r2,g2,b2:byte;var p:palette);
{ramp colors}
var i:word;
    r,g,b:real;
begin
  i:=scol;
  r:=(r2-r1)/(ecol-scol);
  g:=(g2-g1)/(ecol-scol);
  b:=(b2-b1)/(ecol-scol);
  repeat
    p[i*3]  :=r1+round(r*(i-scol));
    p[i*3+1]:=g1+round(g*(i-scol));
    p[i*3+2]:=b1+round(b*(i-scol));
    inc(i);
  until i=ecol+1;
end;

procedure SetUpBuffer(var segment:word;size:word);
{I HATE GETMEM}
var StartAdress:word;
begin
  asm
    mov ax,4821h
    mov bx,size
    int 21h
    mov dx,ax
    jnb @l1
      mov dx,0a000h
      jmp @l2
    @l1:
      shl bx,2
      mov cx,bx
      mov es,ax
      xor di,di
      xor ax,ax
      rep stosw
    @l2:
    mov StartAdress,dx
  end;
  segment:=StartAdress;
  if StartAdress=$0a000 then begin
    asm mov ax,3h;int 10h;end;
    Writeln('Critical error - not enough memory to setup buffer');
    halt;
  end;
end;

procedure FreeBuffer(segment:word);assembler;
{I HATE FREEMEM, TOO}
asm
  mov ax,4921h
  mov bx,segment
  int 21h
end;

procedure init;
var i:word;
begin
  SetUpBuffer(bseg,4096);
  SetUpBuffer(bseg2,4096);
  {Just a few precalcs to gain speed}
  for i:=0 to 255 do cosinus[i]:=round(sin(2*pi*i/255)*35+82);
  for i:=0 to 255 do
           sinus[i]:=round(cos(2*pi*i/255)*80+390);
  for i:=0 to 319 do xarray[i]:=round(i/319*(319-(2*factor)))+factor;
  for i:=0 to 199 do begin
                       yarray[2*i]:=  round(i/199*(199-(2*factor))+factor)*320;
                       yarray[2*i+1]:=round(i/199*(199-(2*factor))+factor)*320;
                     end;
  ramp(  0, 0, 0, 0, 31,26, 3,38,pal);
  ramp( 32,26, 3,38, 63,15,39,63,pal);
  ramp( 64,15,39,63, 95,63,63,63,pal);
  ramp( 96,63,63,63,111,63,63, 3,pal);
  ramp(112,63,63, 3,130,63, 3,27,pal);
  mode($13);setpal;
end;

procedure leave;
begin
  FreeBuffer(bseg);
  FreeBuffer(bseg2);
  mode(3);
end;

begin
  init;
  repeat
    for i:=1 to 130 do dot(sinus[x]+random(80),cosinus[x]+random(80),bseg,130);
    inc(x,2);
    fire(bseg);
    ScaleUp(bseg,bseg2);
    CopyDW(bseg2,$0a000);

    for i:=1 to 20 do dot(random(320),random(140)+15,bseg2,90);
    fire(bseg2);
    ScaleUp(bseg2,bseg);
    CopyDW(bseg,$0a000);
  until keypressed=1;
  leave;
  Writeln('TIAS');
end.