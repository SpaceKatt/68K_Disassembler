*-----------------------------------------------------------
* Title      : Tester file
* Written by : Thomas Kercheval
* Date       :
* Description:
*-----------------------------------------------------------

CR         EQU       $0D            * Carriage return
LF         EQU       $0A            * Line feed

           ORG       $10000
START:                              * first instruction of program
******************** Start*****************************************************
           ********* BIN 0 ***************
           TRAP      #15
           MOVE.B    D0,D3
           MOVE.B    #$12,D3
           MOVE.B    D7,(A3)
           MOVE.B    D4,(A3)+
           MOVE.B    D1,-(A3)
           MOVE.B    #94,$4035
           MOVE.B    D0,$8459

           MOVE.W    D0,D3
           MOVE.W    D7,(A3)
           MOVE.W    D4,(A3)+
           MOVE.W    D1,-(A3)
           MOVE.W    D0,$8459
           MOVE.W    #394,$4035

           MOVE.L    D0,D3
           MOVE.L    #$12,D3
           MOVE.L    D7,(A3)
           MOVE.L    D4,(A3)+
           MOVE.L    D1,-(A3)
           MOVE.L    D0,$8459
           MOVE.L    #394,$4035
           MOVE.L    $FFFFE,$DEADBEEF
           MOVE.L    #$FFFFE,$DEADBEEF

           MOVEA.W   D0,A4
           MOVEA.W   #39,A6
           MOVEA.W   (A3)+,A1
           MOVEA.W   -(A6),A4
           MOVEA.W   $BEEF,A4
           MOVEA.W   $0EEF,A4

           MOVEA.L   D0,A4
           MOVEA.L   #39,A6
           MOVEA.L   (A3)+,A1
           MOVEA.L   -(A6),A4
           MOVEA.L   $BEEF,A4

           ********* BIN 1 ***************
           NEG       D0
           NEG       $398
           NEG       $F398
           NEG       (A1)
           NEG       -(A2)
           NEG       (A7)+
           JSR       BINZZ

           ********* BIN 4 ***************
BRA_1      BVC       BRA_2
BRA_2      BCS       BRA_3
BRA_3      BGE       BRA_4
BRA_4      BLT       BRA_5
BRA_5      BRA       BRA_N

           ********* BINLESSSSSS *********
BINZZ      NOP
           RTS

           ********* BIN 2 ***************
