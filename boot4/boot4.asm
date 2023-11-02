; convert 16-bit hex to dec

[org 0x7c00]

mov bp, 0x8000
mov sp, bp

restart:
    mov bx, startString
    call printString
    ; multiplicand
    mov cx, 0x1000

type:
    xor ah, ah
    int 0x16
    ; restrict to [0-9]
    cmp al, "0"
    jl type
    cmp al, "9"
    jle .ascii09
    ; restrict to [a-f]
    cmp al, "a"
    jl type
    cmp al, "f"
    jle .asciiaf

    jmp type

    .ascii09:
        mov ah, 0x0e
        int 0x10
        sub al, "0"
        jmp .next

    .asciiaf:
        mov ah, 0x0e
        int 0x10
        sub al, 0x57
        jmp .next

    .next:
        xor ah, ah
        ; (dx:)ax = ax * cx
        mul cx
        push ax
        ; e.g., 0x1000 to 0x100
        shr cx, 4
        test cx, cx
        jnz type

addInteger:
    pop ax
    add cx, ax
    cmp sp, bp
    jne addInteger

mov ax, cx
; divisor
mov cx, 10
lastDigit:
    xor dx, dx
    ; dx = dx:ax mod cx
    ; ax = dx:ax / cx
    div cx
    push dx
    test ax, ax
    jnz lastDigit

mov bx, resultString
call printString
printChar:
    pop ax
    mov ah, 0x0e
    add al, "0"
    int 0x10
    cmp sp, bp
    jne printChar

jmp restart

printString:
    mov ah, 0x0e
    mov al, [bx]
    int 0x10
    inc bx
    mov al, [bx]
    test al, al
    jnz printString
    ret

startString:
    db 0x0d, 0x0a, "Convert 16-bit hex (e.g., 0x079b): 0x", 0

resultString:
    db 0x0d, 0x0a, "Decimal: ", 0

times 510-($-$$) db 0
db 0x55, 0xaa