; ──────────────────────────────────────────────
; BINARY TO DECIMAL CONVERSION (for 6502 projects)
; Provides routines to convert 16-bit binary values to ASCII decimal strings
; 
; Exposes:
;   b2d_convert     - Convert 16-bit binary to ASCII decimal string
;   b2d_value       - 2 bytes: input value to convert
;   b2d_message     - 6 bytes: output ASCII decimal string (null-terminated)
; 
; Usage:
;   lda #<value_low
;   ldx #>value_high
;   jsr b2d_convert
;   ; b2d_message now contains ASCII decimal string
; ──────────────────────────────────────────────

; Memory addresses for binary => decimal conversion
b2d_value   = $00 ; 2 bytes: value to convert to decimal
b2d_mod10   = $02 ; 2 bytes: holds remainder during division by 10
b2d_message = $04 ; 6 bytes: stores resulting ASCII decimal string

; ──────────────────────────────────────────────
; b2d_convert: Convert 16-bit binary value to ASCII decimal string
; Input:  A = low byte of value, X = high byte of value
; Output: b2d_message contains null-terminated ASCII decimal string
; ──────────────────────────────────────────────
b2d_convert:
  ; Store input value
  sta b2d_value
  stx b2d_value + 1
  
  ; Clear message buffer
  lda #0
  sta b2d_message
  sta b2d_message + 1
  sta b2d_message + 2
  sta b2d_message + 3
  sta b2d_message + 4
  sta b2d_message + 5
  
  ; Start conversion
  jsr b2d_divide
  rts

; ──────────────────────────────────────────────
; b2d_divide: Main binary-to-decimal conversion loop
; Uses repeated division by 10 to extract decimal digits
; ──────────────────────────────────────────────
b2d_divide:
  lda #0             
  sta b2d_mod10
  sta b2d_mod10 + 1
  clc
 
  ; Loop through the 16 bits of the value
  ldx #16
b2d_divide_loop:
  ; Rotate the quotient and remainder to the left
  rol b2d_value
  rol b2d_value + 1
  rol b2d_mod10
  rol b2d_mod10 + 1

  ; Subtract 10 from low byte and save to Y
  sec
  lda b2d_mod10
  sbc #10
  tay
  ; Subtract high byte from zero to see if we go negative (remainder)
  lda b2d_mod10 + 1
  sbc #0
  ; Branch if no remainder
  bcc b2d_ignore_result
  ; Store the remainder in b2d_mod10
  sty b2d_mod10
  sta b2d_mod10 + 1

b2d_ignore_result:
  dex
  bne b2d_divide_loop
  ; Shift the last bit into quotient
  rol b2d_value
  rol b2d_value + 1

  ; Convert remainder to ASCII and push to message buffer
  lda b2d_mod10
  clc
  adc #"0"
  jsr b2d_push_char

  ; If value is not zero, repeat
  lda b2d_value
  ora b2d_value + 1
  bne b2d_divide
  rts

; ──────────────────────────────────────────────
; b2d_push_char: Add character in A to the beginning of b2d_message
; Used to build the decimal string in reverse order
; ──────────────────────────────────────────────
b2d_push_char:
  pha            ; Push new char onto the stack
  ldy #0

b2d_char_loop:
  lda b2d_message,y  ; Get char from string and put into X
  tax
  pla
  sta b2d_message,y  ; Pull char off stack and add to string
  iny
  txa
  pha            ; Push char from string onto stack
  bne b2d_char_loop
  
  pla
  sta b2d_message,y  ; Pull the null off the stack and add to the end
  rts 