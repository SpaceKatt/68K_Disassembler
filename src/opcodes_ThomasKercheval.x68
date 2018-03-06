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
CONFIRM_T  BRA       END_THOM

*******************************************************************************
******************** Opcode Start *********************************************
OP_START   JSR       READ_OP         * Read opcode into D1
           BRA       NOP_RTS_T       * Check for NOP/RTS
OP_TREE_C  MOVE      #0,CCR          * Clear condition register
           BRA       OP_TREE         * Branch to decision tree

           *BRA       END_THOM        * Let it end! Called elsewhere

*******************************************************************************
******************* Read opcode ***********************************************
READ_OP    MOVE.W    (A0)+,D1        * Read opcode into D1
           MOVE.W    D1,ORIG_OP
           MOVE.L    A2,START_BUFF
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
**  ORI BCLR CMPI MOVEA MOVE NEG JSR MOVEM LEA SUBQ BRA BCS BVC BGE BLT
**  DIVS OR SUB CMP EOR MULS ADD ADDA LSR ASR ROR LSL ASL ROL
*******************************************************************************
*******************************************************************************
OP_TREE    BTST      #15,D1         * Test MSB in opcode
           BNE       ONE

           ** ORI BCLR CMPI MOVEA MOVE
           ** NEG JSR MOVEM LEA SUBQ BRA BCS BVC BGE BLT
           BTST      #14,D1         * Test second most sig bit in opcode
           BEQ       Z_ONE          * ORI BCLR CMPI MOVEA MOVE

           ** NEG JSR MOVEM LEA SUBQ
           ** BRA BCS BVC BGE BLT
           BTST      #13,D1         * Test third MSB in opcode
           BNE       BRANCHZ        * BRA BCS BVC BGE BLT

           ** NEG JSR MOVEM LEA SUBQ
           BTST      #12,D1         * Test fourth MSB in opcode
           BEQ       O_SUBQ

           MOVE.W    MASK_8_11,D2    * Load mask for bits 8-11
           AND.W     D1,D2           * MASK bits
           EORI.W    #$0400,D2       * Will be zero if 8-11 are 0100
           BEQ       O_NEG

           MOVE.W    MASK_8_11,D2    * Load mask for bits 8-11
           AND.W     D1,D2           * MASK bits
           EORI.W    #$0400,D2       * Will be zero if 8-11 are 1110
           BEQ       O_JSR

           MOVE.W    MASK_6_8,D2    * Load mask for bits 8-11
           AND.W     D1,D2           * MASK bits
           EORI.W    #$01C0,D2       * Will be zero if 6-8 are 111
           BEQ       O_LEA

           BRA       O_MOVEM         * Else, we have MOVEM


 ******************************************************************************
 *  DIVS OR SUB CMP EOR
 *  MULS ADD ADDA LSR ASR ROR LSL ASL ROL
 ******************************************************************************
ONE        BTST      #14,D1         * Test second most sig bit in opcode
           BNE       O_ZERO

           **  MULS ADD ADDA
           **  LSR ASR ROR LSL ASL ROL
           BTST      #13,D1         * Test third most sig
           BNE       ROTATEZ        *  LSR ASR ROR LSL ASL ROL

           **  MULS ADD ADDA
           BTST      #12,D1
           BNE       O_MULS         * Identified MULS op

           MOVE.W    MASK_6_7,D2    * Load mask for bits 6-7
           AND.W     D1,D2          * MASK bits
           EORI.W    #$00C0,D2      * Will be zero if 6-7 are 11
           BEQ       O_ADDA         * ADDA

           BRA       O_ADD          * ADD

 ******************************************************************************
 *  DIVS OR SUB
 *  CMP EOR
 ******************************************************************************
O_ZERO     NOP ** CHANGE decision tree to give DIVS OR SUB their own branch

 ******************************************************************************
 *  DIVS OR SUB
 ******************************************************************************
