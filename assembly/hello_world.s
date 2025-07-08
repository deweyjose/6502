; ============================================================================
; HELLO WORLD PROGRAM - 6502 Breadboard Computer
; ============================================================================
; This is a simple "Hello World" program that demonstrates basic LCD output
; functionality on the 6502 breadboard computer. It initializes the LCD
; display and prints a banner message.
;
; Hardware requirements:
; - 16x2 LCD display connected to VIA Port B
; - LCD initialization and control functions from lcd.s library
; ============================================================================

  .include lib/lcd.s

  .org $8000

; ──────────────────────────────────────────────
; reset: Main program entry point
; ──────────────────────────────────────────────
reset:
  jsr lcd_setup      ; Initialize LCD display and configure settings

  ldx #0             ; Initialize X register as character index
  
; ──────────────────────────────────────────────
; print_banner: Loop to print each character of the banner
; ──────────────────────────────────────────────
print_banner:
  lda banner, x      ; Load character from banner string at index X
  beq loop          ; If character is 0 (null terminator), exit loop
  jsr lcd_print_char ; Print the character to LCD
  inx               ; Increment index to next character
  jmp print_banner  ; Continue with next character

; ──────────────────────────────────────────────
; loop: Infinite loop - program stays here after printing banner
; ──────────────────────────────────────────────
loop:
  jmp loop          ; Stay in infinite loop (program complete)

; ──────────────────────────────────────────────
; Data section: Banner text to be displayed
; ──────────────────────────────────────────────
banner: .asciiz "Dewey Jose 2023"  ; Null-terminated string

; ──────────────────────────────────────────────
; Reset vector - tells 6502 where to start execution
; ──────────────────────────────────────────────
  .org $fffc
  .word reset       ; Reset vector points to our reset routine
  .word $0000       ; IRQ vector (not used in this program)
