
uses crt;

const gctitles : array [1..2] of string =
     ('Whats your educational background? (3 maximum)',
      'And how good are you at ');

{$I profdat.pas}       { Profession data }
{$I levelda.pas}       { Level of achievement data }

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
      Level_Achieved : array [1..3] of byte;
    end;

var
   Vert,scan,asc,i : byte;
   CellCount,WhichItem, totalcount, titleindex : byte;
   Field1Count : byte;
   leave : boolean;
   Gothique : ^Goffy;
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

procedure WriteSpecial(itn,_Vert, _CurrentOp : byte);
var
   ind : byte;
begin
  case _CurrentOp of
    1 :
       for ind:= 1 to profmax do
         begin
          if (Gothique^.Professions[ind]) = itn then
            begin
              gotoxy(5,_Vert); Write(SelectChar);
            end;
         end;
  end;
end;
procedure _GcHandler(coffs : word; whichmnu : byte);
var
   MaxOnscreen : byte;
begin
  kill_line;
  textcolor(3);
  case WhichMnu of
    1 : MaxOnScreen:=17;
    2 : MaxOnScreen:=9;
  end;
  for i:= coffs to coffs+MaxOnScreen do
    begin
      gotoxy(1,i-coffs+1);
      case WhichMnu of
        1 :
           begin
             write(gcprofession[i,1],'  �  ');
             write(gcprofession[i,2]);
             write(gcprofession[i,3]);
             WriteSpecial(i,i-coffs+1,CurrentOp);
           end;
        2 :
           begin
             write(levels[i,1],'  �  ');
             write(levels[i,2]);
             WriteSpecial(i,i-coffs+1,CurrentOp);
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
    2 : Xoffs:=2;
  end;
  textcolor(5); ClrEol;
  gotoxy(Xoffs,1);write(gctitles[headernum]);

  if (Headernum > 1) and (headernum < 4) then
     Write(gcprofession[Gothique^.Professions[headernum-1],2]);

  Window(4, 5, 78,22);
end;

procedure HiLightoc(Itemnum, d_type, _vert, _CurrentOp : byte);

  procedure OneLine(Whichline : integer);
    begin
      gotoxy(1,_vert+WhichLine);
      case _CurrentOp of
        1 : begin
              write(gcprofession[itemnum+WhichLine,1],'  �  ');
              write(gcprofession[itemnum+WhichLine,2]);
            end;
        2 : begin
              write(levels[itemnum+WhichLine,1],'  �  ');
              write(levels[itemnum+WhichLine,2]);
            end;
      end;
      WriteSpecial(itemnum+WhichLine,_Vert+WhichLine,_CurrentOp);
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
        if Gothique^.Professions[1] = 0 then
          begin
            Gothique^.Professions[1]:=Gothique^.Professions[2];
            Gothique^.Professions[2]:=Gothique^.Professions[3];
            Gothique^.Professions[3]:=0;
          end
        else
        if Gothique^.Professions[2] = 0 then
           Gothique^.Professions[3]:=Gothique^.Professions[2];
      end;
    end;

var
   ArrayScan : byte;
   Flag : boolean;

begin
Flag := false; CellCount:=0;
 for arrayscan:= 1 to 3 do
   begin
     if (Gothique^.Professions[ArrayScan] = 0) and not Flag then
       begin
         Gothique^.Professions[ArrayScan]:=_Tcount;
         flag := true;
       end
   else
   if (Gothique^.Professions[ArrayScan] = _TCount) then
   begin
    Gothique^.Professions[ArrayScan]:=0;
    flag := true;
   end;
   Sort;
 end;

 for ArrayScan := 1 to 3 do
    if Gothique^.Professions[ArrayScan] <> 0 then inc(CellCount,1)

end;

procedure MultMnuHandler(_CurrentOp : byte;
                         Var _TotalCount : byte);
begin
  case _CurrentOp of
    1 : begin
          if _TotalCount > Profcount then
             _TotalCount := Profcount;
        end;
    2 : begin
          if _TotalCount > LevCount then
             _TotalCount := LevCount;
        end;
  end;
end;

procedure Startup;
var f : file;
begin
  for WhichItem:=1 to 3 do Gothique^.Professions[WhichItem]:=0;

  WhichItem:=1;  TitleIndex:=1; Vert:=1;
  totalcount:=1; CellCount:=0;  CurrentOp:=1;

  clrscr;
  asm
    mov     ax,0100h
    mov     cx,0800h
    int     10h
  end;
  assign(f,'bkansi.bin');
  reset(f,1);
  blockread(f,mem[$b800:0],4000);
  TitleHandler(CurrentOp);
  _GcHandler(WhichItem,1);
  hilightoc(Vert,uparrow,Vert,1);
end;

procedure NewMenuInit(Direction, _Cellcount : byte);
begin
  if _Cellcount > 0 then
    begin
      case Direction of
        LeftArrow :
          begin
            dec(CurrentOp);
            if CurrentOp < 1 then CurrentOp:=1;
          end;
        RightArrow :
          begin
            inc(CurrentOp);
            if CurrentOp > MaxOps then CurrentOp:=MaxOps;
          end;
      end;
    clrscr;
    WhichItem:=1;  TitleIndex:=1; Vert:=1; totalcount:=1;
  end;
  TitleHandler(CurrentOp);
  _GcHandler(1,CurrentOp);
   hilightoc(totalcount,0,Vert,CurrentOp);
end;

Procedure TrapDown(_CurrentOp : byte);
var
   MaxOS : byte;
begin
  inc(totalcount);
  case _CurrentOp of
    1 :
        MaxOS := 18;

    2 :
        MaxOS := 10;
  end;

 inc(Vert);
 if Vert > MaxOS then
    begin
      case _Currentop of
        1 : begin
              inc(WhichItem);
              if (WhichItem) > MaxOS then WhichItem:=MaxOS;
            end;
      end;
      Vert:=MaxOS;
      _GcHandler(WhichItem,_CurrentOp);
    end;
  MultMnuHandler(CurrentOp, TotalCount);
  hilightoc(totalcount,downarrow,Vert,CurrentOp);
end;

begin
Startup;
  repeat
    KbdHandler;
    case scan of

    UpArrow :
      begin
        dec(Vert); dec(totalcount);
        if Vert < 1 then
          begin
            dec(WhichItem);
            if (WhichItem) < 1 then WhichItem:=1;
            _GcHandler(WhichItem,CurrentOp);
            Vert:=1;
          end;
          if totalcount < 1 then totalcount:=1;
        hilightoc(totalcount,uparrow,Vert,CurrentOp);
      end;

    Downarrow : TrapDown(CurrentOp);

    LeftArrow : NewMenuInit(LeftArrow,CellCount);

    RightArrow : NewMenuInit(RightArrow,CellCount);


    EnterKey :
      begin
        cellupdate(totalcount);
        hilightoc(totalcount,0,Vert,CurrentOp);
      end;

    1 : leave:=true

  end;

  until leave=true;

{window(1,1,25,80);clrscr;}
asm mov ax,3; int 10h; end;

end.