O_Z_ZERO   NOP * TODO

 ******************************************************************************
 *  LSR ASR ROR LSL ASL ROL
 ******************************************************************************
ROTATEZ    NOP * TODO

 ******************************************************************************
 *  ORI BCLR CMPI
 *  MOVEA MOVE
 ******************************************************************************
Z_ONE      MOVE.W    MASK_12_15,D2   * Load mask for bits 12-15
           AND.W     D1,D2           * Mask bits 12-15
           CMP.W     #0,D2           * Are they 0000?
           BEQ       Z_ONE_SU

           **  MOVEA MOVE
           MOVE.W    MASK_6_8,D2    * Load mask for bits 6-8
           AND.W     D1,D2          * MASK bits
           EOR.W     #$0040,D2      * Will be zero if 6-8 are 001
           BEQ       O_MOVE         * MOVE
           BRA       O_MOVEA        * MOVEA

 ******************************************************************************
 *  ORI BCLR CMPI
 ******************************************************************************
Z_ONE_SU   MOVE.W    MASK_8_11,D2   * Load mask for bits 8-11
           AND.W     D1,D2          * MASK bits
           EORI.W    #$0000,D2      * Will be zero if 8-11 are 0000
           BEQ       O_ORI          * ORI

           MOVE.W    MASK_8_11,D2   * Load mask for bits 8-11
           AND.W     D1,D2          * MASK bits
           EORI.W    #$0C00,D2      * Will be zero if 8-11 are 1100
           BEQ       O_CMPI         * ORI

           BRA       O_BCLR

 ******************************************************************************
 * BRA BCS BVC BGE BLT
 ******************************************************************************
BRANCHZ    MOVE.W    MASK_8_11,D2   * Load mask for bits 8-11
           AND.W     D1,D2          * MASK bits
           EORI.W    #$0000,D2      * Will be zero if 8-11 are 0000
           BEQ       O_BRA           

           MOVE.W    MASK_8_11,D2   * Load mask for bits 8-11
           AND.W     D1,D2          * MASK bits
           EORI.W    #$0500,D2      * Will be zero if 8-11 are 0101
           BEQ       O_BCS           

           MOVE.W    MASK_8_11,D2   * Load mask for bits 8-11
           AND.W     D1,D2          * MASK bits
           EORI.W    #$0800,D2      * Will be zero if 8-11 are 1000
           BEQ       O_BVC           

           MOVE.W    MASK_8_11,D2   * Load mask for bits 8-11
           AND.W     D1,D2          * MASK bits
           EORI.W    #$0C00,D2      * Will be zero if 8-11 are 1100
           BEQ       O_BGE           

           MOVE.W    MASK_8_11,D2   * Load mask for bits 8-11
           AND.W     D1,D2          * MASK bits
           EORI.W    #$0D00,D2      * Will be zero if 8-11 are 1101
           BEQ       O_BLT           

           BRA       INVALID_OP     * Invalid opcode!

*******************************************************************************
********** END Decision tree***************************************************
*******************************************************************************
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*******************************************************************************
********** Opcode specific processing begin ***********************************
*******************************************************************************
********** ORI ****************************************************************
O_ORI      MOVE.B    #1,EA_FLAG      * Load flag for EA
           LEA       STR_ORI,A6      * Load ORI string into A6
           JSR       WRITE_ANY
           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY
 * TODO
*******************************************************************************
********** BCLR ***************************************************************
O_BCLR     NOP * TODO REMEMBER v2

*******************************************************************************
********** BCLR version 2 *****************************************************
O_BCLR_2   NOP * TODO

*******************************************************************************
********** CMPI ***************************************************************
O_CMPI     NOP * TODO

*******************************************************************************
********** MOVEA **************************************************************
O_MOVEA    MOVE.B    #0,EA_FLAG      * Load flag for EA
           LEA       STR_MOVEA,A6    * Load MOVEA string into A6
           JSR       WRITE_ANY
           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY
           JSR       GET_MV_SZ
           CMP.B     #0,SIZE_OP      * MOVEA cannot be a byte
           BEQ       INVALID_OP
           JSR       WRITE_ANY
           BRA       PREP_EA

