*-----------------------------------------------------------
* Title      : EA resolution
* Written by : Saam Amiri
* Date       :
* Description:
*-----------------------------------------------------------
*STACK      EQU     $8000  
*CR         EQU     $0D      * Carriage return
*LF         EQU     $0A      * Line feed
*
*         ORG       $1000
*START:                      * first instruction of program
*  LEA     STACK,SP
*  *MOVE.B  #3,D2
*  *MOVE.W  #$3308,D3
*  MOVE.B   #10,D2
*  MOVE.W   #$0107,D3
*  JSR      START_EA
* 
*  SIMHALT
  
START_EA                    *OPCODE coming in
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

  MOVE.W  #2,D0             * Set invalid flag
  RTS                       * Return to OP-module
  *BRA     END               * D2 not set to proper EA Flag
  
    
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
  JSR     mode_test         * test mode/reg write to buff 
  RTS                       * return to OPCODER
  
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

  JSR     write_comma       * write , to buff

  MOVE.W  D7,D3             * restore D3
  JSR     mode_test         * print destination
  RTS                       * return to OPCODER

bin4 * 8 bit branch displacment
  LEA     STR_$,A6          * load  $  
  JSR     write_str         * write $ to buff  
  
  CMP.B   #$00,D3           * if $00 read word
  BEQ     read_word
  CMP.B   #$FF,D3           * if $FF read long  
  BEQ     read_long
  MOVE.W  #$00FF,D1         * bitmask to reuse word logic
  AND.W   D3,D1             * bitmasked keeps LSByte
  
  MOVE.W  #$000F,D6         * nibble bit mask const  
  MOVE.W  #3,D7             * nibble counter  
  JSR     word_loop         * write hex word from left->right
  RTS
 
bin5 * Special rotation (12 bit)
  MOVE.W  D3,D6             * save temp
  AND.W   #$FFC7,D3         * bit mask make EA reg DN
  *LSR.W   #$8,D3            * shift dest reg to source reg index
  *LSR.W   #$1,D3            * max of 8 bit shifts per OP
  BTST    #5,D6             * check direction bit
  BEQ     imm_rot           * immediate used
  BNE     reg_rot           * data reg used
imm_rot
  JSR     bin6
  RTS
reg_rot
  *MOVE.W  D3,D6             * save temp
  LSR.W   #$8,D3            * shift dest reg to source reg index
  LSR.W   #$1,D3            * max of 8 bit shifts per OP
  JSR     mode000           * sum Dn reg bits
  MOVE.W  D6,D3
  JSR     write_comma       * write comma
  JSR     mode000           * sum Dn reg bits
  RTS
  
bin6 * SUBQ (special case)
  MOVE.W  D3,D7             * save temp
  LEA     STR_IMM,A6        * load  #
  JSR     write_str         * write #
  MOVE.W  #$0E00,D5         * bit mask data bits
  AND.W   D5,D3             
  CMP.W   #0,D3             * if not zero calculate value  
  BNE     shift
                            * data = 000 -> 8
  MOVE.B  #$38,(A2)+        * place hex aschii 8 into buffer
  JSR     write_comma       * write comma
  MOVE.W  D7,D3             * restore D3
  JSR     mode_test         * test mode/reg
  RTS

shift                       * data != 0 -> (1-7)
  LSR.W   #$8,D3            * shift dest reg to source reg index
  LSR.W   #$1,D3            * max of 8 bit shifts per OP
  JSR     reg_sum           * sum reg bits
  JSR     write_comma       * write comma
  MOVE.W  D7,D3             * restore
  JSR     mode_test
  RTS 
    
bin7 * MOVEM (6 bit w/Direction)
  MOVE.W  (A0)+,D6           * grab reg bit masked word
  MOVE.W  D3,D1              * store temp 
  ANDI.W  #$0038,D1          * bit mask mode bits
  CMPI.W  #$0020,D1          * compare with -(An) mode bits
  BEQ     pre_dec            * flip bit mask if mode -(An)
  BNE     skip_pre_dec       * else, skip over pre_dec
 
pre_dec
  CLR.L   D5                 * CLR temp       
  MOVE.W  #15,D7             * init counter
dec_loop 
  BTST    D7,D6              * test for 1 to add to temp
  BEQ     load_reg           * skip if 0
  ADDQ    #1,D5              * add 1 to reg 
  
load_reg
  ROR.W   #1,D5              * build towards correct formating
  DBF     D7,dec_loop        * dec if not complete
  MOVE.W  D5,D6              * overwrite post inc for pre dec bit mask
 
