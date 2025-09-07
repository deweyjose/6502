# RS-232 UART Serial Interface 🔌

> **Professional serial communication!** Add a real UART chip to your 6502 and experience rock-solid RS-232 communication with proper hardware flow control.

**📁 [View Source Code](../assembly/keyboard/main_rs2_uart.s)**

## 🎯 What It Does

This project brings **professional-grade serial communication** to your breadboard 6502 using the W65C51S ACIA (Asynchronous Communications Interface Adapter)! You can now:

- **Receive characters** from any RS-232 terminal or PC
- **Echo characters back** with proper terminal compatibility
- **Handle special keys** like backspace with correct terminal behavior
- **Use hardware flow control** for reliable data transmission
- **Debug in real-time** with bidirectional character echo
- **Connect to any serial device** with industry-standard RS-232

All powered by a dedicated UART chip handling the complex protocol details!

## 🔧 How It Works

### The W65C51S ACIA Magic

The W65C51S ACIA is a dedicated UART chip that handles all the RS-232 protocol complexity:

```assembly
; Initialize the ACIA
lda #$00
sta ACIA_STATUS     ; Soft reset the ACIA

lda #$1f            ; 8 data bits, no parity, 1 stop bit, 19200 baud
sta ACIA_CTRL

lda #$0b            ; No parity, no echo, no interrupt
sta ACIA_CMD
```

### Hardware Flow Control

The ACIA provides built-in status checking for reliable communication:

```assembly
rx_wait:
  lda ACIA_STATUS
  and #$08          ; Check if data is available (bit 3)
  beq rx_wait       ; Wait until data arrives

  lda ACIA_DATA     ; Read the character
  jsr lcd_print_char ; Display on LCD
  jsr send_char     ; Echo back to terminal
  jmp rx_wait
```

### Transmission with Flow Control

The `send_char` function uses hardware flow control to ensure reliable transmission:

```assembly
send_char:
  sta ACIA_DATA     ; Put character in transmit buffer
  pha
tx_wait:
  lda ACIA_STATUS
  and #$10          ; Check if transmitter is ready (bit 4)
  beq tx_wait       ; Wait until ready
  jsr tx_delay      ; Small delay for reliability
  pla
  rts
```

### Special Key Handling

The system provides proper terminal behavior for special keys:

```assembly
cmp #$7F            ; Check for DEL character
beq del_key

del_key:
  pha
  lda #$08          ; Send backspace to terminal
  jsr send_char
  lda #' '          ; Send space to overwrite
  jsr send_char
  lda #$08          ; Send backspace again
  jsr send_char
  pla
  jsr lcd_backspace ; Handle LCD side
  jmp rx_wait
```

## 🎨 The Hardware Setup

### ACIA Configuration

The W65C51S ACIA handles all RS-232 protocol details:

- **Baud Rate**: 19,200 (configurable via ACIA_CTRL)
- **Data Format**: 8 data bits, no parity, 1 stop bit
- **Flow Control**: Hardware status checking
- **Voltage Levels**: TTL (0V/5V) - requires MAX232 for RS-232 conversion

### MAX232 Level Shifting

Since RS-232 uses ±12V levels and our 6502 uses 5V TTL, we need a MAX232 chip:

```
PC Terminal ←→ MAX232 ←→ W65C51S ACIA ←→ 6502
   ±12V         TTL         TTL          5V
```

### Pin Connections

The ACIA connects to the 6502 through address decoding:

```
ACIA Pin 13 (RXD) ←→ VIA Output (receives data from terminal)
ACIA Pin 14 (TXD) ←→ VIA Input  (sends data to terminal)
ACIA Pin 10 (CTS) ←→ MAX232     (flow control)
ACIA Pin 12 (DCD) ←→ MAX232     (data carrier detect)
```

## 🐛 The Hardware Bug Adventure

### The Mystery: Why Won't It Work?

Getting the UART working perfectly was a **real adventure**! We encountered several mysterious issues:

1. **Characters appearing garbled** on the LCD
2. **Transmission working but reception failing**
3. **Intermittent communication** that would work sometimes
4. **LCD display corruption** during serial communication

### The Debugging Journey

We went through extensive debugging to isolate the problems:

#### 1. Software Debugging
```assembly
; Added binary display to see what we were actually receiving
print_byte_binary:
  pha              ; save original A
  ldy #8           ; 8 bits to process
  sta temp         ; stash working copy in zero page
  ; ... binary display code ...
```

#### 2. LCD Library Bug Fixes
We discovered and fixed several bugs in our LCD library:

**Problem**: The `lcd_print_char` function was corrupting the A register:
```assembly
; BUGGY VERSION - A gets corrupted by ora instructions
lcd_print_char:
  pha
  jsr lcd_wait
  pla
  pha
  lsr
  lsr
  lsr
  lsr             ; Send high 4 bits
  ora #RS         ; A is now modified!
  sta PORTB
  ; ... more ora operations that corrupt A ...
  pla             ; This doesn't restore the original A!
  rts
```

