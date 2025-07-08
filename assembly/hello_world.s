; ──────────────────────────────────────────────
; Hello World Demo
; Displays a banner message on the LCD using 6502 assembly
; ──────────────────────────────────────────────

.include lib/lcd.s

  .org $8000

; ──────────────────────────────────────────────
; Reset vector: program entry point
; ──────────────────────────────────────────────
reset:
  jsr lcd_setup         ; Initialize and configure the LCD

  ldx #0                ; Start at first character of banner
print_banner:
  lda banner, x         ; Load character from banner string
  beq loop              ; If null terminator, done
  jsr lcd_print_char    ; Print character to LCD
  inx
  jmp print_banner      ; Repeat for next character

; ──────────────────────────────────────────────
; Infinite loop (end of program)
; ──────────────────────────────────────────────
loop:
  jmp loop

banner: .asciiz "Dewey Jose 2023" ; Message to display

  .org $fffc
  .word reset
  .word $0000