skip_pre_dec
  BTST    #10,D3             * check direction bit
  BEQ     flip_op            * Bit tested = 0 -> (<list>,EA)  
  JSR     mode_test          * Bit tested = 1 -> (EA,<list>)
  JSR     write_comma        * write comma

reg_set
  MOVE.B  #0,D0              * init counter
  LEA     STR_DA,A4          * points at 'D' will write D(D0)
  MOVE.W  D6,D3              * place bitmasked word
  *MOVE.W  (A0)+,D3           * grab reg bit masked word
  JSR     reg_list           * proccess LS Byte registers
*next byte of register set
  MOVE.B  #0,D0              * init counter
  MOVE.W  D3,D6              * save temp 
  JSR     write_slash        * checks if slash needed
  
  LSR.W   #8,D3              * shift A regs to D regs spot 7-0
  CMP.B   #$00,D3            * check if A regs empty  
  BEQ     return             * next reg_list is empty RTS             

  ADDA.W  #1,A4              * points at 'A' will write A(D0)
  JSR     reg_list           * calc A reg bitmask
  MOVE.B  #0,D0              * set good flag
  RTS                        * return to caller

write_slash
  CMP.B   #$00,D6            * check if D reg empty
  BEQ     return             * empty D regs no / needed
  LSR.W   #8,D6              * shift A regs to D regs spot 7-0
  CMP.B   #$00,D6            * check if A regs empty  
  BEQ     return             * next reg_list is empty RTS
  LEA     str_slash,A6       * load  /
  JSR     write_str          * write /
  RTS
  
flip_op * Bit tested = 0 -> (<list>,EA)
  * Save copy of D3
  MOVE.W  D3,D7              * save temp
  JSR     reg_set            * print reg reg set
  JSR     write_comma        * print comma
  MOVE.W  D7,D3              * restore reg
  JSR     mode_test          * print EA
  RTS

bin8 * 9 bit Address
  JSR     mode_test         * test mode/reg
  JSR     write_comma       * write ,
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
  RTS                       * return to OPCODER

bin10 * 6 bit w/immediate
  JSR     reg100            * jump straight to imm register for print
  JSR     write_comma       * write comma
  JSR     mode_test         * test mode/reg write to buff
  RTS

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
  
mode11 
  SUB.B  #1,D5
  BTST   D5,D3
  BNE    mode111
  BRA    mode110
  
mode10
  SUB.B  #1,D5
  BTST   D5,D3
  BNE    mode101
  BRA    mode100

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

mode111 
  SUB.B  #1,D5
  BTST   D5,D3              * test register for (xxx).W,(xxx).L,#imm
  BNE    reg100             * assume if 1 -> 100 = #imm
  BRA    reg0               * test for remaining EA modes
  
mode110                     * invalid mode (d8,An,Xn)
  MOVE.B #1,D0              * set bad flag for invalid mode
  RTS

mode101                     * invalid mode (d16,An)
  MOVE.B #1,D0              * set bad flag for invalid mode
  RTS 
  
mode100                     * assume if mode 10->100= -(An)
  LEA    STR_DECA,A6        * load  -(A
  JSR    write_str          * write -(A to buff
  JSR    reg_sum            * sum reg, write to buff
  LEA    STR_CP,A6          * load  ) 
  JSR    write_str          * write ) to buff
  RTS                       * return to bin

reg100                      *assume reg 1->100 #imm  
  LEA    STR_IMM,A6         * load  #
  JSR    write_str          * write #
  LEA    STR_$,A6           * load  $
  JSR    write_str          * write $
  
  CMP.B  #2,D4              * check size (2 long) else (word)
  BEQ    read_long          * proccess long
  BRA    read_word          * proccess word   
  RTS
  
reg0
  SUB.B  #1,D5
  BTST   D5,D3              * test for Ea modes  
  BNE    reg01                
  BRA    reg00              
  
reg00                       
  SUB.B  #1,D5
  BTST   D5,D3
  BNE    reg001
  BRA    reg000
  
reg01
  SUB.B  #1,D5
  BTST   D5,D3              * test for Ea modes             
  BNE    reg011              
  BRA    reg010             
  
reg011                      * (d8,PC,Xn)
  MOVE.B #1,D0              * invalid ea mode
  RTS
 
reg010                      * (d16,PC)
  MOVE.B #1,D0              * invalid ea mode
  RTS
  
reg001                      * (xxx).L                       
  LEA    STR_$,A6           * load  $
  JSR    write_str          * write $
  JSR    read_long          * proccess long
  RTS

