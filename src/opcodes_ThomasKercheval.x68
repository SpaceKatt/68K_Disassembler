*-----------------------------------------------------------
* Title       : Opcode Stuff
* Written by  : Thomas Kercheval
* Date        :
* Description : 68K Disassembler Opcode Module
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
OP_START   JSR       READ_OP         * Read opcode into D1
           BRA       NOP_RTS_T       * Check for NOP/RTS
OP_TREE_C  MOVE      #0,CCR          * Clear condition register
           BRA       OP_TREE         * Branch to decision tree

           BRA       END

*******************************************************************************
******************* Read opcode ***********************************************
READ_OP    MOVE.W    (A0)+,D1        * Read opcode into D1
           RTS

*******************************************************************************
******************* Checks for NOP/RTS ****************************************
NOP_RTS_T  CMP.W     (CON_NOP),D1    * Is the opcode NOP?
           BEQ       O_NOP           * Take care of NOP
           CMP.W     (CON_RTS),D1    * Is the opcode RTS?
           BEQ       O_RTS           * Take care of RTS
           BRA       OP_TREE_C

           ********* NOP ******************************************************
O_NOP      LEA       STR_NOP,A6      * Load NOP string into A6
           BRA       W_NO_SIZE

           ********* RTS ******************************************************
O_RTS      LEA       STR_RTS,A6      * Load RTS string into A6
           BRA       W_NO_SIZE

*******************************************************************************
*******************************************************************************
** START DECISION TREE, Available opcodes:
**  ORI BCLR CMPI MOVEA MOVE NEG NOP RTS JSR MOVEM LEA SUBQ BRA BCS BVC BGE BLT
**  DIVS OR SUB CMP EOR MULS ADD ADDA LSR ASR ROR LSL ASL ROL
*******************************************************************************
*******************************************************************************
OP_TREE    BTST      #15,D1         * Test MSB in opcode
           BNE       ONE
           ** ORI BCLR CMPI MOVEA MOVE
           ** NEG NOP RTS JSR MOVEM LEA SUBQ BRA BCS BVC BGE BLT
           BTST      #14,D1         * Test second most sig bit in opcode
           BNE       Z_ONE
           ** NEG NOP RTS JSR MOVEM LEA SUBQ
           ** BRA BCS BVC BGE BLT
           BTST      #13,D1         * Test MSB in opcode
           BNE       BRANCHZ
           ** NEG NOP RTS JSR MOVEM LEA SUBQ
           NOP

 ******************************************************************************
 *  DIVS OR SUB CMP EOR
 *  MULS ADD ADDA LSR ASR ROR LSL ASL ROL
 ******************************************************************************
ONE        BTST      #14,D1         * Test second most sig bit in opcode
           BNE       O_ZERO
           **  MULS ADD ADDA 
           **  LSR ASR ROR LSL ASL ROL
           BTST      #13,D1         * Test third most sig 
           BNE       ROTATEZ

 ******************************************************************************
 *  DIVS OR SUB
 *  CMP EOR
 ******************************************************************************
O_ZERO     NOP ** CHANGE decision tree to give DIVS OR SUB their own branch

 ******************************************************************************
 *  DIVS OR SUB
 ******************************************************************************
O_Z_ZERO   NOP

 ******************************************************************************
 *  LSR ASR ROR LSL ASL ROL
 ******************************************************************************
ROTATEZ    NOP

 ******************************************************************************
 *  ORI BCLR CMPI
 *  MOVEA MOVE
 ******************************************************************************
Z_ONE      MOVE.W    MASK_12_15,D2   * Load mask for bits 12-15
           AND.W     D1,D2           * Mask bits 12-15
           CMP.W     #0,D2           * Are they 0000?
           BRA       Z_ONE_SU
           **  MOVEA MOVE
           NOP

 ******************************************************************************
 *  ORI BCLR CMPI
 ******************************************************************************
Z_ONE_SU   NOP

 ******************************************************************************
 * BRA BCS BVC BGE BLT
 ******************************************************************************
BRANCHZ    NOP

*******************************************************************************
********** END Decision tree***************************************************
*******************************************************************************
********** Opcode specific processing begin ***********************************


********** End opcode specific processing *************************************
*******************************************************************************
*******************************************************************************
*******************************************************************************


*******************************************************************************
******************** Write opcode with no size ********************************
W_NO_SIZE  JSR       WRITE_ANY
           RTS

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
******************** API variable storage *************************************
ORIG_OP    DC.W      $0
SIZE_OP    DC.W      $0
API_A0     DC.W      $0
API_A2     DC.W      $0

*******************************************************************************
******************** Constant opcodes and masks *******************************
                     ** NOP/RTS
CON_NOP    DC.W      $4E71
CON_RTS    DC.W      $4E75

                     ** MASKS
MASK_12_15 DC.W      $F000          * Mask for the bits from X to Y for _X_Y
MASK_8_11  DC.W      $0F00          * Mask for the bits from X to Y for _X_Y
MASK_6_8   DC.W      $01C0          * Mask for the bits from X to Y for _X_Y
MASK_6_7   DC.W      $00C0          * Mask for the bits from X to Y for _X_Y


******************** Opcode strings *******************************************
INVAL_FLG  DC.B      '!','!','!','!',0
STR_NOP    DC.B      'N','O','P',' ',0
STR_RTS    DC.B      'R','T','S',' ',0

******************** Test variables *******************************************
TEST_A0    DC.L      TEST_OP
*TEST_OP    DC.W      $4E71       * NOP
*TEST_OP    DC.W      $4E75        * RTS
TEST_OP    DC.W      $8200        * OR D0,D0
TEST_FLAG  DC.W      $0
TEST_BUFF  DC.B      00,00,00,00

           END       START                    * last line of source

*~Font name~Courier~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
