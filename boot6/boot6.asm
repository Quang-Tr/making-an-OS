; GDT (Global Descriptor Table) & text UI (adapted from Midnight Commander) in 32-bit protected mode
; flat memory model

[org 0x7c00]

; disable cursor
mov ah, 0x01
mov ch, 0x3f    ; bits 6-7 unused, bit 5 disables cursor, bits 0-4 control cursor shape
int 0x10        ; works in real mode

; read 2000 bytes of screen from 4 subsequent sectors
; store pointer in bx
mov ah, 2
mov al, 4
mov ch, 0
mov cl, 2
mov dh, 0
xor bx, bx
mov es, bx
mov bx, screen
int 0x13

; offsets
CODE_SEG equ code_descriptor - GDT_Start
DATA_SEG equ data_descriptor - GDT_Start

; disable all interrupts
cli
; load GDT
lgdt [GDT_Descriptor]
; change last bit of 32-bit cr0 to 1 for actual switch
mov eax, cr0
or eax, 1
mov cr0, eax
; far jump (to other segment)
jmp CODE_SEG:start_protected_mode

; must be at the end of real mode code
GDT_Start:
    null_descriptor:    ; eight times 00000000
        dd 0
        dd 0

    code_descriptor:
        dw 0xffff       ; first 16 bits of 20-bit limit (0xfffff)
        dw 0            ; 16 bits...
        db 0            ; + 8 bits = first 24 bits of 32-bit base (0)
        db 0b10011010
                        ; "1" present: used or not
                        ; "00" descriptor privilege level: ring
                        ; "1" system segment: 1 if this is code/data segment
                        ; then four type flags
                        ; "1" contains code?
                        ; "0" conforming: executed from less-privileged segments?
                        ; "1" readable?
                        ; "0" accessed? (automatically managed)
        db 0b11001111
                        ; four other flags
                        ; "1" granularity: limit *= 0x1000? (to span whole 4 GB memory)
                        ; "1" 32-bit?
                        ; "0" 64-bit?
                        ; "0" AVL? (not used by hardware)
                        ; "1111" then last 4 bits of 20-bit limit (0xfffff)
        db 0            ; last 8 bits of 32-bit base (0)

    data_descriptor:
        dw 0xffff
        dw 0
        db 0
        db 0b10010010   ; "1001" present, descriptor privilege level and system segment same as code_descriptor
                        ; then four type flags
                        ; "0" contains code?
                        ; "0" expand-down? (0 means base --> base + limit)
                        ; "1" writable?
                        ; "0" accessed? (automatically managed)
        db 0
GDT_End:

GDT_Descriptor:
    dw GDT_End - GDT_Start - 1  ; size
    dd GDT_Start                ; start

[bits 32]
start_protected_mode:
    VIDEO_MEM equ 0xb8000   ; video memory starts at 0xb8000 in text mode
    LINE_WIDTH equ 80       ; 80 characters wide and 25 characters lines per screen
    mov ecx, VIDEO_MEM
    mov ah, 0x9f    ; back + fore colors

printScreen:
    mov al, [ebx]   ; character
    call fixBorders
    mov [ecx], ax
    inc ebx
    add ecx, 2      ; next character
    cmp ecx, VIDEO_MEM + (LINE_WIDTH * 25 + 0) * 2
    jl printScreen

; fix corners
mov al, 218     ; top left
mov [VIDEO_MEM + (LINE_WIDTH * 1 + 0) * 2], al
mov [VIDEO_MEM + (LINE_WIDTH * 1 + 40) * 2], al
mov al, 191     ; top right
mov [VIDEO_MEM + (LINE_WIDTH * 1 + 39) * 2], al
mov [VIDEO_MEM + (LINE_WIDTH * 1 + 79) * 2], al
mov al, 195     ; middle left
mov [VIDEO_MEM + (LINE_WIDTH * 19 + 0) * 2], al
mov [VIDEO_MEM + (LINE_WIDTH * 19 + 40) * 2], al
mov al, 180     ; middle right
mov [VIDEO_MEM + (LINE_WIDTH * 19 + 39) * 2], al
mov [VIDEO_MEM + (LINE_WIDTH * 19 + 79) * 2], al
mov al, 192     ; bottom left
mov [VIDEO_MEM + (LINE_WIDTH * 21 + 0) * 2], al
mov [VIDEO_MEM + (LINE_WIDTH * 21 + 40) * 2], al
mov al, 217     ; bottom right
mov [VIDEO_MEM + (LINE_WIDTH * 21 + 39) * 2], al
mov [VIDEO_MEM + (LINE_WIDTH * 21 + 79) * 2], al

; fix cursor
mov al, 219
mov [VIDEO_MEM + (LINE_WIDTH * 23 + 34) * 2], al

; white on black
mov ah, 0x0f
mov ecx, VIDEO_MEM + (LINE_WIDTH * 22 + 0) * 2 + 1  ; start
mov edx, VIDEO_MEM + (LINE_WIDTH * 25 + 0) * 2 + 1  ; end
call changeColors

