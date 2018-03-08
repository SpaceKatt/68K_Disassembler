*-----------------------------------------------------------
* Title       : Opcode Stuff
* Written by  : Thomas Kercheval
* Date        :
* Description : 68K Disassembler Opcode Module
*-----------------------------------------------------------

CR         EQU       $0D             * Carriage return
LF         EQU       $0A             * Line feed
STACKPTRE  EQU       $8000

           ORG       $1000
START:                               * first instruction of program
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
           BRA       WRITE_ANY

           ********* RTS ******************************************************
O_RTS      LEA       STR_RTS,A6      * Load RTS string into A6
           BRA       WRITE_ANY

*******************************************************************************
*******************************************************************************
** START DECISION TREE, Available opcodes:
**  ORI BCLR CMPI MOVEA MOVE NEG JSR MOVEM LEA SUBQ BRA BCS BVC BGE BLT
**  DIVS OR SUB CMP EOR MULS ADD ADDA LSR ASR ROR LSL ASL ROL
*******************************************************************************
*******************************************************************************
OP_TREE    BTST      #15,D1          * Test MSB in opcode
           BNE       ONE

           ** ORI BCLR CMPI MOVEA MOVE
           ** NEG JSR MOVEM LEA SUBQ BRA BCS BVC BGE BLT
           BTST      #14,D1          * Test second most sig bit in opcode
           BEQ       Z_ONE           * ORI BCLR CMPI MOVEA MOVE

           ** NEG JSR MOVEM LEA SUBQ
           ** BRA BCS BVC BGE BLT
           BTST      #13,D1          * Test third MSB in opcode
           BNE       BRANCHZ         * BRA BCS BVC BGE BLT

           ** NEG JSR MOVEM LEA SUBQ
           BTST      #12,D1          * Test fourth MSB in opcode
           BNE       O_SUBQ

           MOVE.W    MASK_8_11,D2    * Load mask for bits 8-11
           AND.W     D1,D2           * MASK bits
           CMPI.W    #$0400,D2       * Will be zero if 8-11 are 0100
           BEQ       O_NEG

           CMPI.W    #$0E00,D2       * Will be zero if 8-11 are 1110
           BEQ       O_JSR

           MOVE.W    MASK_6_8,D2     * Load mask for bits 8-11
           AND.W     D1,D2           * MASK bits
           CMPI.W    #$01C0,D2       * Will be zero if 6-8 are 111
           BEQ       O_LEA

           BRA       O_MOVEM         * Else, we have MOVEM

 ******************************************************************************
 *  DIVS OR SUB CMP EOR
 *  MULS ADD ADDA LSR ASR ROR LSL ASL ROL
 ******************************************************************************
ONE        BTST      #14,D1          * Test second most sig bit in opcode
           BEQ       O_ZERO

           **  MULS ADD ADDA
           **  LSR ASR ROR LSL ASL ROL
           BTST      #13,D1          * Test third most sig
           BNE       ROTATEZ         *  LSR ASR ROR LSL ASL ROL

           **  MULS ADD ADDA
           BTST      #12,D1
           BEQ       O_MULS          * Identified MULS op

           MOVE.W    MASK_6_7,D2     * Load mask for bits 6-7
           AND.W     D1,D2           * MASK bits
           CMPI.W    #$00C0,D2       * Will be zero if 6-7 are 11
           BEQ       O_ADDA          * ADDA

           BRA       O_ADD           * ADD

 ******************************************************************************
 *  DIVS OR SUB
 *  CMP EOR
 ******************************************************************************
O_ZERO     BTST      #13,D1          * Test third MSB
           BEQ       O_Z_ZERO        * DIVS OR SUB

           **  CMP EOR
           BTST      #8,D1           * This is pretty obvious
           BNE       O_EOR

           BRA       O_CMP

 ******************************************************************************
 *  DIVS OR SUB
 ******************************************************************************
O_Z_ZERO   BTST      #12,D1          * Test fourth MSB
           BNE       O_SUB

           MOVE.W    MASK_6_8,D2     * Load mask for bits 8-11
           AND.W     D1,D2           * MASK bits
           CMPI.W    #$01C0,D2       * Will be zero if 6-8 are 111
           BEQ       O_DIVS

           BRA       O_OR

 ******************************************************************************
 *  LSR ASR ROR LSL ASL ROL
 ******************************************************************************
