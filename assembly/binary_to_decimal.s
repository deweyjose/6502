; ──────────────────────────────────────────────
; Binary to Decimal Conversion Demo
; Converts a 16-bit binary value to ASCII decimal and prints to LCD
; ──────────────────────────────────────────────

; Memory addresses for binary => decimal conversion
value   = $0200 ; 2 bytes: address of the value we want to convert to decimal
mod10   = $0202 ; 2 bytes: holds remainder during division by 10
message = $0204 ; 6 bytes: stores resulting ASCII decimal string

  .org $8000

; ──────────────────────────────────────────────
; Reset vector: program entry point
; ──────────────────────────────────────────────
reset:
  ldx $ff         ; Initialize stack pointer
  txs

  jsr lcd_init    ; Initialize LCD hardware
  jsr lcd_setup   ; Configure LCD display

  ; Clear the message buffer
  lda #0
  sta message
  sta message + 1 
  sta message + 2 
  sta message + 3 
  sta message + 4 
  sta message + 5 

  ; Load the number to convert into 'value' (from 'number' below)
  lda number
  sta value
  lda number + 1
  sta value + 1

; ──────────────────────────────────────────────
; b2d_divide: Main binary-to-decimal conversion loop
; Uses repeated division by 10 to extract decimal digits
; ──────────────────────────────────────────────
b2d_divide:
  lda #0             
  sta mod10
  sta mod10 + 1
  clc
 
  ; Loop through the 16 bits of the value
  ldx #16
b2d_divide_loop:
  ; Rotate the quotient and remainder to the left
  rol value
  rol value + 1
  rol mod10
  rol mod10 + 1

  ; Subtract 10 from low byte and save to Y
  sec
  lda mod10
  sbc #10
  tay
  ; Subtract high byte from zero to see if we go negative (remainder)
  lda mod10 + 1
  sbc #0
  ; Branch if no remainder
  bcc b2d_ignore_result
  ; Store the remainder in mod10
  sty mod10
  sta mod10 + 1

b2d_ignore_result:
  dex
  bne b2d_divide_loop
  ; Shift the last bit into quotient
  rol value
  rol value + 1

  ; Convert remainder to ASCII and push to message buffer
  lda mod10
  clc
  adc #"0"
  jsr push_char

  ; If value is not zero, repeat
  lda value
  ora value + 1
  bne b2d_divide

  ; All digits pushed, print the message
  ldx #0
b2d_print_message:
  lda message,x
  beq loop
  jsr lcd_print_char
  inx
  jmp b2d_print_message

; ──────────────────────────────────────────────
; Infinite loop (end of program)
; ──────────────────────────────────────────────
loop:
  jmp loop

; ──────────────────────────────────────────────
; Data section
; ──────────────────────────────────────────────
number: .word 1729      ; Number to convert (change as needed)
dx: .asciiz "X"         ; Unused/test string

; ──────────────────────────────────────────────
; push_char: Add character in A to the beginning of the null-terminated string 'message'
; Used to build the decimal string in reverse order
; ──────────────────────────────────────────────
push_char:
  pha            ; Push new char onto the stack
  ldy #0

char_loop:
  lda message,y  ; Get char from string and put into X
  tax
  pla
  sta message,y  ; Pull char off stack and add to string
  iny
  txa
  pha            ; Push char from string onto stack
  bne char_loop
  
  pla
  sta message,y  ; Pull the null off the stack and add to the end
  rts

; ──────────────────────────────────────────────
; LCD utility routines (external)
; ──────────────────────────────────────────────
.include lib/lcd.s

  .org $fffc
  .word reset
  .word $0000
