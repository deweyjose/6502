; ============================================================================
; RS232 KEYBOARD INTERFACE - 6502 Breadboard Computer
; ============================================================================
; This program implements a simple RS232 keyboard interface for the 6502
; breadboard computer. It monitors the RS232 input line and displays
; received characters on the LCD display.
;
; Hardware requirements:
; - RS232 interface connected to VIA Port A
; - 16x2 LCD display connected to VIA Port B
; - RS232 receive line connected to bit 6 of Port A (overflow flag)
; ============================================================================

; VIA Port A registers
PORTA = $6001       ; Port A data register (RS232 input)
DDRA = $6003        ; Port A data direction register

  .org $8000

; ──────────────────────────────────────────────
; reset: Main program entry point
; ──────────────────────────────────────────────
reset:
  ldx #$ff          ; Initialize stack pointer
  txs               ; Transfer X to stack pointer
  
  lda #%00000000    ; Set all pins on port A to input
  sta DDRA          ; Configure Port A for RS232 input

  jsr lcd_init      ; Initialize LCD hardware
  jsr lcd_setup     ; Configure LCD display settings
  
  ldx #0            ; Initialize character index for banner
  
; ──────────────────────────────────────────────
; print_banner: Display startup message on LCD
; ──────────────────────────────────────────────
print_banner:
  lda banner, x     ; Load character from banner string
  beq rx_wait       ; If null terminator, start RS232 receive loop
  jsr lcd_print_char ; Print character to LCD
  inx               ; Move to next character
  jmp print_banner  ; Continue printing banner

; ──────────────────────────────────────────────
; rx_wait: Wait for RS232 data to arrive
; Monitors the overflow flag (bit 6) of Port A for RS232 activity
; ──────────────────────────────────────────────
rx_wait:
  bit PORTA         ; Test bits in Port A
  bvc rx_wait       ; Branch if overflow flag (bit 6) is clear
                    ; Overflow flag indicates RS232 data received

  lda #"x"          ; Load 'x' character (placeholder for received data)
  jsr lcd_print_char ; Print the character to LCD
  jmp rx_wait       ; Continue monitoring for more RS232 data

; Include LCD library functions
 .include lib/lcd.s

; ──────────────────────────────────────────────
; Data section: Startup banner message
; ──────────────────────────────────────────────
banner: .asciiz "Dewey Jose 2023"  ; Null-terminated startup message

; ──────────────────────────────────────────────
; Reset vector - tells 6502 where to start execution
; ──────────────────────────────────────────────
  .org $fffc
  .word reset       ; Reset vector points to our reset routine
  .word $0000       ; IRQ vector (not used in this program)
