; boot.asm - 512-byte boot sector
bits 16
org 0x7C00      ; BIOS loads the bootloader at 0x7C00

start:
    mov si, msg
    call print_string

    jmp $       ; Hang the system (infinite loop)


; ----------------------------
; Print string at [SI]
print_string:
    mov ah, 0x0E    ; BIOS teletype output
.print_char:
    lodsb           ; Load next byte from [SI] into AL
    cmp al, 0
    je .done
    int 0x10        ; BIOS interrupt to print character
    jmp .print_char
.done:
    ret

msg db "Booting OS...", 0

; ----------------------------
; Pad to 512 bytes and add boot signature
times 510-($-$$) db 0
dw 0xAA55