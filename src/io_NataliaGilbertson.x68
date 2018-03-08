*-----------------------------------------------------------
* Title      : I/O handling
* Written by : Natalia Gilbertson
* Date       :
* Description: Disassembler I/O code
*-----------------------------------------------------------

CR              EQU       $0D   * Carriage return
LF              EQU       $0A   * Line feed
Stack           EQU       $8000 *the stack grows backwards
UserTypesENTER  EQU       $8002 *any unusual user input will not overwrite our code
PageOfOutput    EQU       80  

           ORG       $1000
START:                              * first instruction of program
******************** Start*****************************************************
            LEA     Stack,SP 
            
            LEA     PromptStartAddr,A1      *Load prompt to print
            MOVE.B  #14,D0                  *Print string at A1 to console
            TRAP    #15
    
            LEA     StoreInputStartAddr,A1
            MOVE.B  #2,D0                   *Read string from keyboard into (A1)
            TRAP    #15                     *length of string is stored at D1
            MOVE.B  D1,D7                   *Store startAddr length at D7
             
            JSR     ValidAddressChars       *check if starting address is valid
            
            LEA     StoreInputStartAddr,A4  *Now convert input into hex addresses
            JSR     TranslateInputToAddrReg
            
            MOVE.L  A6,D6
            BTST.L  #0,D6                   *check that the address is on a word boundary
            BNE     ThrowInputError
            MOVEA.L A6,A0
            
            LEA     PromptEndAdder,A1       *Load prompt to print
            MOVE.B  #14,D0                  *Print string at A1 to console
            TRAP    #15
            
            LEA     StoreInputEndAddr,A1
            MOVE.B  #2,D0                   *Read string from keyboard into (A1)
            TRAP    #15                     *length of string is stored at D1
            
            JSR     ValidAddressChars       *check if ending address is valid
  
            LEA     StoreInputEndAddr,A4    *Now convert input into hex addresses
            JSR     TranslateInputToAddrReg
            
            MOVE.L  A6,D6
            BTST.L  #0,D6                   *check that the address is on a word boundary
            BNE     ThrowInputError
            MOVEA.L A6,A3
  
            *Pointer to next opcode is in A0
            *Ending address is at A3
            
            *check that startAddress < endAddress
            CMPA.L  A3,A0
            BGT     endProg
            
            *Clear data registers
            CLR.L   D0
            CLR.L   D4
            CLR.L   D6
            CLR.L   D7
            MOVE.L  #0,A1
            MOVE.L  #0,A4
            MOVE.L  #0,A5
            MOVE.L  #0,A6

            *Use A4 to check for user pressing ENTER
            *(A4), which is set to FF will change to 00 if the user
            *   presses ENTER, and the trap task will store in D1 that
            *   no characters were read in when reading a string
            MOVEA.L #UserTypesEnter,A4
            
waitForENTER    MOVE.L  #0,D2   *reset linesOutputted
                MOVE.B  #2,D0   *trap task for reading input
                TRAP    #15     *read input
            
                *while instructionPtr <= ending address
loopPrintLines  CMP.L   A3,A0   
                BGT     endProg
            
                *stop printing when linesOutputted == 80
                CMP.L   #80,D2   
                BEQ     waitForENTER
                *increment linesOutputted
                ADD.B   #1,D2        
              
                *Set output buffer to A2
                LEA     OutputBuffer,A2
                *get ready to call opcodes
                JSR     AddCurrAddressToBuffer
                
                MOVE.B  #$46,(A2)+
                MOVE.B  #$41,(A2)+
                MOVE.B  #$44,(A2)+
                
                *save all registers except A0,A2,D0
                MOVEM.L D1-D7/A1/A3-A6,-(SP)
                *clear bad flag
                MOVE.B  #0,D0
                *call opcodes
                *mess up the data registers
                MOVEA.L #$FFFFFFFF,A3
                MOVEA.L #$FFFFFFFF,A6
                MOVEA.L #$FFFFFFFF,A5
                MOVE.L  #$FFFFFFFF,D1
                MOVE.L  #$FFFFFFFF,D2
                MOVE.L  #$FFFFFFFF,D3
                MOVE.L  #$FFFFFFFF,D4
                *restore my registers (except A0,A2,D0)
                MOVEM.L (SP)+,D1-D7/A1/A3-A6
                *bad flag set?
                CMP.B   #0,D0
                BEQ     noFlagSet
                JSR     HandleBadFlag
noFlagSet       *add CRLF,0 to end of each buffered line
                *MOVE.B  #CR,(A2)+
                *MOVE.B  #LF,(A2)+
                MOVE.B  #0,(A2)+
                JSR     OutputTheBuffer
                ADDA    #2,A0   *MOCK opcodes + EA reading a word
            
                BRA     loopPrintLines               
       
