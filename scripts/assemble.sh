#!/bin/bash

# 6502 Assembly Script
# Usage: ./assemble.sh [source_file.s]

# Default source file
SOURCE_FILE=${1:-"hello_world.s"}

echo "🔧 Assembling 6502 code: $SOURCE_FILE"

# Run the assembler
docker-compose run --rm vasm "$SOURCE_FILE"

# Check if assembly was successful
if [ $? -eq 0 ]; then
    echo "✅ Assembly successful! Output: ${SOURCE_FILE%.s}.out"
    echo "📁 Binary file ready for EPROM programming"
else
    echo "❌ Assembly failed!"
    exit 1
fi 