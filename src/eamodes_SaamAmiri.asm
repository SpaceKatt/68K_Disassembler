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
START:                           * first instruction of program
  LEA     STACK,SP
  *MOVE.B  #$3,D2
  *MOVE.W  #$3308,D3
  MOVE.B   #$2,D2
  MOVE.W   #$0F08,D3
  JSR      START_EA
 
  SIMHALT
  
START_EA                         *OPCODE coming in
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

  CMP     #10,D2
  BEQ     bin10  
  BRA     END               * D2 not set to proper EA Flag
  
    
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
  RTS                       * return to OPCODER

bin1 * 6 bit
  JSR     mode_test
  RTS                       *return to OPCODER
  
bin2 * 9 bit Data <ea>,Dn
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
  BTST    #8,D3             * check direction bit
  BEQ     bin2              * bra if bit = zero
 
  MOVE.W  D3,D7             * store temp 
 
  LEA     STR_D,A6          * load  D
  JSR     write_str         * write D to buff
  LSR.W   #$8,D3            * shift dest reg to source reg index
  LSR.W   #$1,D3            * max of 8 bit shifts per OP
  JSR     reg_sum           * sum reg bits

  LEA     STR_COMMA,A6      * load  ,
  JSR     write_str         * write , to buff

  MOVE.W  D7,D3             * restore D3
  JSR     mode_test         * print destination
  RTS                       * return to OPCODER

bin4 * 8 bit branch displacment

bin5 * Special rotation (12 bit)

bin6 * SUBQ (special case)
  MOVE.W  D3,D7             * save temp
  LEA     STR_IMM,A6        * load  #
  JSR     write_str         * write #
  MOVE.W  #$0E00,D5         * bit mask data bits
  AND.W   D5,D3             
  CMP.W   #0,D3             *
  BNE     shift
              
  MOVE.B  #$38,(A2)+
  JSR     write_comma
  MOVE.W  D7,D3             * restore D3
  JSR     mode_test
  RTS

shift
  LSR.W   #$8,D3            * shift dest reg to source reg index
  LSR.W   #$1,D3            * max of 8 bit shifts per OP
  JSR     reg_sum           * sum reg bits
  JSR     write_comma       * write comma
  MOVE.W  D7,D3
  JSR     mode_test
  RTS 
    
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
bin9  * just like 2 but Dn,<ea>
  MOVE.W  D3,D7             * save temp
  LEA     STR_D,A6          * load  D
  JSR     write_str         * write D to buff
  LSR.W   #$8,D3            * shift dest reg to source reg index
  LSR.W   #$1,D3            * max of 8 bit shifts per OP
  MOVE.W  #$0007,D5         * bitmask all except 3 LSB
  AND.W   D5,D3             * keep only 3 LSB
  JSR     reg_sum           * sum reg bits
  
  LEA     STR_COMMA,A6      * load  ,
  JSR     write_str         * write , to buff
  MOVE.W  D7,D3             * restore orig
  JSR     mode_test         * test orginal
  RTS                       *return to OPCODER

bin10 * 6 bit w/immediate

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
  BTST   #2,D3
  BNE    reg100             * assume if 1 -> 100 = #imm
  BRA    reg00              * assume if 0 -> 00
  
reg100 *assume 1->100 #imm  
  LEA    STR_IMM,A6         * load  #
  JSR    write_str          * write #
  LEA    STR_$,A6           * load  $
  JSR    write_str          * write $
  
  CMP.B  #2,D4              * check size (2 long) else (word)
  BEQ    read_long          * proccess long
  BRA    read_word          * proccess word   
  RTS
  
reg00                        *TODO add validation assume 00
  BTST   #0,D3
  BNE    reg001
  BRA    reg000
  
reg001 * (xxx).L                       
  LEA    STR_$,A6           * load  $
  JSR    write_str          * write $
  JSR    read_long          * proccess long
  RTS

reg000 * (xxx).W
  LEA    STR_$,A6           * load  $
  JSR    write_str          * write $
  JSR    read_word          * proccess word
  RTS


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
  BEQ       write_done          * null terminated?
  MOVE.B    (A6)+,(A2)+         * increment string and buffer 
  BRA       write_str           
write_done  RTS
 
write_comma                     * write comma to buffer 
  LEA       STR_COMMA,A6
  JSR       write_str
  RTS 
  
read_word                       * proccess word after instruction
  MOVE.W    (A0)+,D1            * read next word
  MOVE.W    #$000F,D6           * init bit mask
  MOVE.W    #3,D7               * init nibble counter
word_loop
  ROL.W     #4,D1               * rot MS nibble to LS nibble
  MOVE.W    D1,D2               * save D1
  AND.W     D6,D2               * bitmask LS nibble
  MOVEA.W   D2,A6               * copy to address reg
  MOVE.B    (SUMTABLE,A6),(A2)+ * store ascii at index to goodbuff
  DBF       D7,word_loop        
  RTS



read_long                       * proccess long after instruction
  MOVE.L    (A0)+,D1            * read next long            
  MOVE.W    #$000F,D6           * init bit mask
  MOVE.B    #7,D7               * init nibble counter
long_loop
  ROL.L     #4,D1               * rot MS nibble to LS nibble
  MOVE.L    D1,D2               * save D1
  AND.W     D6,D2               * bitmask LS nibble
  MOVEA.W   D2,A6               * copy to address reg
  MOVE.B    (SUMTABLE,A6),(A2)+ * store ascii at index to goodbuff
  DBF       D7,long_loop
  RTS

END      SIMHALT
*******************************************************************************
******************** Put variables and constants here *************************

*SUMTABLE1  DC.B      $30,$31,$32,$33,$34,$35,$36,$37
SUMTABLE   DC.B      '0','1','2','3','4','5','6','7','8'
           DC.B      '9','A','B','C','D','E','F'

*GOODBUFF   DC.B      $00

STR_IMM    DC.B      '#',0
STR_$      DC.B      '$',0
STR_D      DC.B      'D',0
STR_A      DC.B      'A',0

STR_INDA   DC.B      '(','A',0
STR_DECA   DC.B      '-','(','A',0 
STR_CP     DC.B      ')',0
STR_CPINC  DC.B      ')','+',0
STR_COMMA  DC.B      ',',0        
  END START