ROTATEZ    BTST      #8,D1           * Determines direction
           BEQ       GO_RIGHT
           MOVE.W    #1,D7           * Lets say 0 is R and 1 is left
           BRA       CONT_ROTZ
GO_RIGHT   MOVE.W    #0,D7           * Lets say 0 is R and 1 is left

CONT_ROTZ  MOVE.W    MASK_6_7,D2     * Load mask for bits 6-7
           AND.W     D1,D2           * Mask bits 6-7
           CMP.W     #$00C0,D2       * Sets Z to 1 if equal
           BEQ       NORM_ROTZ

           MOVE.W    #5,EA_FLAG      * "weird" rotation
           MOVE.W    #$0018,D2       * Load mask for bits 3-4
           AND.W     D1,D2           * Mask bits 3-4
           LSR       #3,D2
           BRA       COMP_ROTZ

NORM_ROTZ  MOVE.W    #1,EA_FLAG      * Normal 6-EA
           MOVE.W    #$0600,D2       * Load mask for bits 9-10
           AND.W     D1,D2           * Mask bits 9-10
           LSR       #8,D2
           LSR       #1,D2

COMP_ROTZ  CMPI.W    #$0000,D2       * ASd signature
           BEQ       O_ASd

           CMPI.W    #$0001,D2       * LSd signature
           BEQ       O_LSd

           CMPI.W    #$0003,D2       * ROd signature
           BEQ       O_ROd

           BRA       INVALID_OP      * Invalid opcode

 ******************************************************************************
 *  ORI BCLR CMPI
 *  MOVEA MOVE
 ******************************************************************************
Z_ONE      MOVE.W    MASK_12_15,D2   * Load mask for bits 12-15
           AND.W     D1,D2           * Mask bits 12-15
           CMP.W     #0,D2           * Are they 0000?
           BEQ       Z_ONE_SU

           **  MOVEA MOVE
           MOVE.W    MASK_6_8,D2     * Load mask for bits 6-8
           AND.W     D1,D2           * MASK bits
           CMPI.W    #$0040,D2       * Will be zero if 6-8 are 001
           BEQ       O_MOVEA         * MOVEA

           BRA       O_MOVE          * MOVE

 ******************************************************************************
 *  ORI BCLR CMPI
 ******************************************************************************
Z_ONE_SU   MOVE.W    MASK_8_11,D2    * Load mask for bits 8-11
           AND.W     D1,D2           * MASK bits
           CMPI.W    #$0000,D2       * Will be zero if 8-11 are 0000
           BEQ       O_ORI           * ORI

           CMPI.W    #$0C00,D2       * Will be zero if 8-11 are 1100
           BEQ       O_CMPI          * ORI

           BRA       O_BCLR

 ******************************************************************************
 * BRA BCS BVC BGE BLT
 ******************************************************************************
BRANCHZ    MOVE.W    MASK_8_11,D2    * Load mask for bits 8-11
           AND.W     D1,D2           * MASK bits
           CMPI.W    #$0000,D2       * Will be zero if 8-11 are 0000
           BEQ       O_BRA

           CMPI.W    #$0500,D2       * Will set zero if 8-11 are 0101
           BEQ       O_BCS

           CMPI.W    #$0800,D2       * Will set zero if 8-11 are 1000
           BEQ       O_BVC

           CMPI.W    #$0C00,D2       * Will set zero if 8-11 are 1100
           BEQ       O_BGE

           CMPI.W    #$0D00,D2       * Will set zero if 8-11 are 1101
           BEQ       O_BLT

           BRA       INVALID_OP      * Invalid opcode!

*******************************************************************************
********** END Decision tree***************************************************
*******************************************************************************
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*******************************************************************************
********** Opcode specific processing begin ***********************************
*******************************************************************************
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
********** ORI ****************************************************************
O_ORI      MOVE.W    #10,EA_FLAG      * Load flag for EA
           LEA       STR_ORI,A6      * Load ORI string into A6
           JSR       NORM_OP_FL      * Write op, '.', get size, write size

           BRA       PREP_EA

