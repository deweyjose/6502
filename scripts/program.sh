#!/bin/bash

# 6502 EPROM Programming Script
# Usage: ./program.sh [binary_file.out] [eprom_type]

# Default values
BINARY_FILE=${1:-"hello_world.out"}
EPROM_TYPE=${2:-"AT28C256"}

echo "🔧 Programming EPROM: $BINARY_FILE to $EPROM_TYPE"

# Check if file exists
if [ ! -f "build/$BINARY_FILE" ]; then
    echo "❌ File build/$BINARY_FILE not found!"
    echo "💡 Make sure to assemble your code first with ./assemble.sh"
    exit 1
fi

# Run the EPROM programmer
echo "📡 Connecting to TL866II+ programmer..."
minipro -p "$EPROM_TYPE" -w "build/$BINARY_FILE" -u

# Check if programming was successful
if [ $? -eq 0 ]; then
    echo "✅ EPROM programming successful!"
    echo "📁 $BINARY_FILE has been written to $EPROM_TYPE"
    echo "🔌 You can now insert the EEPROM into your 6502 computer"
else
    echo "❌ EPROM programming failed!"
    echo "💡 Make sure your TL866II+ programmer is connected"
    exit 1
fi 