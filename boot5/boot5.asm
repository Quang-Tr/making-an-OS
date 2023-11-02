; read disk with failure detection

[org 0x7c00]

mov bx, readingString
call printString

mov ah, 2       ; int 0x13 function 2
mov al, 1       ; how many sectors to read
                ; cx = 10-bit cylinder + 6-bit sector
mov ch, 0       ; which cylinder
mov cl, 3       ; which sector, starting from 1 (boot sector)
mov dh, 0       ; which head
                ; which drive, already set to current drive in dl
xor bx, bx
mov es, bx      ; mov es, 0 not directly possible
mov bx, sector2 ; es:bx buffer address pointer
int 0x13

jc fail         ; check if carry flag cf is set
cmp al, 1       ; actual sectors read count in al
jne fail
call printString
mov bx, successString
jmp status
fail:
    mov bx, failString

status:
    call printString
    jmp $

printString:
    mov ah, 0x0e
    mov al, [bx]
    int 0x10
    inc bx
    mov al, [bx]
    test al, al
    jnz printString
    ret

readingString:
    db "Reading...", 0
successString:
    db 0x0d, 0x0a, "Success!", 0
failString:
    db 0x0d, 0x0a, "Fail!", 0

times 510-($-$$) db 0
db 0x55, 0xaa

sector2:
    times 512 db 0

sector3:
    db " Messenger from a neighbour sector."
    ; times 512-($-sector3) db 0