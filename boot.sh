#!/bin/bash

if [[ "$#" -ne 1 ]] || [[ "$1" -lt 2 ]] || [[ "$1" -gt 3 ]]; then
    # Redirect stdout to stderr
    echo "Pass one argument of valid directory number" >&2
    exit 1
fi

# Create binary file
nasm -f bin boot"$1"/boot"$1".asm -o boot"$1"/boot"$1".bin

# Run emulator
qemu-system-x86_64 -drive file=boot"$1"/boot"$1".bin,format=raw