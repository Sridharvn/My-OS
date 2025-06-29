bits 32
section .text
global protected_entry
extern protected_main

protected_entry:
    ; Set up segments
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Setup stack
    mov esp, 0x90000

    ; Call protected_main
    call protected_main

.halt:
    hlt
    jmp .halt
