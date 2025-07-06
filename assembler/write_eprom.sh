#!/bin/bash
# Create the output directory if it doesn't exist
mkdir -p output
set -e
./vasm/vasm6502_oldstyle -Fbin -dotdir -o output/$1.out $1
minipro -p AT28C256 -w output/$1.out 
