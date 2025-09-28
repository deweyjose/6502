# Microsoft BASIC on the 6502 Breadboard Computer 🖥️

> Bringing interactive programming to our breadboard computer - Microsoft BASIC ported and running on custom hardware

## Overview

Microsoft BASIC represents the culmination of our breadboard 6502 computer project - a full-featured programming language running on custom hardware. This port brings the power of interactive programming to our breadboard system, enabling users to write, run, and debug programs directly on the 6502.

## 🏗️ Architecture

### Memory Layout
```
$0000-$00FF: Zero Page (BASIC variables and system data)
$0100-$01FF: 6502 Stack
$0400-$7FFF: BASIC Program Space
$8000-$FDFF: BASIC Interpreter Code
$FE00-$FEFD: Wozmon Monitor (integrated)
$FFFA-$FFFF: Reset and Interrupt Vectors
```

### Key Components

| Component | Purpose | Memory Range |
|-----------|---------|--------------|
| **BASIC Interpreter** | Core language engine | $8000-$FDFF |
| **Program Storage** | User BASIC programs | $0400-$7FFF |
| **Zero Page** | Variables and system data | $0000-$00FF |
| **Wozmon Integration** | Monitor and debugging | $FE00-$FEFD |
| **I/O Routines** | Character input/output | BIOS integration |

## 📁 File Structure

```
assembly/msbasic/
├── msbasic.s              # Main BASIC interpreter
├── defines.s              # Platform detection and includes
├── defines_eater.s        # Eater-specific configuration
├── header.s               # Entry points and vectors
├── init.s                 # Cold start initialization
├── extra.s                # Platform-specific extensions
├── eater_iscntc.s         # Eater interrupt/control routines
├── bios.s                 # BIOS integration
├── *.cfg                  # Memory configuration files
└── [core modules]         # BASIC language implementation
```

### Core Language Modules

| Module | Purpose | Description |
|--------|---------|-------------|
| **`token.s`** | Tokenization | Convert keywords to tokens |
| **`eval.s`** | Expression evaluation | Parse and evaluate expressions |
| **`flow1.s`** | Control structures | IF, FOR, NEXT, GOTO, GOSUB |
| **`flow2.s`** | Advanced flow control | WHILE, WEND, ON statements |
| **`print.s`** | Output formatting | PRINT, TAB, SPC functions |
| **`input.s`** | Input handling | INPUT, READ, DATA statements |
| **`string.s`** | String operations | String manipulation functions |
| **`math.s`** | Mathematical functions | SIN, COS, LOG, SQR, etc. |
| **`var.s`** | Variable management | Variable storage and retrieval |
| **`memory.s`** | Memory management | Program storage and organization |

## 🔧 Configuration

### Eater-Specific Settings (`defines_eater.s`)

```assembly
; Memory Configuration
ZP_START1 = $00           ; Zero page start
ZP_START2 = $0A           ; Additional zero page
ZP_START3 = $60           ; Extended zero page
ZP_START4 = $6B           ; Final zero page range

; System Constants
SPACE_FOR_GOSUB := $3E    ; GOSUB stack space
STACK_TOP := $FA          ; 6502 stack top
WIDTH := 40               ; Display width
WIDTH2 := 30              ; Secondary width
RAMSTART2 := $0400        ; Program storage start

; I/O Integration
USR := GORESTART          ; USR() function handler
```

### Memory Configuration (`eater.cfg`)

```ld65
MEMORY {
    ZP:         start = $0000, size = $0100, type = rw;
    BASROM:     start = $8000, size = $7E00, fill = yes, file = %O;
    WOZMON:     start = $FE00, size = $1FA, fill = yes, file=%O;
    RESETVEC:   start = $FFFA, size = 6, fill = yes, file=%O;
    DUMMY:      start = $0000, size = $00FF, file = "";  
}
```

## 🚀 System Integration

