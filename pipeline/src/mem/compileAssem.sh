#!/bin/bash

# Check if input and output file names are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input.S> <output.hex>"
  exit 1
fi

INPUT=$1
INPUT_BASENAME=$(basename "$INPUT" .S)
OUTPUT=$2
OBJECT_OUTPUT="temp.o"
LINKER_SCRIPT="../scripts/${INPUT_BASENAME}.ld"
ELF_OUTPUT="temp.elf"
BIN_OUTPUT="temp.bin"

# Compile the assembly file to ELF
riscv64-unknown-elf-as -o $OBJECT_OUTPUT "$INPUT"
riscv64-unknown-elf-ld -T $LINKER_SCRIPT -o $ELF_OUTPUT $OBJECT_OUTPUT

# Convert ELF to Intel HEX format
riscv64-unknown-elf-objcopy -O binary $ELF_OUTPUT $BIN_OUTPUT
xxd -p -c 4 $BIN_OUTPUT | awk '{print toupper(substr($0,7,2) substr($0,5,2) substr($0,3,2) substr($0,1,2))}' > "$OUTPUT"


echo "Compilation complete. Output saved as: $OUTPUT"

# Optionally remove the temporary ELF file
rm -f $ELF_OUTPUT
rm -f $BIN_OUTPUT
rm -f $OBJECT_OUTPUT