#!/bin/bash
./vasm/vasm6502_oldstyle -Fbin -dotdir -o hello_world.out hello_world.s
minipro -p AT28C256 -w hello_world.out 