*******************************************************************************
********** BCLR ***************************************************************
O_BCLR     BTST      #8,D1           * Delineate between versions of BCLR
           BEQ       O_BCLR_2        * "Weird" BCLR

           MOVE.W    #2,EA_FLAG      * Load flag for EA
WR_BCLR    LEA       STR_BCLR,A6     * Load BCLR string into A6
           JSR       WRITE_ANY
           
           BRA       PREP_EA

*******************************************************************************
********** BCLR version 2 *****************************************************
O_BCLR_2   MOVE.W    #9,EA_FLAG      * Load flag for EA

           BRA       WR_BCLR         * Everything other than EA flag is same

*******************************************************************************
********** CMPI ***************************************************************
O_CMPI     MOVE.W    #10,EA_FLAG      * Load flag for EA
           LEA       STR_CMPI,A6     * Load CMPI string into A6
           JSR       NORM_OP_FL      * Write op, '.', get size, write size

           BRA       PREP_EA

*******************************************************************************
********** MOVEA **************************************************************
O_MOVEA    MOVE.W    #0,EA_FLAG      * Load flag for EA
           LEA       STR_MOVEA,A6    * Load MOVEA string into A6
           JSR       WRITE_ANY

           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY
           JSR       GET_MV_SZ

           CMP.W     #0,SIZE_OP      * MOVEA cannot be a byte
           BEQ       INVALID_OP

           JSR       WRITE_ANY
           BRA       PREP_EA

*******************************************************************************
********** MOVE ***************************************************************
O_MOVE     MOVE.W    #0,EA_FLAG      * Load flag for EA
           LEA       STR_MOVE,A6     * Load MOVE string into A6
           JSR       WRITE_ANY

           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY

           JSR       GET_MV_SZ
           JSR       WRITE_ANY
           BRA       PREP_EA

*******************************************************************************
********** NEG ****************************************************************
O_NEG      MOVE.W    #1,EA_FLAG      * Load flag for EA
           LEA       STR_NEG,A6      * Load NEG string into A6
           JSR       NORM_OP_FL      * Write op, '.', get size, write size

           BRA       PREP_EA

*******************************************************************************
********** JSR ****************************************************************
O_JSR      MOVE.W    #10,EA_FLAG      * Load flag for EA
           LEA       STR_JSR,A6      * Load NEG string into A6
           JSR       WRITE_ANY       * Write op
           MOVE.W    #2,SIZE_OP      * Tell EA to grab a long

           BRA       PREP_EA

*******************************************************************************
********** MOVEM **************************************************************
O_MOVEM    MOVE.W    #7,EA_FLAG      * Load flag for EA
           LEA       STR_MOVEM,A6    * Load MOVEM string into A6
           JSR       WRITE_ANY

           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY

           MOVE.W    D1,D6           * Must test bit 6 for size flag
           LSR.W     #6,D6           * Shift 6th bit into least sig postition
           JSR       SINGLE_SZ       * MOVEM has one size flag
           JSR       WRITE_ANY

           BRA       PREP_EA

*******************************************************************************
********** LEA ****************************************************************
O_LEA      MOVE.W    #8,EA_FLAG      * Load flag for EA
           LEA       STR_LEA,A6      * Load LEA string into A6
           JSR       WRITE_ANY       * Writes the op (previously loaded to A6)

           BRA       PREP_EA

*******************************************************************************
********** SUBQ ***************************************************************
O_SUBQ     MOVE.W    #6,EA_FLAG      * Load flag for EA
           LEA       STR_SUBQ,A6     * Load SUBQ string into A6
           JSR       NORM_OP_FL      * Write op, '.', get size, write size

           BRA       PREP_EA

*******************************************************************************
********** BRA ****************************************************************
O_BRA      MOVE.W    #4,EA_FLAG      * Load flag for EA
           LEA       STR_BRA,A6      * Load BRA string into A6
           JSR       WRITE_ANY

           BRA       PREP_EA

*******************************************************************************
********** BCS ****************************************************************
O_BCS      MOVE.W    #4,EA_FLAG      * Load flag for EA
           LEA       STR_BCS,A6      * Load BCS string into A6
           JSR       WRITE_ANY

           BRA       PREP_EA

