; ──────────────────────────────────────────────
; Blink Demo
; Toggles an output pin to blink an LED (or similar device)
; on a 6502 breadboard computer using VIA port B.
; ──────────────────────────────────────────────

  .org $8000

; ──────────────────────────────────────────────
; Reset vector: program entry point
; ──────────────────────────────────────────────
reset:
  lda #$ff            ; Set all pins on VIA port B to output
  sta $6002           ; $6002 = DDRB (Data Direction Register B)

  lda #$50            ; Initial value to output (arbitrary pattern)
  sta $6000           ; $6000 = PORTB (Output register)

; ──────────────────────────────────────────────
; Main loop: repeatedly rotates and outputs value
; This will toggle the output pins, blinking an LED
; if connected to the appropriate pin on port B.
; ──────────────────────────────────────────────
loop:
  ror                 ; Rotate right (affects A)
  sta $6000           ; Output new value to port B

  jmp loop            ; Repeat forever

; ──────────────────────────────────────────────
; Vectors
; ──────────────────────────────────────────────
  .org $fffc
  .word reset
  .word $0000