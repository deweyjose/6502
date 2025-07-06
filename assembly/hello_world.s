
  .org $8000

reset:
  jsr lcd_setup

  ldx #0
print_banner:
  lda banner, x
  beq loop
  jsr lcd_print_char
  inx
  jmp print_banner


loop:
  jmp loop

banner: .asciiz "Dewey Jose 2023"

  .include lcd.s

  .org $fffc
  .word reset
  .word $0000
