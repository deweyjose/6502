; ============================================================================
; PS/2 KEYBOARD INTERFACE - 6502 Breadboard Computer
; ============================================================================
; This program implements a full PS/2 keyboard interface with interrupt-driven
; input handling. It supports key press/release detection, shift key modifier,
; and special keys (Enter, Escape, Backspace). The program uses a circular
; buffer to store keypresses and displays both the typed characters and their
; raw scancodes on the LCD.
;
; Hardware requirements:
; - PS/2 keyboard connected to VIA Port A (clock and data lines)
; - 16x2 LCD display connected to VIA Port B
; - VIA configured for interrupts on Port A activity
;
; Memory layout:
; - $0000-$0002: Keyboard state variables (pointers and flags)
; - $0200-$02FF: Keyboard character buffer (256 bytes)
; - $0300-$03FF: Raw scancode buffer (256 bytes)
; - $8000-$FCFF: Program code
; - $FD00-$FEFF: Keyboard mapping tables
; - $FFFA-$FFFF: Interrupt vectors
; ============================================================================

; VIA (Versatile Interface Adapter) registers
PORTA = $6001       ; Port A data register (PS/2 keyboard data)
DDRA = $6003        ; Port A data direction register
PCR = $600c         ; Peripheral Control Register (interrupt config)
IFR = $600d         ; Interrupt Flag Register (interrupt status)
IER = $600e         ; Interrupt Enable Register (interrupt control)

; Keyboard state variables in zero page (fast access)
kb_wptr = $0000     ; Write pointer for circular buffer
kb_rptr = $0001     ; Read pointer for circular buffer
kb_flags = $0002    ; Keyboard state flags (shift, release, etc.)

; Keyboard state flag bits
RELEASE = %00000001 ; Bit 0: Set when processing key release
SHIFT   = %00000010 ; Bit 1: Set when shift key is pressed

; Keyboard buffers (256 bytes each for efficient circular buffering)
kb_buffer = $0200       ; 256-byte kb buffer 0200-02ff
kb_raw_buffer = $0300   ; 256-byte raw buffer 0300-03ff

  .org $8000

; ──────────────────────────────────────────────
; reset: Main program entry point and system initialization
; ──────────────────────────────────────────────
reset:
  ; Initialize stack pointer
  ldx #$ff
  txs

  ; Configure VIA for PS/2 keyboard interrupts
  lda #$01            ; Configure for positive edge interrupt
  sta PCR             ; Set Peripheral Control Register
  lda #$82            ; Enable CA1 interrupt (bit 7=1, bit 1=1)
  sta IER             ; Set Interrupt Enable Register
  cli                 ; Clear interrupt disable flag (enable interrupts)
  
  lda #%00000000      ; Set all pins on port A to input
  sta DDRA            ; Configure Port A for PS/2 input

  ; Initialize LCD display
  jsr lcd_init
  jsr lcd_setup

  ; Initialize keyboard state variables
  ldx #0
  lda #$00
  sta kb_flags        ; Clear all keyboard flags
  sta kb_wptr         ; Initialize write pointer
  sta kb_rptr         ; Initialize read pointer

; ──────────────────────────────────────────────
; loop: Main program loop - processes keyboard input
; ──────────────────────────────────────────────
loop:
  ; Check if there are characters in the keyboard buffer
  sei                 ; Disable interrupts while checking pointers
  lda kb_rptr         ; Load read pointer
  cmp kb_wptr         ; Compare with write pointer
  cli                 ; Re-enable interrupts
  bne key_pressed     ; If pointers differ, we have a key to process
  jmp loop            ; Otherwise, keep waiting

; ──────────────────────────────────────────────
; key_pressed: Process a key from the keyboard buffer
; ──────────────────────────────────────────────
key_pressed:
  ldx kb_rptr         ; Load read pointer as index
  lda kb_buffer, x    ; Get character from buffer
  
  ; Check for special keys
  cmp #$0a           ; enter - go to second line
  beq enter_pressed
  cmp #$1b           ; escape - clear display
  beq esc_pressed
  cmp #$0b           ; backspace
  beq backspace_pressed
  
  ; Regular character - print it
  jsr lcd_print_char
  
  ; Also display the raw scancode for debugging
  lda kb_raw_buffer, x
  jsr print_hex
  
  inc kb_rptr         ; Move to next character in buffer
  jmp loop

