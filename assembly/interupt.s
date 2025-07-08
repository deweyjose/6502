; ──────────────────────────────────────────────
; Interrupt Counter Demo
; Uses VIA interrupts to increment a counter and display its value
; in decimal on the LCD using 6502 assembly.
; ──────────────────────────────────────────────

PRC = $600c
IFR = $600d
IER = $600e
PORTA = $6001
DDRA = $6003

; Memory addresses for binary => decimal conversion
value = $0200 ; 2 bytes: value to convert to decimal
mod10 = $0202 ; 2 bytes: holds remainder during division by 10
message = $0204 ; 6 bytes: stores resulting ASCII decimal string
counter = $020a ; 2 bytes: incremented by interrupt

  .org $8000

; ──────────────────────────────────────────────
; Reset vector: program entry point
; ──────────────────────────────────────────────
reset:
  ldx $ff
  txs
  
  ; Configure VIA for rising edge interrupt
  lda #$01
  sta PRC
  lda #$82
  sta IER
  cli

  lda #%00000000 ; Set all pins on port A to input
  sta DDRA

  jsr lcd_init
  jsr lcd_setup

  lda #0   ; Clear accumulator

loop:
  lda #0
  sta message
  
  jsr lcd_home    ; Move LCD cursor to home
    
  lda counter
  sta value
  lda counter + 1
  sta value + 1

; ──────────────────────────────────────────────
; b2d_divide: Main binary-to-decimal conversion loop
; ──────────────────────────────────────────────
b2d_divide:
  lda #0             
  sta mod10
  sta mod10 + 1
  clc
 
  ldx #16
b2d_divide_loop:
  rol value
  rol value + 1
  rol mod10
  rol mod10 + 1

  sec
  lda mod10
  sbc #10
  tay
  lda mod10 + 1
  sbc #0
  bcc b2d_ignore_result
  sty mod10
  sta mod10 + 1

b2d_ignore_result:
  dex
  bne b2d_divide_loop
  rol value
  rol value + 1

  lda mod10
  clc
  adc #"0"
  jsr push_char

  lda value
  ora value + 1
  bne b2d_divide

  ldx #0
b2d_print_message:
  lda message,x
  beq loop
  jsr lcd_print_char
  inx
  jmp b2d_print_message

; ──────────────────────────────────────────────
; push_char: Add character in A to the beginning of the null-terminated string 'message'
; Used to build the decimal string in reverse order
; ──────────────────────────────────────────────
push_char:
  pha
  ldy #0
char_loop:
  lda message,y
  tax
  pla
  sta message,y
  iny
  txa
  pha
  bne char_loop
  pla
  sta message,y
  rts

; ──────────────────────────────────────────────
; increment_counter: VIA interrupt handler
; Increments the counter variable on each interrupt
; ──────────────────────────────────────────────
increment_counter:
  pha
  lda PORTA
  sta counter
  pla
  rti 

; ──────────────────────────────────────────────
; nmi: Non-maskable interrupt handler (unused)
; ──────────────────────────────────────────────
nmi:
  rti

; ──────────────────────────────────────────────
; LCD utility routines (external)
; ──────────────────────────────────────────────
.include lib/lcd.s

  .org $fffa
  .word nmi 
  .word reset
  .word increment_counter
