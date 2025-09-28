; ──────────────────────────────────────────────
; PS/2 Keyboard Demo
; Reads input from a PS/2 keyboard and displays characters
; and scancodes on the LCD using 6502 assembly.
; ──────────────────────────────────────────────

PORTA = $6001
DDRA = $6003
PCR = $600c
IFR = $600d
IER = $600e

kb_wptr = $0000
kb_rptr = $0001
kb_flags = $0002
display_mode = $0003 ; 0 = normal, 1 = hex

RELEASE = %00000001
SHIFT   = %00000010

kb_buffer = $0200       ; 256-byte kb buffer 0200-02ff
kb_raw_buffer = $0300   ; 256-byte raw buffer 0300-03ff

  .org $8000

; ──────────────────────────────────────────────
; Reset vector: program entry point
; ──────────────────────────────────────────────
reset:
  ldx #$ff
  txs

  ; Configure VIA for keyboard interrupt
  lda #$01
  sta PCR
  lda #$82
  sta IER
  cli
  
  lda #%00000000 ; Set all pins on port A to input
  sta DDRA

  jsr lcd_init
  jsr lcd_setup

  ldx #0
  lda #$00
  sta kb_flags
  sta kb_wptr
  sta kb_rptr
  sta display_mode

; ──────────────────────────────────────────────
; Main loop: Wait for key, print char and scancode
; ──────────────────────────────────────────────
loop:
  sei
  lda kb_rptr
  cmp kb_wptr
  cli
  bne key_pressed
  jmp loop

key_pressed:
  ldx kb_rptr
  lda kb_buffer, x  
  
  cmp #$0a           ; enter - go to second line
  beq enter_pressed
  cmp #$1b           ; escape - clear display
  beq esc_pressed
  cmp #$0b          ; backspace - move cursor left
  beq backspace_pressed

  lda kb_raw_buffer, x
  cmp #$05          ; toggle mode - toggle between char and hex
  beq toggle_mode

  lda display_mode
  beq char_mode
  
hex_mode:
  lda kb_raw_buffer, x
  jsr print_hex
  jmp key_pressed_end

char_mode:
  lda kb_buffer, x  
  jsr lcd_print_char
  jmp key_pressed_end
    
key_pressed_end:
  inc kb_rptr
  jmp loop

enter_pressed:
  ; TODO should only do this if we're on line 1.
  lda #%10101000 ; put cursor at position 40
  jsr lcd_instruction
  inc kb_rptr
  jmp loop

esc_pressed:
  lda #%00000001 ; Clear display
  jsr lcd_instruction
  inc kb_rptr
  jmp loop

backspace_pressed:
  lda #%00010000 ; move cursor left 0001 Shift(0) Right(0) 0 0
  jsr lcd_instruction
  lda #" "       ; clear the character
  jsr lcd_print_char
  lda #%00010000 ; put cursor at position 15
  jsr lcd_instruction
  inc kb_rptr
  jmp loop

toggle_mode:
  lda display_mode
  eor #01
  sta display_mode
  inc kb_rptr
  jmp loop

; ──────────────────────────────────────────────
; IRQ vector: Keyboard interrupt handler
; Handles key press, release, and shift state
; ──────────────────────────────────────────────
keyboard_interrupt:
  pha
  txa
  pha
  lda kb_flags
  and #RELEASE   ; check if we're releasing a key
  beq read_key   ; otherwise, read the key

  lda kb_flags
  eor #RELEASE   ; flip the releasing bit
  sta kb_flags
  lda PORTA      ; read key value that's being released
  cmp #$12       ; left shift
  beq shift_up
  cmp #$59       ; right shift
  beq shift_up
  jmp exit

shift_up:
  lda kb_flags
  eor #SHIFT  ; flip the shift bit
  sta kb_flags
  jmp exit

