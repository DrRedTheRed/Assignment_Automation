; Define memory locations
DATA_START equ 0x30  ; Start address of data block
DATA_END equ 0x3f    ; End address of data block

MOV 30H, #27  
MOV 31H, #5  
MOV 32H, #32  
MOV 33H, #47  
MOV 34H, #38  
MOV 35H, #235  
MOV 36H, #79  
MOV 37H, #17  
MOV 38H, #187  
MOV 39H, #58  
MOV 3AH, #23  
MOV 3BH, #35  
MOV 3CH, #211  
MOV 3DH, #104  
MOV 3EH, #9  

; Initialize checksum
MOV R1, #0           ; Clear accumulator (checksum)

; Loop through the data block and sum up the bytes
MOV R0, #DATA_START  ; Initialize pointer to start of data block
AGAIN:
    MOV A, @R0       ; Load byte from memory into accumulator
    ADD A, R1        ; Add byte to checksum
    MOV R1, A        ; Store result back in accumulator
    INC R0           ; Move to the next byte
    CJNE R0, #DATA_END, AGAIN  ; Continue loop until end of data block is reached

; Take two's complement of checksum
CPL A                ; One's complement
INC A                ; Add 1 to get two's complement

; Result is stored in A

MOV 3FH, A
END