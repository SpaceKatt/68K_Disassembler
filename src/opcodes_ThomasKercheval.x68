*-----------------------------------------------------------
* Title       : Opcode Stuff
* Written by  : Thomas Kercheval
* Date        :
* Description : 68K Disassembler Opcode Module
*-----------------------------------------------------------

CR         EQU       $0D             * Carriage return
LF         EQU       $0A             * Line feed

*******************************************************************************
******************** Opcode Start *********************************************
OP_START   JSR       READ_OP         * Read opcode into D1
           BRA       NOP_RTS_T       * Check for NOP/RTS
           BRA       EXTRA_CRED
OP_TREE_C  MOVE      #0,CCR          * Clear condition register
           BRA       OP_TREE         * Branch to decision tree

*******************************************************************************
******************* Read opcode ***********************************************
READ_OP    MOVE.W    (A0)+,D1        * Read opcode into D1
           MOVE.W    D1,ORIG_OP
           MOVE.L    A2,START_BUFF
           RTS

*******************************************************************************
******************* ADHOC checks for extra credit *****************************
********** These checks are not good (uses linear serach) *********************
********** Since these operators were not included in our original design *****
********** They are not done in as efficient of a way *************************
*******************************************************************************
EXTRA_CRED MOVE.W    #$F0C0,D2           * Move mask to D2
           AND.W     D1,D2               * Mask dem bits
           CMPI.W    #$B0C0,D2           * Check for CMPA
           BEQ       O_CMPA
           CMPI.W    #$90C0,D2           * Check for SUBA
           BEQ       O_SUBA
           
           BRA       OP_TREE_C           * EXTRA_CRED ops not found
           
          
           ********* CMPA *****************************************************
O_CMPA     LEA       STR_CMPA,A6      * Load CMPA string into A6
           BRA       CMPASUBA

           ********* SUBA *****************************************************
O_SUBA     LEA       STR_SUBA,A6      * Load SUBA string into A6
           BRA       CMPASUBA

*******************************************************************************
******************* Checks for NOP/RTS ****************************************
NOP_RTS_T  CMP.W     (CON_NOP),D1    * Is the opcode NOP?
           BEQ       O_NOP           * Take care of NOP
           CMP.W     (CON_RTS),D1    * Is the opcode RTS?
           BEQ       O_RTS           * Take care of RTS
           CMPI.W    #$4E4F,D1       * Is it TRAP #15?
           BEQ       O_TRAP
           BRA       EXTRA_CRED

           ********* NOP ******************************************************
O_NOP      LEA       STR_NOP,A6      * Load NOP string into A6
           BRA       WRITE_ANY

           ********* NOP ******************************************************
O_TRAP     LEA       STR_TRAP,A6      * Load NOP string into A6
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

           CMPI.W    #$0200,D2       * Will be zero if 8-11 are 0100
           BEQ       O_CLR

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
           BTST      #12,D1          * Both of these have 1 in bit 12
           BEQ       INVALID_OP      * Else are invalid

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
ROTATEZ    BTST      #12,D1          * All of these opcodes should have 0 here
           BNE       INVALID_OP      * Else, are invalid

           BTST      #8,D1           * Determines direction
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
           LSR       #3,D2           * Shift into LSB for test
           BRA       COMP_ROTZ

NORM_ROTZ  MOVE.W    #1,EA_FLAG      * Normal 6-EA
           MOVE.W    #$0600,D2       * Load mask for bits 9-10
           AND.W     D1,D2           * Mask bits 9-10
           LSR       #8,D2           * Shift into LSB for test
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

           CMPI.W    #$0200,D2       * Will be zero if 8-11 are 0010
           BEQ       O_ANDI          * ANDI

           CMPI.W    #$0400,D2       * Will be zero if 8-11 are 0100
           BEQ       O_SUBI          * SUBI

           CMPI.W    #$0600,D2       * Will be zero if 8-11 are 0110
           BEQ       O_ADDI          * ADDI

           CMPI.W    #$0A00,D2       * Will be zero if 8-11 are 1010
           BEQ       O_EORI          * EORI

           CMPI.W    #$0C00,D2       * Will be zero if 8-11 are 1100
           BEQ       O_CMPI          * CMPI

           BRA       O_BCLR

 ******************************************************************************
 * BRA BCS BVC BGE BLT
 ******************************************************************************
