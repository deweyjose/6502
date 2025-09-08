# Wozmon Monitor Program 🍎

> **Step into 1976!** Run the legendary Apple I monitor program on your breadboard 6502 and experience computing history firsthand.

**📁 [View Source Code](../assembly/wozmon/wozmon.s)**

## 🎯 What It Does

Wozmon is the **original Apple I monitor program** written by Steve Wozniak in 1976. This project brings that legendary piece of computing history to your breadboard 6502 computer! You can now:

- **Examine memory** at any address in hex format
- **Modify memory** by writing hex values directly
- **Load programs** by pasting machine code
- **Run programs** with a simple command
- **Debug code** by examining memory contents
- **Experience computing history** exactly as it was in 1976

All through a simple, elegant command-line interface over serial communication!

## 🔧 How It Works

### The Classic Wozmon Interface

Wozmon provides a simple but powerful command interface:

```
*8000: FF 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
8000: FF 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
*8000R
```

**Commands:**
- **`8000`** - Examine memory at address 8000
- **`8000: FF 00 01`** - Store values FF, 00, 01 at address 8000
- **`8000R`** - Run program starting at address 8000
- **`.`** - Set block examine mode
- **`:`** - Set store mode
- **`R`** - Run program at current address

### The ACIA Integration

Wozmon uses the W65C51S ACIA for serial communication:

```assembly
; Initialize ACIA for 19200 baud
LDA     #$1F           ; 8-N-1, 19200 baud
STA     ACIA_CTRL
LDA     #$0B           ; No parity, no echo, no interrupts
STA     ACIA_CMD
```

### Memory Management

Wozmon uses zero-page memory for its internal state:

```assembly
XAML  = $24            ; Last "opened" location Low
XAMH  = $25            ; Last "opened" location High
STL   = $26            ; Store address Low
STH   = $27            ; Store address High
L     = $28            ; Hex value parsing Low
H     = $29            ; Hex value parsing High
YSAV  = $2A            ; Used to see if hex value is given
MODE  = $2B            ; $00=XAM, $7F=STOR, $AE=BLOCK XAM
```

## 🚀 Key Features

- **Memory Examination**: View any memory location in hex
- **Memory Modification**: Write hex values directly to memory
- **Program Loading**: Load machine code by pasting hex values
- **Program Execution**: Run programs with simple commands
- **Block Operations**: Examine or modify ranges of memory
- **Hex Input/Output**: Full hexadecimal number system support
- **Serial Communication**: Works with any RS-232 terminal
- **Historical Accuracy**: Authentic 1976 Apple I experience

## 🎓 What You'll Learn

- **Memory Management**: Understanding how programs are stored and executed
- **Hexadecimal Numbers**: Working with hex addresses and values
- **Machine Code**: Loading and running raw 6502 instructions
- **Serial Communication**: Terminal-based program interaction
- **Computing History**: Experience the tools that built the personal computer revolution
- **Debugging Techniques**: Examining memory to understand program behavior

## 🔍 Technical Details

- **Protocol**: RS-232 serial communication at 19200 baud
- **Memory Range**: Full 64KB address space accessible
- **Command Format**: Simple text-based commands
- **Input Buffer**: 256-byte input buffer for commands
- **Address Display**: 4-digit hexadecimal addresses
- **Data Display**: 2-digit hexadecimal values
- **Memory Usage**: ~500 bytes of code + 256 bytes data

## 🎉 The Result

When you run Wozmon on your breadboard computer:

1. **Connect via serial terminal** and see the `*` prompt
2. **Examine memory** by typing addresses like `8000`
3. **Load programs** by pasting hex machine code
4. **Run programs** with commands like `8000R`
5. **Debug and explore** your 6502 system interactively

## 🔧 Hardware Requirements

- **W65C51S ACIA**: For serial communication
- **MAX232**: For RS-232 level conversion
- **Serial Terminal**: PC or terminal emulator
- **6502 System**: Your breadboard computer

## 📝 Using Wozmon

### Basic Commands

**Examine Memory:**
```
*8000
8000: FF 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
```

**Store Data:**
```
*8000: 48 65 6C 6C 6F
8000: 48 65 6C 6C 6F
```

**Run Program:**
```
*8000R
```

### Loading Programs

**Method 1: Manual Entry**
```
*8000: A9 48 8D 01 60 A9 65 8D 01 60 60
*8000R
```

**Method 2: File Transfer**
Use the hexdump conversion command to load entire programs:
```bash
hexdump -e '"1%03_ax: " 16/1 "%02X " " \n"' assembly/build/hello_world.out | awk '{print toupper($0)}'
```

Then paste the output into Wozmon and run with `1000R`.

### Terminal Configuration

For reliable communication, configure your terminal with:
- **Baud Rate**: 19200
- **Character Delay**: 10ms
- **Newline Delay**: 5ms
- **Line Endings**: CR only (not CRLF)

## 🎯 Example Programs

### LED Blinker
```
*8000: A9 FF 8D 03 60 A9 01 8D 01 60 A9 00 8D 01 60 4C 05 80
*8000R
```

### Hello World
```
*1000: 48 65 6C 6C 6F 20 57 6F 72 6C 64 21 0A 00
*1000R
```

## 🔍 Debugging with Wozmon

Wozmon is perfect for debugging your 6502 programs:

1. **Load your program** into memory
2. **Examine memory** to verify it loaded correctly
3. **Run the program** and see what happens
4. **Check memory** after execution to see results
5. **Modify values** and try again

## 🎨 The Historical Significance

Wozmon represents a pivotal moment in computing history:

- **1976**: Written by Steve Wozniak for the Apple I
- **Revolutionary**: First personal computer monitor program
- **Influential**: Inspired generations of computer enthusiasts
- **Educational**: Perfect for learning computer fundamentals
- **Timeless**: Still relevant for understanding how computers work

## 🚀 Advanced Usage

### Block Operations
```
*8000.8010          ; Examine memory from 8000 to 8010
*8000: FF FF FF FF  ; Store multiple values
```

### Program Development
1. **Write assembly code** in your favorite editor
2. **Assemble** with VASM or your preferred assembler
3. **Convert to hex** with the hexdump command
4. **Load into Wozmon** by pasting the hex
5. **Run and debug** interactively

### Memory Mapping
Wozmon can access your entire 6502 memory map:
- **$0000-$00FF**: Zero page
- **$0100-$01FF**: Stack
- **$0200-$02FF**: Input buffer
- **$6000-$600F**: VIA registers
- **$8000-$FFFF**: Program memory

## 🎉 The Magic Moment

When you first see the `*` prompt and type `8000`, you're experiencing computing history exactly as Steve Wozniak intended in 1976. You're not just running a program - you're stepping into the shoes of the pioneers who built the personal computer revolution!

---

*"The best way to predict the future is to invent it." - Alan Kay*

*And Wozmon helped invent the future! 🍎*
