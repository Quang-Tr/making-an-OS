#!/bin/bash
# Pass one argument of directory number

# Create binary file
nasm -f bin boot$1/boot$1.asm -o boot$1/boot$1.bin

# Run emulator
qemu-system-x86_64 -drive file=boot$1/boot$1.bin,format=raw