; ──────────────────────────────────────────────
; Special key handlers
; ──────────────────────────────────────────────
enter_pressed:
  ; TODO should only do this if we're on line 1.
  lda #%10101000      ; put cursor at position 40 (second line)
  jsr lcd_instruction
  inc kb_rptr
  jmp loop

esc_pressed:
  lda #%00000001      ; Clear display
  jsr lcd_instruction
  inc kb_rptr
  jmp loop

backspace_pressed:
  lda #%00010000      ; move cursor left
  jsr lcd_instruction
  lda #" "            ; clear the character
  jsr lcd_print_char
  lda #%00010000      ; move cursor left again
  jsr lcd_instruction
  inc kb_rptr
  jmp loop

home_pressed:
  lda #%10000000      ; put cursor at position 0
  jsr lcd_instruction
  inc kb_rptr
  jmp loop

; ──────────────────────────────────────────────
; keyboard_interrupt: PS/2 keyboard interrupt handler
; This routine is called whenever the PS/2 keyboard sends data
; ──────────────────────────────────────────────
keyboard_interrupt:
  ; Save processor state
  pha                 ; Save accumulator
  txa                 ; Transfer X to accumulator
  pha                 ; Save X register
  
  ; Check if we're processing a key release
  lda kb_flags
  and #RELEASE        ; check if we're releasing a key
  beq read_key        ; otherwise, read the key

  ; Handle key release
  lda kb_flags
  eor #RELEASE        ; flip the releasing bit
  sta kb_flags
  lda PORTA           ; read key value that's being released
  cmp #$12            ; left shift
  beq shift_up
  cmp #$59            ; right shift
  beq shift_up
  jmp exit

shift_up:
  lda kb_flags
  eor #SHIFT          ; flip the shift bit
  sta kb_flags
  jmp exit

; ──────────────────────────────────────────────
; read_key: Process a key press
; ──────────────────────────────────────────────
read_key:
  lda PORTA           ; Read scancode from PS/2 keyboard
  cmp #$f0            ; Check for key release prefix
  beq key_release     ; set the releasing bit  
  cmp #$12            ; left shift
  beq shift_down
  cmp #$59            ; right shift
  beq shift_down

  ; Normal key press - convert scancode to character
  tax                 ; transfer scancode from a to x
  tay                 ; transfer scancode from a to y (for raw buffer)
  lda kb_flags        ; load flags
  and #SHIFT          ; check if shift is pressed
  bne shifted_key     ; if so, map to shifted key

  lda keymap, x       ; map to character code  
  jmp push_key            

shifted_key:
  lda keymap_shifted, x   ; map to shift+character code

; ──────────────────────────────────────────────
; push_key: Add character to keyboard buffer
; ──────────────────────────────────────────────
push_key:  
  ldx kb_wptr         ; load write pointer into x register
  sta kb_buffer, x    ; store the mapped char at index kb_wptr
  tya                 ; transfer scancode from y to a  
  sta kb_raw_buffer, x ; store the raw scancode at index kb_wptr
  inc kb_wptr         ; increment the write pointer
  jmp exit            ; exit interrupt handler

shift_down:
  lda kb_flags
  ora #SHIFT          ; set shift flag
  sta kb_flags
  jmp exit

key_release:
  lda kb_flags
  ora #RELEASE        ; set release flag
  sta kb_flags

exit:
  ; Restore processor state
  pla                 ; Restore X register
  tax
  pla                 ; Restore accumulator
  rti                 ; Return from interrupt

; ──────────────────────────────────────────────
; print_hex: Print a byte as two hex digits
; Input: A register contains byte to print
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

; Include LCD library functions
 .include lib/lcd.s

; ──────────────────────────────────────────────
; PS/2 Keyboard Mapping Tables
; These tables convert PS/2 scancodes to ASCII characters
; ──────────────────────────────────────────────
  .org $fd00

; Standard keymap (no shift pressed)
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

; Shifted keymap (shift key pressed)
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

; Hex conversion table for displaying scancodes
HEX_TABLE:  .db "0123456789ABCDEF" 

; ──────────────────────────────────────────────
; Interrupt Vector Table
; ──────────────────────────────────────────────
  .org $fffa
  .word nmi                 ; Non-maskable interrupt vector
  .word reset               ; Reset vector (program start)
  .word keyboard_interrupt  ; IRQ vector (keyboard interrupt)