*******************************************************************************
********** BVC ****************************************************************
O_BVC      MOVE.W    #4,EA_FLAG      * Load flag for EA
           LEA       STR_BVC,A6      * Load BVC string into A6
           JSR       WRITE_ANY

           BRA       PREP_EA

*******************************************************************************
********** BGE ****************************************************************
O_BGE      MOVE.W    #4,EA_FLAG      * Load flag for EA
           LEA       STR_BGE,A6      * Load BGE string into A6
           JSR       WRITE_ANY

           BRA       PREP_EA

*******************************************************************************
********** BLT ****************************************************************
O_BLT      MOVE.W    #4,EA_FLAG      * Load flag for EA
           LEA       STR_BLT,A6      * Load BLT string into A6
           JSR       WRITE_ANY

           BRA       PREP_EA

*******************************************************************************
********** DIVS ***************************************************************
O_DIVS     MOVE.W    #2,EA_FLAG      * Load flag for EA
           LEA       STR_DIVS,A6     * Load DIVS string into A6
           JSR       WRITE_ANY       * Writes the op (previously loaded to A6)
* TODO validation
           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY       * Write '.' to buffer

           MOVE.W    #1,SIZE_OP      * 1 into size_op to represent word for API
           LEA       STR_WORD,A6
           JSR       WRITE_ANY       * Write size to buffer

           BRA       PREP_EA

*******************************************************************************
********** OR *****************************************************************
O_OR       MOVE.W    #3,EA_FLAG      * Load flag for EA
           LEA       STR_OR,A6       * Load OR string into A6
           JSR       NORM_OP_FL      * Write op, '.', get size, write size

           BRA       PREP_EA

*******************************************************************************
********** SUB ****************************************************************
O_SUB      MOVE.W    #3,EA_FLAG      * Load flag for EA
           LEA       STR_SUB,A6       * Load SUB string into A6
           JSR       NORM_OP_FL      * Write op, '.', get size, write size

           BRA       PREP_EA

*******************************************************************************
********** CMP ****************************************************************
O_CMP      MOVE.W    #3,EA_FLAG      * Load flag for EA
           LEA       STR_CMP,A6      * Load CMP string into A6
           JSR       NORM_OP_FL      * Write op, '.', get size, write size

           BRA       PREP_EA

*******************************************************************************
********** EOR ****************************************************************
O_EOR      MOVE.W    #3,EA_FLAG      * Load flag for EA
           LEA       STR_EOR,A6      * Load EOR string into A6
           JSR       NORM_OP_FL      * Write op, '.', get size, write size

           BRA       PREP_EA

*******************************************************************************
********** MULS ***************************************************************
O_MULS     MOVE.W    #2,EA_FLAG      * Load flag for EA
           LEA       STR_MULS,A6     * Load ORI string into A6
           JSR       WRITE_ANY       * Writes the op (previously loaded to A6)
* TODO validation
           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY       * Write '.' to buffer

           MOVE.W    #1,SIZE_OP      * 1 into size_op to represent word for API
           LEA       STR_WORD,A6
           JSR       WRITE_ANY       * Write size to buffer

           BRA       PREP_EA

*******************************************************************************
********** ADD ****************************************************************
O_ADD      MOVE.W    #3,EA_FLAG      * Load flag for EA
           LEA       STR_ADD,A6      * Load ADD string into A6
           JSR       NORM_OP_FL      * Write op, '.', get size, write size

           BRA       PREP_EA

*******************************************************************************
********** ADDA ***************************************************************
O_ADDA     MOVE.W    #8,EA_FLAG      * Load flag for EA
           LEA       STR_ADDA,A6     * Load ADDA string into A6
           JSR       WRITE_ANY       * Writes the op (previously loaded to A6)

           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY       * Write '.' to buffer

           MOVE.W    D1,D6           * Move opcode into D6
           LSR.W     #8,D6           * Shift 6th bit into least sig postition

           JSR       SINGLE_SZ       * Grab single size
           JSR       WRITE_ANY       * Write size to buffer

           BRA       PREP_EA