*******************************************************************************
********** MOVE ***************************************************************
O_MOVE     MOVE.B    #0,EA_FLAG      * Load flag for EA
           LEA       STR_MOVE,A6     * Load MOVE string into A6
           JSR       WRITE_ANY
           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY
           JSR       GET_MV_SZ
           JSR       WRITE_ANY
           BRA       PREP_EA

*******************************************************************************
********** NEG ****************************************************************
O_NEG      NOP * TODO


*******************************************************************************
********** JSR ****************************************************************
O_JSR      NOP * TODO


*******************************************************************************
********** MOVEM **************************************************************
O_MOVEM    NOP * TODO


*******************************************************************************
********** LEA ****************************************************************
O_LEA      NOP * TODO


*******************************************************************************
********** SUBQ ***************************************************************
O_SUBQ     NOP * TODO


*******************************************************************************
********** BRA ****************************************************************
O_BRA      NOP * TODO


*******************************************************************************
********** BCS ****************************************************************
O_BCS      NOP * TODO


*******************************************************************************
********** BVC ****************************************************************
O_BVC      NOP * TODO


*******************************************************************************
********** BGE ****************************************************************
O_BGE      NOP * TODO


*******************************************************************************
********** BLT ****************************************************************
O_BLT      NOP * TODO


*******************************************************************************
********** DIVS ***************************************************************
O_DIVS     NOP * TODO


*******************************************************************************
********** OR *****************************************************************
O_OR       NOP * TODO


*******************************************************************************
********** SUB ****************************************************************
O_SUB      NOP * TODO


*******************************************************************************
********** CMP ****************************************************************
O_CMP      NOP * TODO


*******************************************************************************
********** EOR ****************************************************************
O_EOR      NOP * TODO


*******************************************************************************
********** MULS ***************************************************************
O_MULS     NOP * TODO


*******************************************************************************
********** ADD ****************************************************************
O_ADD      NOP * TODO


*******************************************************************************
********** ADDA ***************************************************************
O_ADDA     NOP * TODO


*******************************************************************************
********** LSR ****************************************************************
O_LSR      NOP * TODO


*******************************************************************************
********** ASR ****************************************************************
O_ASR      NOP * TODO


*******************************************************************************
********** ROR ****************************************************************
O_ROR      NOP * TODO


*******************************************************************************
********** LSL ****************************************************************
O_LSL      NOP * TODO


*******************************************************************************
********** ASL ****************************************************************
O_ASL      NOP * TODO


*******************************************************************************
********** ROL ****************************************************************
O_ROL      NOP * TODO


********** End opcode specific processing *************************************
*******************************************************************************
*******************************************************************************
*******************************************************************************

*******************************************************************************
******************** Prepare for Call to Saam *********************************
PREP_EA    JSR       SPACE_FILL
           MOVE.W    EA_FLAG,D2
           MOVE.W    ORIG_OP,D3
           MOVE.W    SIZE_OP,D4
           MOVE.W    #0,D0
           JSR       START_EA
           BRA       PREP_RET

*******************************************************************************
******************** Prepare for return to IO *********************************
PREP_RET   RTS * TODO

*******************************************************************************
******************** Invalid opcode handling **********************************
INVALID_OP RTS * TODO

*******************************************************************************
******************** Write opcode with no size ********************************
W_NO_SIZE  JSR       WRITE_ANY
           RTS

*******************************************************************************
******************** Get Size *************************************************
GET_SIZE   NOP * TODO

*******************************************************************************
******************** Fill with whitespace *************************************
SPACE_FILL LEA       STR_SPACE,A6   * Load whitespace into A6
           MOVE.L    START_BUFF,D0  * Load starting address of buffer into D0
           SUB.L     A2,D0          * Loads difference into D0
           NEG.L     D0
           SUBQ      #1,D0
