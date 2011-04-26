uses dos,crt;

          Type
            ST3  = string[3];
            ST80 = string[80];
            ST5  = string[5];

            Registers = record
              case integer of
                1: (AX,BX,CX,DX,BP,SI,DI,DS,ES,FLAGS: Integer);
                2: (AL,AH,BL,BH,CL,CH,DL,DH         : Byte);
              end;

          Const
            EMM_INT                    = $67;
            DOS_Int                    = $21;
            GET_PAGE_FRAME             = $41;
            GET_UNALLOCATED_PAGE_COUNT = $42;
            ALLOCATE_PAGES             = $43;
            MAP_PAGES                  = $44;
            DEALLOCATE_PAGES           = $45;
            GET_VERSION                = $46;
            STATUS_OK                  = 0;

            {------------------------------------------------------------}
            { Assume the application needs one EMM page.                 }
            {------------------------------------------------------------}
            APPLICATION_PAGE_COUNT = 1;

          Var
            Regs: Registers;

            Emm_handle,
            Page_Frame_Base_Address,
            Pages_Needed,
            Physical_Page,
            Logical_Page,
            Offset,
            Error_Code,
            Pages_EMM_Available,
            Total_EMM_Pages,
            Available_EMM_Pages: Integer;

            Version_Number,
            Pages_Number_String: ST3;

            Verify: Boolean;

            {------------------------------------------------------------}
            { The function Hex_String converts an integer into a four    }
            { character hexadecimal number (string) with leading zeros.  }
            {------------------------------------------------------------}
            Function Hex_String (Number: Integer): ST5;
              Function Hex_Char (Number: Integer): Char;
                Begin
                  If Number < 10 then
                    Hex_Char := Char (Number + 48)
                  else
                    Hex_Char := Char (Number + 55);
                end; { Function Hex_char }

            Var
              S: ST5;

            Begin
              S := '';
              S := Hex_Char ((Number shr 1) div 2048);
              Number := (((Number shr 1) mod 2048) shl 1) + (Number and 1);
              S := S + Hex_Char (Number div 256);
              Number := Number mod 256;
              S := S + Hex_Char (Number div 16);
              Number := Number mod 16;
              S := S + Hex_Char (Number);
              Hex_String := S + 'h';
            end; { Function Hex_String }

            {------------------------------------------------------------}
            { The function Emm_Installed checks to see if the            }
            { EMM is loaded in memory.  It does this by looking          }
            { for the string 'EMMXXXX0', which should be located         }
            { at 10 bytes from the beginning of the code segment the     }
            { EMM interrupt, 67h, points to.                             }
            {------------------------------------------------------------}
            Function Emm_Installed: Boolean;
              Var
                Emm_Device_Name   : string[8];
                Int_67_Device_Name: string[8];
                Position          : integer;
                Regs              : registers;

              Begin
                Int_67_Device_Name := '';
                Emm_Device_Name    := 'EMMXXXX0';
                with Regs do
                  Begin
                    {----------------------------------------------------}
                    { Get the code segment interrupt 67h points to       }
                    { the EMM interrupt by using DOS function 35h.       }
                    { (get interrupt vector)                             }
                    {----------------------------------------------------}
                    AH := $35;
                    AL := EMM_INT;
                    Intr (DOS_Int, Regs);
                    {----------------------------------------------------}
                    { The ES pseudo-register contains the segment        }
                    { address pointed to by interrupt 67h.  Create an    }
                    { eight character string from the eight successive   }
                    { bytes at address ES:$000A (10 bytes from ES)       }
                    {----------------------------------------------------}
                    For Position := 0 to 7 do
                      Int_67_Device_Name :=
                        Int_67_Device_Name + Chr (mem[ES:Position + $0A]);
                    Emm_Installed := True;
                    {----------------------------------------------------}
                    { If the string is the EMM manager signature,        }
                    { 'EMMXXXX0', then EMM is installed and ready for    }
                    { use.  If not, then EMM is not present.             }
                    {----------------------------------------------------}
                    If Int_67_Device_Name <> Emm_Device_Name
                      then Emm_Installed := False;
                  end; { with Regs do }
              end; { Function Emm_Installed }

            {------------------------------------------------------------}
            { This function returns the total number of EMM pages        }
            { present in the system, and the number of EMM pages that    }
            { are available.                                             }
            {------------------------------------------------------------}
            Function EMM_Pages_Available
              (Var Total_EMM_Pages, Pages_Available: Integer): Integer;
              Var
                Regs: Registers;

              Begin
                with Regs do
                  Begin
                    {----------------------------------------------------}
                    { Get the number of currently unallocated pages and  }
                    { the total number of pages in the system from EMM.  }
                    { Load pseudo-registers prior to invoking EMM.       }
                    {    AH = get unallocated page count function        }
                    {----------------------------------------------------}
                    AH := GET_UNALLOCATED_PAGE_COUNT;
                    Intr (EMM_INT, Regs);
                    {----------------------------------------------------}
                    { Unload the pseudo-registers after invoking EMM.    }
                    {    BX = currently unallocated pages                }
                    {    DX = total pages in the system                  }
                    {    AH = status                                     }
                    {----------------------------------------------------}
                    Pages_Available := BX;
                    Total_EMM_Pages := DX;
                    EMM_Pages_Available := AH;
                  end;
              end; { Function EMM_Pages_Available }


            {------------------------------------------------------------}
            { This function requests the specified number of pages       }
            { from the EMM.                                              }
            {------------------------------------------------------------}
            Function Allocate_Expanded_Memory_Pages
              (Pages_Needed: Integer; Var Handle: Integer): Integer;
              Var
                Regs: Registers;
              Begin
                with Regs do
                  Begin
                    {----------------------------------------------------}
                    { Allocate the specified number of pages from EMM.   }
                    { Load pseudo-registers prior to invoking EMM.       }
                    {    AH = allocate pages function.                   }
                    {    BX = number of pages to allocate.               }
                    {----------------------------------------------------}
                    AH := ALLOCATE_PAGES;
                    BX := Pages_Needed;
                    Intr (EMM_INT, Regs);
                    {----------------------------------------------------}
                    { Unload the pseudo-registers after invoking EMM.    }
                    {    DX = EMM handle                                 }
                    {    AH = status                                     }
                    {----------------------------------------------------}
                    Handle := DX;
                    Allocate_Expanded_Memory_Pages := AH;
                  end;
              end; { Function Allocate_Expanded_Memory_Pages }


            {------------------------------------------------------------}
            { This function maps a logical page allocated by the         }
            { Allocate_Expanded_Memory_Pages function into one of the    }
            { four physical pages.                                       }
            {------------------------------------------------------------}
            Function Map_Expanded_Memory_Pages
              (Handle, Logical_Page, Physical_Page: Integer): Integer;
              Var
                Regs: Registers;

              Begin
                with Regs do
                  Begin
                    {----------------------------------------------------}
                    { Map a logical page at a physical page.             }
                    { Load pseudo-registers prior to invoking EMM.       }
                    {    AH = map page function                          }
                    {    DX = handle                                     }
                    {    BX = logical page number                        }
                    {    AL = physical page number                       }
                    {----------------------------------------------------}
                    AH := MAP_PAGES;
                    DX := Handle;
                    BX := Logical_Page;
                    AL := Physical_Page;
                    Intr (EMM_INT, Regs);
                    {----------------------------------------------------}
                    { Unload the pseudo-registers after invoking EMM.    }
                    {    AH = status                                     }
                    {----------------------------------------------------}
                    Map_Expanded_Memory_Pages := AH;
                  end; { with Regs do }
              end; { Function Map_Expanded_Memory_Pages }


            {------------------------------------------------------------}
            { This function gets the physical address of the EMM page    }
            { frame we are using.  The address returned is the segment   }
            { of the page frame.                                         }
            {------------------------------------------------------------}
            Function Get_Page_Frame_Base_Address
              (Var Page_Frame_Address: Integer): Integer;
              Var
                Regs: Registers;

              Begin
                with Regs do
                  Begin
                    {----------------------------------------------------}
                    { Get the page frame segment address from EMM.       }
                    { Load pseudo-registers prior to invoking EMM.       }
                    {    AH = get page frame segment function            }
                    {----------------------------------------------------}
                    AH := GET_PAGE_FRAME;
                    Intr (EMM_INT, Regs);
                    {----------------------------------------------------}
                    { Unload the pseudo-registers after invoking EMM.    }
                    {    BX = page frame segment address                 }
                    {    AH = status                                     }
                    {----------------------------------------------------}
                    Page_Frame_Address := BX;
                    Get_Page_Frame_Base_Address := AH;
                  end; { with Regs do }
              end; { Function Get_Page_Frame_Base_Address }


            {------------------------------------------------------------}
            { This function releases the EMM memory pages allocated to   }
            { us, back to the EMM memory pool.                           }
            {------------------------------------------------------------}
            Function Deallocate_Expanded_Memory_Pages
              (Handle: Integer): Integer;
              Var
                Regs: Registers;
              Begin
                with Regs do
                  Begin
                    {----------------------------------------------------}
                    { Deallocate the pages allocated to an EMM handle.   }
                    { Load pseudo-registers prior to invoking EMM.       }
                    {    AH = deallocate pages function                  }
                    {    DX = EMM handle                                 }
                    {----------------------------------------------------}
                    AH := DEALLOCATE_PAGES;
                    DX := Handle;
                    Intr (EMM_INT, Regs);
                    {----------------------------------------------------}
                    { Unload the pseudo-registers after invoking EMM.    }
                    {    AH = status                                     }
                    {----------------------------------------------------}
                    Deallocate_Expanded_Memory_Pages := AH;
                  end; { with Regs do }
              end; { Function Deallocate_Expanded_Memory_Pages }


            {------------------------------------------------------------}
            { This function returns the version number of the EMM as     }
            { a three-character string.                                  }
            {------------------------------------------------------------}
            Function Get_Version_Number (Var Version_String: ST3): Integer;
              Var
                Regs: Registers;
                Integer_Part, Fractional_Part: Char;

              Begin
                with Regs do
                  Begin
                    {----------------------------------------------------}
                    { Get the version of EMM.                            }
                    { Load pseudo-registers prior to invoking EMM.       }
                    {    AH = get EMM version function                   }
                    {----------------------------------------------------}
                    AH := GET_VERSION;
                    Intr (EMM_INT, Regs);
                    {----------------------------------------------------}
                    { If the version number returned was OK, then        }
                    { convert it to a three-character string.            }
                    {----------------------------------------------------}
                    If AH=STATUS_OK then
                      Begin
                        {------------------------------------------------}
                        { The upper four bits of AH are the integer      }
                        { portion of the version number, the lower four  }
                        { bits are the fractional portion.  Convert the  }
                        { integer value to ASCII by adding 48.           }
                        {------------------------------------------------}
                        Integer_Part    := Char (AL shr 4  + 48);
                        Fractional_Part := Char (AL and $F + 48);
                        Version_String  := Integer_Part + '.' +
                                                          Fractional_Part;
                      end; { If AH=STATUS_OK }
                    {----------------------------------------------------}
                    { Unload the pseudo-registers after invoking EMM.    }
                    {    AH = status                                     }
                    {----------------------------------------------------}
                    Get_Version_Number := AH;
                  end; { with Regs do }
              end; { Function Get_Version_Number }


            {------------------------------------------------------------}
            { This procedure prints an error message passed by the       }
            { caller, prints the error code passed by the caller in hex, }
            { and then terminates the program with an error level of 1.  }
            {------------------------------------------------------------}
            Procedure Error (Error_Message: ST80; Error_Number: Integer);
              Begin
                Writeln (Error_Message);
                Writeln ('  Error_Number = ', Hex_String (Error_Number));
                Writeln ('EMM test program aborting.');
                Halt (1);
              end; { Procedure Error }


          {--------------------------------------------------------------}
          { This program is an example of the basic EMM functions that   }
          { you need in order to use EMM memory with Turbo Pascal.       }
          {--------------------------------------------------------------}
          Begin
            ClrScr;
            Window (5,2,77,22);

            {------------------------------------------------------------}
            { Determine if the Expanded Memory Manager is installed.  If }
            { not, then terminate 'main' with an ErrorLevel code of 1.   }
            {------------------------------------------------------------}
            If not (Emm_Installed) then
              Begin
                Writeln ('The LIM EMM is not installed.');
                Halt (1);
              end
            else
              Begin
                { Get the version number and display it }
                Error_Code := Get_Version_Number (Version_Number);
                If Error_Code <> STATUS_OK then
                  Error ('Error getting EMM version number.', Error_Code)
                else
                  Writeln ('LIM Expanded Memory Manager, version ',
                           Version_Number, ' is ready for use.');
              end;
            Writeln;

            {------------------------------------------------------------}
            { Determine if there are enough expanded memory pages for    }
            { this application.                                          }
            {------------------------------------------------------------}
            Pages_Needed := APPLICATION_PAGE_COUNT;
            Error_Code   := EMM_Pages_Available (Total_EMM_Pages,
                                                 Available_EMM_Pages);
            If Error_Code <> STATUS_OK then
              Error ('Error determining number of EMM pages available.',
                     Error_Code);
            Writeln ('There are a total of ', Total_EMM_Pages,
                     ' expanded memory pages present in this system.');
            Writeln ('  ', Available_EMM_Pages,
                     ' of those pages are available for use.');
            Writeln;

            {------------------------------------------------------------}
            { If there is an insufficient number of pages for the        }
            { application, then report the error and terminate the EMM   }
            { example program.                                           }
            {------------------------------------------------------------}
            If Pages_Needed > Available_EMM_Pages then
              Begin
                Str (Pages_Needed, Pages_Number_String);
                Error ('We need ' + Pages_Number_String +
                       ' EMM pages.  There are not that many available.',
                       Error_Code);
              end; { Pages_Needed > Available_EMM_Pages }


            {------------------------------------------------------------}
            { Allocate expanded memory pages for our use.                }
            {------------------------------------------------------------}
            Error_Code :=
              Allocate_Expanded_Memory_Pages (Pages_Needed, Emm_Handle);
            Str (Pages_Needed, Pages_Number_String);
            If Error_Code <> STATUS_OK then
              Error ('EMM test program failed trying to allocate '
                     + Pages_Number_String
                     + ' pages for usage.', Error_Code);
            Writeln (APPLICATION_PAGE_COUNT,
                     ' EMM page(s) allocated for the EMM test program.');
            Writeln;

            {------------------------------------------------------------}
            { Map in the required logical pages to the physical pages    }
            { given to us, in this case just one page.                   }
            {------------------------------------------------------------}
            Logical_Page  := 0;
            Physical_Page := 0;
            Error_Code := Map_Expanded_Memory_Pages (Emm_Handle,
                                                     Logical_Page,
                                                     Physical_Page);
            If Error_Code <> STATUS_OK then
              Error ('EMM test program failed trying to map '
                     + 'logical pages into physical pages.',
                     Error_Code);

            Writeln ('Logical Page ',
                     Logical_Page,
                     ' successfully mapped into Physical Page ',
                     Physical_Page);
            Writeln;

            {------------------------------------------------------------}
            { Get the expanded memory page frame address.                }
            {------------------------------------------------------------}
            Error_Code := Get_Page_Frame_Base_Address
                            (Page_Frame_Base_Address);
            If Error_Code <> STATUS_OK then
              Error ('EMM test program unable to get the base Page'
                     + ' Frame Address.',
                     Error_Code);
            Writeln ('The base address of the EMM page frame is = '
                     + Hex_String (Page_Frame_Base_Address));
            Writeln;
            {------------------------------------------------------------}
            { Write a test pattern to expanded memory.                   }
            {------------------------------------------------------------}
            For Offset := 0 to 16382 do
              Begin
                Mem[Page_Frame_Base_Address:Offset] := Offset mod 256;
              end;

            {------------------------------------------------------------}
            { Make sure that what is in EMM memory is what was just      }
            { written.                                                   }
            {------------------------------------------------------------}
            Writeln ('Testing EMM memory.');

            Offset := 1;
            Verify := True;
            while (Offset <= 16382) and (Verify = True) do
              Begin
                If Mem[Page_Frame_Base_Address:Offset] <> Offset mod 256
                  then Verify := False;
                Offset := Succ (Offset);
              end; { while (Offset <= 16382) and (Verify = True) }

            {------------------------------------------------------------}
            { If what is read does not match what was written,           }
            { an error occurred.                                         }
            {------------------------------------------------------------}
            If not Verify then
              Error ('What was written to EMM memory was not found during'
                     + ' memory verification test.',
                     0);
            Writeln ('EMM memory test successful.');
            Writeln;

            {------------------------------------------------------------}
            { Return the expanded memory pages given to us back to the   }
            { EMM memory pool before terminating our test program.       }
            {------------------------------------------------------------}
            Error_Code := Deallocate_Expanded_Memory_Pages (Emm_Handle);
            If Error_Code <> STATUS_OK then
              Error ('EMM test program was unable to deallocate '
                     + 'the EMM pages in use.',
                     Error_Code);
            Writeln (APPLICATION_PAGE_COUNT,
                     ' pages(s) deallocated.');
            Writeln;
            Writeln ('EMM test program completed.');

          end.