*******************************************************************************
********** LSd ****************************************************************
O_LSd      LEA       STR_LSR,A6      * Load LSR into A6
           JSR       DIR_UTIL
           JSR       WRITE_ANY

           JSR       SIZE_UTIL
           BRA       PREP_EA

*******************************************************************************
********** ASd ****************************************************************
O_ASd      LEA       STR_ASR,A6      * Load ASR into A6
           JSR       DIR_UTIL
           JSR       WRITE_ANY

           JSR       SIZE_UTIL
           BRA       PREP_EA

*******************************************************************************
********** ROd ****************************************************************
O_ROd      LEA       STR_ROR,A6      * Load ROR into A6
           JSR       DIR_UTIL
           JSR       WRITE_ANY

           JSR       SIZE_UTIL
           BRA       PREP_EA

  ******** UTILITY TO SELECT R/L version of LSd/ASd/ROd
DIR_UTIL   BTST      #0,D7           * 0 is R and 1 is left
           BEQ       RET_DIR_U
           ADDA.L    #4,A6           * If left, add one to select left version
RET_DIR_U  RTS

  ******** UTILITY TO GET SIZE of LSd/ASd/ROd
SIZE_UTIL  LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY       * Write '.' to buffer

           JSR       GET_OP_SZ
           CMPI.W    #-5,SIZE_OP     * If size bits are 11, then it is "weird"
           BEQ       WEIRD_ROT       * Handle memory shift
           JSR       WRITE_ANY       * Else, write size
           RTS

         * Handles case where there is no size (memory shifts)
WEIRD_ROT  MOVE.B    STR_SPACE,-(A2) * Erase '.' from buffer
           MOVE.W    #2,SIZE_OP      * Tell EA to grab long from immediate
           RTS

********** End opcode specific processing *************************************
*******************************************************************************
*******************************************************************************
*******************************************************************************

*******************************************************************************
******************** The flow of a normal operator ****************************
NORM_OP_FL JSR       WRITE_ANY       * Writes the op (previously loaded to A6)

           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY       * Write '.' to buffer

           JSR       GET_OP_SZ       * Get size of the op
           JSR       WRITE_ANY       * Write size to buffer

           RTS                       * Return for opcode specific processing

*******************************************************************************
******************** Prepare for Call to Saam *********************************
PREP_EA    JSR       SPACE_FILL    
         * CLEAR ALL DATA REGISTERS
           CLR.L     D0
           CLR.L     D1
           CLR.L     D2
           CLR.L     D3
           CLR.L     D4
           CLR.L     D5
           CLR.L     D6
           CLR.L     D7
         * CLEAR NON-API ADDRESS REGISTERS
           MOVEA.L   #0,A1
           MOVEA.L   #0,A3
           MOVEA.L   #0,A4
           MOVEA.L   #0,A5
           MOVEA.L   #0,A6

         * LOAD API SPECIFIC REGISTERS
           MOVE.W    EA_FLAG,D2
           MOVE.W    ORIG_OP,D3
           MOVE.W    SIZE_OP,D4
           MOVE.W    #0,D0
           JSR       START_EA
           JSR       EA_VALID
           BRA       PREP_RET

*******************************************************************************
******************** Prepare for return to IO *********************************
PREP_RET   RTS * TODO

*******************************************************************************
******************** Invalid opcode handling **********************************
INVALID_OP RTS * TODO

*******************************************************************************
******************** EA buffer address return validation **********************
EA_VALID   MOVE.L    A0,D7
           BTST      #0,D7
           BEQ       EA_IS_VAL
           LEA       INVAL_MSG,A1
           BRA       ERR_MSG

EA_IS_VAL  RTS

*******************************************************************************
******************** Validate size, if invalid size is found, then op is too **
SZ_VALID   CMPI.W    #-5,D4
           BNE       EA_IS_VAL
           LEA       INVAL_SZG,A1
           BRA       ERR_MSG

SZ_IS_VAL  RTS

*******************************************************************************
******************** Write an error message ***********************************
ERR_MSG    MOVE.B    #14,D0          * Write message
           TRAP      #15
           MOVE.B    #9,D0           * Break out of sim
           TRAP      #15

