; store & relay keyboard input

; memory address origin
[org 0x7c00]

restart:
    ; store pointer to traverse characters
    mov bx, start

printStart:
    mov ah, 0x0e
    ; [string] dereferences like *string
    mov al, [bx]
    int 0x10
    inc bx
    cmp al, 0
    jne printStart

mov bx, buffer
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
    ; store to buffer
    mov [bx], al
    ; immediately print typed characters
    mov ah, 0x0e
    int 0x10
    inc bx
    ; +1 for last `\0`
    mov al, [bx+1]
    cmp al, 0
    je type

endInput:
    mov bx, result
printResult:
    mov ah, 0x0e
    mov al, [bx]
    int 0x10
    inc bx
    cmp al, 0
    jne printResult

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

result:
    ; new line `\r\n` due to underlying Windows(?)
    ; change to `\n` in proper Linux(?)
    db 0x0d, 0x0a, "You typed: "

; buffer directly concatenated to result
; buffer before start to easily mark buffer end
buffer:
    ; last byte reserved for `\0`
    times 11 db 0

start:
    db 0x0d, 0x0a, "Start typing (max 10 characters, ENTER to confirm):", 0

times 510-($-$$) db 0
db 0x55, 0xaa