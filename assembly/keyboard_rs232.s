; ──────────────────────────────────────────────
; RS232 Keyboard Demo
; Displays a banner and then prints 'x' for each received character
; on the LCD using 6502 assembly and VIA port A.
; ──────────────────────────────────────────────

PORTA = $6001
DDRA = $6003

  .org $8000

; ──────────────────────────────────────────────
; Reset vector: program entry point
; ──────────────────────────────────────────────
reset:
  ldx #$ff
  txs 
  
  lda #%00000000 ; Set all pins on port A to input
  sta DDRA

  jsr lcd_init
  jsr lcd_setup
  
  ldx #0
print_banner:
  lda banner, x
  beq rx_wait
  jsr lcd_print_char
  inx
  jmp print_banner

; ──────────────────────────────────────────────
; Main loop: Wait for input, print 'x' for each received char
; ──────────────────────────────────────────────
rx_wait:
  bit PORTA
  bvc rx_wait

  lda #"x"
  jsr lcd_print_char
  jmp rx_wait 

.include lib/lcd.s

banner: .asciiz "Dewey Jose 2023"

  .org $fffc
  .word reset
  .word $0000
