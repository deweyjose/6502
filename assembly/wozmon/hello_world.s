  .org $1000
hello_world:
  jsr lcd_init
  jsr lcd_setup
 
  ldx #$00
print_loop:
  lda message, x
  beq halt
  jsr lcd_print_char
  inx
  jmp print_loop

halt:
  jmp $ff00

message: .asciiz "Hello, World!"

  .include lib/lcd.s