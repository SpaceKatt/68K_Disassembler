*-----------------------------------------------------------
* Title      : Opcode Stuff
* Written by : Thomas Kercheval
* Date       :
* Description:
*-----------------------------------------------------------

CR         EQU       $0D            * Carriage return
LF         EQU       $0A            * Line feed
STACKPTRE  EQU       $8000

           ORG       $1000
START:                              * first instruction of program
******************** Start*****************************************************
TEST_START LEA       STACKPTRE,SP
           LEA       TEST_OP,A0
           MOVE.B    TEST_FLAG,D0
           LEA       TEST_BUFF,A2
           JSR       OP_START
CONFIRM_T  BRA       END

*******************************************************************************
******************** Opcode Start *********************************************
OP_START   JSR       READ_OP        * Read opcode into D1
           BRA       NOP_RTS_T      * Check for NOP/RTS
OP_TREE    NOP

           BRA       END

*******************************************************************************
******************* Read opcode ***********************************************
READ_OP    MOVE.W    (A0)+,D1         * Read opcode into D1
           RTS

*******************************************************************************
******************* Checks for NOP/RTS ****************************************
NOP_RTS_T  CMP.W     (CON_NOP),D1    * Is the opcode NOP?
           BEQ       O_NOP           * Take care of NOP
           CMP.W     (CON_RTS),D1    * Is the opcode RTS?
           BEQ       O_RTS           * Take care of RTS
           BRA       OP_TREE

           ********* NOP *******************************************************
O_NOP      LEA       STR_NOP,A6       * Load NOP string into A6
           BRA       W_NO_SIZE

           ********* RTS *******************************************************
O_RTS      LEA       STR_RTS,A6       * Load RTS string into A6
           BRA       W_NO_SIZE

*******************************************************************************
******************* Write opcode with no size *********************************
W_NO_SIZE  JSR       WRITE_ANY
           RTS

*******************************************************************************
*******************************************************************************
** START DECISION TREE, Available opcodes:
**  ORI BCLR CMPI MOVEA MOVE NEG NOP RTS JSR MOVEM LEA SUBQ BRA BCS BVC BGE BLT
**  DIVS OR SUB CMP EOR MULS ADD ADDA LSR ASR ROR LSL ASL ROL
*******************************************************************************
*******************************************************************************


*******************************************************************************
*******************************************************************************
*******************************************************************************
*******************************************************************************


*******************************************************************************
******************** Get Size *************************************************
GET_SIZE   NOP


*******************************************************************************
******************** Write a null-term string to buff *************************
WRITE_ANY  CMPI.B    #0,(A6)        * Is the byte at A6 the NULL Char?
           BEQ       W_DONE
           MOVE.B    (A6)+,(A2)+
           BRA       WRITE_ANY
W_DONE     RTS

*******************************************************************************
******************** Fin ******************************************************
END        MOVE.B    #9,D0          * Break out of sim
           TRAP      #15

*******************************************************************************
******************** Put variables and constants here *************************
CON_NOP    DC.W      $4E71
CON_RTS    DC.W      $4E75


******************** Put variables and constants here *************************
INVAL_FLG  DC.B      '!','!','!','!',0
STR_NOP    DC.B      'N','O','P',' ',0
STR_RTS    DC.B      'R','T','S',' ',0

******************** Test variables *******************************************
TEST_A0    DC.L      TEST_OP
*TEST_OP    DC.W      $4E71       * NOP
TEST_OP    DC.W      $4E75        * RTS
TEST_FLAG  DC.W      $0
TEST_BUFF  DC.B      00,00,00,00

           END       START                    * last line of source

*~Font name~Courier~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