endProg     STOP    #3000

*******************************************************************************
******************** Fin ******************************************************
ThrowInputError     LEA       InvalidInputError,A1
                    MOVE.B    #14,D0
                    TRAP      #15

END                 MOVE.B    #9,D0          * Break out of sim
                    TRAP      #15

*******************************************************************************
******************** Put methods here *****************************************

*Load the string you want to check into A1 before calling the method
*Load the length of the string into D1
ValidAddressChars       CMP.B   #1,D1           *Must have b/t 1 - 8 characters in address                     
                        BLT     ThrowInputError
                        CMP.B   #8,D1     
                        BGT     ThrowInputError
                        
VACloop                 CMP.B   D1,D3           *D3 is loop counter
                        BEQ     endMethodVAC
                        MOVE.B  (A1)+,D2        *D2 holds current byte to check
                        CMP.B   #$30,D2
                        BLT     ThrowInputError
                        CMP.B   #$46,D2
                        BGT     ThrowInputError
                        CMP.B   #$40,D2
                        BEQ     ThrowInputError
                        ADDQ    #1,D3           *increment counter
                        BRA     VACloop
                        
                        *Check that the address is at a word boundary
                        
                        
endMethodVAC            MOVE.L  #0,D3           *clear out counter data reg
                        RTS   


*Translate the address into A0
*D1 holds the charLength of the address to decode
*A4 holds the starting address of the input
TranslateInputToAddrReg CLR.L   D7
                        MOVEA.L A4,A5           *Remember the start address
                        MOVE.B  D1,D4           *Remember the char count
                        MOVE.B  #1,D6           *shifting variable
TITARloop1              CMP.B   D1,D3
                        BEQ     endTITARloop1
                        CMP.B   #$40,(A4)
                        BGT     handleAThroughF
                        SUB.B   #$30,(A4)
                        BRA     digitBt0And9
handleAThroughF         SUB.B   #$37,(A4)
digitBt0And9            ADD.B   (A4),D7
                        ADDA.L  #1,A4
                        SUB.B   #1,D1           *decrement counter
                        CMP.B   D1,D3
                        BEQ     doNotShiftThisTime     
                        LSL.L   #$04,D7 
doNotShiftThisTime      BRA     TITARloop1
                        
endTITARloop1           MOVE.L D7,A6
                        RTS
                        
*Each disassembled line needs the address of the instruction in memory
*printed on the left side
AddCurrAddressToBuffer  MOVE.B  #0,D3
                        MOVE.L  A0,D4
loopACATB               CMP.B   #8,D3
                        BEQ     endMethodACATB
                        ADDQ    #1,D3
                        ROL.L   #$04,D4
                        MOVE.B  D4,D5
                        AND     #%00001111,D5
                        MOVEA   D5,A5  
                        MOVE.B  (NumbersToASCII,A5),(A2)+
                        BRA     loopACATB
                        
endMethodACATB          MOVE.B  #$20,(A2)+
                        MOVE.B  #$20,(A2)+
                        MOVE.B  #$20,(A2)+
                        MOVE.B  #$20,(A2)+
                        RTS
                        
*Handles problems encountered by opcode section
*the bad flag is stored at D0                        
HandleBadFlag           *nothing here yet
                        *reset the flag
                        MOVE.B  #0,D0
                        RTS
                        
*print a page of the disassembled instructions to the user                        
OutputTheBuffer         MOVE.B  #0,D0
                        LEA     OutputBuffer,A1
                        MOVEA.L A2,A5
                        SUBA    OutputBuffer,A5
                        MOVE.W  A5,D1
                        TRAP    #15
                        
                        RTS
*******************************************************************************
******************** Put variables and constants here *************************

NumbersToASCII          DC.B    $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$41,$42,$43,$44,$45,$46                        
PromptStartAddr         DC.B    'Enter starting address of file, then press ENTER: ',0    
PromptEndAdder          DC.B    'Enter ending address of file, then press ENTER: ',0
InvalidInputError       DC.B    'ERROR: Invalid input address. Addresses must be between 1 and 8 characters long, ',CR,LF,'at a word boundary, and containing only digits 0-9 and characters A-F.',0        
StoreInputStartAddr     DC.L    0   *Each address needs 8 bytes to be read into memory 
StoreInputStartAddr2    DC.L    0   
StoreInputEndAddr       DC.L    0
StoreInputEndAddr2      DC.L    0
OutputBuffer            DC.L    0
                        
*******************************************************************************
*******************************************************************************
    END    START                    * last line of source





*~Font name~Courier~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
