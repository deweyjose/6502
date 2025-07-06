#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: <sourcefile.s>"
  exit 1
fi

SOURCE="$1"
BASENAME=$(basename "$SOURCE" .s)
OUTPUT_DIR="build"
OUTPUT="${OUTPUT_DIR}/${BASENAME}.out"

mkdir -p "$OUTPUT_DIR"

exec vasm6502_oldstyle -Fbin -dotdir -o "$OUTPUT" "$SOURCE"
