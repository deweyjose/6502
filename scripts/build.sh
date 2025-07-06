#!/bin/bash

# 6502 Complete Build Script
# Usage: ./build.sh [source_file.s] [eprom_type]

# Default values
SOURCE_FILE=${1:-"hello_world.s"}
EPROM_TYPE=${2:-"AT28C256"}

echo "🚀 Building 6502 project: $SOURCE_FILE"

# Get the base filename without extension
BASE_NAME=$(basename "$SOURCE_FILE" .s)
BINARY_FILE="${BASE_NAME}.out"

echo "📝 Step 1: Assembling $SOURCE_FILE..."
./scripts/assemble.sh "$SOURCE_FILE"

# Check if assembly was successful
if [ $? -ne 0 ]; then
    echo "❌ Assembly failed! Stopping build."
    exit 1
fi

echo "✅ Assembly successful!"
echo "📝 Step 2: Programming $BINARY_FILE to $EPROM_TYPE..."

# Program the EPROM
./scripts/program.sh "$BINARY_FILE" "$EPROM_TYPE"

# Check if programming was successful
if [ $? -eq 0 ]; then
    echo "🎉 Build complete! Your 6502 program is ready to run."
    echo "🔌 Insert the EEPROM into your 6502 computer and power it up."
else
    echo "❌ Programming failed! Check your hardware connections."
    exit 1
fi 