*******************************************************************************
******************** Fill with whitespace *************************************
SPACE_FILL LEA       STR_SPACE,A6    * Load whitespace into A6
           MOVE.L    START_BUFF,D0   * Load starting address of buffer into D0
           SUB.L     A2,D0           * Loads difference into D0
           *NEG.L     D0
           ADD.W     #$A,D0
           *MOVE      #0,CCR
SPACE_LOOP MOVE.B    (A6),(A2)+
           DBEQ      D0,SPACE_LOOP   * Compare is D0 > 0?
SPACE_DONE RTS

*******************************************************************************
******************** Get MOVE size ********************************************
GET_MV_SZ  MOVE.W    MASK_12_15,D2
           AND.W     D1,D2
           CMP.W     #$1000,D2       * Byte if size bits are 01
           BEQ       OP_B_SZ

           CMP.W     #$2000,D2       * Byte if size bits are 11
           BEQ       OP_L_SZ

           CMP.W     #$3000,D2       * Byte if size bits are 10
           BEQ       OP_W_SZ

           BRA       SZ_INVLD

*******************************************************************************
******************** Get size of most ops *************************************
GET_OP_SZ  MOVE.W    MASK_6_7,D2
           AND.W     D1,D2
           CMP.W     #$0000,D2       * Byte if size bits are 00
           BEQ       OP_B_SZ

           CMP.W     #$0040,D2       * Byte if size bits are 01
           BEQ       OP_W_SZ

           CMP.W     #$0080,D2       * Byte if size bits are 10
           BEQ       OP_L_SZ

SZ_INVLD   MOVE.W    #-5,SIZE_OP     * Something invalid
           RTS

OP_B_SZ    MOVE.W    #0,SIZE_OP      * Load size flag for API call later
           LEA       STR_BYTE,A6     * Load str representation for byte
           RTS
OP_W_SZ    MOVE.W    #1,SIZE_OP      * Load size flag for API call later
           LEA       STR_WORD,A6     * Load str representation for word
           RTS
OP_L_SZ    MOVE.W    #2,SIZE_OP      * Load size flag for API call later
           LEA       STR_LONG,A6     * Load str representation for long
           RTS

*******************************************************************************
******************** Get size of single flag ops, where flag is in LSB of D6 **
SINGLE_SZ  BTST      #0,D6
           BEQ       OP_W_SZ         * 0 is a word
           BRA       OP_L_SZ         * Else, 1 is a long

*******************************************************************************
******************** Write a null-term string to buff *************************
WRITE_ANY  CMPI.B    #0,(A6)         * Is the byte at A6 the NULL Char?
           BEQ       W_DONE
           MOVE.B    (A6)+,(A2)+
           BRA       WRITE_ANY
W_DONE     RTS

*******************************************************************************
******************** Fin ******************************************************
END_THOM   MOVE.B    #9,D0           * Break out of sim
           TRAP      #15

*******************************************************************************
******************** API variable storage *************************************
START_BUFF DC.L      $0
ORIG_OP    DC.W      $0
EA_FLAG    DC.W      -1
SIZE_OP    DC.W      $0
API_A0     DC.W      $0
API_A2     DC.W      $0

*******************************************************************************
******************** Constant opcodes and masks *******************************
                     ** NOP/RTS
CON_NOP    DC.W      $4E71
CON_RTS    DC.W      $4E75

                     ** MASKS
MASK_12_15 DC.W      $F000           * Mask for the bits from X to Y for _X_Y
MASK_8_11  DC.W      $0F00           * Mask for the bits from X to Y for _X_Y
MASK_6_8   DC.W      $01C0           * Mask for the bits from X to Y for _X_Y
MASK_6_7   DC.W      $00C0           * Mask for the bits from X to Y for _X_Y


******************** Opcode strings *******************************************
INVAL_FLG  DC.B      '!!!!',0
INVAL_MSG  DC.B      'Returned buffer must be on word boundary, looking at you Saam!',CR,LF,0
INVAL_SZG  DC.B      'Found an invalid size!',CR,LF,0

