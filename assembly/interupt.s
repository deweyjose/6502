; ============================================================================
; INTERRUPT-DRIVEN COUNTER - 6502 Breadboard Computer
; ============================================================================
; This program demonstrates interrupt-driven input handling on the 6502
; breadboard computer. It uses external interrupts to increment a counter
; and displays the current count in decimal format on the LCD display.
;
; The program combines:
; - Interrupt handling for external input
; - Binary-to-decimal conversion for display
; - Real-time counter updates
;
; Hardware requirements:
; - External interrupt source connected to VIA Port A
; - 16x2 LCD display connected to VIA Port B
; - VIA configured for interrupts
; ============================================================================

; VIA control registers
PRC = $600c         ; Peripheral Control Register (typo: should be PCR)
IFR = $600d         ; Interrupt Flag Register
IER = $600e         ; Interrupt Enable Register
PORTA = $6001       ; Port A data register
DDRA = $6003        ; Port A data direction register

; Memory layout for binary to decimal conversion
value = $0200       ; 2 bytes address of the value we want to convert to decimal
mod10 = $0202       ; 2 bytes
message = $0204     ; 6 bytes
counter = $020a     ; 2 bytes - the interrupt counter

  .org $8000

; ──────────────────────────────────────────────
; reset: Main program entry point and system initialization
; ──────────────────────────────────────────────
reset:
  ; Initialize stack pointer
  ldx $ff
  txs
  
  ; Configure VIA for interrupts
  lda #$01          ; Configure for positive edge interrupt
  sta PRC           ; Set Peripheral Control Register
  lda #$82          ; Enable CA1 interrupt (bit 7=1, bit 1=1)
  sta IER           ; Set Interrupt Enable Register
  cli               ; Clear interrupt disable flag (enable interrupts)

  ; Configure Port A for input
  lda #%00000000    ; set all pins on port A to input
  sta DDRA

  ; Initialize LCD display
  jsr lcd_init
  jsr lcd_setup

  ; Initialize counter to 0
  lda #0   

; ──────────────────────────────────────────────
; loop: Main program loop - continuously displays counter value
; ──────────────────────────────────────────────
loop:
  ; Clear the message buffer for new conversion
  lda #0
  sta message
  
  ; Move cursor to home position
  jsr lcd_home
    
  ; Copy current counter value to conversion variable
  lda counter
  sta value
  lda counter + 1
  sta value + 1
  
; ──────────────────────────────────────────────
; b2d_divide: Binary to decimal conversion routine
; Converts the 16-bit counter value to decimal digits for display
; ──────────────────────────────────────────────
b2d_divide:
  ; Initialize remainder to 0
  lda #0             
  sta mod10
  sta mod10 + 1
  clc
 
  ; Process all 16 bits of the counter value
  ldx #16
  
b2d_divide_loop:
  ; Rotate quotient and remainder left (divide by 2, multiply remainder by 2)
  rol value
  rol value + 1
  rol mod10
  rol mod10 + 1

  ; Try to subtract 10 from remainder (check if >= 10)
  sec
  lda mod10
  sbc #10
  tay
  lda mod10 + 1
  sbc #0
  bcc b2d_ignore_result ; If result negative, remainder was < 10
  
  ; Remainder was >= 10, so keep subtraction (adds 1 to quotient)
  sty mod10
  sta mod10 + 1

b2d_ignore_result:
  dex
  bne b2d_divide_loop
  
  ; Complete the division by shifting final bit into quotient
  rol value
  rol value + 1

  ; Convert remainder digit (0-9) to ASCII and add to result string
  lda mod10
  clc
  adc #"0"
  jsr push_char

  ; Continue if more digits to process
  lda value
  ora value + 1
  bne b2d_divide    ; If quotient not zero, continue dividing

  ; Display the converted decimal number
  ldx #0
b2d_print_message:
  lda message,x
  beq loop          ; If end of string, loop back for next update
  jsr lcd_print_char
  inx
  jmp b2d_print_message

; ──────────────────────────────────────────────
; push_char: Prepend character to message string
; This function adds a character to the beginning of the message string,
; shifting all existing characters to the right.
; Input: A register contains character to prepend
; ──────────────────────────────────────────────
push_char:
  pha               ; Save new character on stack
  ldy #0            ; Initialize string index

char_loop:
  lda message,y     ; Load character from string at current position
  tax               ; Save current character in X
  pla               ; Get character from stack (new or shifted)
  sta message,y     ; Store character in current position
  iny               ; Move to next position
  txa               ; Get saved character
  pha               ; Push it for next iteration
  bne char_loop     ; Continue if not null terminator
  
  pla               ; Remove final null from stack
  sta message,y     ; Store null terminator at end
  rts

; ──────────────────────────────────────────────
; increment_counter: Interrupt service routine
; Called when external interrupt occurs (button press, etc.)
; Increments the counter and updates the display
; ──────────────────────────────────────────────
increment_counter:
  pha               ; Save accumulator
  lda PORTA         ; Read the input value from Port A
  sta counter       ; Store it as the counter value
  pla               ; Restore accumulator
  rti               ; Return from interrupt

; ──────────────────────────────────────────────
; nmi: Non-maskable interrupt handler (unused)
; ──────────────────────────────────────────────
nmi:
  rti

; Include LCD library functions
  .include "lib/lcd.s"

; ──────────────────────────────────────────────
; Interrupt Vector Table
; ──────────────────────────────────────────────
  .org $fffa
  .word nmi                 ; Non-maskable interrupt vector
  .word reset               ; Reset vector (program start)
  .word increment_counter   ; IRQ vector (points to our interrupt handler)
