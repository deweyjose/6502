temp = $00

  .org $8000

reset:
  lda #$00
  sta $5001        ; reset ACIA

  lda #$1E
  sta $5003        ; control: 9600, 8N1

  lda #$0B
  sta $5002        ; command: TX/RX enable, no echo, no ints

loop:
  lda $5001        ; status
  jsr print_byte_binary
  lda #'X'
  jsr lcd_print_char
  jmp loop

print_byte_binary:
  pha              ; save original A
  ldy #8           ; 8 bits to process

  pla              ; pull original A into A
  sta temp         ; stash working copy in zero page

loop2:
  lda temp         ; load working copy
  and #%00000001   ; mask bit 0
  beq print0
  lda #'1'
  jsr lcd_print_char
  jmp shift
print0:
  lda #'0'
  jsr lcd_print_char
shift:
  lda temp
  lsr              ; shift right
  sta temp
  dey
  bne loop2
  rts
nmi:
  rti

irq:
  rti

  .include lib/lcd.s
  .org $fffa
  .word nmi
  .word reset
  .word irq
