set -e

echo "[+] Cleaning previous build..."
rm -rf build/kernel.o build/kernel.bin

echo "[+] Compiling kernel..."
clang -target x86_64-elf \
      -ffreestanding -nostdlib -fno-exceptions -fno-rtti -O2 \
      -c kernel/kernel.c -o build/kernel.o

echo "[+] Linking Kernel..."
ld.lld -T linker.ld -o build/kernel.bin build/kernel.o

echo "[✅] Build complete. Output -> build/kernel.bin"