; white on light blue
mov ah, 0x9f
mov ecx, VIDEO_MEM + (LINE_WIDTH * 23 + 77) * 2 + 1
mov edx, VIDEO_MEM + (LINE_WIDTH * 24 + 0) * 2 + 1
call changeColors

; black on white
mov ah, 0xf0
mov ecx, VIDEO_MEM + (LINE_WIDTH * 1 + 43) * 2 + 1
mov edx, VIDEO_MEM + (LINE_WIDTH * 1 + 65) * 2 + 1
call changeColors

; yellow on light blue
mov ah, 0x9e
mov ecx, VIDEO_MEM + (LINE_WIDTH * 2 + 1) * 2 + 1
mov edx, VIDEO_MEM + (LINE_WIDTH * 2 + 79) * 2 + 1
call changeColorsSkipBorder
mov ecx, VIDEO_MEM + (LINE_WIDTH * 10 + 2) * 2 + 1
mov edx, VIDEO_MEM + (LINE_WIDTH * 10 + 39) * 2 + 1
call changeColorsSkipBorder

; black on cyan
mov ah, 0x30
mov ecx, VIDEO_MEM + (LINE_WIDTH * 0 + 0) * 2 + 1
mov edx, VIDEO_MEM + (LINE_WIDTH * 1 + 0) * 2 + 1
call changeColors
mov ecx, VIDEO_MEM + (LINE_WIDTH * 3 + 41) * 2 + 1
mov edx, VIDEO_MEM + (LINE_WIDTH * 3 + 79) * 2 + 1
call changeColors
mov ecx, VIDEO_MEM + (LINE_WIDTH * 24 + 0) * 2 + 1
mov edx, VIDEO_MEM + (LINE_WIDTH * 25 + 0) * 2 + 1
footer:
    mov al, [ecx - 1]
    cmp al, "A"
    jl .skipNumber
    mov [ecx], ah
    mov [ecx + 2], ah
    .skipNumber:
    add ecx, 2
    cmp ecx, edx
    jl footer

jmp $

fixBorders:
    cmp al, "_"
    je .fixHorizontalBorder
    .afterFixHorizontalBorder:
    cmp al, "|"
    je .fixVerticalBorder
    .afterFixVerticalBorder:
    ret
.fixHorizontalBorder:
    mov al, 196
    jmp .afterFixHorizontalBorder
.fixVerticalBorder:
    mov al, 179
    jmp .afterFixVerticalBorder

changeColors:
    mov [ecx], ah
    add ecx, 2
    cmp ecx, edx
    jl changeColors
    ret

changeColorsSkipBorder:
    mov al, [ecx - 1]
    cmp al, 179
    je .skipVerticalBorder
    mov [ecx], ah
    .skipVerticalBorder:
    add ecx, 2
    cmp ecx, edx
    jl changeColorsSkipBorder
    ret

times 510-($-$$) db 0
dw 0xaa55

screen:     ; placeholder "?"
    db "  Left     File     Command     Options     Right                               "
    db "?<_ ~/making-an-OS _______________.[^]>??<_ ~/making-an-OS/boot6 _________.[^]>?"
    db "|.n     Name       | Size  |Modify time||.n     Name       | Size  |Modify time|"
    db "|/..               |UP--DIR|Jan 1 00:00||/..               |UP--DIR|Jan 1 00:00|"
    db "|/.git             |   4096|Jan 1 00:00|| boot6.asm        |   8112|Jan 1 00:00|"
    db "|/boot2            |   4096|Jan 1 00:00|| boot6.bin        |   2512|Jan 1 00:00|"
    db "|/boot3            |   4096|Jan 1 00:00|| boot6.png        |  25833|Jan 1 00:00|"
    db "|/boot4            |   4096|Jan 1 00:00||                  |       |           |"
    db "|/boot5            |   4096|Jan 1 00:00||                  |       |           |"
    db "|/boot6            |   4096|Jan 1 00:00||                  |       |           |"
    db "| README.md        |   2513|Jan 1 00:00||                  |       |           |"
    db "|*boot.sh          |    344|Jan 1 00:00||                  |       |           |"
    db "|                  |       |           ||                  |       |           |"
    db "|                  |       |           ||                  |       |           |"
    db "|                  |       |           ||                  |       |           |"
    db "|                  |       |           ||                  |       |           |"
    db "|                  |       |           ||                  |       |           |"
    db "|                  |       |           ||                  |       |           |"
    db "|                  |       |           ||                  |       |           |"
    db "?______________________________________??______________________________________?"
    db "|UP--DIR                               ||UP--DIR                               |"
    db "?__________________ 232G / 251G (92%) _??__________________ 232G / 251G (92%) _?"
    db 'Hint: The file listing format can be customized; do "man mc" for details.       '
    db "C:\home\quang\making-an-OS\boot6> ?                                          [^]"
    db "  1Help  2Menu  3View  4Edit  5Copy  6RenMov  7Mkdir  8Delete  9PullDn  10Quit  "