BRANCHZ    BTST      #12,D1          * Should be 0
           BNE       INVALID_OP      * Else, not a branch

           CLR.L     D2
           MOVE.W    MASK_8_11,D2    * Load mask for bits 8-11
           AND.L     D1,D2           * MASK bits

           LSR.L     #8,D2           * Make bits into 0-F index
           MULS      #4,D2           * Multiply by 4, because each address in
           MOVEA.W   D2,A6           * BRA_TABLE is a LONG. Move to A6 for
                                     * use as a displacement

           MOVE.W    #4,EA_FLAG      * Load flag for EA
           LEA       (BRA_TABLE,PC,A6),A6      * Load BRA string into A6
           MOVEA.L   (A6),A6

           CMP.B     #0,(A6)         * Invalid opcode! BF doesn't exist
                                     * It's string is set to NULL
           BRA       WR_PRP_EA

BRA_TABLE  DC.L      STR_BRA,STR_BF,STR_BHI,STR_BLS,STR_BCC,STR_BCS,STR_BNE
           DC.L      STR_BEQ,STR_BVC,STR_BVS,STR_BPL,STR_BMI,STR_BGE,STR_BLT
           DC.L      STR_BGT,STR_BLE

STR_BRA    DC.B      'BRA',0
STR_BF     DC.B      0
STR_BHI    DC.B      'BHI',0
STR_BLS    DC.B      'BLS',0
STR_BCC    DC.B      'BCC',0
STR_BCS    DC.B      'BCS',0
STR_BNE    DC.B      'BNE',0
STR_BEQ    DC.B      'BEQ',0
STR_BVC    DC.B      'BVC',0
STR_BVS    DC.B      'BVS',0
STR_BPL    DC.B      'BPL',0
STR_BMI    DC.B      'BMI',0
STR_BGE    DC.B      'BGE',0
STR_BLT    DC.B      'BLT',0
STR_BGT    DC.B      'BGT',0
STR_BLE    DC.B      'BLE',0

*******************************************************************************
********** END Decision tree***************************************************
*******************************************************************************
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*******************************************************************************
********** Opcode specific processing begin ***********************************
*******************************************************************************
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
********** ORI ****************************************************************
O_ORI      MOVE.W    #10,EA_FLAG     * Load flag for EA
           LEA       STR_ORI,A6      * Load ORI string into A6
           BRA       NORM_OP_FL      * Write op, '.', get size, write size

*******************************************************************************
********** BCLR ***************************************************************
O_BCLR     MOVE.W    MASK_6_7,D2     * Load mask for validation
           AND.W     D1,D2           * Mask bits 6-7 in opcode
           MOVE.W    #9,EA_FLAG      * Load flag for EA
           CMPI.W    #$0000,D2       * If it be %00, then we found BTST
           BEQ       O_BTST          * Found BTST

           CMPI.W    #$0080,D2       * Should be %10, else invalid
           BNE       INVALID_OP      * If invalid, exit

           BTST      #8,D1           * Delineate between versions of BCLR
           BEQ       O_BCLR_2        * "Weird" BCLR

WR_BCLR    LEA       STR_BCLR,A6     * Load BCLR string into A6
WR_BTST    MOVE.W    #1,SIZE_OP

           BRA       WR_PRP_EA

*******************************************************************************
********** BCLR version 2 *****************************************************
O_BCLR_2   MOVE.W    #10,EA_FLAG      * Load flag for EA
           MOVE.W    MASK_8_11,D2     * Load mask for validation
           AND.W     D1,D2            * Mask bits, should be %1000 for BCLR
           CMPI.W    #$0800,D2
           BNE       INVALID_OP       * Else, are invalid

           BRA       WR_BCLR         * Everything other than EA flag is same

O_BTST     LEA       STR_BTST,A6      * Load str for BTST
           BTST      #8,D1           * Delineate between versions of BTST
           BEQ       O_BTST_2        * "Weird" BTST

           BRA       WR_BTST

O_BTST_2   MOVE.W    #10,EA_FLAG      * Load flag for EA
           BRA       WR_BTST

*******************************************************************************
********** ANDI ***************************************************************
O_ANDI     MOVE.W    #10,EA_FLAG      * Load flag for EA
           LEA       STR_ANDI,A6     * Load ANDI string into A6
           BRA       NORM_OP_FL      * Write op, '.', get size, write size

