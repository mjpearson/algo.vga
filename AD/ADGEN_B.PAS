{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M 16384,0,655360}

uses crt;

const gctitles : array [1..2] of string =
     ('Whats your educational background? (3 maximum)',
      'And how good are you at : ');

{$I profdat.pas}       { Profession data }
{$I levelda.pas}
{$I bkans.pas}

      DownArrow  = $50;
      UpArrow    = $48;
      LeftArrow  = $4b;
      RightArrow = $4d;
      EnterKey   = $1c;

      MaxOps     = 2;
      SelectChar = '';

type
    Goffy = record
      Professions : array [1..3] of byte;
    end;

var
   Vert,scan,asc,i : byte;
   Cellcount, Itemcount, totalcount, titleindex : byte;
   AnsOfs,AnsSeg : word;
   leave : boolean;
   Gothique : Goffy;
   CurrentOp : byte;

procedure KbdHandler; Assembler;
asm
  xor ah,ah
  int 16h
  mov scan,ah
  mov asc,al
end;

procedure Kill_Line;
var
  _YIndex : byte;
  begin
    for _YIndex:= 1 to 18 do
      begin
        gotoxy(1,_Yindex);
        ClrEol;
      end;
  end;

procedure WriteSpecial(itn,_Vert : byte);
var
   ind : byte;
begin
  for ind:= 1 to profmax do
    begin
  if (Gothique.Professions[ind]) = itn then
       begin
         gotoxy(5,_Vert); Write(SelectChar);
       end;
     end;
end;

procedure _GcHandler(coffs : word; whichmnu : byte);
var
   MnuOffset : byte;
begin
  kill_line;
  textcolor(3);
  case WhichMnu of
    1 : MnuOffset:=17;
    2 : MnuOffset:=9;
  end;
  for i:= (coffs) to (coffs+MnuOffset) do
    begin
      gotoxy(1,i-coffs+1);
      case WhichMnu of
        1 :
           begin
             write(gcprofession[i,1],'  ù  ');
             write(gcprofession[i,2]);
             WriteSpecial(i,i-coffs+1);
           end;
        2 :
           begin
             write(levels[i,1],'  ù  ');
             write(levels[i,2]);
             WriteSpecial(i,i-coffs+1);
           end;
      end;
    end;
end;

procedure TitleHandler(headernum : byte);
var
   Xoffs : byte;
begin
  Window(2, 3, 78,22);
  case headernum of
    1 : Xoffs:=18;
    2 : Xoffs:=22;
  end;
  textcolor(5); ClrEol;
  gotoxy(Xoffs,1);write(gctitles[headernum]);
  if (Headernum > 1) and (headernum < 4) then
     Write(gcprofession[Gothique.Professions[headernum-1],1]);

  Window(4, 5, 78,22);

end;

procedure HiLightoc(Itemnum, d_type, _vert : byte);

  procedure OneLine(Whichline : integer);
    begin
      gotoxy(1,_vert+WhichLine);
      write(gcprofession[itemnum+WhichLine,1],'  ù  ');
      write(gcprofession[itemnum+WhichLine,2]);
      WriteSpecial(itemnum+WhichLine,_Vert+WhichLine);
    end;

begin
  textcolor(3);   { Normal text colour }
  case d_type of
    downarrow : OneLine(-1);
    uparrow : OneLine(1);
  end;
  textcolor(11);  {hilight colour }
  OneLine(0);
end;

procedure CellupDate(_Tcount : byte);

  procedure Sort;
   var vi : byte;
    begin
      for vi := 1 to 2 do
      begin
        if Gothique.Professions[1] = 0 then
          begin
            Gothique.Professions[1]:=Gothique.Professions[2];
            Gothique.Professions[2]:=Gothique.Professions[3];
            Gothique.Professions[3]:=0;
          end
        else
        if Gothique.Professions[2] = 0 then
           Gothique.Professions[3]:=Gothique.Professions[2];
      end;
    end;

var
   ArrayScan : byte;
   Flag : boolean;

begin
Flag := false;
 for arrayscan:= 1 to 3 do
   begin
     if (Gothique.Professions[ArrayScan] = 0) and (not Flag) then
       begin
         Gothique.Professions[ArrayScan]:=_Tcount;
         flag := true;
       end
   else
   if (Gothique.Professions[ArrayScan] = _TCount) then
   begin
    Gothique.Professions[ArrayScan]:=0;
    flag := true;
   end;
 Sort;
 end;
end;

begin
for itemcount:=1 to 3 do
  Gothique.Professions[itemcount]:=0;

ItemCount:=1; TitleIndex:=1; Vert:=1; totalcount:=1; Cellcount:=1;
CurrentOp:=1;
clrscr;

asm
  mov     ax,0100h
  mov     cx,0800h
  int     10h
end;

AnsOfs:=Ofs(BACKANS);
AnsSeg:=Seg(BACKANS);

move(Mem[AnsSeg:AnsOfs],Mem[$B800:0],4000);
TitleHandler(CurrentOp);
_GcHandler(ItemCount,1);
hilightoc(Vert,uparrow,Vert);

  repeat
    KbdHandler;
    case scan of

    UpArrow :
      begin
        dec(Vert); dec(totalcount);
        if Vert < 1 then
          begin
            dec(ItemCount);
            if (ItemCount) < 1 then ItemCount:=1;
            _GcHandler(ItemCount,1);
            Vert:=1;
          end;
          if totalcount < 1 then totalcount:=1;
        hilightoc(totalcount,uparrow,Vert);
      end;

    Downarrow :
      begin
        inc(Vert); inc(totalcount);
        if Vert > 18 then
          begin
            Vert:=18;
            inc(ItemCount);
            if (ItemCount) > 18 then ItemCount:=18;
            _GcHandler(ItemCount,1);
          end;
        if totalcount > profcount then
           totalcount := profcount;
        hilightoc(totalcount,downarrow,Vert);
      end;

    LeftArrow :
      begin
        dec(CurrentOp); if CurrentOp < 1 then CurrentOp:=1;
        TitleHandler(CurrentOp);
        clrscr;
        _GcHandler(1,CurrentOp);
        hilightoc(totalcount,0,Vert);
      end;

    RightArrow :
      begin
        inc(CurrentOp); if CurrentOp > MaxOps then CurrentOp:=MaxOps;
        TitleHandler(CurrentOp);
        clrscr;
        _GcHandler(1,CurrentOp);
        hilightoc(totalcount,0,Vert);
      end;
    EnterKey :
      begin
        cellupdate(totalcount);
        hilightoc(totalcount,0,Vert);
      end;

    1 : leave:=true

  end;

  until leave=true;

end.
