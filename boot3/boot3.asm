; store & relay keyboard input

; memory address origin
; or mov ds, 0x7c0 because ds:offset = 0x7c0 * 16 + offset
[org 0x7c00]

; initialize stack
mov bp, 0x8000
mov sp, bp

restart:
    ; store pointer to traverse characters
    mov bx, startString
    call print
    ; track input length
    xor cx, cx

type:
    mov ah, 0
    ; BIOS interrupt for keyboard service
    int 0x16
    ; typed ASCII character stored in al
    ; check ENTER key
    cmp al, 0x0d
    je endInput
    ; prohibit special keys
    cmp al, 0x20
    jl type

    ; push to stack ah (0) + al (typed character)
    push ax
    ; immediately print
    mov ah, 0x0e
    int 0x10
    inc cx
    jmp type

endInput:
    ; if nothing was typed then no pop
    cmp sp, bp
    je printResult
    ; move pointer past resultString + offset of input length
    mov bx, resultString
    add bx, 12
    add bx, cx

reverse:
    pop ax
    mov [bx], al
    dec bx
    cmp sp, bp
    jne reverse

printResult:
    mov bx, resultString
    call print

mov bx, buffer
clearBuffer:
    ; straight up mov [bx], 0 impossible
    mov al, 0
    mov [bx], al
    inc bx
    mov al, [bx]
    cmp al, 0
    jne clearBuffer

jmp restart

print:
    mov ah, 0x0e
    ; [string] dereferences like *string
    mov al, [bx]
    int 0x10
    inc bx
    cmp al, 0
    jne print
    ret

startString:
    ; new line `\r\n` due to underlying Windows(?)
    ; change to `\n` in proper Linux(?)
    db 0x0d, 0x0a, "Start typing (ENTER to confirm):", 0

resultString:
    db 0x0d, 0x0a, "You typed: "

; buffer directly concatenated to resultString
; can grow further
buffer:
    times 11 db 0

times 510-($-$$) db 0
db 0x55, 0xaa