reg000                      * (xxx).W
  LEA    STR_$,A6           * load  $
  JSR    write_str          * write $
  JSR    read_word          * proccess word
  RTS


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
  MOVE.W     #$0007,D5          * bitmask keep 3 LSB
  AND.W      D3,D5              * store D3 bitmasked bits to D6
  MOVEA.W    D5,A5              * prepare for index
  MOVE.B    (SUMTABLE,PC,A5),(A2)+ * store ascii at index to goodbuff 
  RTS                           * return to caller

************************MOVEM****************************
reg_list
  BTST      D0,D3
  BNE       full_reg            * bit contains 1
  BEQ       empty_reg           * bit contains 0
      

full_reg
  MOVE.B    (A4),(A2)+          * write 'D' or 'A' to buff
  MOVEA.W   D0,A5               * prepare for index
  MOVE.B    (SUMTABLE,PC,A5),(A2)+ * store ascii at index to goodbuff
  ADDQ      #1,D0               * increment counter
  CMP.B     #8,D0               * check if within bounds
  BEQ       return              * returns to caller
  BTST      D0,D3               * test bit    
  BNE       hyphen              * bit = 1 
  BEQ       slash               * bit = 0
    
hyphen  
  LEA       STR_hyphen,A6       * load  -
  JSR       write_str           * write -
hyphen_loop
  ADDQ      #1,D0               * increment count
  CMP.B     #8,D0               * check bounds
  BEQ       hyphen_end          * exceed bound
  BTST      D0,D3               * test bit
  BNE       hyphen_loop         * loop until no longer contigous 
  SUBQ      #1,D0               * dec count to valid reg (cur reg is 0)    
  BRA       full_reg
      
hyphen_end * subtract 1, print,RTS
  SUBQ      #1,D0               * decrement to valid reg
  MOVE.B    (A4),(A2)+          * write reg to buff
  MOVEA.W   D0,A5               * prepare for index into sumtable
  MOVE.B    (SUMTABLE,PC,A5),(A2)+ * store aschii at index to buff
  RTS                           * return to caller
  
slash
  ADDQ      #1,D0              * inc counter
  CMP.B     #8,D0              * check bounds
  BEQ       return             * return
  BTST      D0,D3              * test bit
  BEQ       slash              * bit = 0 loop
  LEA       STR_SLASH,A6       * bit = 1 write slash
  JSR       write_str
  BRA       full_reg           *  
           
SUMTABLE   DC.B      '0','1','2','3','4','5','6','7','8'
           DC.B      '9','A','B','C','D','E','F'
           
empty_reg 
  ADDQ      #1,D0               * incrmeent counter
  CMP.B     #8,D0               * check out of range
  BEQ       return              * counter = range 
  BRA       reg_list            * continue
  
  
return
  RTS  
*******************************************************

*Function write string to the buffer
write_str  
  CMPI.B    #0,(A6)             * is the byte at A6 the NULL Char?
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
  MOVE.W    #$000F,D5           * init bit mask
  MOVE.W    #3,D7               * init nibble counter
word_loop
  ROL.W     #4,D1               * rot MS nibble to LS nibble
  MOVE.W    D1,D2               * save D1
  AND.W     D5,D2               * bitmask LS nibble
  MOVEA.W   D2,A6               * copy to address reg
  MOVE.B    (SUMTABLE,PC,A6),(A2)+ * store ascii at index to goodbuff
  DBF       D7,word_loop        
  RTS



read_long                       * proccess long after instruction
  MOVE.L    (A0)+,D1            * read next long            
  MOVE.W    #$000F,D5           * init bit mask
  MOVE.W    #7,D7               * init nibble counter
long_loop
  ROL.L     #4,D1               * rot MS nibble to LS nibble
  MOVE.L    D1,D2               * save D1
  AND.W     D5,D2               * bitmask LS nibble
  MOVEA.W   D2,A6               * copy to address reg
  MOVE.B    (SUMTABLE,PC,A6),(A2)+ * store ascii at index to goodbuff
  DBF       D7,long_loop
  RTS

*END      SIMHALT
*******************************************************************************
******************** Put variables and constants here *************************

STR_IMM    DC.B      '#',0
STR_$      DC.B      '$',0
STR_SLASH  DC.B      '/',0
STR_HYPHEN DC.B      '-',0
STR_D      DC.B      'D',0
STR_A      DC.B      'A',0

STR_DA     DC.B      'D','A',0

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
