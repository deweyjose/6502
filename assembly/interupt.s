PRC = $600c
IFR = $600d
IER = $600e
PORTA = $6001
DDRA = $6003

; memory addresses for binary => decimal conversion
value = $0200 ; 2 bytes address of the value we want to convert to decimal
mod10 = $0202 ; 2 bytes
message = $0204 ; 6 bytes
counter = $020a

  .org $8000

reset:
  ldx $ff
  txs
  
  ; rising edge
  lda #$01
  sta PRC
  lda #$82
  sta IER
  cli

  lda #%00000000 ; set all pins on port A to input
  sta DDRA

  jsr lcd_init
  jsr lcd_setup

  lda #0   

loop:
  lda #0
  sta message
  
  jsr lcd_home
    
  lda counter
  sta value
  lda counter + 1
  sta value + 1
  
b2d_divide:
  lda #0             
  sta mod10
  sta mod10 + 1
  clc
 
  ; loop through the 16 bits
  ldx #16
b2d_divide_loop:
  ; rotate the quotient and remainder to the left
  rol value
  rol value + 1
  rol mod10
  rol mod10 + 1

  ; subtract 10 from low byte and save to Y
  sec
  lda mod10
  sbc #10
  tay
  ; subtract high byte from zero to see if we go negative (we have a remainder)
  lda mod10 + 1
  sbc #0
  ; branch if no remainder
  bcc b2d_ignore_result
  ; store the remainder in mod10
  sty mod10
  sta mod10 + 1

b2d_ignore_result:
  dex
  bne b2d_divide_loop
  ; shift the last bit into quotient
  rol value
  rol value + 1

  lda mod10
  clc
  adc #"0"
  jsr push_char

  lda value
  ora value + 1
  ; if we are not 0, we have more work to do ...
  bne b2d_divide

  ; binary_value is zero, we've pushed all the bytes
  ; into message, time to print it
  ldx #0
b2d_print_message:
  lda message,x
  beq loop
  jsr lcd_print_char
  inx
  jmp b2d_print_message

; add the character in the A register to the beginning of the 
; null-terminated string `message`
push_char:
  pha            ; push first new char onto the stack
  ldy #0

char_loop:
  lda message,y ; get char on string and put into x 
  tax
  pla
  sta message,y ; pul char off stack and add to the string
  iny
  txa
  pha            ; push car from string onto stack
  bne char_loop
  
  pla
  sta message,y  ; pull the null off the stack and add to the end

  rts

increment_counter:
  pha
  lda PORTA
  sta counter
  pla
  rti 

nmi:
  rti

  .include lcd.s


  .org $fffa
  .word nmi 
  .word reset
  .word increment_counter
