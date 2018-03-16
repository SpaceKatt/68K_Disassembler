*-----------------------------------------------------------
* Title      : Disassembler I/O
* Written by : Natalia Gilbertson of Sexy8K
* Date       : 2/15/2018
* Description: Takes in and parses user input for the disassembling to begin.
*              Prints out the disassembled code 20 lines at a time.
*-----------------------------------------------------------

CR              EQU       $0D   * Carriage return
LF              EQU       $0A   * Line feed
Stack           EQU       $8000 * where the stack pointer begins
PageOfOutput    EQU       20    * how many lines of disassembled code is printing
                                * when the user presses ENTER

           ORG       $1000
START:                          * first instruction of program
******************** Start*****************************************************
                LEA     Stack,SP                * load stack pointer value (A7 is stack pointer)

                LEA     Welcome,A1              * print welcome message
                MOVE.B  #14,D0
                TRAP    #15

restart         LEA     PromptStartAddr,A1      * load prompt to print, asking user for starting address
                MOVE.B  #14,D0                  * print string at A1 to console
                TRAP    #15

                LEA     StoreInputStartAddr,A1  * load address to store user input
                MOVE.B  #2,D0                   * read string from keyboard into (A1)
                TRAP    #15                     * length of string is stored at D1
                MOVE.B  D1,D7                   * store starting address length at D7 for now

                JSR     ValidAddressChars       * check if starting address is valid

                LEA     StoreInputStartAddr,A4  * now convert input into hex address
                JSR     TranslateInputToAddrReg

                MOVE.L  A6,D6                   * move the returned address into a data register to perform a bit test
                BTST.L  #0,D6                   * check that the address is on a word boundary
                BNE     ThrowInputError
                MOVEA.L A6,A0                   * put the starting address (returned into A6) into A0

                LEA     PromptEndAdder,A1       * load prompt to print, asking user for ending address
                MOVE.B  #14,D0                  * print string at A1 to console
                TRAP    #15

                LEA     StoreInputEndAddr,A1
                MOVE.B  #2,D0                   * read string from keyboard into (A1)
                TRAP    #15                     * length of string input is stored at D1

                JSR     ValidAddressChars       * check if ending address is valid

                LEA     StoreInputEndAddr,A4    * now convert input into hex address
                JSR     TranslateInputToAddrReg

                MOVE.L  A6,D6                   * move the returned address into a data register to perform a bit test
                BTST.L  #0,D6                   * check that the address is on a word boundary
                BNE     ThrowInputError
                MOVEA.L A6,A3                   * put the ending address at A3

                * pointer to next opcode is in A0
                * ending address is at A3

                CMPA.L  A3,A0                   * check that startAddress <= endAddress
                BGT     endProg                 * exit program if start > end

                * clear some registers
                CLR.L   D0
                CLR.L   D4
                CLR.L   D6
                CLR.L   D7
                MOVE.L  #0,A1
                MOVE.L  #0,A4
                MOVE.L  #0,A5
                MOVE.L  #0,A6

                LEA     PromptToPressENTER,A1   * prompt user to press ENTER for next page of data
                MOVE.B  #14,D0
                TRAP    #15

**************************************** printing out disassembled code ********************************************
waitForENTER    LEA     OutputBuffer,A1
                MOVE.L  #0,D2                   * reset linesOutputted to 0
                MOVE.B  #2,D0                   * trap task for reading input
                TRAP    #15                     * read input, expecting ENTER from user to proceed disassembling

loopPrintLines  CMP.L   A3,A0                   * while pointerToNextOpcode <= ending address
                BGT     endProg

                CMP.L   #PageOfOutput,D2        * stop printing when linesOutputted == linesInAPage
                BEQ     waitForENTER            * go back to waiting for ENTER from user
                ADD.B   #1,D2                   * increment linesOutputted

                * prepare to call opcodes
                LEA     OutputBuffer,A2         * set output buffer to A2
                MOVEA.L A0,A6                   * track current pointerToNextOpcode in case bad flag is set

                JSR     AddCurrAddressToBuffer  * put current address into the output buffer

                MOVEM.L D1-D7/A1/A3-A6,-(SP)    * save all registers except A0 (pointerToNextOpcode),
                                                *                           A2 (output buffer pointer),
                                                *                           D0 (bad flag)
                MOVE.B  #0,D0                   * clear bad flag

                JSR     OP_START                * call opcodes

                MOVEM.L (SP)+,D1-D7/A1/A3-A6    * restore all registers except A0,A2,D0

                CMP.B   #0,D0                   * bad flag set?
                BEQ     noFlagSet
                JSR     HandleBadFlag           * handle bag flag if it was set