### BIOS Integration
BASIC seamlessly integrates with our custom BIOS:
- **Character Input**: Uses `CHRIN` for user input
- **Character Output**: Uses `CHROUT` for program output
- **Serial Communication**: Full RS-232 support
- **Error Handling**: Graceful error reporting

### Wozmon Integration
The monitor and BASIC coexist perfectly:
- **Program Loading**: Load BASIC programs via Wozmon
- **Memory Inspection**: Debug BASIC programs
- **System Control**: Switch between monitor and BASIC
- **Development Workflow**: Seamless development experience

## 💻 BASIC Language Features

### Core Language Support
- **Variables**: Integer and floating-point variables
- **Arrays**: Single and multi-dimensional arrays
- **Strings**: String variables and operations
- **Control Structures**: IF/THEN/ELSE, FOR/NEXT, WHILE/WEND
- **Subroutines**: GOSUB/RETURN with proper stack management
- **Functions**: Built-in mathematical and string functions

### Mathematical Functions
```basic
SIN(X)    - Sine function
COS(X)    - Cosine function
TAN(X)    - Tangent function
LOG(X)    - Natural logarithm
SQR(X)    - Square root
ABS(X)    - Absolute value
INT(X)    - Integer part
RND(X)    - Random number generation
```

### String Functions
```basic
LEFT$(A$,N)    - Left substring
RIGHT$(A$,N)   - Right substring
MID$(A$,N,M)   - Middle substring
LEN(A$)        - String length
ASC(A$)        - ASCII value
CHR$(N)        - Character from ASCII
```

### I/O Commands
```basic
PRINT          - Output with formatting
INPUT          - User input
READ/DATA      - Data statements
RESTORE        - Reset data pointer
```

## 🛠️ Building and Programming

### Assembly Process
```bash
# Build complete system with BASIC
./scripts/make.sh
```

### Build Configuration
The system uses a sophisticated build process:
1. **Platform Detection**: Automatically selects Eater configuration
2. **Memory Layout**: Configures proper memory segments
3. **BIOS Integration**: Links with custom BIOS
4. **Wozmon Integration**: Includes monitor functionality
5. **Vector Setup**: Proper reset and interrupt vectors

## 🎮 Usage Examples

### Hello World Program
```basic
10 PRINT "HELLO, WORLD!"
20 PRINT "WELCOME TO BASIC ON THE 6502!"
30 END
```

### Interactive Calculator
```basic
10 INPUT "ENTER FIRST NUMBER: ", A
20 INPUT "ENTER SECOND NUMBER: ", B
30 INPUT "ENTER OPERATION (+, -, *, /): ", OP$
40 IF OP$ = "+" THEN PRINT A + B
50 IF OP$ = "-" THEN PRINT A - B
60 IF OP$ = "*" THEN PRINT A * B
70 IF OP$ = "/" THEN PRINT A / B
80 GOTO 10
```

### Number Guessing Game
```basic
10 RANDOMIZE
20 SECRET = INT(RND(1) * 100) + 1
30 PRINT "I'M THINKING OF A NUMBER 1-100"
40 INPUT "YOUR GUESS: ", GUESS
50 IF GUESS = SECRET THEN PRINT "CORRECT!": GOTO 80
60 IF GUESS > SECRET THEN PRINT "TOO HIGH"
70 IF GUESS < SECRET THEN PRINT "TOO LOW"
75 GOTO 40
80 PRINT "PLAY AGAIN? (Y/N)"
90 INPUT A$
100 IF A$ = "Y" THEN GOTO 10
110 END
```

## 🔍 Technical Implementation

### Tokenization Process
1. **Keyword Recognition**: Convert BASIC keywords to tokens
2. **Variable Parsing**: Identify and store variable names
3. **Number Conversion**: Convert numeric literals
4. **String Handling**: Process string literals
5. **Line Numbering**: Maintain program structure

### Expression Evaluation
1. **Operator Precedence**: Proper mathematical order
2. **Function Calls**: Handle built-in functions
3. **Variable Lookup**: Access stored variables
4. **Type Conversion**: Automatic type handling
5. **Error Detection**: Syntax and runtime errors