BRA_N      DIVS.W    D1,D2
           DIVS.W    #$A,D2
           DIVS.W    (A1),D2
           DIVS.W    (A1)+,D2
           DIVS.W    -(A1),D2

           MULS.W    D1,D2
           MULS.W    #$A,D2
           MULS.W    (A1),D2
           MULS.W    (A1)+,D2
           MULS.W    -(A1),D2

           CMP.B     D1,D2
           CMP.B     #$A,D2
           CMP.B     (A1),D2
           CMP.B     (A1)+,D2
           CMP.B     -(A1),D2

           CMP.W     D1,D2
           CMP.W     #$A,D2
           CMP.W     A1,D2
           CMP.W     (A1),D2
           CMP.W     (A1)+,D2
           CMP.W     -(A1),D2

           CMP.L     D1,D2
           CMP.L     #$A,D2
           CMP.L     A1,D2
           CMP.L     (A1),D2
           CMP.L     (A1)+,D2
           CMP.L     -(A1),D2

           ********* BIN 3 ***************
           OR.B     D1,D1
           OR.B     #$A,D4
           OR.B     $88,D2
           OR.B     $FFF88,D2
           OR.B     (A1),D7
           OR.B     (A1)+,D2
           OR.B     -(A1),D5
           OR.W     D1,D1
           OR.W     #$A,D4
           OR.W     $88,D2
           OR.W     $FFF88,D2
           OR.W     (A1),D7
           OR.W     (A1)+,D2
           OR.W     -(A1),D5
           OR.L     D1,D1
           OR.L     #$A,D4
           OR.L     $88,D2
           OR.L     $FFF88,D2
           OR.L     (A1),D7
           OR.L     (A1)+,D2
           OR.L     -(A1),D5
           
           OR.B     D1,D1
           OR.B     D2,$88
           OR.B     D2,$FFF88
           OR.B     D7,(A1)
           OR.B     D2,(A1)+
           OR.B     D5,-(A1)
           OR.W     D1,D1
           OR.W     D2,$88
           OR.W     D2,$FFF88
           OR.W     D7,(A1)
           OR.W     D2,(A1)+
           OR.W     D5,-(A1)
           OR.L     D1,D1
           OR.L     D2,$88
           OR.L     D2,$FFF88
           OR.L     D7,(A1)
           OR.L     D2,(A1)+
           OR.L     D5,-(A1)

           SUB.B     D1,D1
           SUB.B     $88,D2
           SUB.B     $FFF88,D2
           SUB.B     (A1),D7
           SUB.B     (A1)+,D2
           SUB.B     -(A1),D5
           SUB.W     D1,D1
           SUB.W     $88,D2
           SUB.W     $FFF88,D2
           SUB.W     (A1),D7
           SUB.W     (A1)+,D2
           SUB.W     -(A1),D5
           SUB.L     D1,D1
           SUB.L     $88,D2
           SUB.L     $FFF88,D2
           SUB.L     (A1),D7
           SUB.L     (A1)+,D2
           SUB.L     -(A1),D5
         
           SUB.B     D1,D1
           SUB.B     D2,$88
           SUB.B     D2,$FFF88
           SUB.B     D7,(A1)
           SUB.B     D2,(A1)+
           SUB.B     D5,-(A1)
           SUB.W     D1,D1
           SUB.W     D2,$88
           SUB.W     D2,$FFF88
           SUB.W     D7,(A1)
           SUB.W     D2,(A1)+
           SUB.W     D5,-(A1)
           SUB.L     D1,D1
           SUB.L     D2,$88
           SUB.L     D2,$FFF88
           SUB.L     D7,(A1)
           SUB.L     D2,(A1)+
           SUB.L     D5,-(A1)
 
           ADD.B     D1,D1
           ADD.B     $88,D2
           ADD.B     $FFF88,D2
           ADD.B     (A1),D7
           ADD.B     (A1)+,D2
           ADD.B     -(A1),D5
           ADD.W     D1,D1
           ADD.W     $88,D2
           ADD.W     $FFF88,D2
           ADD.W     (A1),D7
           ADD.W     (A1)+,D2
           ADD.W     -(A1),D5
           ADD.L     D1,D1
           ADD.L     $88,D2
           ADD.L     $FFF88,D2
           ADD.L     (A1),D7
           ADD.L     (A1)+,D2
           ADD.L     -(A1),D5
         
           ADD.B     D1,D1
           ADD.B     D2,$88
           ADD.B     D2,$FFF88
           ADD.B     D7,(A1)
           ADD.B     D2,(A1)+
           ADD.B     D5,-(A1)
           ADD.W     D1,D1
           ADD.W     D2,$88
           ADD.W     D2,$FFF88
           ADD.W     D7,(A1)
           ADD.W     D2,(A1)+
           ADD.W     D5,-(A1)
           ADD.L     D1,D1
           ADD.L     D2,$88
           ADD.L     D2,$FFF88
           ADD.L     D7,(A1)
           ADD.L     D2,(A1)+
           ADD.L     D5,-(A1)

           ********* BIN 5 ***************
           ** TODO
*           LSR.W     D7,D3
*           ASR.W     D7,D3
*           ROR.W     D7,D3

           ********* BIN 6 ***************
           SUBQ.B     #1,D1
           SUBQ.B     #2,$88
           SUBQ.B     #3,$FFF88
           SUBQ.B     #4,(A1)
           SUBQ.B     #5,(A1)+
           SUBQ.B     #6,-(A1)
           SUBQ.W     #7,D1
           SUBQ.W     #8,$88
           SUBQ.W     #8,$FFF88
           SUBQ.W     #8,(A1)
           SUBQ.W     #1,(A1)+
           SUBQ.W     #2,-(A1)
           SUBQ.L     #4,D1
           SUBQ.L     #6,$88
           SUBQ.L     #8,$FFF88
           SUBQ.L     #3,(A1)
           SUBQ.L     #2,(A1)+
           SUBQ.L     #6,-(A1)

           ADDQ.B     #1,D1
           ADDQ.B     #2,$88
           ADDQ.B     #3,$FFF88
           ADDQ.B     #4,(A1)
           ADDQ.B     #5,(A1)+
           ADDQ.B     #6,-(A1)
           ADDQ.W     #7,D1
           ADDQ.W     #8,$88
           ADDQ.W     #8,$FFF88
           ADDQ.W     #8,(A1)
           ADDQ.W     #1,(A1)+
           ADDQ.W     #2,-(A1)
           ADDQ.L     #4,D1
           ADDQ.L     #6,$88
           ADDQ.L     #8,$FFF88
           ADDQ.L     #3,(A1)
           ADDQ.L     #2,(A1)+
           ADDQ.L     #6,-(A1)

           ********* BIN 7 ***************