STR_NOP    DC.B      'NOP',0
STR_RTS    DC.B      'RTS',0
STR_MOVE   DC.B      'MOVE',0
STR_MOVEM  DC.B      'MOVEM',0
STR_MOVEA  DC.B      'MOVEA',0
STR_ORI    DC.B      'ORI',0
STR_ADD    DC.B      'ADD',0
STR_ADDA   DC.B      'ADDA',0
STR_BCLR   DC.B      'BCLR',0
STR_BCS    DC.B      'BCS',0
STR_BGE    DC.B      'BGE',0
STR_BLT    DC.B      'BLT',0
STR_BRA    DC.B      'BRA',0
STR_BVC    DC.B      'BVC',0
STR_CMP    DC.B      'CMP',0
STR_CMPI   DC.B      'CMPI',0
STR_DIVS   DC.B      'DIVS',0
STR_EOR    DC.B      'EOR',0
STR_JSR    DC.B      'JSR',0
STR_LEA    DC.B      'LEA',0
STR_LSR    DC.B      'LSR',0
STR_LSL    DC.B      'LSL',0
STR_ASR    DC.B      'ASR',0
STR_ASL    DC.B      'ASL',0
STR_ROR    DC.B      'ROR',0
STR_ROL    DC.B      'ROL',0
STR_MULS   DC.B      'MULS',0
STR_NEG    DC.B      'NEG',0
STR_OR     DC.B      'OR',0
STR_SUB    DC.B      'SUB',0
STR_SUBQ   DC.B      'SUBQ',0

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
*TEST_OP    DC.W      $3200        * MOVE.W D0,D1
*TEST_OP    DC.W      $3240        * MOVEA.W D0,A1
*TEST_OP    DC.W      $0880        * BCLR  #15,D0
*TEST_OP    DC.W      $0380        * BCLR  D1,D0
*TEST_OP    DC.W      $0043        * ORI.W #5,D3
*TEST_OP    DC.W      $4403        * NEG.B D3
*TEST_OP    DC.W      $C7C1        * MULS.W D1,D3
*TEST_OP    DC.W      $D485        * ADD.L  D5,D2
*TEST_OP    DC.W      $6000        * BRA    <LABEL>
*TEST_OP    DC.W      $6500        * BCS    <LABEL>
*TEST_OP    DC.W      $6800        * BVC    <LABEL>
*TEST_OP    DC.W      $6C00        * BGE    <LABEL>
*TEST_OP    DC.W      $6D00        * BLT    <LABEL>
*TEST_OP    DC.W      $5B04        * SUBQ.B   $5,D4
*TEST_OP    DC.W      $48E7        * MOVEM.L D1-D7/A1/A3-A6,-(SP)
*TEST_OP    DC.W      $49F8        * LEA $1012,A4
*TEST_OP    DC.W      $0884        * BCLR   #4,D4
*TEST_OP    DC.W      $E84E        * LSR      #4,D6
*TEST_OP    DC.W      $EB49        * LSL.W    #5,D1
*TEST_OP    DC.W      $E3F8        * LSL.W    $1012
*TEST_OP    DC.W      $E2F8        * LSL      $1012
*TEST_OP    DC.W      $E846        * ASR.W    #4,D6
*TEST_OP    DC.W      $EB41        * ASL.W    #5,D1
*TEST_OP    DC.W      $E0F8        * ASL      $1012
*TEST_OP    DC.W      $E1F8        * ASL      $1012
*TEST_OP    DC.W      $E85E        * ROR.W    #4,D6
*TEST_OP    DC.W      $EB59        * ROL.W    #5,D1
*TEST_OP    DC.W      $E6F8        * ROL      $1012
*TEST_OP    DC.W      $E7F8        * ROL      $1012
*TEST_OP    DC.W      $4EB9        * JSR      <LABEL>
*TEST_OP    DC.W      $85C1        * DIVS.W   D1,D2
*TEST_OP    DC.W      $8240        * OR.W     D0,D1
*TEST_OP    DC.W      $928B        * SUB.L    A3,D1
*TEST_OP    DC.W      $B507        * EOR.B    #2,D7
TEST_OP    DC.W      $D8C2        * ADDA.W   D4,A4

TEST_FLAG  DC.W      $0
TEST_BUFF  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

           INCLUDE   tester_eamodes_SaamAmiri.x68

           END       START                    * last line of source

*~Font name~Courier~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
