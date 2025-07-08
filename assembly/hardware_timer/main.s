; ──────────────────────────────────────────────
; Hardware Timer Demo
; Uses VIA hardware timer to increment a counter
; and display its value on the LCD using 6502 assembly
; and blink an LED on port A.
; ──────────────────────────────────────────────

PORTA = $6001         ; VIA Port A (LED output)
DDRA = $6003          ; VIA Data Direction Register A
T1CL = $6004          ; VIA Timer 1 Counter Low
T1CH = $6005          ; VIA Timer 1 Counter High
ACR  = $600B          ; VIA Auxiliary Control Register
IFR  = $600D          ; VIA Interrupt Flag Register
IER  = $600E          ; VIA Interrupt Enable Register

ticks = $10           ; 4-byte tick counter (incremented by timer IRQ)
toggle_time = $14     ; Last tick value when LED was toggled
lcd_time = $15        ; Last tick value when LCD was updated

  .org $8000

; ──────────────────────────────────────────────
; Reset vector: program entry point
; Sets up Port A, clears outputs, and starts the timer
; ──────────────────────────────────────────────
reset:
  lda #%11111111      ; Set all Port A pins to output
  sta DDRA
  lda #0
  sta PORTA           ; Turn off all Port A outputs (LEDs off)
  sta toggle_time     ; Initialize toggle_time
  sta lcd_time        ; Initialize lcd_time
  jsr lcd_init        ; Initialize LCD
  jsr lcd_setup       ; Configure LCD
  jsr init_timer      ; Set up VIA Timer 1 and enable interrupts
  
loop:
  jsr update_led
  jsr update_lcd
  jmp loop

; ──────────────────────────────────────────────
; update_led: Wait for 250 ms, then toggle LED
; Uses ticks (incremented by timer IRQ) to measure time
; ──────────────────────────────────────────────
update_led:
  sec
  lda ticks
  sbc toggle_time
  cmp #25             ; Have 250 ms elapsed? (25 x 10ms ticks)
  bcc exit_update_led ; If not, keep waiting
  lda #$01
  eor PORTA           ; Toggle LED on Port A, bit 0
  sta PORTA
  lda ticks
  sta toggle_time     ; Update last toggle time
exit_update_led:
  rts

; ──────────────────────────────────────────────
; update_lcd: Every 1 second, display tick count on LCD
; Converts the first 16 bits of ticks to decimal and prints
; ──────────────────────────────────────────────
update_lcd:
  sec
  lda ticks
  sbc lcd_time
  cmp #200            ; Has 2 second elapsed? (200 x 10ms ticks)
  bcc exit_update_lcd
  lda ticks
  sta lcd_time        ; Update last LCD update time

  ; Print tick count (16 bits) to LCD
  jsr lcd_home
  lda ticks           ; Low byte
  ldx ticks + 1       ; High byte
  jsr lcd_print_num   ; Use the new lcd_print_num routine

exit_update_lcd:
  rts

; ──────────────────────────────────────────────
; init_timer: Configure VIA Timer 1 for periodic interrupts
; Sets up timer for ~10ms interval and enables IRQ
; ──────────────────────────────────────────────
init_timer:
  lda #%00000000
  sta ticks 
  sta ticks + 1
  sta ticks + 2
  sta ticks + 3
  lda #%01000000      ; Timer 1 free-run mode (ACR bit 6)
  sta ACR
  lda #$0e
  sta T1CL            ; Timer 1 low byte (adjust for timing)
  lda #$27
  sta T1CH            ; Timer 1 high byte (adjust for timing)
  lda #%11000000      ; Enable Timer 1 interrupt (IER bit 7=1, bit 6=1)
  sta IER
  cli
  rts

; ──────────────────────────────────────────────
; irq: Timer 1 interrupt handler
; Increments the 4-byte tick counter
; ──────────────────────────────────────────────
irq:
  bit T1CL            ; Acknowledge interrupt by reading T1CL
  inc ticks
  bne end_irq
  inc ticks + 1
  bne end_irq
  inc ticks + 2
  bne end_irq
  inc ticks + 3
end_irq:
  rti

  .include lib/lcd.s

  .org $fffc
  .word reset
  .word irq