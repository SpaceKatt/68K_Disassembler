*-----------------------------------------------------------
* Title      :
* Written by : Thomas Kercheval
* Date       :
* Description:
*-----------------------------------------------------------

CR         EQU       $0D            * Carriage return
LF         EQU       $0A            * Line feed

           ORG       $1000
START:                              * first instruction of program
******************** Start*****************************************************

           MOVEA.W    #$110,A0
           MOVE.B    (SAAMSTAB,A0),GOODBUFF

*******************************************************************************
*******************************************************************************

*******************************************************************************
******************** Fin ******************************************************
END        MOVE.B    #9,D0          * Break out of sim
           TRAP      #15


*******************************************************************************
******************** Put variables and constants here *************************
SAAMSTAB   DC.B      $30,$31,$32,$33,$34,$35,$36,$37
GOODBUFF   DC.B      $00

    END    START                    * last line of source

*~Font name~Courier~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
