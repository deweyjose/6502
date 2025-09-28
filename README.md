# 6502 Breadboard Computer 🖥️

> Building a functional computer from scratch, one breadboard at a time

A hands-on educational project that brings computer architecture to life by constructing a working 6502 microprocessor system on breadboards. This project follows [Ben Eater's 6502 tutorial series](https://eater.net/6502) and demonstrates fundamental concepts in computer science, electronics, and low-level programming.

## ✨ Features

- **Complete 6502 System**: Fully functional microprocessor with memory, I/O, and display
- **Real-time Debugging**: Arduino-based monitoring system for step-by-step execution
- **LCD Output**: 16x2 character display for program output
- **Educational Focus**: Perfect for learning computer architecture fundamentals
- **Single-step Execution**: Manual clock control for detailed instruction observation

## 🛠️ 6502 Projects

| Project | Description | Status | Documentation |
|---------|-------------|--------|---------------|
| Hardware Timer Demo | Uses VIA hardware timer to increment a counter and display its value on the LCD, with LED blinking every 250ms. | ✅ Complete | [📖 Details](docs/hardware_timer.md) |
| Keyboard - PS/2 | Reads input from a PS/2 keyboard and displays characters and scancodes on the LCD with mode toggle between char and hex display. | ✅ Complete | [📖 Details](docs/main_ps2.md) |
| RS-232 Serial Keyboard | Receive characters from a PC or terminal over RS-232 and display them on the LCD using bit-banging techniques. | ✅ Complete | [📖 Details](docs/serial_interface.md) |
| RS232 interface with the 6551 UART | Integrate the 6551 UART chip for RS232 serial communication with hardware flow control and proper terminal compatibility. | ✅ Complete | [📖 Details](docs/uart_serial_interface.md) |
| Fixing a hardware bug in software (65C51 UART) | Debug and fix hardware issues including wrong capacitor values and LCD library bugs that prevented proper UART communication. | ✅ Complete | [📖 Details](docs/uart_serial_interface.md) |
| Running Apple 1 software on a breadboard computer (Wozmon) | Get the classic Wozmon monitor running on the breadboard 6502 with serial communication and program loading capabilities. | ✅ Complete | [📖 Details](docs/wozmon.md) |
| Adapting WozMon for the breadboard 6502 | Modify and adapt WozMon for compatibility and usability on this custom build with proper serial communication and program loading. | ✅ Complete | [📖 Details](docs/wozmon.md) |
| A simple BIOS for my breadboard computer | Develop a basic BIOS to manage program selection and I/O routines. | ✅ Complete | [📖 Details](docs/bios.md) |
| Running MSBASIC on my breadboard 6502 computer | Port and run Microsoft BASIC, enabling interactive programming on the breadboard system. | ✅ Complete | [📖 Details](docs/msbasic.md) |

## 📋 Requirements

### Hardware Components
See [Ben Eater's 6502 tutorial](https://eater.net/6502) for the complete parts list and component specifications.

### Software Tools
- **VASM Assembler**: For compiling 6502 assembly code
- **Arduino IDE**: For debugging and monitoring

## 🚀 Setup

### 1. VASM Assembler

VASM is the recommended assembler for 6502 development. It compiles assembly code into machine code that can be programmed into the EEPROM.

- **Download**: [VASM website](http://www.compilers.de/vasm.html)
- **Source**: [VASM repository](http://sun.hasenbraten.de/vasm/index.php?view=relsrc)
- **Documentation**: [VASM docs](http://sun.hasenbraten.de/vasm/release/vasm.html)

**We use Docker for VASM** - see the [Docker Setup](#docker-setup) section below for easy assembly.

**Example:**
```bash
# Assemble a 6502 program
docker-compose run --rm vasm keyboard_ps2.s
```

**Output:**
```
vasm 2.0b (c) in 2002-2025 Volker Barthelmann
vasm 6502 cpu backend 1.0b (c) 2002,2006,2008-2012,2014-2025 Frank Wille
vasm oldstyle syntax module 0.21 (c) 2002-2025 Frank Wille
vasm binary output module 2.3d (c) 2002-2025 Volker Barthelmann and Frank Wille

org0001:8000(acrwx1):            479 bytes
org0002:fd00(acrwx1):            528 bytes
org0003:fffa(acrwx1):              6 bytes
```

### 2. EPROM Programmer

The EPROM programmer transfers your compiled machine code from the computer to the AT28C256 EEPROM chip. This chip stores your program and boots when the 6502 starts up.

**Installation:**
```bash
# macOS
brew install minipro

# Linux/Windows: Download from http://www.autoelectric.cn/en/minipro.html
```

**Hardware Required:** TL866II+ programmer or compatible device

**Note:** While we provide a Docker setup for minipro, USB device passthrough is not supported on macOS. You'll need to use the native `brew install minipro` installation for EEPROM programming on Mac.

## 🔧 Development Workflow

This project uses two different build systems depending on the complexity of the software:

### Build System Overview

| Project Type | Compiler | Script | Use Case |
|--------------|----------|--------|----------|
| **Early Exercises** | VASM | `assemble.sh` | Hardware timer, keyboard demos, libraries |
| **Advanced Software** | CA65/LD65 | `make.sh` | BIOS, Wozmon, Microsoft BASIC |

### 🐳 Docker Setup

First, build the required Docker images:

```bash
# Build VASM compiler image (for early exercises)
docker-compose build vasm

# Build CA65/LD65 compiler images (for advanced software)
docker-compose build ca65 ld65

# Build minipro programmer image
docker-compose build minipro
```

**Optional: Create convenient aliases**
Add these to your `~/.bashrc` or `~/.zshrc`:

```bash
# CA65 compiler alias
alias ca65='docker run -it --rm -v.:/workspace 6502-ca65'

# LD65 linker alias
alias ld65='docker run -it --rm --entrypoint=/opt/cc65/bin/ld65 -v .:/workspace 6502-ld65'
```

**Note:** Minipro cannot run in Docker due to USB device access requirements, so use the native installation instead.

### 🔨 Building Projects

#### For Early Exercises (Hardware Timer, Keyboard, Libraries)
Use VASM compiler for simple, single-file projects:

```bash
# Assemble the code
./scripts/assemble.sh assembly/keyboard/main_ps2.s

# Program the EPROM
./scripts/program.sh keyboard_ps2.out

# Or use the build wrapper (one command)
./scripts/build.sh assembly/keyboard/main_ps2.s
```

**Output:**
```
🔧 Assembling 6502 code: keyboard_ps2.s
vasm 2.0b (c) in 2002-2025 Volker Barthelmann
vasm 6502 cpu backend 1.0b (c) 2002,2006,2008-2012,2014-2025 Frank Wille
vasm oldstyle syntax module 0.21 (c) 2002-2025 Frank Wille
vasm binary output module 2.3d (c) 2002-2025 Volker Barthelmann and Frank Wille

org0001:8000(acrwx1):            479 bytes
org0002:fd00(acrwx1):            528 bytes
org0003:fffa(acrwx1):              6 bytes
✅ Assembly successful! Output: keyboard_ps2.out
📁 Binary file ready for EPROM programming
```

#### For Advanced Software (BIOS, Wozmon, Microsoft BASIC)
Use CA65/LD65 compiler for complex, multi-file projects:

```bash
# Build complete system with BIOS, Wozmon, and BASIC
./scripts/make.sh
```

**Output:**
```
🔧 Building 6502 project: eater
✅ Assembly successful! Output: eater.o
🔧 Linking 6502 project: eater
✅ Linking successful! Output: eater.bin
🔧 Programming EPROM: eater.bin to AT28C256
📡 Connecting to TL866II+ programmer...
Found TL866II+ 04.2.131 (0x283)
Erasing... 0.02Sec OK
Protect off...OK
Writing Code...  6.78Sec  OK
Reading Code...  0.49Sec  OK
Verification OK
Protect on...OK
✅ EPROM programming successful!
📁 eater.bin has been written to AT28C256
🔌 You can now insert the EEPROM into your 6502 computer
```

### 🐛 Debug Setup
1. Upload `arduino/sketch/sketch.ino` to your Arduino
2. **Important**: Watch [Ben Eater's Arduino debugging video](https://www.youtube.com/watch?v=LnzuMJLZRdU) to learn how to connect the Arduino GPIO pins to the 6502's data and address lines correctly
3. Connect Arduino to the breadboard computer following Ben's wiring diagram
4. Open Serial Monitor (57600 baud) to see real-time execution





## 🎓 Learning Objectives

This project covers essential computer science concepts:
- **Computer Architecture**: CPU, memory, and I/O systems
- **Assembly Programming**: Low-level programming with 6502
- **Digital Electronics**: Logic gates, timing, and signal integrity
- **Memory Management**: Address decoding and memory mapping
- **I/O Programming**: Device communication and protocols
- **Debugging**: Hardware and software troubleshooting


## 📚 Resources

- **[Ben Eater's 6502 Tutorial](https://eater.net/6502)**: Complete video series
- **[VASM Documentation](http://sun.hasenbraten.de/vasm/release/vasm.html)**: Assembler reference
- **[VASM Downloads](http://www.compilers.de/vasm.html)**: Pre-built binaries for your platform
- **[VASM Source](http://sun.hasenbraten.de/vasm/index.php?view=relsrc)**: Source code repository
- **[6502 Instruction Set](http://www.6502.org/tutorials/6502opcodes.html)**: CPU reference
- **[W65C02S Datasheet](manuals/w65c02s.pdf)**: Detailed CPU specifications

## 🙏 Credits

**Microsoft BASIC Implementation**: This project uses the excellent [mist64/msbasic](https://github.com/mist64/msbasic) port by Michael Steil and contributors. This remarkable work provides a single integrated assembly source tree that can generate nine different versions of Microsoft BASIC for 6502. See [assembly/msbasic/README.md](assembly/msbasic/README.md) for full attribution and details.

## 📄 License

This project is open source. See [LICENSE](LICENSE) for details.

---

**Built with ❤️ and lots of breadboards**
