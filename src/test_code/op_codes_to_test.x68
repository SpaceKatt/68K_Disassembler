*-----------------------------------------------------------
* Title      : Tester file
* Written by : Thomas Kercheval
* Date       :
* Description:
*-----------------------------------------------------------

CR         EQU       $0D            * Carriage return
LF         EQU       $0A            * Line feed

           ORG       $400
START:                              * first instruction of program
******************** Start*****************************************************
           ********* BIN 0 ***************
           MOVE.B    D0,D3
           MOVE.B    #$12,D3
           MOVE.B    D7,(A3)
           MOVE.B    D4,(A3)+
           MOVE.B    D1,-(A3)
           MOVE.B    #94,$4035
           MOVE.B    D0,$8459

           MOVE.W    D0,D3
           MOVE.W    #$12,D3
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
           ********* BIN 5 ***************
           ********* BIN 6 ***************
           ********* BIN 7 ***************
           ********* BIN 8 ***************
           ********* BIN 9 ***************
           ********* BIN 10 **************
           BCLR      #1,D4
           ORI.W     #10,D2
           CMPI.L    #14,D1
********** All of this causes error, for now (well, only ROR)
*           LSR.W     #7,D3
*           ASR.W     #7,D3
*           ROR.W     #7,D3
*           
*           LSR.W     D7,D3
*           ASR.W     D7,D3
*           ROR.W     D7,D3

           ********* INVALID STUFF

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
