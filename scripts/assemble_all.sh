#!/bin/bash

# Simple assemble all script for 6502 projects
set -e

for srcfile in assembly/*.s; do
  fname=$(basename "$srcfile")
  echo "Assembling $fname..."
  ./scripts/assemble.sh "$fname"
done

echo "All projects assembled!" 