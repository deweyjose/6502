; LCD MANAGEMENT CODE

PORTB = $6000 ; first 8 bits
PORTA = $6001 ; last  8 bits

DDRB = $6002 ; data direction register for PORTB
DDRA = $6003 ; data direction register for PORTA

E  = %10000000
RW = %01000000
RS = %00100000

  .org $8000

reset:
  ldx #$ff
  txs

  ; initialize the IO interface chip
  
  lda #%11111111    ; set all pins on PORTB to output   
  sta DDRB

  lda #%11100000    ; set top 3  pins on PORTA to output
  sta DDRA

  lda #%00111000     ; set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction

  lda #%00001110     ; display on; cursor on; blink off 
  jsr lcd_instruction

  lda #%00000110     ; increment and shift cursor; don't shift display 
  jsr lcd_instruction
  
  lda #%00000001     ; clear screen
  jsr lcd_instruction

  ldx #0
print:
  lda message, x
  beq loop
  jsr print_char
  inx
  jmp print

loop:
  jmp loop

message: .asciiz "   Dewey Jose                                Hello 2023!"

lcd_wait:
  pha
  lda #%00000000 ; PORT B is input
  sta DDRB
lcd_busy:
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB
  and #%10000000
  bne lcd_busy
 
  lda #RW
  sta PORTA
  lda #%11111111    ; set all pins on PORTB to output   
  sta DDRB
  pla
  rts

lcd_instruction:
  jsr lcd_wait

  sta PORTB         ; store what ever was lda'd
  ; ------------------------------------------------
  ; next 3 commands tells the display to interface
  ; accept the instruction sitting on the data pins.

  lda #0           ; clear RS/RW/E bits
  sta PORTA
  lda #E           ; set E bit to send instruction
  sta PORTA
  lda #0           ; clear RS/RW/E bits
  sta PORTA
  rts

print_char:
  jsr lcd_wait

  sta PORTB
  lda #RS           ; set RS, clear RW/E bits
  sta PORTA
  lda #(RS | E)     ; set RS and E, clear RW bits 
  sta PORTA
  lda #RS           ; set RS, clear RW/E bits
  sta PORTA
  rts

  .org $fffc
  .word reset
  .word $0000
