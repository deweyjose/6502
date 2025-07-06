# 6502 Breadboard Computer 🖥️

> Building a functional computer from scratch, one breadboard at a time

A hands-on educational project that brings computer architecture to life by constructing a working 6502 microprocessor system on breadboards. This project follows [Ben Eater's 6502 tutorial series](https://eater.net/6502) and demonstrates fundamental concepts in computer science, electronics, and low-level programming.

## ✨ Features

- **Complete 6502 System**: Fully functional microprocessor with memory, I/O, and display
- **Real-time Debugging**: Arduino-based monitoring system for step-by-step execution
- **LCD Output**: 16x2 character display for program output
- **Educational Focus**: Perfect for learning computer architecture fundamentals
- **Single-step Execution**: Manual clock control for detailed instruction observation



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

### 2. EPROM Programmer

The EPROM programmer transfers your compiled machine code from the computer to the AT28C256 EEPROM chip. This chip stores your program and boots when the 6502 starts up.

**Installation:**
```bash
# macOS
brew install minipro

# Linux/Windows: Download from http://www.autoelectric.cn/en/minipro.html
```

**Hardware Required:** TL866II+ programmer or compatible device

## 🐳 Docker Setup

For easy assembly without installing VASM locally, we provide a Docker setup:

### Quick Assembly
```bash
# Assemble the default hello_world.s
./assemble.sh

# Assemble a specific file
./assemble.sh my_program.s
```

### Manual Docker Usage
```bash
# Build the VASM image
docker-compose build vasm

# Run assembly manually
docker-compose --profile assemble run --rm vasm vasm6502_oldstyle -Fbin -dotdir hello_world.s
```

### 3. Build and Program

#### Assemble Your Code
**Important**: Use the `-Fbin` option to generate binary machine code for the EPROM.

```bash
# Assemble the hello world program
vasm6502_oldstyle -Fbin -dotdir assembler/hello_world.s

# This creates a.out (binary file ready for EPROM)
```

#### Program the EPROM
```bash
# Program the AT28C256 EEPROM
minipro -p AT28C256 -w a.out
```

**Expected Output:**
```
Found TL866II+ 04.2.131 (0x283)
Erasing... 0.02Sec OK
Protect off...OK
Writing Code...  6.78Sec  OK
Reading Code...  0.49Sec  OK
Verification OK
Protect on...OK
```

### 4. Debug Setup
1. Upload `arduino/sketch/sketch.ino` to your Arduino
2. Connect Arduino to the breadboard computer
3. Open Serial Monitor (57600 baud) to see real-time execution




## 🔧 Development Workflow

1. **Write Assembly**: Create/modify 6502 assembly code in `assembler/`
2. **Assemble**: Compile to machine code using VASM
3. **Program**: Burn to EEPROM using minipro
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

## 🤝 Contributing

This is primarily an educational project, but contributions are welcome:
- Bug reports and fixes
- Additional example programs
- Documentation improvements
- Hardware enhancements

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

**Built with ❤️ and lots of breadboards** | **Last Updated**: November 16, 2023
