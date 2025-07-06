
; memory addresses for binary => decimal conversion
value = $0200 ; 2 bytes address of the value we want to convert to decimal
mod10 = $0202 ; 2 bytes
message = $0204 ; 6 bytes

  .org $8000

reset:
  ldx $ff
  txs

  jsr lcd_init
  jsr lcd_setup

  lda #0
  sta message
  sta message + 1 
  sta message + 2 
  sta message + 3 
  sta message + 4 
  sta message + 5 

  ; load the number into the value (memory)
  lda number
  sta value
  lda number + 1
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

loop:
  jmp loop

number: .word 1729
dx: .asciiz "X"

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

  
  .include lcd.s

  .org $fffc
  .word reset
  .word $0000