noFlagSet       MOVE.B  #0,(A2)+                * null terminate the string stored at (A2)

                JSR     OutputTheBuffer

                BRA     loopPrintLines          * go back to process and print another line

*******************************************************************************
******************** FIN ******************************************************
endProg         LEA     EOF,A1                * print end of file message
                MOVE.B  #14,D0
                TRAP    #15

                STOP    #3000                 * end program

*******************************************************************************
******************** Errors ***************************************************
ThrowInputError LEA     InvalidInputError,A1  * load address that holds error string
                MOVE.B  #0,D0                 * print the string
                MOVE.B  #155,D1
                TRAP    #15

                CLR.L   D0
                CLR.L   D1
                CLR.L   D2
                CLR.L   D4
                CLR.L   D6
                CLR.L   D7
                MOVE.L  #0,A1
                MOVE.L  #0,A4
                MOVE.L  #0,A5
                MOVE.L  #0,A6

                MOVE.B  #CR,(A1)+
                MOVE.B  #LF,(A1)+
                MOVE.B  #0,D0                 * print the string
                MOVE.B  #0,D1
                TRAP    #15

                BRA     restart

*******************************************************************************
******************** Method ***************************************************

* load the string you want to check for validity into A1 before calling the method
* load the length of the string into D1
ValidAddressChars       CMP.B   #1,D1                 * must have b/t 1 and 8 characters in address
                        BLT     ThrowInputError       * error if less than 1
                        CMP.B   #8,D1
                        BGT     ThrowInputError       * error if greater than 8

VACloop                 CMP.B   D1,D3                 * D3 is loop counter
                        BEQ     endMethodVAC
                        MOVE.B  (A1)+,D2              * D2 holds current byte to check
                        CMP.B   #$30,D2               * each character must be >= $30 (0)
                        BLT     ThrowInputError
                        CMP.B   #$46,D2               * each character must be <= $46 (F)
                        BGT     ThrowInputError
                        CMP.B   #$40,D2               * $40 (@) is an invalid character in range $30-$46
                        BEQ     ThrowInputError
                        ADDQ    #1,D3                 * increment counter
                        BRA     VACloop

endMethodVAC            MOVE.L  #0,D3                 * clear out counter data reg
                        RTS


* translate the address into register A0
* D1 holds the length in chars of the address to decode
* A4 holds the starting address of the input
TranslateInputToAddrReg CLR.L   D7
                        MOVEA.L A4,A5                 * remember the start address
                        MOVE.B  D1,D4                 * remember the char count
TITARloop1              CMP.B   D1,D3                 * while loop counter < address length in chars
                        BEQ     endTITARloop1
                        CMP.B   #$40,(A4)             * greater than $40? translate A-F
                        BGT     handleAThroughF
                        SUB.B   #$30,(A4)             * subtract $30 from the 0-9 char in ASCII
                        BRA     digitBt0And9          * handle characters between 0 and 9
handleAThroughF         SUB.B   #$37,(A4)             * subtract $37 from the A-F char in ASCII
digitBt0And9            ADD.B   (A4),D7               * add the translated byte into D7
                        ADDA.L  #1,A4                 * increment A4
                        SUB.B   #1,D1                 * decrement counter
                        CMP.B   D1,D3                 * do not shift when we reach the last char in the address
                        BEQ     doNotShiftThisTime
                        LSL.L   #$04,D7               * shift the translated part of the address four bits to the left
doNotShiftThisTime      BRA     TITARloop1            * shifting allows adding the next nibble of the translated address to D7

endTITARloop1           CMP.B   #4,D4
                        BGT     moveLongAddress       * if the address is >4 hex chars long move it into an address reg as a long
                        MOVEA.W D7,A6                 * if the address is <=4 hex chars move it as a word (supports sign extension)
                        BRA     endMethodTITAR
moveLongAddress         MOVEA.L D7,A6                 * move the translated address into an address register
endMethodTITAR          RTS

* each disassembled line needs the address of the instruction in memory
* printed on the left side, this method loads the address into the output buffer
* current address is stored at A0
AddCurrAddressToBuffer  MOVE.B  #0,D3                     * clear loop counter
                        MOVE.L  A0,D4                     * put the current address into D4
loopACATB               CMP.B   #8,D3                     * while not all 8 characters of the address are in the output buffer...
                        BEQ     endMethodACATB
                        ADDQ    #1,D3                     * increment counter
                        ROL.L   #$04,D4                   * load the most significant nibble into the first byte
                        MOVE.B  D4,D5                     * move the first byte of D4 into D5
                        AND     #%00001111,D5             * bit mask the second nibble out of the byte
                        MOVEA   D5,A5                     * move the nibble in question into A5
                        MOVE.B  (NumbersToASCII,A5),(A2)+ * displace the nibble value into the string hashtable and put
                        BRA     loopACATB                 * the hash result into the output buffer
                                                          * do this for all characters in the address

                        *Tab, put a full tab into the output buffer for output formatting