*           MOVEM.W   D0-D1/D3/D5-D7,(A7)
*           MOVEM.W   D0-D1/D3/D5-D7/A1/A3-A6,(A7)
*           MOVEM.W   D0/D3/D5-D7/A4/A5-A6,(A7)
*           MOVEM.W   A1-A3/A4/A6,(A7)
*           MOVEM.W   D0/A1-A3/A4/A6,(A7)
*           MOVEM.W   D7/A1-A3/A4/A6,(A7)
*           MOVEM.W   A6,(A7)
*           MOVEM.W   D6,(A7)
*
*           MOVEM.W   D0-D1/D3/D5-D7,-(A7)
*           MOVEM.W   D0-D1/D3/D5-D7/A1/A3-A6,-(A7)
*           MOVEM.W   D0/D3/D5-D7/A4/A5-A6,-(A7)
*           MOVEM.W   A1-A3/A4/A6,-(A7)
*           MOVEM.W   D0/A1-A3/A4/A6,-(A7)
*           MOVEM.W   D7/A1-A3/A4/A6,-(A7)
*           MOVEM.W   A6,-(A7)
*           MOVEM.W   D6,-(A7)
*           
*           MOVEM.W   D0-D1/D3/D5-D7,$FE
*           MOVEM.W   D0-D1/D3/D5-D7/A1/A3-A6,$FE
*           MOVEM.W   D0/D3/D5-D7/A4/A5-A6,$FE
*           MOVEM.W   A1-A3/A4/A6,$FE
*           MOVEM.W   D0/A1-A3/A4/A6,$FE
*           MOVEM.W   D7/A1-A3/A4/A6,$FE
*           MOVEM.W   A6,$FE
*           MOVEM.W   D6,$FE
*           
*           MOVEM.W   D0-D1/D3/D5-D7,$FDDDE
*           MOVEM.W   D0-D1/D3/D5-D7/A1/A3-A6,$FDDDE
*           MOVEM.W   D0/D3/D5-D7/A4/A5-A6,$FDDDE
*           MOVEM.W   A1-A3/A4/A6,$FDDDE
*           MOVEM.W   D0/A1-A3/A4/A6,$FDDDE
*           MOVEM.W   D7/A1-A3/A4/A6,$FDDDE
*           MOVEM.W   A6,$FDDDE
*           MOVEM.W   D6,$FDDDE
*           
*           MOVEM.L   D0-D1/D3/D5-D7,(A7)
*           MOVEM.L   D0-D1/D3/D5-D7/A1/A3-A6,(A7)
*           MOVEM.L   D0/D3/D5-D7/A4/A5-A6,(A7)
*           MOVEM.L   A1-A3/A4/A6,(A7)
*           MOVEM.L   D0/A1-A3/A4/A6,(A7)
*           MOVEM.L   D7/A1-A3/A4/A6,(A7)
*           MOVEM.L   A6,(A7)
*           MOVEM.L   D6,(A7)
*
*           MOVEM.L   D0-D1/D3/D5-D7,-(A7)
*           MOVEM.L   D0-D1/D3/D5-D7/A1/A3-A6,-(A7)
*           MOVEM.L   D0/D3/D5-D7/A4/A5-A6,-(A7)
*           MOVEM.L   A1-A3/A4/A6,-(A7)
*           MOVEM.L   D0/A1-A3/A4/A6,-(A7)
*           MOVEM.L   D7/A1-A3/A4/A6,-(A7)
*           MOVEM.L   A6,-(A7)
*           MOVEM.L   D6,-(A7)
*           
*           MOVEM.L   D0-D1/D3/D5-D7,$FE
*           MOVEM.L   D0-D1/D3/D5-D7/A1/A3-A6,$FE
*           MOVEM.L   D0/D3/D5-D7/A4/A5-A6,$FE
*           MOVEM.L   A1-A3/A4/A6,$FE
*           MOVEM.L   D0/A1-A3/A4/A6,$FE
*           MOVEM.L   D7/A1-A3/A4/A6,$FE
*           MOVEM.L   A6,$FE
*           MOVEM.L   D6,$FE
*           
*           MOVEM.L   D0-D1/D3/D5-D7,$FDDDE
*           MOVEM.L   D0-D1/D3/D5-D7/A1/A3-A6,$FDDDE
*           MOVEM.L   D0/D3/D5-D7/A4/A5-A6,$FDDDE
*           MOVEM.L   A1-A3/A4/A6,$FDDDE
*           MOVEM.L   D0/A1-A3/A4/A6,$FDDDE
*           MOVEM.L   D7/A1-A3/A4/A6,$FDDDE
*           MOVEM.L   A6,$FDDDE
*           MOVEM.L   D6,$FDDDE
*           
*           MOVEM.W   (A7),D0-D1/D3/D5-D7
*           MOVEM.W   (A7),D0-D1/D3/D5-D7/A1/A3-A6
*           MOVEM.W   (A7),D0/D3/D5-D7/A4/A5-A6
*           MOVEM.W   (A7),A1-A3/A4/A6
*           MOVEM.W   (A7),D0/A1-A3/A4/A6
*           MOVEM.W   (A7),D7/A1-A3/A4/A6
*           MOVEM.W   (A7),A6
*           MOVEM.W   (A7),D6
*
*           MOVEM.W   (A7)+,D0-D1/D3/D5-D7
*           MOVEM.W   (A7)+,D0-D1/D3/D5-D7/A1/A3-A6
*           MOVEM.W   (A7)+,D0/D3/D5-D7/A4/A5-A6
*           MOVEM.W   (A7)+,A1-A3/A4/A6
*           MOVEM.W   (A7)+,D0/A1-A3/A4/A6
*           MOVEM.W   (A7)+,D7/A1-A3/A4/A6
*           MOVEM.W   (A7)+,A6
*           MOVEM.W   (A7)+,D6
*           
*           MOVEM.W   $FE,D0-D1/D3/D5-D7
*           MOVEM.W   $FE,D0-D1/D3/D5-D7/A1/A3-A6
*           MOVEM.W   $FE,D0/D3/D5-D7/A4/A5-A6
*           MOVEM.W   $FE,A1-A3/A4/A6
*           MOVEM.W   $FE,D0/A1-A3/A4/A6
*           MOVEM.W   $FE,D7/A1-A3/A4/A6
*           MOVEM.W   $FE,A6
*           MOVEM.W   $FE,D6
*           
*           MOVEM.W   $FDDDE,D0-D1/D3/D5-D7
*           MOVEM.W   $FDDDE,D0-D1/D3/D5-D7/A1/A3-A6
*           MOVEM.W   $FDDDE,D0/D3/D5-D7/A4/A5-A6
*           MOVEM.W   $FDDDE,A1-A3/A4/A6
*           MOVEM.W   $FDDDE,D0/A1-A3/A4/A6
*           MOVEM.W   $FDDDE,D7/A1-A3/A4/A6
*           MOVEM.W   $FDDDE,A6
*           MOVEM.W   $FDDDE,D6
*           
*           MOVEM.L   (A7),D0-D1/D3/D5-D7
*           MOVEM.L   (A7),D0-D1/D3/D5-D7/A1/A3-A6
*           MOVEM.L   (A7),D0/D3/D5-D7/A4/A5-A6
*           MOVEM.L   (A7),A1-A3/A4/A6
*           MOVEM.L   (A7),D0/A1-A3/A4/A6
*           MOVEM.L   (A7),D7/A1-A3/A4/A6
*           MOVEM.L   (A7),A6
*           MOVEM.L   (A7),D6
*
*           MOVEM.L   (A7)+,D0-D1/D3/D5-D7
*           MOVEM.L   (A7)+,D0-D1/D3/D5-D7/A1/A3-A6
*           MOVEM.L   (A7)+,D0/D3/D5-D7/A4/A5-A6
*           MOVEM.L   (A7)+,A1-A3/A4/A6
*           MOVEM.L   (A7)+,D0/A1-A3/A4/A6
*           MOVEM.L   (A7)+,D7/A1-A3/A4/A6
*           MOVEM.L   (A7)+,A6
*           MOVEM.L   (A7)+,D6
*           
*           MOVEM.L   $FE,D0-D1/D3/D5-D7
*           MOVEM.L   $FE,D0-D1/D3/D5-D7/A1/A3-A6
*           MOVEM.L   $FE,D0/D3/D5-D7/A4/A5-A6
*           MOVEM.L   $FE,A1-A3/A4/A6
*           MOVEM.L   $FE,D0/A1-A3/A4/A6
*           MOVEM.L   $FE,D7/A1-A3/A4/A6
*           MOVEM.L   $FE,A6
*           MOVEM.L   $FE,D6
*           
*           MOVEM.L   $FDDDE,D0-D1/D3/D5-D7
*           MOVEM.L   $FDDDE,D0-D1/D3/D5-D7/A1/A3-A6
*           MOVEM.L   $FDDDE,D0/D3/D5-D7/A4/A5-A6
*           MOVEM.L   $FDDDE,A1-A3/A4/A6
*           MOVEM.L   $FDDDE,D0/A1-A3/A4/A6
*           MOVEM.L   $FDDDE,D7/A1-A3/A4/A6
*           MOVEM.L   $FDDDE,A6
*           MOVEM.L   $FDDDE,D6
           

           ********* BIN 8 ***************
           LEA       BRA_1,A1
           LEA       (A2),A4
           LEA       $EF,A6
           LEA       $FFFF,A7

           ********* BIN 9 ***************
           BCLR      D1,D4
           BCLR      D3,(A4)
           BCLR      D3,(A4)+
           BCLR      D7,-(A4)
           BCLR      D5,$302
           BCLR      D5,$30243

           EOR.B     D1,D1
           EOR.B     D2,$88
           EOR.B     D2,$FFF88
           EOR.B     D7,(A1)
           EOR.B     D2,(A1)+
           EOR.B     D5,-(A1)

           EOR.W     D1,D1
           EOR.W     D2,$88
           EOR.W     D2,$FFF88
           EOR.W     D7,(A1)
           EOR.W     D2,(A1)+
           EOR.W     D5,-(A1)

           EOR.L     D1,D1
           EOR.L     D2,$88
           EOR.L     D2,$FFF8
           EOR.L     D7,(A1)
           EOR.L     D2,(A1)+
           EOR.L     D5,-(A1)

           ********* BIN 10 **************
           BCLR      #1,D4
           BCLR      #3,(A4)
           BCLR      #3,(A4)+
           BCLR      #7,-(A4)
           BCLR      #8,$FF302

           ORI.B     #10,D2
           ORI.B     #26,$88
           ORI.B     #88,$FFF88
           ORI.B     #53,(A1)
           ORI.B     #92,(A1)+
           ORI.B     #6,-(A1)
           ORI.W     #10,D2
           ORI.W     #26,$88
           ORI.W     #988,$FFF88
           ORI.W     #153,(A1)
           ORI.W     #92,(A1)+
           ORI.W     #6,-(A1)
           ORI.L     #10,D2
           ORI.L     #26,$88
           ORI.L     #988,$FFF88
           ORI.L     #153,(A1)
           ORI.L     #92,(A1)+
           ORI.L     #6,-(A1)

           CMPI.B    #10,D2
           CMPI.B    #26,$88
           CMPI.B    #88,$FFF88
           CMPI.B    #53,(A1)
           CMPI.B    #92,(A1)+
           CMPI.B    #6,-(A1)
           CMPI.W    #10,D2
           CMPI.W    #26,$88
           CMPI.W    #988,$FFF88
           CMPI.W    #153,(A1)
           CMPI.W    #92,(A1)+
           CMPI.W    #6,-(A1)
           CMPI.L    #10,D2
           CMPI.L    #26,$88
           CMPI.L    #988,$FFF88
           CMPI.L    #153,(A1)
           CMPI.L    #92,(A1)+
           CMPI.L    #6,-(A1)

*           LSR.W     #7,D3
*           ASR.W     #7,D3
*           ROR.W     #7,D3
********** All of this causes error, for now (well, only ROR)
*           

           ********* INVALID STUFF
           MOVE.W    #$12,D3
           SUB.B     #$A,D4
           SUB.L     #$A,D4
           SUB.W     #$A,D4
           ADD.B     #$A,D4
           ADD.L     #$A,D4
           ADD.W     #$A,D4

*******************************************************************************
******************** Fin ******************************************************
END        MOVE.B    #9,D0          * Break out of sim
           TRAP      #15

*******************************************************************************
******************** Put variables and constants here *************************

    END    START                    * last line of source




*~Font name~Courier~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
