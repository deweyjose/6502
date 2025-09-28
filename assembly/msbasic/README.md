# Microsoft BASIC for 6502 - Credits and Attribution

## 🎯 Original Source

This Microsoft BASIC implementation is based on the excellent work by **Michael Steil** and contributors at [mist64/msbasic](https://github.com/mist64/msbasic).

## 📚 What is mist64/msbasic?

The [mist64/msbasic](https://github.com/mist64/msbasic) repository is a remarkable piece of reverse engineering and historical preservation. It's a **single integrated assembly source tree** that can generate nine different versions of Microsoft BASIC for 6502, including:

- **Commodore BASIC 1 & 2** (1977-1979)
- **AppleSoft I & II** (1977-1978) 
- **OSI BASIC** (1977)
- **KIM-1 BASIC** (1977)
- **AIM-65 BASIC** (1978)
- **SYM-1 BASIC** (1978)
- **KBD BASIC** (1982)
- **MicroTAN BASIC** (1980)

## 🏆 Why This Matters

This project represents an incredible achievement in computer history preservation:

- **Historical Accuracy**: Faithful recreation of 1970s Microsoft BASIC implementations
- **Educational Value**: Perfect for understanding how early microcomputer software worked
- **Cross-Platform**: Single source code that generates multiple historical versions
- **Reverse Engineering**: Meticulous work to recreate the original Microsoft source code

## 🔧 How We Use It

Our breadboard 6502 computer uses the **Eater configuration** from mist64/msbasic, which includes:

- **Platform Detection**: Automatically selects Eater-specific settings
- **Memory Configuration**: Proper segment layout for our hardware
- **BIOS Integration**: Seamless integration with our custom BIOS
- **Wozmon Integration**: Works alongside our monitor program

## 👥 Credits

**Original Work by:**
- **Michael Steil** (mist64@mac.com) - Main development
- **Martin Hoffmann-Vetter** - AIM-65 and SYM-1 contributions
- **Bob Sander-Cederlof** - AppleSoft II disassembly reference
- **Tom Greene** - Applesoft lite contributions
- **Joe Zbicak** - Intellivision Keyboard BASIC help

**Dedicated to:** Michael "acidity" Kollmann

## 📄 License

This work is released under the **2-clause BSD license** - see the [original repository](https://github.com/mist64/msbasic) for details.

## 🔗 Links

- **[Original Repository](https://github.com/mist64/msbasic)** - The source of this amazing work
- **[Blog Entry](https://www.pagetable.com/?p=46)** - Detailed analysis of Microsoft BASIC versions
- **[Ben Eater's Video](https://www.youtube.com/watch?v=LnzuMJLZRdU)** - Porting BASIC to breadboard computers

---

**We are deeply grateful to Michael Steil and all contributors for making this historical software available and for their incredible work in preserving computer history. Without their efforts, running Microsoft BASIC on our breadboard 6502 computer would not have been possible.**

*This attribution is our way of saying "thank you" to the community that makes projects like ours possible.*
