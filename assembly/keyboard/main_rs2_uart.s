; ──────────────────────────────────────────────
; RS-232 Serial Keyboard Demo
; Reads input from a RS-232 serial port and displays 
; characters on the LCD using 6502 assembly.
; ──────────────────────────────────────────────

PORTA = $6001
DDRA = $6003
PCR = $600c
IFR = $600d
IER = $600e

ACIA_DATA = $5000
ACIA_STATUS = $5001
ACIA_CMD = $5002
ACIA_CTRL = $5003    

temp = $00

  .org $8000

; ──────────────────────────────────────────────
; Reset vector: program entry point
; ──────────────────────────────────────────────
reset:
  ldx #$ff
  txs

  ; Set all pins on Port B to Output
  lda #%11111111
  sta DDRB
  ; Set bit 6 of DDRA as input (RS-232 RX), others as output
  lda #%10111111
  sta DDRA
  
  jsr lcd_init
  jsr lcd_setup

  lda #$00
  sta ACIA_STATUS ; soft reset

  lda #$1f       ; N-8-1 19200 baud  
  sta ACIA_CTRL   

  lda #$0b ; no parity, no echo , no interrupt
  sta ACIA_CMD

rx_wait:
  lda ACIA_STATUS
  and #$08  ; check rx buffer status flag     
  beq rx_wait ; loop if rx buffer is empty

  lda ACIA_DATA
  
  cmp #$7F  ; del
  beq del_key

  jsr lcd_print_char
  jsr send_char
  
  jmp rx_wait

del_key:
  pha
  lda #$08  
  jsr send_char
  pla
  lda #' ' 
  jsr send_char
  pla
  lda #$08  
  jsr send_char
  pla  
  jsr lcd_del
  jmp rx_wait

send_char:
  sta ACIA_DATA
  pha
tx_wait:
  lda ACIA_STATUS
  and #$10
  beq tx_wait
  jsr tx_delay
  pla
  rts

tx_delay:
  phx
  ldx #100
tx_delay_loop:
  dex
  bne tx_delay_loop  
  plx
  rts

; assumes A has the value you want to print
; print the value in A as 8 binary digits (MSB first)
print_byte_binary:
  pha              ; save original A
  ldy #8           ; 8 bits to process
  sta temp         ; stash working copy in zero page

loop:
  lda temp         ; load working copy
  and #%10000000   ; mask bit 7
  beq print0
  lda #'1'
  jsr lcd_print_char
  jmp shift
print0:
  lda #'0'
  jsr lcd_print_char
shift:
  lda temp
  asl              ; shift left
  sta temp
  dey
  bne loop
  pla
  rts
; 1 0 0 0 0 0 0 0
; ──────────────────────────────────────────────
; NMI handler
; ──────────────────────────────────────────────
nmi:
  rti

; ──────────────────────────────────────────────
; IRQ handler
; ──────────────────────────────────────────────
irq_handler:
  rti

  .include ../lib/lcd.s

  .org $fffa
  .word nmi
  .word reset
  .word irq_handler