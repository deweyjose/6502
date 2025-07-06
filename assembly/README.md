# Tools

We need to install an assembler, we'll use VASM Ben Eater recommended.

The source can be found [here](http://sun.hasenbraten.de/vasm/index.php?view=relsrc)

Or you can download the assembler for your platform [here](http://www.compilers.de/vasm.html)

You can find the docs on vasm [here](http://sun.hasenbraten.de/vasm/release/vasm.html)

## compile vasm

Unpack the vasm source and build it.

```cmd
$ tar xf vasm.tar.gz
$ cd vasm
$ make CPU=6502 SYNTAX=oldstyle
```

## assemble

It's important to use the -Fbin option here
We need binary machine code to put on the eprom.

```cmd
$ vasm6502_oldstyle -Fbin -dotdir blink.s
```

## minipro

Once we have a binary we need to load it into the eprom

```sh
$ brew install minipro

$ minipro -p AT28C256 -w a.out 
Found TL866II+ 04.2.131 (0x283)
Erasing... 0.02Sec OK
Protect off...OK
Writing Code...  6.78Sec  OK
Reading Code...  0.49Sec  OK
Verification OK
Protect on...OK

```