### Memory Management
1. **Program Storage**: Efficient program representation
2. **Variable Space**: Dynamic variable allocation
3. **String Storage**: String variable management
4. **Garbage Collection**: Memory cleanup
5. **Stack Management**: GOSUB/RETURN stack

## 🐛 Debugging and Development

### Built-in Debugging Features
- **Line-by-line execution**: Step through programs
- **Variable inspection**: View variable values
- **Error reporting**: Clear error messages
- **Memory management**: Monitor memory usage

### Wozmon Integration
- **Memory inspection**: View program memory
- **Register examination**: Check CPU state
- **Breakpoint support**: Set execution breakpoints
- **Program modification**: Direct memory editing

## 🎓 Learning Outcomes

This Microsoft BASIC implementation teaches:

- **Language Design**: How programming languages work
- **Compiler Theory**: Tokenization and parsing
- **Memory Management**: Dynamic memory allocation
- **System Integration**: Hardware/software interaction
- **User Interface Design**: Interactive programming environments
- **Error Handling**: Robust error detection and reporting

## 🚀 Performance Characteristics

### Memory Usage
- **Interpreter**: ~32KB of ROM
- **Program Space**: ~30KB available for user programs
- **Variables**: Dynamic allocation in zero page and RAM
- **Stack**: 256 bytes for GOSUB/RETURN

### Execution Speed
- **Simple Operations**: Near real-time response
- **Mathematical Functions**: Reasonable performance for educational use
- **String Operations**: Efficient string handling
- **I/O Operations**: Limited by serial communication speed

## 🔧 Troubleshooting

### Common Issues

| Problem | Symptoms | Solution |
|---------|----------|----------|
| **Syntax Errors** | Program won't run | Check BASIC syntax |
| **Memory Errors** | Program crashes | Reduce program size |
| **I/O Problems** | No input/output | Check BIOS integration |
| **Stack Overflow** | GOSUB errors | Reduce nesting depth |

### Debugging Tips
1. **Use Wozmon**: Monitor memory and registers
2. **Check Syntax**: Verify BASIC program structure
3. **Test Incrementally**: Build programs step by step
4. **Monitor Memory**: Watch for memory conflicts

## 📚 Technical References

- **[Microsoft BASIC Reference](https://en.wikipedia.org/wiki/Microsoft_BASIC)**: Language specification
- **[6502 Assembly Reference](http://www.6502.org/tutorials/6502opcodes.html)**: CPU instructions
- **[W65C02S Datasheet](manuals/w65c02s.pdf)**: Processor specifications
- **[BASIC Programming Guide](https://archive.org/details/bitsavers_appleIIBASIC_1980)**: Historical documentation

## 🎯 Future Enhancements

Potential improvements for the BASIC system:
- **Graphics Support**: Simple graphics commands
- **File I/O**: Program save/load functionality
- **Extended Math**: Additional mathematical functions
- **Sound Support**: Audio output capabilities
- **LCD Integration**: Direct LCD display functions

## 🌟 Historical Significance

This Microsoft BASIC port represents a significant achievement:

- **Historical Accuracy**: Faithful recreation of 1970s BASIC
- **Educational Value**: Perfect for learning programming concepts
- **Hardware Integration**: Seamless operation on custom hardware
- **Complete System**: Full-featured programming environment

---

**Microsoft BASIC on our breadboard 6502 computer represents the perfect marriage of hardware and software - a complete programming environment running on custom-built hardware. It's a testament to the power of well-designed systems and the enduring appeal of interactive programming.**

*From breadboards to BASIC - a journey through computer history, one instruction at a time.*

---

**For your daughter**: *This is what your dad built - a complete computer from scratch, with a programming language that people used in the 1970s. Every character you type, every program you write, flows through circuits we built by hand. It's not just code; it's understanding how computers really work, from the silicon up.*