*******************************************************************************
********** ADDI ***************************************************************
O_ADDI     MOVE.W    #10,EA_FLAG      * Load flag for EA
           LEA       STR_ADDI,A6     * Load ADDI string into A6
           BRA       NORM_OP_FL      * Write op, '.', get size, write size

*******************************************************************************
********** SUBI ***************************************************************
O_SUBI     MOVE.W    #10,EA_FLAG     * Load flag for EA
           LEA       STR_SUBI,A6     * Load SUBI string into A6
           BRA       NORM_OP_FL      * Write op, '.', get size, write size

*******************************************************************************
********** EORI ***************************************************************
O_EORI     MOVE.W    #10,EA_FLAG     * Load flag for EA
           LEA       STR_EORI,A6     * Load EORI string into A6
           BRA       NORM_OP_FL      * Write op, '.', get size, write size

*******************************************************************************
********** CMPI ***************************************************************
O_CMPI     MOVE.W    #10,EA_FLAG     * Load flag for EA
           LEA       STR_CMPI,A6     * Load CMPI string into A6
           BRA       NORM_OP_FL      * Write op, '.', get size, write size

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
           CMP.W     #-5,SIZE_OP     * MOVEA must have valid size
           BEQ       INVALID_OP

           BRA       WR_PRP_EA

*******************************************************************************
********** MOVE ***************************************************************
O_MOVE     MOVE.W    #0,EA_FLAG      * Load flag for EA
           LEA       STR_MOVE,A6     * Load MOVE string into A6
           JSR       WRITE_ANY

           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY

           JSR       GET_MV_SZ
           CMP.W     #-5,SIZE_OP     * MOVE must have valid size
           BEQ       INVALID_OP

           BRA       WR_PRP_EA

*******************************************************************************
********** NEG ****************************************************************
O_NEG      MOVE.W    #1,EA_FLAG      * Load flag for EA
           LEA       STR_NEG,A6      * Load NEG string into A6
           BRA       NORM_OP_FL      * Write op, '.', get size, write size

*******************************************************************************
********** NEG ****************************************************************
O_CLR      MOVE.W    #1,EA_FLAG      * Load flag for EA
           LEA       STR_CLR,A6      * Load CLR string into A6
           BRA       NORM_OP_FL      * Write op, '.', get size, write size

*******************************************************************************
********** JSR ****************************************************************
O_JSR      MOVE.W    #1,EA_FLAG      * Load flag for EA
           MOVE.W    MASK_6_7,D2     * Load mask for validation
           AND.W     D1,D2           * Mask bits 6-7
           CMPI.W    #$0080,D2       * Should be %10
           BNE       INVALID_OP      * Else, invalid

           LEA       STR_JSR,A6      * Load JSR string into A6
           MOVE.W    #2,SIZE_OP      * Tell EA to grab a long

           BRA       WR_PRP_EA

*******************************************************************************
********** MOVEM **************************************************************
O_MOVEM    BTST      #11,D1          * 11th bit must be 1 for MOVEM
           BEQ       INVALID_OP      * Else is invalid
           MOVE.W    #$0380,D2       * Load mask for bits 7-9
           AND.W     D1,D2           * Mask bits 7-9
           CMPI      #$0080,D2       * Bits 7-9 should be %001
           BNE       INVALID_OP      * Else, it is not MOVEM

           MOVE.W    #7,EA_FLAG      * Load flag for EA
           LEA       STR_MOVEM,A6    * Load MOVEM string into A6
           JSR       WRITE_ANY

           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY

           MOVE.W    D1,D6           * Must test bit 6 for size flag test
           LSR.W     #6,D6           * Shift 6th bit into least sig postition
           JSR       SINGLE_SZ       * MOVEM has one size flag, test it

           BRA       WR_PRP_EA

*******************************************************************************
********** LEA ****************************************************************
O_LEA      MOVE.W    #8,EA_FLAG      * Load flag for EA
           LEA       STR_LEA,A6      * Load LEA string into A6

           BRA       WR_PRP_EA

*******************************************************************************
********** SUBQ ***************************************************************
O_SUBQ     MOVE.W    #6,EA_FLAG      * Load flag for EA
           BTST      #8,D1           * SUBQ has 1 in bit 8
           BEQ       O_ADDQ          * If it is 0, then is ADDQ
           LEA       STR_SUBQ,A6     * Load SUBQ string into A6

Q_OPS      BRA       NORM_OP_FL      * Write op, '.', get size, write size

