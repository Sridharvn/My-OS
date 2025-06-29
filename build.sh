set -e

echo "[+] Cleaning previous build..."
rm -rf build
mkdir -p build

echo "[+] Assembling bootloader (real mode)..."
nasm -f bin boot/boot.asm -o build/boot.bin

echo "[+] Assembling protected mode entry..."
nasm -f elf32 boot/pm_entry.asm -o build/pm_entry.o
echo "[+] Assembling protected mode setup..."
nasm -f elf32 boot/protected.asm -o build/protected.o

echo "[+] Compiling kernel..."
clang -target i386-elf -ffreestanding -m32 -c kernel/kernel.c -o build/kernel.o

echo "[+] Linking kernel and protected mode setup..."
ld.lld -T linker.ld -m elf_i386 -nostdlib -o build/kernel.bin build/pm_entry.o build/protected.o build/kernel.o

echo "[+] Creating bootable image..."
cat build/boot.bin build/kernel.bin > build/os-image.bin

echo "[✅] Build complete. Output -> build/os-image.bin"