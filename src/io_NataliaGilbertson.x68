*-----------------------------------------------------------
* Title      : I/O handling
* Written by : Natalia Gilbertson
* Date       :
* Description: Disassembler I/O code
*-----------------------------------------------------------

CR         EQU       $0D            * Carriage return
LF         EQU       $0A            * Line feed
Stack      EQU       $8000

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
            
            *Clear data registers
            CLR.L   D0
            CLR.L   D2
            CLR.L   D4
            CLR.L   D6
            CLR.L   D7
            MOVE.L  #0,A1
            MOVE.L  #0,A4
            MOVE.L  #0,A5
            MOVE.L  #0,A6

            *Set output buffer to A2
       
            STOP    #3000

*******************************************************************************
******************** Fin ******************************************************
ThrowInputError     LEA       InvalidInputError,A1
                    MOVE.B    #14,D0
                    TRAP      #15

END                 MOVE.B    #9,D0          * Break out of sim
                    TRAP      #15

*******************************************************************************
******************** Put variables and constants here *************************
                        
PromptStartAddr         DC.B    'Enter starting address of file, then press ENTER: ',0    
PromptEndAdder          DC.B    'Enter ending address of file, then press ENTER: ',0
InvalidInputError       DC.B    'ERROR: Invalid input address. Addresses must be between 1 and 8 characters long, ',CR,LF,'at a word boundary, and containing only digits 0-9 and characters A-F.',0        
StoreInputStartAddr     DC.L    0   *Each address needs 8 bytes to be read into memory 
StoreInputStartAddr2    DC.L    0   
StoreInputEndAddr       DC.L    0
StoreInputEndAddr2      DC.L    0

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
                        
*******************************************************************************
*******************************************************************************
    END    START                    * last line of source


*~Font name~Courier~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
