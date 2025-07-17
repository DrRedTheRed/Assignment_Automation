;Don't get it. Use ChatGPT. Still don't get it.
;Small modification was made. Chatty makes bullshit contents sometimes. --Dr.Red 2024.3.26

ORG 0x00

MAIN:
    MOV R1, #desired_temperature   ; Set desired temperature in R1
    CALL READ_ROOM_TEMP            ; Call subroutine to read room temperature
    ANL A, #0x02                   ; Mask with 0000 0010 to extract P2.1 value
    CJNE A, #0x00, RUN_COMPRESSOR  ; If P2.1 is 'H', jump to RUN_COMPRESSOR
    SJMP MAIN                      ; If P2.1 is 'L', continue looping

RUN_COMPRESSOR:
    SETB P2.1                      ; Set P2.1 to turn on compressor
    SJMP MAIN                      ; Continue looping

; Subroutine to read room temperature from P1
READ_ROOM_TEMP:
    MOV A, P1                      ; Move input from P1 to accumulator A
    RET                            ; Return from subroutine

; Variable declarations
desired_temperature:  DB 25       ; Desired temperature

END
