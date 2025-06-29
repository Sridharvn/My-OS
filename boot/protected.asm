bits 32
section .text

global protected_main

protected_main:
    ; Clear the screen by writing spaces to video memory
    mov edi, 0xb8000
    mov ecx, 80*25
    mov ax, 0x0720      ; Space character with attribute
.clear:
    stosw
    loop .clear
    ; Jump to kernel main (you will define this in C)
    call 0x100000   ; Kernel is loaded at 0x100000 (1MB)
.halt:
    hlt
    jmp .halt