SPACE_LOOP JSR       WRITE_ANY
           MOVE      #0,CCR
           DBEQ      D0,SPACE_LOOP  * Compare is D0 > 0?
SPACE_DONE RTS

*******************************************************************************
******************** Get MOVE size ********************************************
GET_MV_SZ  MOVE.W    MASK_12_15,D2
           AND.W     D1,D2
           CMP.W     #$1000,D2
           BEQ       MV_B_SZ
           CMP.W     #$2000,D2
           BEQ       MV_L_SZ
           CMP.W     #$3000,D2
           BEQ       MV_W_SZ
           MOVE.W    #-5,SIZE_OP
           RTS
MV_B_SZ    MOVE.W    #0,SIZE_OP
           LEA       STR_BYTE,A6
           RTS
MV_W_SZ    MOVE.W    #1,SIZE_OP
           LEA       STR_WORD,A6
           RTS
MV_L_SZ    MOVE.W    #2,SIZE_OP
           LEA       STR_LONG,A6
           RTS

*******************************************************************************
******************** Write a null-term string to buff *************************
WRITE_ANY  CMPI.B    #0,(A6)        * Is the byte at A6 the NULL Char?
           BEQ       W_DONE
           MOVE.B    (A6)+,(A2)+
           BRA       WRITE_ANY
W_DONE     RTS

*******************************************************************************
******************** Fin ******************************************************
END_THOM   MOVE.B    #9,D0          * Break out of sim
           TRAP      #15

*******************************************************************************
******************** API variable storage *************************************
START_BUFF DC.L      $0
ORIG_OP    DC.W      $0
EA_FLAG    DC.W      $0
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
STR_MOVE   DC.B      'MOVE',0
STR_MOVEA  DC.B      'MOVEA',0
STR_ORI    DC.B      'ORI',0
STR_ADD    DC.B      'ADD',0
STR_ADDA   DC.B      'ADD',0
STR_ASL    DC.B      'ASL',0
STR_ASR    DC.B      'ASR',0
STR_BCLR   DC.B      'BCL',0
STR_BCLR   DC.B      'BCL',0
STR_BCS    DC.B      'BCS',0
STR_BGE    DC.B      'BGE',0
STR_BLT    DC.B      'BLT',0
STR_BRA    DC.B      'BRA',0
STR_BVC    DC.B      'BVC',0
STR_CMP    DC.B      'CMP',0
STR_CMPI   DC.B      'CMP',0
STR_DIVS   DC.B      'DIV',0
STR_EOR    DC.B      'EOR',0
STR_JSR    DC.B      'JSR',0
STR_LEA    DC.B      'LEA',0
STR_LSL    DC.B      'LSL',0
STR_LSR    DC.B      'LSR',0
STR_MOVE   DC.B      'MOV',0
STR_MULS   DC.B      'MUL',0
STR_NEG    DC.B      'NEG',0
STR_OR     DC.B      'OR',0
STR_ROL    DC.B      'ROL',0
STR_ROR    DC.B      'ROR',0
STR_SUB    DC.B      'SUB',0
STR_SUBQ   DC.B      'SUB',0

STR_PERI   DC.B      '.',0
STR_SPACE  DC.B      ' ',0
STR_BYTE   DC.B      'B',0
STR_WORD   DC.B      'W',0
STR_LONG   DC.B      'L',0

******************** Test variables *******************************************
TEST_A0    DC.L      TEST_OP
*TEST_OP    DC.W      $4E71       * NOP
*TEST_OP    DC.W      $4E75        * RTS
*TEST_OP    DC.W      $8200        * OR D0,D0
TEST_OP    DC.W      $3200        * MOVE.W D0,D1

TEST_FLAG  DC.W      $0
TEST_BUFF  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

           INCLUDE   tester_eamodes_SaamAmiri.x68

           END       START                    * last line of source

*~Font name~Courier~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
