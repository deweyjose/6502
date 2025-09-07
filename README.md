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
| Running Apple 1 software on a breadboard computer (Wozmon) | Get the classic Wozmon monitor running on the breadboard 6502. | ⏳ Planned |
| Adapting WozMon for the breadboard 6502 | Modify and adapt WozMon for compatibility and usability on this custom build. | ⏳ Planned |
| A simple BIOS for my breadboard computer | Develop a basic BIOS to manage program selection and I/O routines. | ⏳ Planned |
| Running MSBASIC on my breadboard 6502 computer | Port and run Microsoft BASIC, enabling interactive programming on the breadboard system. | ⏳ Planned |

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

Complete workflow from assembly to programming using our Docker-based tools:

### 1. Assemble the code
```bash
./scripts/assemble.sh keyboard_ps2.s
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

### 2. Program the EPROM
```bash
./scripts/program.sh keyboard_ps2.out
```

**Output:**
```
🔧 Programming EPROM: keyboard_ps2.out to AT28C256
📡 Connecting to TL866II+ programmer...
Found TL866II+ 04.2.131 (0x283)
Erasing... 0.02Sec OK
Protect off...OK
Writing Code...  6.78Sec  OK
Reading Code...  0.49Sec  OK
Verification OK
Protect on...OK
✅ EPROM programming successful!
📁 keyboard_ps2.out has been written to AT28C256
🔌 You can now insert the EEPROM into your 6502 computer
```

### 3. Build Wrapper (One-Command Solution)
```bash
./scripts/build.sh keyboard_ps2.s
```

**Output:**
```
🚀 Building 6502 project: keyboard_ps2.s
📝 Step 1: Assembling keyboard_ps2.s...
🔧 Assembling 6502 code: keyboard_ps2.s
...
✅ Assembly successful! Output: keyboard_ps2.out
📁 Binary file ready for EPROM programming
✅ Assembly successful!
📝 Step 2: Programming keyboard_ps2.out to AT28C256...
🔧 Programming EPROM: keyboard_ps2.out to AT28C256
📡 Connecting to TL866II+ programmer...
Found TL866II+ 04.2.131 (0x283)
...
Verification OK
✅ EPROM programming successful!
📁 keyboard_ps2.out has been written to AT28C256
🔌 You can now insert the EEPROM into your 6502 computer
🎉 Build complete! Your 6502 program is ready to run.
🔌 Insert the EEPROM into your 6502 computer and power it up.
```

### 4. Debug Setup
1. Upload `arduino/sketch/sketch.ino` to your Arduino
2. **Important**: Watch [Ben Eater's Arduino debugging video](https://www.youtube.com/watch?v=LnzuMJLZRdU) to learn how to connect the Arduino GPIO pins to the 6502's data and address lines correctly
3. Connect Arduino to the breadboard computer following Ben's wiring diagram
4. Open Serial Monitor (57600 baud) to see real-time execution




## 🔧 Development Workflow

1. **Write Assembly**: Create/modify 6502 assembly code in `assembly/`
2. **Assemble**: Compile to machine code using `./scripts/assemble.sh`
3. **Program**: Burn to EEPROM using `./scripts/program.sh`
4. **Test**: Run on breadboard computer
5. **Debug**: Use Arduino monitor to observe execution

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

## 📄 License

This project is open source. See [LICENSE](LICENSE) for details.

---

**Built with ❤️ and lots of breadboards**
