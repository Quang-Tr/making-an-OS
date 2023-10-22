; print alphabet in alternating caps aBcD...

; teletype mode in ax register
mov ah, 0x0e
mov al, 'a'

loop:
    ; BIOS interrupt for video service
    int 0x10
    ; switch to next uppercase letter
    sub al, 0x1f
    int 0x10
    ; switch to next lowercase letter
    add al, 0x21
    ; loop until passing z
    cmp al, 'z'
    jl loop

; forever loop at current point
jmp $

; ($-$$) is length of all previous code
; fill with 0 up to 510th byte
times 510-($-$$) db 0

; two-byte end signature of boot sector
db 0x55, 0xaa