**Solution**: Proper register preservation:
```assembly
; FIXED VERSION - A is properly preserved
lcd_print_char:
  pha             ; Save original A
  jsr lcd_wait
  pla             ; Get original back
  pha             ; Save it again
  lsr
  lsr
  lsr
  lsr             ; Send high 4 bits
  ora #RS         ; A is modified, but we have original on stack
  sta PORTB
  ; ... process high nibble ...
  pla             ; Get original character back
  pha             ; Save it again for after the function
  and #%00001111  ; Send low 4 bits
  ora #RS         ; A is modified again
  sta PORTB
  ; ... process low nibble ...
  pla             ; Restore original A
  rts
```

#### 3. The Hardware Culprit: Wrong Capacitor!

After extensive software debugging, we discovered the **real problem**:

**The Issue**: The kit included a **50nF capacitor** when it should have been a **30pF capacitor**!

**Why This Matters**:
- The capacitor is used in the MAX232's internal oscillator circuit
- Wrong capacitance = wrong oscillator frequency
- Wrong frequency = incorrect baud rate generation
- Incorrect baud rate = garbled communication

**The Fix**: Replace the 50nF capacitor with the correct 30pF capacitor.

### The Learning Experience

This debugging adventure taught us valuable lessons:

1. **Hardware issues can masquerade as software bugs**
2. **Always verify component values** match the schematic
3. **Systematic debugging** is essential for complex systems
4. **Library functions must be well-behaved** (preserve registers)
5. **Sometimes the problem is in the parts bin, not the code!**

## 🚀 Key Features

- **Hardware UART**: Dedicated chip handles all protocol details
- **Bidirectional Communication**: Send and receive simultaneously
- **Real-time Echo**: See what you type on both LCD and terminal
- **Special Key Support**: Proper backspace handling with terminal compatibility
- **Hardware Flow Control**: Uses ACIA's built-in status checking
- **Robust Communication**: Handles timing and protocol automatically
- **Debug Friendly**: Easy to see data flow in both directions

## 🎓 What You'll Learn

- **UART Programming**: Configuring asynchronous communication adapters
- **Hardware Debugging**: Systematic approach to hardware/software issues
- **Level Shifting**: Converting between voltage standards
- **Flow Control**: Managing data transmission timing
- **Library Design**: Writing well-behaved assembly routines
- **Component Verification**: Importance of correct component values
- **System Integration**: Connecting multiple chips together

## 🔍 Technical Details

- **Protocol**: RS-232 asynchronous serial
- **Baud Rate**: 19,200 (configurable)
- **Data Format**: 8N1 (8 data bits, no parity, 1 stop bit)
- **Flow Control**: Hardware status checking
- **Buffer Size**: Single character (ACIA handles buffering)
- **Response Time**: < 1ms for character echo
- **Memory Usage**: ~300 bytes of code
- **Compatibility**: Works with any RS-232 terminal

## 🎉 The Result

When you connect your 6502 to a computer terminal:

1. **Type on the terminal** and see characters appear on the LCD
2. **Characters echo back** to the terminal as you type
3. **Use backspace** and watch it work on both displays
4. **Experience rock-solid communication** between your 6502 and computer
5. **Feel the satisfaction** of debugging hardware issues and making it work!

## 🔧 Hardware Requirements

The UART interface requires:

- **W65C51S ACIA**: Handles RS-232 protocol
- **MAX232**: Converts voltage levels (with correct 30pF capacitor!)
- **DB-9 Connector**: Standard RS-232 port
- **VIA Integration**: Address decoding and control

### Critical Component Values

**⚠️ IMPORTANT**: Ensure you have the correct capacitor values:
- **MAX232 Oscillator Capacitor**: 30pF (NOT 50nF!)
- **Other capacitors**: Follow the MAX232 datasheet exactly

## 🎯 Debugging Tips

Based on our debugging adventure:

1. **Check component values** first - wrong parts cause mysterious bugs
2. **Verify library functions** preserve registers properly
3. **Use binary display** to see what you're actually receiving
4. **Test with known data** patterns
5. **Check baud rate** with oscilloscope if possible
6. **Verify connections** with multimeter

## 🔄 Comparison: Bit-Banging vs UART

| Feature | Bit-Banging | UART (ACIA) |
|---------|-------------|-------------|
| **Hardware** | VIA GPIO only | Dedicated UART chip |
| **Software** | Complex timing | Simple register access |
| **Reliability** | Timing dependent | Hardware guaranteed |
| **Baud Rate** | Fixed by software | Configurable |
| **Learning Value** | Protocol understanding | Hardware integration |
| **Real-world Use** | Educational | Professional |

Both approaches have their place, but the UART approach is more practical for real applications!

---

*"The best debugging is done with a multimeter and a magnifying glass." - Anonymous*

*And sometimes with a parts inventory! 🔌*