*******************************************************************************
********** SUBQ ***************************************************************
O_ADDQ     LEA       STR_ADDQ,A6     * ADDQ and SUBQ are only one bit off :)
           BRA       Q_OPS           * So, we pushed them into same bin

*******************************************************************************
********** DIVS ***************************************************************
O_DIVS     MOVE.W    #2,EA_FLAG      * Load flag for EA
           LEA       STR_DIVS,A6     * Load DIVS string into A6
           JSR       WRITE_ANY       * Writes the op (previously loaded to A6)

           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY       * Write '.' to buffer

           MOVE.W    #1,SIZE_OP      * 1 into size_op to represent word for API
           LEA       STR_WORD,A6

           BRA       WR_PRP_EA

*******************************************************************************
********** OR *****************************************************************
O_OR       MOVE.W    #3,EA_FLAG      * Load flag for EA
           LEA       STR_OR,A6       * Load OR string into A6
           BRA       NORM_OP_FL      * Write op, '.', get size, write size

*******************************************************************************
********** SUB ****************************************************************
O_SUB      MOVE.W    #3,EA_FLAG      * Load flag for EA
           LEA       STR_SUB,A6       * Load SUB string into A6
           BRA       NORM_OP_FL      * Write op, '.', get size, write size

*******************************************************************************
********** CMP ****************************************************************
O_CMP      MOVE.W    #2,EA_FLAG      * Load flag for EA
           LEA       STR_CMP,A6      * Load CMP string into A6
           BRA       NORM_OP_FL      * Write op, '.', get size, write size

*******************************************************************************
********** EOR ****************************************************************
O_EOR      MOVE.W    #9,EA_FLAG      * Load flag for EA
           LEA       STR_EOR,A6      * Load EOR string into A6
           BRA       NORM_OP_FL      * Write op, '.', get size, write size

*******************************************************************************
********** MULS ***************************************************************
O_MULS     MOVE.W    MASK_6_8,D2     * Load mask for validation
           AND.W     D1,D2           * Mask to check bits 6-8
           CMPI.W    #$00C0,D2       * They should be %011 for MULU
           BEQ       O_MULU          * is mulu
           CMPI.W    #$01C0,D2       * They should be %111 for MULS
           BEQ       O_AND           * Else, is AND

           LEA       STR_MULS,A6     * Load MULS string into A6

WR_MULUS   JSR       WRITE_ANY       * Writes the op (previously loaded to A6)
           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY       * Write '.' to buffer

           MOVE.W    #1,SIZE_OP      * 1 into size_op to represent word for API
           LEA       STR_WORD,A6

           MOVE.W    #2,EA_FLAG      * Load flag for EA
           BRA       WR_PRP_EA

*******************************************************************************
********** MULU ***************************************************************
O_MULU     LEA       STR_MULU,A6
           BRA       WR_MULUS
           
*******************************************************************************
********** AND ****************************************************************
O_AND      MOVE.W    #3,EA_FLAG      * Load flag for EA
           LEA       STR_ADD,A6      * Load AND string into A6
           BRA       NORM_OP_FL      * Write op, '.', get size, write size

*******************************************************************************
********** ADD ****************************************************************
O_ADD      MOVE.W    #3,EA_FLAG      * Load flag for EA
           LEA       STR_ADD,A6      * Load ADD string into A6
           BRA       NORM_OP_FL      * Write op, '.', get size, write size

*******************************************************************************
********** ADDA ***************************************************************
O_ADDA     LEA       STR_ADDA,A6     * Load ADDA string into A6
CMPASUBA   MOVE.W    #8,EA_FLAG      * Load flag for EA
           JSR       WRITE_ANY       * Writes the op (previously loaded to A6)

           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY       * Write '.' to buffer

           MOVE.W    D1,D6           * Move opcode into D6
           LSR.W     #8,D6           * Shift 6th bit into least sig postition

           JSR       SINGLE_SZ       * Grab single size

           BRA       WR_PRP_EA

*******************************************************************************
********** LSd ****************************************************************
O_LSd      LEA       STR_LSR,A6      * Load LSR into A6
           BRA       ALLSHFTROT

*******************************************************************************
********** ASd ****************************************************************
O_ASd      LEA       STR_ASR,A6      * Load ASR into A6
           BRA       ALLSHFTROT