read_key:
  lda PORTA  
  cmp #$f0        ; if releasing a key
  beq key_release ; set the releasing bit  
  cmp #$12        ; left shift
  beq shift_down
  cmp #$59        ; right shift
  beq shift_down

  tax                     ; transfer scancode from a to x
  tay                     ; transfer scancode from a to y    
  lda kb_flags            ; load flags
  and #SHIFT              ; check if shift is pressed
  bne shifted_key         ; if so, map to shifted key

  lda keymap, x           ; map to character code  
  jmp push_key            

shifted_key:
  lda keymap_shifted, x   ; map to shift+character code

push_key:  
  ldx kb_wptr             ; load write pointer into x register
  sta kb_buffer, x        ; store the mapped char at index kb_wptr
  tya                     ; transfer scancode from y to a  
  sta kb_raw_buffer, x    ; store the raw scancode at index kb_wptr
  inc kb_wptr             ; increment the x register
  jmp exit                ; exit

shift_down:
  lda kb_flags
  ora #SHIFT
  sta kb_flags
  jmp exit

key_release:
  lda kb_flags
  ora #RELEASE
  sta kb_flags

exit:
  pla
  tax
  pla
  rti

; ──────────────────────────────────────────────
; print_hex: Print 2-digit hex value to LCD
; ──────────────────────────────────────────────
print_hex:  
  pha                 ; push a onto the stack
  lsr                 ; shift the high nibble into the low nibble
  lsr
  lsr
  lsr
  and #$0f            ; mask the high nibble
  tax                 ; tranfer a to x  
  lda HEX_TABLE, x    ; get the ascii value
  jsr lcd_print_char  ; lets print it

  pla                 ; restore the original value
  and #$0f            ; mask the low nibble  
  tax                 ; transfer to x
  lda HEX_TABLE, x    ; get the ascii value
  jsr lcd_print_char  ; lets print it
  rts

; ──────────────────────────────────────────────
; nmi: Non-maskable interrupt handler (unused)
; ──────────────────────────────────────────────
nmi:
  rti

  .include ../lib/lcd.s

  .org $fd00
keymap:
  .byte "????????????? `?" ; 00-0F
  .byte "?????q1???zsaw2?" ; 10-1F
  .byte "?cxde43?? vftr5?" ; 20-2F
  .byte "?nbhgy6???mju78?" ; 30-3F
  .byte "?,kio09??./l;p-?" ; 40-4F
  .byte "??'?[=????",$0a,"]?\??" ; 50-5F
  .byte "??????",$0b,"??1?47???" ; 60-6F
  .byte "0.2568",$1b,"??+3-*9??" ; 70-7F
  .byte "????????????????" ; 80-8F
  .byte "????????????????" ; 90-9F
  .byte "????????????????" ; A0-AF
  .byte "????????????????" ; B0-BF
  .byte "????????????????" ; C0-CF
  .byte "????????????????" ; D0-DF
  .byte "????????????????" ; E0-EF
  .byte "????????????????" ; F0-FF
keymap_shifted:
  .byte "????????????? ~?" ; 00-0F
  .byte "?????Q!???ZSAW@?" ; 10-1F
  .byte "?CXDE#$?? VFTR%?" ; 20-2F
  .byte "?NBHGY^???MJU&*?" ; 30-3F
  .byte "?<KIO)(??>?L:P_?" ; 40-4F
  .byte '??"?{+?????}?|??' ; 50-5F
  .byte "?????????1?47???" ; 60-6F
  .byte "0.2568???+3-*9??" ; 70-7F
  .byte "????????????????" ; 80-8F
  .byte "????????????????" ; 90-9F
  .byte "????????????????" ; A0-AF
  .byte "????????????????" ; B0-BF
  .byte "????????????????" ; C0-CF
  .byte "????????????????" ; D0-DF
  .byte "????????????????" ; E0-EF
  .byte "????????????????" ; F0-FF

HEX_TABLE:  .db "0123456789ABCDEF" 

; Reset/IRQ vectors
  .org $fffa
  .word nmi
  .word reset
  .word keyboard_interrupt