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
  
  ; ──────────────────────────────────────────────
  ; Test RS-232 transmission: Send '*' character
  ; ──────────────────────────────────────────────
  lda #1
  sta PORTA                                    ; Set start bit (LOW)

  lda #"*"                                     ; Load test character '*'
  sta $0200                                    ; Store character in memory for bit shifting

  lda #$01                                     ; Prepare to clear bit 0 (TX pin)
  trb PORTA                                    ; Clear bit 0 (start bit)

  ldx #8                                       ; Bit counter for 8 data bits
write_bit:
  jsr bit_delay                               ; Wait full bit time
  ror $0200                                   ; Rotate character right, carry gets next bit
  bcs send_1                                  ; If carry set, send 1
  trb PORTA                                   ; Clear bit 0 (send 0)
  jmp tx_done
send_1:
  tsb PORTA                                   ; Set bit 0 (send 1)
tx_done:
  dex                                         ; Decrement bit counter
  bne write_bit                               ; Continue until all 8 bits sent
  
  jsr bit_delay                               ; Wait for stop bit
  trb PORTA                                   ; Clear bit 0 (stop bit)
  jsr bit_delay                               ; Wait full stop bit time

; ──────────────────────────────────────────────
; Main loop: Wait for RS-232 start bit
; ──────────────────────────────────────────────
rx_wait:
  bit PORTA
  bvs rx_wait

  jsr half_bit_delay                          ; Wait half bit time for center sampling

  ldx #8
read_bit:
  jsr bit_delay                               ; Wait full bit time
  
  ; Sample the bit and set carry flag
  bit PORTA
  bvs recv_1                                  ; If overflow flag set, we're receiving a 1
  clc                                         ; Clear carry bit to 0 because we're receiving a 0
  jmp recv_done                               ; We are done reading the bit
recv_1:
  nop 
  nop 
  sec                                         ; We read a 1 so set the carry bit to 1
recv_done:
  ror                                         ; Rotate the carry bit into the accumulator
  dex
  bne read_bit

  jsr lcd_print_char
  jsr bit_delay
  jmp rx_wait


; ──────────────────────────────────────────────
; bit_delay: Delay for full bit time
; ──────────────────────────────────────────────
bit_delay:
  phx
  ldx #13
bit_delay_1:
  dex
  bne bit_delay_1                             ; Loop until x is 0
  plx
  rts

; ──────────────────────────────────────────────
; half_bit_delay: Delay for half bit time
; ──────────────────────────────────────────────
half_bit_delay:
  phx
  ldx #6
half_bit_delay_1:
  dex
  bne half_bit_delay_1                        ; Loop until x is 0
  plx
  rts

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