*******************************************************************************
********** ROd ****************************************************************
O_ROd      LEA       STR_ROR,A6      * Load ROR into A6

  ******** UTILITY TO DO EVERYTHING FOR ROTATIONS
ALLSHFTROT JSR       DIR_UTIL
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
******************** The flow of a normal operator ****************************
NORM_OP_FL JSR       WRITE_ANY       * Writes the op (previously loaded to A6)

           LEA       STR_PERI,A6     * Load '.' string into A6
           JSR       WRITE_ANY       * Write '.' to buffer

           JSR       GET_OP_SZ       * Get size of the op
           CMPI.W    #-5,SIZE_OP     * -5 indicated invalid size
           BEQ       EXIT_BAD        * Should have valid size, else exit
           JSR       WRITE_ANY       * Write size to buffer

           BRA       PREP_EA         * Prepare to call EA

EXIT_BAD   MOVE.W    #1,D0           * Tell I/O that something bad happened
           RTS

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
           BRA       PREP_RET

*******************************************************************************
******************** Prepare for return to IO *********************************
PREP_RET   NOP
         * CLEAR ALL DATA REGISTERS
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
           RTS

*******************************************************************************
******************** Invalid opcode handling **********************************
INVALID_OP MOVE.L    #1,D0           * Load flag for invalid input
           RTS

*******************************************************************************
******************** Fill with whitespace *************************************
SPACE_FILL LEA       STR_SPACE,A6    * Load whitespace into A6
           MOVE.L    START_BUFF,D0   * Load starting address of buffer into D0
           SUB.L     A2,D0           * Loads difference into D0
           ADD.W     #$A,D0
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
******************** Common pattern, encapsulate ******************************
WR_PRP_EA  JSR       WRITE_ANY       * Write NULLTRM str at (A6)
           BRA       PREP_EA         * Send to EA module

*******************************************************************************
******************** Write a null-term string to buff *************************
WRITE_ANY  CMPI.B    #0,(A6)         * Is the byte at A6 the NULL Char?
           BEQ       W_DONE
           MOVE.B    (A6)+,(A2)+
           BRA       WRITE_ANY
W_DONE     RTS

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
CON_SIMHLT DC.W      $FFFF

                     ** MASKS
MASK_12_15 DC.W      $F000           * Mask for the bits from X to Y for _X_Y
MASK_8_11  DC.W      $0F00           * Mask for the bits from X to Y for _X_Y
MASK_6_8   DC.W      $01C0           * Mask for the bits from X to Y for _X_Y
MASK_6_7   DC.W      $00C0           * Mask for the bits from X to Y for _X_Y


******************** Opcode strings *******************************************
STR_NOP    DC.B      'NOP',0
STR_RTS    DC.B      'RTS',0
STR_MOVE   DC.B      'MOVE',0
STR_MOVEM  DC.B      'MOVEM',0
STR_MOVEA  DC.B      'MOVEA',0
STR_ORI    DC.B      'ORI',0
STR_ADD    DC.B      'ADD',0
STR_AND    DC.B      'AND',0
STR_ADDA   DC.B      'ADDA',0
STR_SUBA   DC.B      'SUBA',0
STR_CMPA   DC.B      'CMPA',0
STR_BCLR   DC.B      'BCLR',0
STR_BTST   DC.B      'BTST',0
STR_CMP    DC.B      'CMP',0
STR_ADDI   DC.B      'ADDI',0
STR_SUBI   DC.B      'SUBI',0
STR_EORI   DC.B      'EORI',0
STR_ANDI   DC.B      'ANDI',0
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
STR_MULU   DC.B      'MULU',0
STR_NEG    DC.B      'NEG',0
STR_CLR    DC.B      'CLR',0
STR_OR     DC.B      'OR',0
STR_SUB    DC.B      'SUB',0
STR_SUBQ   DC.B      'SUBQ',0
STR_ADDQ   DC.B      'ADDQ',0
STR_TRAP   DC.B      'TRAP       #15',0

STR_PERI   DC.B      '.',0
STR_SPACE  DC.B      ' ',0
STR_BYTE   DC.B      'B',0
STR_WORD   DC.B      'W',0
STR_LONG   DC.B      'L',0

           NOP  *** THIS IS NEEDED, ELSE EA MODULE CAN ORG AT NONWORD ALIGNED
           INCLUDE   "eamodes_SaamAmiri.x68"

           END       START                    * last line of source

*~Font name~Courier~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

