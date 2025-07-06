; LCD MANAGEMENT CODE

PORTB = $6000     ; first 8 bits
DDRB = $6002      ; data direction register for PORTB

E  = %01000000
RW = %00100000
RS = %00010000

lcd_init:  
  lda #%11111111  ; set all pins on PORTB to output   
  sta DDRB
  lda #%00000011  ; 1st Set 8-bit mode
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB
  lda #%00000011  ; 2nd Set 8-bit mode
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB
  lda #%00000011  ; 3rd Set 8-bit mode
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB
  lda #%00000010  ; Set 4-bit mode
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB
  rts

lcd_setup:
  lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction  
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #%00000001 ; Clear display
  jsr lcd_instruction
  rts

lcd_wait:
  pha
  lda #%11110000  ; LCD data is input
  sta DDRB
lcd_busy:
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read high nibble
  pha             ; and put on stack since it has the busy flag
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read low nibble
  pla             ; Get high nibble off stack
  and #%00001000
  bne lcd_busy
  lda #RW
  sta PORTB
  lda #%11111111  ; LCD data is output
  sta DDRB
  pla
  rts

lcd_instruction:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr            ; Send high 4 bits
  sta PORTB
  ora #E         ; Set E bit to send instruction
  sta PORTB
  eor #E         ; Clear E bit
  sta PORTB
  pla
  and #%00001111 ; Send low 4 bits
  sta PORTB
  ora #E         ; Set E bit to send instruction
  sta PORTB
  eor #E         ; Clear E bit
  sta PORTB
  rts

lcd_print_char:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr             ; Send high 4 bits
  ora #RS         ; Set RS
  sta PORTB
  ora #E          ; Set E bit to send instruction
  sta PORTB
  eor #E          ; Clear E bit
  sta PORTB
  pla
  and #%00001111  ; Send low 4 bits
  ora #RS         ; Set RS
  sta PORTB
  ora #E          ; Set E bit to send instruction
  sta PORTB
  eor #E          ; Clear E bit
  sta PORTB
  rts

lcd_home:
  lda #%00000010      ; Move cursor to home position.
  jsr lcd_instruction
  rts