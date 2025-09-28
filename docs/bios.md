# BIOS: Basic Input/Output System 🖥️

> The heart of our breadboard 6502 computer - a simple but functional BIOS that bridges hardware and software

## Overview

The BIOS (Basic Input/Output System) is the foundational software layer that provides essential I/O services to higher-level programs like Wozmon and Microsoft BASIC. It abstracts the hardware complexity and provides a clean interface for character input/output operations.

## 🏗️ Architecture

### Memory Layout
```
$5000-$5003: 6551 ACIA (Asynchronous Communications Interface Adapter)
$6000-$6002: 6522 VIA (Versatile Interface Adapter) - Port B for LCD
$8000-$FDFF: BIOS Code and Data
$FE00-$FEFD: Wozmon Monitor
$FFFA-$FFFF: Reset and Interrupt Vectors
```

### Key Components

| Component | Purpose | Implementation |
|-----------|---------|----------------|
| **Serial I/O** | RS-232 communication via 6551 ACIA | Hardware UART with proper timing |
| **Character Input** | `CHRIN` - Read characters from serial | Polling-based with status checking |
| **Character Output** | `CHROUT` - Send characters to serial | Direct hardware write with delay |
| **Monitor Integration** | Wozmon compatibility | Seamless integration with monitor |
| **Vector Table** | Reset and interrupt handling | Proper vector setup for system startup |

## 📁 File Structure

```
assembly/
├── bios.s          # Main BIOS implementation
├── bios.cfg        # Memory configuration for BIOS
└── lib/
    ├── lcd.s       # LCD display routines
    └── b2d.s       # Binary-to-decimal conversion
```

## 🔧 Implementation Details

### Core Functions

#### `CHRIN` - Character Input
```assembly
CHRIN:
    lda ACIA_STATUS      ; Check if data available
    and #$08            ; Test data ready bit
    beq @no_keypressed  ; No data, return with carry clear
    lda ACIA_DATA       ; Read character
    jsr CHROUT          ; Echo character back
    sec                 ; Set carry to indicate success
    rts
@no_keypressed:
    clc                 ; Clear carry to indicate no data
    rts
```

**Features:**
- Non-blocking character input
- Automatic echo of received characters
- Proper status flag handling
- Well-behaved routine (preserves registers)

#### `CHROUT` - Character Output
```assembly
CHROUT:
    pha                 ; Save accumulator
    sta ACIA_DATA       ; Send character to UART
    lda #$FF            ; Simple delay loop
@txdelay:
    dec
    bne @txdelay
    pla                 ; Restore accumulator
    rts
```

**Features:**
- Simple but effective transmission
- Built-in delay for UART timing
- Well-behaved routine (preserves registers)
- Compatible with 6551 ACIA timing requirements

### Hardware Integration

#### 6551 ACIA Configuration
- **Data Register**: `$5000` - Read/write characters
- **Status Register**: `$5001` - Check transmission/reception status
- **Command Register**: `$5002` - Control UART behavior
- **Control Register**: `$5003` - Set baud rate and format

#### Memory Configuration (`bios.cfg`)
```ld65
MEMORY {
  RAM: start = $0000, size = $4000, type = rw;
  ROM: start = $8000, size = $7F00, type = ro, fill = yes;
  WOZMON: start = $FF00, size = $FA, type = ro, fill = yes;
  RESETVEC: start = $FFFA, size = 6, type = ro, fill = yes;
}
```

## 🚀 System Startup Sequence

1. **Power-On Reset**: 6502 jumps to reset vector at `$FFFC`
2. **Vector Redirect**: Reset vector points to Wozmon's `RESET` routine
3. **Wozmon Initialization**: Monitor sets up its environment
4. **BIOS Integration**: Wozmon calls BIOS functions for I/O
5. **Ready State**: System ready for user interaction

## 🔌 Integration with Higher-Level Software

### Wozmon Integration
The BIOS provides the I/O foundation that Wozmon relies on:
- **Character Input**: For user commands and program input
- **Character Output**: For displaying responses and program output
- **Serial Communication**: For loading programs from external sources

### Microsoft BASIC Integration
BASIC uses the BIOS through the same I/O vectors:
- **`CHRIN`**: For reading user input and program lines
- **`CHROUT`**: For displaying program output and prompts
- **Consistent Interface**: Same I/O behavior across all software layers

## 🛠️ Development and Testing

### Building the BIOS
```bash
# Assemble BIOS with Wozmon integration
./scripts/assemble.sh bios.s

# Program to EEPROM
./scripts/program.sh bios.out
```

### Testing I/O Functions
1. **Serial Loopback Test**: Send characters and verify echo
2. **Wozmon Integration**: Test monitor commands and responses
3. **BASIC Integration**: Verify BASIC input/output works correctly

## 🎯 Design Principles

### Well-Behaved Routines
Following the principle that routines should behave like function calls:
- **Register Preservation**: Only modify registers when documented
- **Clear Return Values**: Use carry flag for success/failure indication
- **Consistent Interface**: Same calling convention across all functions
- **Error Handling**: Graceful handling of hardware errors

### Hardware Abstraction
- **Device Independence**: BIOS routines work regardless of specific hardware quirks
- **Timing Management**: Proper delays and status checking
- **Error Recovery**: Graceful handling of communication errors

## 🔍 Troubleshooting

### Common Issues

| Problem | Symptoms | Solution |
|---------|----------|----------|
| **No Serial Output** | Characters not appearing on terminal | Check ACIA configuration and timing |
| **Echo Problems** | Double characters or missing echo | Verify `CHRIN` echo implementation |
| **Timing Issues** | Characters corrupted or lost | Adjust delay loops in `CHROUT` |
| **Vector Problems** | System doesn't start | Verify reset vector configuration |

### Debugging Tips
1. **Use Wozmon**: Monitor can help debug BIOS issues
2. **Check Status Registers**: Verify ACIA status bits
3. **Test Individual Functions**: Isolate I/O problems
4. **Verify Memory Layout**: Ensure proper segment configuration

## 📚 Technical References

- **[W65C02S Datasheet](manuals/w65c02s.pdf)**: CPU specifications and timing
- **[W65C51S Datasheet](manuals/w65c51s.pdf)**: ACIA register descriptions
- **[W65C22 Datasheet](manuals/w65c22.pdf)**: VIA specifications for LCD
- **[6502 Instruction Set](http://www.6502.org/tutorials/6502opcodes.html)**: Assembly reference

## 🎓 Learning Outcomes

Building this BIOS teaches fundamental concepts:

- **System Programming**: Low-level I/O and hardware control
- **Memory Management**: Proper segment configuration and vector setup
- **Hardware Integration**: Working with UARTs and timing requirements
- **Software Architecture**: Creating clean interfaces between layers
- **Debugging Skills**: Hardware/software integration troubleshooting

## 🚀 Future Enhancements

Potential improvements for the BIOS:
- **Interrupt-Driven I/O**: More efficient character handling
- **LCD Integration**: Direct LCD output functions
- **Error Reporting**: Better error handling and reporting
- **Configuration**: Runtime configuration of I/O parameters
- **Extended Functions**: Additional utility routines

---

**The BIOS represents the bridge between the raw hardware and the sophisticated software that runs on our breadboard computer. It's a testament to the power of well-designed system software - simple, reliable, and essential.**

*Built with patience, debugging skills, and a deep appreciation for how computers really work.*
