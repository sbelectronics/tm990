; TMS9900 Assembly program to speak "scott was here" using SP0256A-AL2
; Assumes CRU base address of >EFA0 for the speech synthesizer
; Program starts at memory address >2000

    AORG >2000

    DEF START

; Memory-mapped I/O addresses
EFB4    EQU  >EFB4  ; Address to write phonemes
EFB8    EQU  >EFB8  ; Address to unmute amplifier
EFA4    EQU  >EFA4  ; Address to read ALD status

START
    LIMI 0          ; Disable interrupts

    ; Unmute amplifier
    LI   R1,1
    MOVB R1,@EFB8

    ; Speak "scott was here"
    LI   R2,PHRASE
LOOP
    MOVB *R2+,R1    ; Load next phoneme
    JEQ  END        ; If phoneme is 0, end program
    BL   @SPEAK     ; Speak the phoneme
    JMP  LOOP       ; Continue with next phoneme

END
    LIMI 2          ; Re-enable interrupts
    BLWP @0         ; Return to system

SPEAK
    MOVB R1,@EFB4   ; Write phoneme to synthesizer
WAIT
    MOVB @EFA4,R3   ; Read ALD status
    ANDI R3,>0100   ; Check bit 1
    JEQ  WAIT       ; If not set, keep waiting
    RT              ; Return

; Phoneme data for "scott was here"
PHRASE
    BYTE >37        ; /SS/
    BYTE >2A        ; /KK1/
    BYTE >18        ; /AA/
    BYTE >11        ; /TT1/
    BYTE >2E        ; /WW/
    BYTE >1E        ; /UH/
    BYTE >2B        ; /ZZ/
    BYTE >39        ; /HH2/
    BYTE >13        ; /IY/
    BYTE >27        ; /RR2/
    BYTE >00        ; PA1 (pause)
    BYTE >00        ; End marker

    END START
