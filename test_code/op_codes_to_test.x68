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
           MOVE.B    D0,D3
           MOVE.B    #$12,D3
           MOVE.B    D7,(A3)
           MOVE.B    D4,(A3)+
           MOVE.B    D1,-(A3)
           MOVE.B    D0,$8459
           MOVE.B    #94,$4035

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


*******************************************************************************
*******************************************************************************

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
