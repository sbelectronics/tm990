       AORG >2000

* Constants
CHANNEL_A_FINE_TUNE  EQU  0
CHANNEL_A_COARSE_TUNE EQU 1
MIXER_CONTROL        EQU  7
CHANNEL_A_VOLUME     EQU  8

C4_TONE              EQU  427
D4_TONE              EQU  380
E4_TONE              EQU  339
F4_TONE              EQU  320
G4_TONE              EQU  285

AY_REG_SELECT        EQU  >F00A
AY_REG_WRITE         EQU  >F00C

* Main program
MAIN   LWPI >8300
       BL   @PLAY_MELODY
       BLWP @0

* Subroutines
MS     MOV  *R11+,R1    * Get ms value
       SLA  R1,2        * Multiply by 4
MS_LOOP
       DEC  R1
       JNE  MS_LOOP
       RT

AY_WRITE
       MOV  *R11+,R0    * Get value
       MOV  *R11+,R1    * Get register
       MOVB R1,@AY_REG_SELECT
       MOVB R0,@AY_REG_WRITE
       RT

SET_TONE
       MOV  *R11+,R0    * Get tone value
       MOVB R0,R1
       SRL  R0,8
       MOVB R1,@AY_REG_SELECT
       MOVB R1,@AY_REG_WRITE
       MOVB @ONE,@AY_REG_SELECT
       MOVB R0,@AY_REG_WRITE
       RT

PLAY_NOTE
       MOV  *R11+,R2    * Get duration
       BL   @SET_TONE
       LI   R0,>FE      * Enable tone on channel A
       LI   R1,MIXER_CONTROL
       BL   @AY_WRITE
       LI   R0,15       * Set volume
       LI   R1,CHANNEL_A_VOLUME
       BL   @AY_WRITE
       MOV  R2,R1       * Set duration
       BL   @MS
       CLR  R0          * Set volume to 0
       LI   R1,CHANNEL_A_VOLUME
       BL   @AY_WRITE
       RT

PAUSE  MOV  *R11+,R1
       BL   @MS
       RT

PLAY_MELODY
       LI   R11,MELODY_DATA
PLAY_LOOP
       MOV  *R11+,R0
       JEQ  PLAY_END
       MOV  *R11+,R1
       BL   @PLAY_NOTE
       LI   R1,200
       BL   @PAUSE
       JMP  PLAY_LOOP
PLAY_END
       RT

* Data
ONE    BYTE 1
       EVEN
MELODY_DATA
       DATA E4_TONE,500, D4_TONE,500, C4_TONE,500, D4_TONE,500
       DATA E4_TONE,500, E4_TONE,500, E4_TONE,1000
       DATA D4_TONE,500, D4_TONE,500, D4_TONE,1000
       DATA E4_TONE,500, G4_TONE,500, G4_TONE,1000
       DATA E4_TONE,500, D4_TONE,500, C4_TONE,500, D4_TONE,500
       DATA E4_TONE,500, E4_TONE,500, E4_TONE,500, E4_TONE,500
       DATA D4_TONE,500, D4_TONE,500, E4_TONE,500, D4_TONE,500
       DATA C4_TONE,1000
       DATA 0  * End of melody marker

       END  MAIN
