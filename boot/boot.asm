; boot.asm — real mode 16-bit bootloader to jump to protected mode
bits 16
org 0x7C00



start:
    cli ; Disable interrupts during setup
    xor ax,ax
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp, 0x7C00      ; Stack grows down

    mov si, boot_msg
    call print_string

    call enable_a20
    call load_gdt
    call enter_protected_mode


; This should never be reached
    hlt
    jmp $

; -------------------------------------------------------------------
; Enable A20 line using BIOS keyboard controller

enable_a20:
    in al,0x64
.wait1:
    test al,2
    jnz .wait1
    mov al, 0xD1
    out 0x64,al
.wait2:
    in al,0x64
    test al,2
    jnz .wait2
    mov al,0xDF
    out 0x60,al
    ret
; -------------------------------------------------------------------
; Load Global Descriptor Table
load_gdt:
    lgdt [gdt_descriptor]
    ret

; -------------------------------------------------------------------
; Switch to protected mode
enter_protected_mode:
    mov eax,cr0
    or eax,1
    mov cr0,eax

    jmp CODE_SEG:init_pm  ; Far jump to clear prefetch and load CS
; -------------------------------------------------------------------
; 32-bit protected mode segment begins here
[bits 32]
init_pm:
    mov ax,DATA_SEG
    mov ds,ax
    mov ss,ax
    mov es,ax
    mov fs,ax
    mov gs,ax

    ; Load the stack
    mov esp,0x90000
    ; Jump to protected_entry (in pm_entry.asm) at 0x08:0x8000
    jmp 0x08:protected_entry_offset
.hang:
    hlt
    jmp .hang
; -------------------------------------------------------------------
; GDT (Global Descriptor Table)
gdt_start:
    ; Null Descriptor
    dq 0x0000000000000000

    ; Code Segment: base=0, limit=4GB, type=code
    dq 0x00CF9A000000FFFF

    ; Data Segment: base=0, limit=4GB, type=data
    dq 0x00CF92000000FFFF

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start -1
    dd gdt_start

CODE_SEG equ 0x08
DATA_SEG equ 0x10

; Offset for protected_entry in the kernel binary
protected_entry_offset equ 0x8000

; Print a string using BIOS teletype (int 0x10)
print_string:
    pusha
.print_loop:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .print_loop
.done:
    popa
    ret

boot_msg db "Bootloader OK", 0

; -------------------------------------------------------------------
; Pad to 512 bytes + signature
times 510 - ($-$$) db 0
dw 0xAA55