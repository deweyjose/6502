# RS-232 Serial Keyboard Demo 📡

> **Type over the wire!** Connect a serial terminal to your 6502 and watch as every character you type appears on the LCD.

**📁 [View Source Code](../assembly/keyboard/main_rs2.s)**

## 🎯 What It Does

This project turns your breadboard 6502 into a **serial terminal** using RS-232 communication! You can:

- **Receive characters** from a PC or terminal over RS-232
- **Display received characters** on the LCD in real-time
- **Test transmission** with a simple '*' character on startup
- **Handle full RS-232 protocol** using bit-banging techniques
- **Connect to any serial device** (PC, Raspberry Pi, etc.)

All implemented using **software timing** and the VIA's GPIO pins - no UART chip required!

## 🔧 How It Works

### The RS-232 Protocol

RS-232 is a serial communication standard that sends data one bit at a time:
- **Start bit**: Always 0 (LOW)
- **Data bits**: 8 bits of actual data (LSB first)
- **Stop bit**: Always 1 (HIGH)
- **Baud rate**: 9600 bps (104µs per bit)

### Bit-Banging Implementation

Since we don't have a UART chip, we implement the protocol in software using precise timing loops. The code includes a test transmission of '*' character, but the main focus is **receiving** data:

```assembly
; Test transmission: Send '*' character on startup
lda #"*"                    ; Load test character
sta $0200                   ; Store for bit shifting

lda #$01                    ; Prepare to clear bit 0 (TX pin)
trb PORTA                   ; Clear bit 0 (start bit)

ldx #8                      ; Bit counter for 8 data bits
write_bit:
  jsr bit_delay            ; Wait full bit time
  ror $0200                ; Rotate character right, carry gets next bit
  bcs send_1               ; If carry set, send 1
  trb PORTA                ; Clear bit 0 (send 0)
  jmp tx_done
send_1:
  tsb PORTA                ; Set bit 0 (send 1)
tx_done:
  dex                      ; Decrement bit counter
  bne write_bit            ; Continue until all 8 bits sent
```

### Precise Timing

The key to successful RS-232 communication is **precise timing**. Our bit delay routine provides exactly 104µs per bit:

```assembly
bit_delay:
  phx
  ldx #13                  ; Calibrated for 9600 baud
bit_delay_1:
  dex
  bne bit_delay_1          ; Loop until x is 0
  plx
  rts
```

### Receiving Data

The receive routine waits for the start bit, then samples each data bit:

```assembly
rx_wait:
  bit PORTA                ; Check for start bit (LOW)
  bvs rx_wait              ; Wait for start bit

  jsr half_bit_delay       ; Wait half bit time for center sampling

  ldx #8
read_bit:
  jsr bit_delay            ; Wait full bit time
  
  ; Sample the bit and set carry flag
  bit PORTA
  bvs recv_1               ; If overflow flag set, we're receiving a 1
  clc                      ; Clear carry bit to 0
  jmp recv_done
recv_1:
  nop 
  nop 
  sec                      ; Set carry bit to 1
recv_done:
  ror                      ; Rotate carry into accumulator
  dex
  bne read_bit
```

### Half-Bit Delay for Sampling

To sample bits in the center (most reliable), we use a half-bit delay:

```assembly
half_bit_delay:
  phx
  ldx #6                   ; Half of the full bit delay
half_bit_delay_1:
  dex
  bne half_bit_delay_1
  plx
  rts
```

## 🎨 The Complete System

### Initialization

```assembly
reset:
  ldx #$ff
  txs

  ; Set all pins on Port B to Output
  lda #%11111111
  sta DDRB
  ; Set bit 6 of DDRA as input (RS-232 RX), others as output
  lda #%10111111
  sta DDRA
  
  jsr lcd_init
  jsr lcd_setup
```

### Test Transmission

The program starts by sending a test character to verify transmission:

```assembly
; Test RS-232 transmission: Send '*' character
lda #1
sta PORTA                  ; Set start bit (LOW)

lda #"*"                   ; Load test character '*'
sta $0200                  ; Store character in memory for bit shifting

; ... bit-banging transmission code ...
```

### Main Loop

The main loop continuously waits for incoming data and displays it on the LCD:

```assembly
rx_wait:
  bit PORTA                ; Wait for start bit
  bvs rx_wait

  jsr half_bit_delay       ; Wait half bit time for center sampling

  ldx #8
read_bit:
  jsr bit_delay            ; Wait full bit time
  
  ; Sample the bit and set carry flag
  bit PORTA
  bvs recv_1               ; If overflow flag set, we're receiving a 1
  clc                      ; Clear carry bit to 0
  jmp recv_done
recv_1:
  nop 
  nop 
  sec                      ; Set carry bit to 1
recv_done:
  ror                      ; Rotate carry into accumulator
  dex
  bne read_bit

  jsr lcd_print_char       ; Display received character
  jsr bit_delay
  jmp rx_wait              ; Loop forever
```

## 🚀 Key Features

- **Pure Software Implementation**: No UART chip required
- **Precise Timing**: Software-based bit timing for 9600 baud
- **Real-time Display**: Shows received characters on LCD as you type
- **Test Transmission**: Sends '*' character on startup to verify TX
- **Robust Protocol**: Proper start/stop bit handling
- **Serial Terminal**: Turn your 6502 into a serial display terminal

## 🎓 What You'll Learn

- **Serial Communication**: Understanding RS-232 protocol
- **Bit-Banging**: Implementing protocols in software
- **Precise Timing**: Critical timing in embedded systems
- **GPIO Programming**: Using VIA pins for communication
- **Protocol Implementation**: Building communication layers
- **Real-time Systems**: Handling time-critical operations

## 🔍 Technical Details

- **Baud Rate**: 9600 bps (104µs per bit)
- **Data Format**: 8 data bits, 1 start bit, 1 stop bit
- **Timing Accuracy**: Software loops calibrated for 1MHz 6502
- **GPIO Usage**: Port A bit 0 (TX), bit 6 (RX)
- **Memory Usage**: ~200 bytes of code
- **Compatibility**: Works with any RS-232 device

## 🎉 The Result

When you run this on your breadboard computer:

1. **Sends '*' character** on startup to test transmission
2. **Waits for incoming data** from your PC or terminal
3. **Displays received characters** on the LCD as you type them
4. **Creates a serial terminal** that shows everything you type
5. **Proves your 6502 can communicate** with the outside world!

## 🔧 Hardware Connection

The RS-232 interface uses the VIA's Port A:
- **TX (Transmit)**: VIA Port A, bit 0
- **RX (Receive)**: VIA Port A, bit 6
- **Ground**: Common ground
- **Level Shifting**: May need MAX232 or similar for PC connection

## 🎯 Why Bit-Banging?

While UART chips make serial communication easier, bit-banging teaches you:
- **How protocols work** at the bit level
- **Timing precision** required in embedded systems
- **GPIO programming** techniques
- **Real-time programming** concepts
- **The fundamentals** that UART chips hide

## 🔍 Debugging Tips

- **Check timing**: Verify bit delays are accurate
- **Monitor signals**: Use oscilloscope to see bit patterns
- **Test with known data**: Send predictable patterns
- **Verify connections**: Ensure proper wiring
- **Check baud rate**: Match sender and receiver

---

*"Communication is the key to success." - Anonymous*

*Even for 6502s! 📡*
