; ──────────────────────────────────────────────
; LCD MANAGEMENT UTILITIES (for 6502 projects)
; Provides routines to initialize, configure, and control a 4-bit parallel LCD
; display using VIA port B. Designed for reuse in multiple 6502 projects.
; 
; Exposes:
;   lcd_init         - Run LCD hardware init sequence (8-bit to 4-bit mode)
;   lcd_setup        - Configure display (lines, font, cursor, clear)
;   lcd_wait         - Wait for LCD to be ready (busy flag)
;   lcd_instruction  - Send instruction byte to LCD
;   lcd_print_char   - Print a character to the LCD
;   lcd_home         - Move cursor to home position
; 
; Hardware:
;   PORTB = $6000    - VIA port B (data pins)
;   DDRB  = $6002    - VIA data direction register for port B
;   E, RW, RS        - LCD control bits
; ──────────────────────────────────────────────

PORTB = $6000    ; first 8 bits of PORTB (data pins)
DDRB = $6002     ; data direction register for PORTB (data pins)

E  = %01000000   ; Enable bit (LCD: latch data on high-to-low transition)
RW = %00100000   ; Read/Write bit (LCD: 0=write, 1=read)
RS = %00010000   ; Register Select bit (LCD: 0=instruction, 1=data)

; ──────────────────────────────────────────────
; lcd_init: Initialize LCD and set 4-bit mode
; Follows the standard LCD power-on sequence:
;   - Set 8-bit mode 3x, then switch to 4-bit mode
; ──────────────────────────────────────────────
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

; ──────────────────────────────────────────────
; lcd_setup: Configure LCD display settings
; Sets 4-bit mode, 2-line display, font, cursor, and clears display
; ──────────────────────────────────────────────
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

; ──────────────────────────────────────────────
; lcd_wait: Wait for LCD to be ready (busy flag)
; Reads busy flag by switching PORTB to input, polling, then restoring output
; ──────────────────────────────────────────────
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

; ──────────────────────────────────────────────
; lcd_instruction: Send instruction byte to LCD
; Splits byte into high and low nibbles for 4-bit mode
; ──────────────────────────────────────────────
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

; ──────────────────────────────────────────────
; lcd_print_char: Print a character to the LCD
; Splits byte into nibbles, sets RS for data
; ──────────────────────────────────────────────
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

; ──────────────────────────────────────────────
; lcd_home: Move cursor to home position
; ──────────────────────────────────────────────
lcd_home:
  lda #%00000010      ; Move cursor to home position.
  jsr lcd_instruction
  rts