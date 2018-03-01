*-----------------------------------------------------------
* Title      : I/O handling
* Written by : Natalia Gilbertson
* Date       :
* Description:
*-----------------------------------------------------------

CR         EQU       $0D            * Carriage return
LF         EQU       $0A            * Line feed

           ORG       $1000
START:                              * first instruction of program
******************** Start*****************************************************
            LEA     PromptStartAddr,A1                     *Print 'Hello'
            MOVE.B  #14,D0
            TRAP    #15
    
            MOVE.B  #2,D0
            TRAP    #15
            
            MOVE.L  A1,A0               *A0 holds start addr
            
            LEA     PromptEndAdder,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVE.B  #2,D0
            TRAP    #15
            
            MOVE.L  A1,A3               *A3 holds end addr
  
end_loop    STOP    #3000

*******************************************************************************
*******************************************************************************

PromptStartAddr DC.B    'Starting address of file: ',0    
PromptEndAdder  DC.B    'Ending address of file: ',0

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
