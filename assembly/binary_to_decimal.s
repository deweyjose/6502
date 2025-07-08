; ============================================================================
; BINARY TO DECIMAL CONVERSION - 6502 Breadboard Computer
; ============================================================================
; This program demonstrates binary-to-decimal conversion using the double-
; dabble algorithm (also known as shift-and-add-3). It converts a 16-bit
; binary number to its decimal representation and displays it on the LCD.
;
; The algorithm works by:
; 1. Shifting the binary number left bit by bit
; 2. Adding 3 to any BCD digit that becomes >= 5
; 3. Repeating until all bits are processed
; 4. The result is a packed BCD representation
;
; Hardware requirements:
; - 16x2 LCD display connected to VIA Port B
; - VIA configured for LCD control
; ============================================================================

; Memory layout for binary to decimal conversion
value = $0200 ; 2 bytes address of the value we want to convert to decimal
mod10 = $0202 ; 2 bytes
message = $0204 ; 6 bytes

  .org $8000

; ──────────────────────────────────────────────
; reset: Main program entry point
; ──────────────────────────────────────────────
reset:
  ; Initialize stack pointer
  ldx $ff
  txs

  ; Initialize LCD display
  jsr lcd_init
  jsr lcd_setup

  ; Clear the message buffer
  lda #0
  sta message
  sta message + 1 
  sta message + 2 
  sta message + 3 
  sta message + 4 
  sta message + 5 

  ; Load the test number into the value variable
  ; This loads the 16-bit number 1729 (the Hardy-Ramanujan number)
  lda number
  sta value
  lda number + 1
  sta value + 1

; ──────────────────────────────────────────────
; b2d_divide: Binary to decimal conversion main loop
; Uses repeated division by 10 to extract decimal digits
; ──────────────────────────────────────────────
b2d_divide:
  ; Initialize the remainder to 0
  lda #0             
  sta mod10
  sta mod10 + 1
  clc
 
  ; Loop through all 16 bits of the input number
  ldx #16
  
b2d_divide_loop:
  ; Rotate the quotient and remainder left by 1 bit
  ; This effectively multiplies remainder by 2 and adds next bit from quotient
  rol value
  rol value + 1
  rol mod10
  rol mod10 + 1

  ; Try to subtract 10 from the current remainder
  ; This is equivalent to checking if remainder >= 10
  sec
  lda mod10
  sbc #10           ; Subtract 10 from low byte
  tay               ; Save result in Y
  lda mod10 + 1
  sbc #0            ; Subtract borrow from high byte
  bcc b2d_ignore_result ; If carry clear, remainder was < 10, ignore subtraction
  
  ; Remainder was >= 10, so keep the subtraction result
  ; This gives us one more in the quotient
  sty mod10
  sta mod10 + 1

b2d_ignore_result:
  dex
  bne b2d_divide_loop
  
  ; After processing all bits, shift the final quotient bit
  rol value
  rol value + 1

  ; Convert the remainder (0-9) to ASCII and add to result string
  lda mod10
  clc
  adc #"0"          ; Convert to ASCII ('0' + digit)
  jsr push_char     ; Add character to beginning of message string

  ; Check if we have more digits to process
  lda value
  ora value + 1
  bne b2d_divide    ; If quotient is not zero, continue dividing

  ; All digits processed, now display the result
  ldx #0
b2d_print_message:
  lda message,x
  beq loop          ; If null terminator reached, we're done
  jsr lcd_print_char
  inx
  jmp b2d_print_message

; ──────────────────────────────────────────────
; loop: Infinite loop - program complete
; ──────────────────────────────────────────────
loop:
  jmp loop

; ──────────────────────────────────────────────
; Data section
; ──────────────────────────────────────────────
number: .word 1729   ; Test number (Hardy-Ramanujan number)
dx: .asciiz "X"      ; Unused string

; ──────────────────────────────────────────────
; push_char: Add character to beginning of null-terminated string
; This function implements a "prepend" operation by shifting all existing
; characters right and inserting the new character at the beginning.
; Input: A register contains the character to prepend to 'message'
; ──────────────────────────────────────────────
push_char:
  pha            ; Save the new character on stack
  ldy #0         ; Initialize index to 0

char_loop:
  lda message,y  ; Load character from string at current position
  tax            ; Save it in X register
  pla            ; Get character from stack (new char or shifted char)
  sta message,y  ; Store it in the string at current position
  iny            ; Move to next position
  txa            ; Get the character we saved in X
  pha            ; Push it onto stack for next iteration
  bne char_loop  ; If character wasn't null, continue shifting
  
  pla            ; Remove the final null terminator from stack
  sta message,y  ; Store null terminator at end of string
  rts

; Include LCD library functions
  .include lib/lcd.s

; ──────────────────────────────────────────────
; Reset vector - tells 6502 where to start execution
; ──────────────────────────────────────────────
  .org $fffc
  .word reset     ; Reset vector points to our reset routine
  .word $0000     ; IRQ vector (not used in this program)