endMethodACATB          MOVE.B  #$20,(A2)+
                        MOVE.B  #$20,(A2)+
                        MOVE.B  #$20,(A2)+
                        MOVE.B  #$20,(A2)+
                        RTS

* handles problems encountered by opcodes and effective addressing for the output buffer
* the bad flag is stored at D0
HandleBadFlag           LEA     OutputBuffer,A2           * reset the output buffer to overwrite any bad data
                        ADDA    #12,A2                    * don't overwrite the address location which is already in there

                        * reset the flag
                        MOVE.B  #0,D0

                        * put 'DATA' into the output buffer
                        MOVE.B  #$44,(A2)+
                        MOVE.B  #$41,(A2)+
                        MOVE.B  #$54,(A2)+
                        MOVE.B  #$41,(A2)+

                        * put space formatting into the output buffer
                        MOVE.B  #$20,(A2)+
                        MOVE.B  #$20,(A2)+
                        MOVE.B  #$20,(A2)+
                        MOVE.B  #$20,(A2)+
                        MOVE.B  #$20,(A2)+
                        MOVE.B  #$20,(A2)+
                        MOVE.B  #$20,(A2)+

                        * add the $ to the buffer to show the hex value
                        MOVE.B  #$24,(A2)+

                        * get the instruction word that could not be disassembled
                        MOVE.W  (A6),D1                   * A6 stores the saved pointerToNextOpcode before opcodes was called
                        LSL.L   #$08,D1                   * shift the value left a word
                        LSL.L   #$08,D1

                        * put the bad instruction word into the output buffer
                        MOVE.B  #0,D3                     * reset loop counter
loopHBF                 CMP.B   #4,D3                     * loop for each hex character in the word
                        BEQ     endMethodHBF
                        ADDQ    #1,D3                     * increment counter
                        ROL.L   #$04,D1                   * move one nibble at a time into the first byte of D1
                        MOVE.B  D1,D4                     * pass the nibble to D4
                        AND     #%00001111,D4             * bit mask the second nibble in the first byte that was grabbed
                        MOVEA   D4,A5                     * move the single hex char into A5
                        MOVE.B  (NumbersToASCII,A5),(A2)+ * displace the hex value into the string hashtable and load the result
                        BRA     loopHBF                   * into the output buffer

endMethodHBF            RTS

* print a disassembled instructions to the user
OutputTheBuffer         MOVE.B  #0,D0                     * load trap task for printing a string at A1
                        LEA     OutputBuffer,A1           * load output buffer into A1
                        MOVEA.L A2,A5                     * get the current pointer spot in the output buffer
                        SUBA    OutputBuffer,A5           * subtract the address of the beginning of the output buffer
                                                          * from the address of the current pointer in the output buffer
                        MOVE.W  A5,D1                     * this results in the number of characters in the buffer to print out
                        TRAP    #15                       * which is stored in D1, telling TRAP how much to print

                        RTS



*******************************************************************************
******************** variables and constants **********************************
* string hashtable
NumbersToASCII          DC.B    $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$41,$42,$43,$44,$45,$46
* prompts to user
PromptStartAddr         DC.B    'Enter starting address of file, then press ENTER: ',0
PromptEndAdder          DC.B    'Enter ending address of file, then press ENTER: ',0
PromptToPressENTER      DC.B    'Press ENTER to get the next page of disassembled code.',0
Welcome                 DC.B    'Welcome to our disassembler!',CR,LF,'Created by Sexy8k: [Natalia Gilbertson][Thomas Kercheval][Saam Amiri]',CR,LF,'Please load your file into memory.',CR,LF,CR,LF,0
EOF                     DC.B    '~ End of file ~',0
* error message
InvalidInputError       DC.B    'ERROR: Invalid input address. Addresses must be between 1 and 8 characters long, ',CR,LF,'at a word boundary, and containing only digits 0-9 and characters A-F.',0

StoreInputStartAddr     DC.L    0   * each address needs 8 bytes to be read into memory
StoreInputStartAddr2    DC.L    0   * so more space is built in
StoreInputEndAddr       DC.L    0
StoreInputEndAddr2      DC.L    0
OutputBuffer            DCB.B   84,0

*******************************************************************************
*******************************************************************************
                        NOP
                        INCLUDE "opcodes_ThomasKercheval.x68"

    END    START                    * last line of source
*~Font name~Courier~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
