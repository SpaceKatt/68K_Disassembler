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
START:                             * first instruction of program
  LEA     STACK,SP
  MOVE.B  #$8,D2
  MOVE.W  #$3300,D3
  JSR     START_EA
 
  SIMHALT
  
START_EA                           *OPCODE coming in

  CMP     #0,D2
  BEQ     bin0

  CMP     #1,D2
  BEQ     bin1
  
  CMP     #2,D2
  BEQ     bin2  
  
  CMP     #3,D2
  BEQ     bin3
  
  CMP     #4,D2
  BEQ     bin4
    
  CMP     #5,D2
  BEQ     bin5
    
  CMP     #6,D2
  BEQ     bin6
    
  CMP     #7,D2
  BEQ     bin7

  CMP     #8,D2
  BEQ     bin8
  
  CMP     #9,D2
  BEQ     bin9
  
  BRA     END * D2 not set to proper EA Flag
  
    
bin0 * 12 bit      
  JSR     mode_test         * tests source mode/reg
  
  LEA     STR_COMMA,A6      * load  ,
  JSR     write_str         * write , to buff

  MOVE.W  D3,D6             * temp D3
  
  LSR.W   #$8,D3            * shift dest reg to source reg index
  LSR.W   #$1,D3            * max of 8 bit shifts per OP
  MOVE.W  #$0007,D5         * bitmask all except 3 LSB
  AND.W   D5,D3             * keep only 3 LSB

  LSR.W   #$3,D6            * shift dest mode to source mode index
  MOVE.W  #$0038,D5         * bitmask all except 5,4,3 bit index
  AND.W   D5,D6             * keep only above 5,4,3 bits
  
  ADD.W   D6,D3             * combine reg and mode bits  
 
  JSR     mode_test         *
             
  RTS                       *return to OPCODER

bin1 * 6 bit
  JSR     mode_test
  RTS                       *return to OPCODER
  
bin2 * 9 bit Data
  JSR     mode_test

  LEA     STR_COMMA,A6      * load  ,
  JSR     write_str         * write , to buff
  LEA     STR_D,A6          * load  D
  JSR     write_str         * write D to buff

  LSR.W   #$8,D3            * shift dest reg to source reg index
  LSR.W   #$1,D3            * max of 8 bit shifts per OP
  MOVE.W  #$0007,D5         * bitmask all except 3 LSB
  AND.W   D5,D3             * keep only 3 LSB
  JSR     reg_sum           * sum reg bits
  RTS                       *return to OPCODER  
bin3 * 9 bit Data w/Direction

bin4 * 8 bit branch displacment

bin5 * Special rotation (12 bit)

bin6 * SUBQ (special case)

bin7 * MOVEM (6 bit w/Direction)

bin8 * 9 bit Address
  JSR     mode_test

  LEA     STR_COMMA,A6      * load  ,
  JSR     write_str         * write , to buff
  LEA     STR_A,A6          * load  A
  JSR     write_str         * write A to buff

  LSR.W   #$8,D3            * shift dest reg to source reg index
  LSR.W   #$1,D3            * max of 8 bit shifts per OP
  MOVE.W  #$0007,D5         * bitmask all except 3 LSB
  AND.W   D5,D3             * keep only 3 LSB
  JSR     reg_sum           * sum reg bits
  RTS                       * return to OPCODER  
bin9 * BCLR w/immediate
  
  
**Function finds mode than calls reg_test than returns back to Bin caller 
mode_test
  MOVE.B #5,D5 *set bit decrement counter
  BTST   D5,D3 *check mode bit 1
  BNE    mode1
  BRA    mode0
  
mode1

  SUB.B  #1,D5 *decrement bit counter 
  BTST   D5,D3 *check mode bit 2
  BNE    mode11
  BRA    mode10 

mode0
  SUB.B  #1,D5
  BTST   D5,D3
  BNE    mode01
  BRA    mode00
  
mode11                      * assume mode 11->111
  *test register for (xxx).W,(xxx).L,#imm
  

mode10                      * assume if mode 10->100= -(An)
  LEA    STR_DECA,A6        * load  -(A
  JSR    write_str          * write -(A to buff
  JSR    reg_sum            * sum reg, write to buff
  LEA    STR_CP,A6          * load  ) 
  JSR    write_str          * write ) to buff
  RTS                       * return to bin
  * prep for caller
mode01
  SUB.B  #1,D5              * decrement bit counter 
  BTST   D5,D3              * check mode bit 2
  BNE    mode011
  BRA    mode010

mode00
  SUB.B  #1,D5              * decrement bit counter 
  BTST   D5,D3              * check mode bit 2
  BNE    mode001
  BRA    mode000
   
mode011 * (An)+
  LEA    STR_INDA,A6        * load  (A
  JSR    write_str          * write (A to buff 
  JSR    reg_sum            * sum reg, write to buff
  LEA    STR_CPINC,A6       * load  )+
  JSR    write_str          * write )+ to buff
  RTS                       * return to bin

    
mode010 * (An)
  LEA    STR_INDA,A6        * load  (A
  JSR    write_str          * write (A to buff 
  JSR    reg_sum            * sum reg, write to buff
  LEA    STR_CP,A6          * load  )
  JSR    write_str          * write ) to buff
  RTS                       * return to bin

mode001 * An
  LEA    STR_A,A6           * load  A
  JSR    write_str          * write A to buff 
  JSR    reg_sum            * sum reg, write to buff
  RTS                       * return to bin


mode000 * Dn
  LEA    STR_D,A6           * load  D
  JSR    write_str          * write D to buff 
  JSR    reg_sum            * sum reg, write to buff
  RTS                       * return to bin 

*Function that sums up the register returns to mode_test
reg_sum
  MOVE.W     #$0007,D6          * bitmask keep 3 LSB
  AND.W      D3,D6              * store D3 bitmasked bits to D6
  MOVEA.W    D6,A5              * prepare for index
  MOVE.B    (SUMTABLE,A5),(A2)+ *store ascii at index to goodbuff 
  RTS                           *return to caller

*Function write string to the buffer
write_str  
  CMPI.B    #0,(A6)             * Is the byte at A6 the NULL Char?
  BEQ       write_done
  MOVE.B    (A6)+,(A2)+
  BRA       write_str
write_done  RTS
 

END      SIMHALT
*******************************************************************************
******************** Put variables and constants here *************************

SUMTABLE   DC.B      $30,$31,$32,$33,$34,$35,$36,$37
GOODBUFF   DC.B      $00

STR_D      DC.B      'D',0
STR_A      DC.B      'A',0

STR_INDA   DC.B      '(','A',0
STR_DECA   DC.B      '-','(','A',0 
STR_CP     DC.B      ')',0
STR_CPINC  DC.B      ')','+',0
STR_COMMA  DC.B      ',',0        
  END START






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
