; ============================================================================
; LED BLINK PROGRAM - 6502 Breadboard Computer
; ============================================================================
; This program demonstrates basic I/O operations by blinking an LED connected
; to the 6502 breadboard computer. The LED is connected to the VIA (Versatile
; Interface Adapter) at address $6000.
;
; Hardware setup:
; - LED connected to VIA Port A (address $6000)
; - VIA Data Direction Register at $6002
; ============================================================================

  .org $8000

; ──────────────────────────────────────────────
; reset: Main program entry point
; ──────────────────────────────────────────────
reset:
  lda #$ff        ; Load $FF (all 1s) into accumulator
  sta $6002       ; Set VIA Port A data direction register to output
                  ; (1 = output, 0 = input for each bit)

  lda #$50        ; Load initial LED pattern ($50 = 01010000 binary)
  sta $6000       ; Store pattern to VIA Port A to turn on LED

; ──────────────────────────────────────────────
; loop: Main program loop - continuously blinks LED
; ──────────────────────────────────────────────
loop:
  ror             ; Rotate bits right (moves rightmost bit to leftmost)
                  ; This creates a shifting pattern effect
  sta $6000       ; Update VIA Port A with new pattern

  jmp loop        ; Jump back to loop (infinite loop)

; ──────────────────────────────────────────────
; Reset vector - tells 6502 where to start execution
; ──────────────────────────────────────────────
  .org $fffc
  .word reset     ; Reset vector points to our reset routine
  .word $0000     ; IRQ vector (not used in this program)