include Emu8086.inc
.model small
.stack 100h
.data
    file db "File4.txt",0
    buffer db 5000 dup("$")
    input db 100 dup("?")
    error db "File could not be opened! $"
    error2 db "File could not be closed! $"
.code
main proc
    ; Load data segment
    mov ax, @data
    mov ds, ax
    
    ; Open file in read/write mode
    lea dx, file  
    mov al, 1      ; Read/write mode
    mov ah, 3dh
    int 21h
    jc if_error
    mov bx, ax     ; Store file handle in BX
    
    ; Move file pointer to end (append mode)
    xor cx, cx
    xor dx, dx
    mov al, 2
    mov ah, 42h
    int 21h

    ; Take string input
    lea si, input
take_input:
    mov ah, 1
    int 21h
    cmp al, 0dh    ; Check for Enter key
    je end_input
    mov [si], al
    inc si
    jmp take_input
end_input:
    mov [si], '$'  ; Terminate input for display

    ; Calculate input length and write to file
    lea di, input
    sub si, di
    mov cx, si
    lea dx, input
    mov ah, 40h
    int 21h

    ; Close file after writing
    mov ah, 3eh
    int 21h
    jc not_closed
    
    ; Re-open file in read-only mode
    lea dx, file
    mov al, 0      ; Read-only mode
    mov ah, 3dh
    int 21h
    jc if_error
    mov bx, ax

    ; Read file contents
    lea dx, buffer
    mov cx, 500    ; Read up to 500 bytes
    mov ah, 3fh
    int 21h
    jc if_error

    ; Display file contents
    lea dx, buffer
    mov ah, 9
    int 21h

    ; Close file after reading
    mov ah, 3eh
    int 21h

    jmp exit

if_error:
    lea dx, error
    mov ah, 9
    int 21h 
    jmp exit

not_closed:
    lea dx, error2
    mov ah, 9
    int 21h 
    jmp exit

exit:
main endp
end main
