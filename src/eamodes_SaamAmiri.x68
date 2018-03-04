*-----------------------------------------------------------
* Title      : EA resolution
* Written by : Saam Amiri
* Date       :
* Description:
*-----------------------------------------------------------
STACK      EQU     $8000  
CR         EQU     $0D            * Carriage return
LF         EQU     $0A            * Line feed

         ORG       $1000
START:                              * first instruction of program

  LEA STACK,SP

  CMP #0,D2
  BEQ bin0

  CMP #1,D2
  BEQ bin1
  
  CMP #2,D2
  BEQ bin2  
  
  CMP #3,D2
  BEQ bin3
  
  CMP #4,D2
  BEQ bin4
    
  CMP #5,D2
  BEQ bin5
    
  CMP #6,D2
  BEQ bin6
    
  CMP #7,D2
  BEQ bin7

  CMP #8,D2
  BEQ bin8
  
  CMP #9,D2
  BEQ bin9
  
  BRA  END * D2 not set to proper EA Flag
  
    
bin0 * 12 bit      
 
bin1 * 6 bit
  JSR mode_test
bin2 * 9 bit Address

bin3 * 9 bit Data w/Direction

bin4 * 8 bit branch displacment

bin5 * Special rotation (12 bit)

bin6 * SUBQ (special case)

bin7 * MOVEM (6 bit w/Direction)

bin8 * 9 bit Data

bin9 * BCLR w/immediate
  
  
**Function finds mode than calls reg_test than returns back to Bin caller 
mode_test
  MOVE.B #5,D5 *set bit decrement counter
  BTST   D5,D3 *check mode bit 1
  BNE    mode1
  BRA    mode0
  
mode1
  SUB.B  #1,D5 *decrement bit counter 
  BTST  D5,D3 *check mode bit 2
  BNE    mode11
  BRA    mode10 

mode0
  SUB.B  #1,D5
  BTST   D5,D3
  BNE    mode01
  BRA    mode00
  
mode11 *assume mode 11->111
  *test register for (xxx).W,(xxx).L,#imm

mode10 *assume if mode 10->100= -(An)
  * print -(A
  JSR    reg_sum
  * print )
  * prep for caller
mode01
  SUB.B  #1,D5 *decrement bit counter 
  BTST   D5,D3 *check mode bit 2
  BNE    mode011
  BRA    mode010

mode00
  SUB.B  #1,D5 *decrement bit counter 
  BTST   D5,D3 *check mode bit 2
  BNE    mode001
  BRA    mode000
   
mode011 * (An)+
  * print (A
  JSR   reg_sum
  * print )+
  * prep for caller
    
mode010 * (An)
  * print (A
  JSR   reg_sum
  * print )
  * prep for caller
 
mode001 * Dn
  * print D
  JSR   reg_sum
  * prep for caller

mode000 * An
  * print A
  JSR   reg_sum
  * prep for caller

*Function that sums up the register returns to mode_test
reg_sum
  MOVE.W  #$0007,D6 * bitmask keep 3 LSB
  AND.W   D3,D6     * store D3 bitmasked bits to D6
  MOVEA.W D6,A5     * prepare for index
  MOVE.B  (SUMTABLE,A5),(A2)+ *store ascii at index to goodbuff 
  RTS               *return to caller
 
END      SIMHALT
*******************************************************************************
******************** Put variables and constants here *************************

SUMTABLE   DC.B      $30,$31,$32,$33,$34,$35,$36,$37
GOODBUFF   DC.B      $00    
  END START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
