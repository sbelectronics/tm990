***********************************************************************************
*
* fig-FORTH 9900 listing retrieved from: www.forth.org/fig-forth/contents.html.
* The 'listing page x' references in this code relate to the pages of that listing.
* This code contains a bare minimum of comments; more comments are included
* in the original listing.
*
* Modified by Stuart Conner for TM990
* Modified by Scott Baker to fix issues with burning to ROM
*    Put vocabulary in RAM
*    Eliminated RAM scan and used staticly defined ZHI
*    Eliminated self-modifying code of HI, LIMIT, and FORLNK
*
***********************************************************************************
*
* For a specific 9900 system, the following changes need to be made:
*
* - listing page 1:
*   -- ZRAM equate -  beginning of RAM.
*   -- ZROM equate -  beginning of Forth ROM (or area of RAM allocated if running
*                     code from RAM instead of blowing it to ROM).
*                     The code entry point is at the start of the ROM area, or
*                     (start + 4) for a warm start which preserves the user 
*                     dictionary after a program crash (having said that, a warm
*                     start seems to crash the system anyway).
*   -- ZHI equate   - set to highest RAM address
*   -- DISKH equate - address of disk handler interface. Linked to from a BLWP on
*                     listing page 57. System seems to work OK if no disk system
*                     is present as long a no disk calls are made. Changed code to
*                     quit to TIBUG if a disk call is made.
*   -- NSCR equate -  adjust according to the RAM available.
*
* - listing page 8:
*   -- Implementation of 'KEY' command. Currently an XOP to TIBUG routine.
*
* - listing page 9:
*   -- Implementation of 'EMIT' command. Currently an XOP to TIBUG routine.
*   -- Implementation of the '?TERMINAL' command. Currently uses the CRU interface.
*
***********************************************************************************
*
* Other changes made to the code in the listing:
*
* - listing page 1:
*   -- Changed ZRUB equate to match Windows keyboard <Backspace> key.
*
* - listing page 46:
*   -- Added VT100 escape code sequences to clear screen before printing FORTH
*      welcome message.
*
* - listing page 68:
*   -- Changed command 'HELP' to 'VLIST' to match the name used in the
*      FORTH documentation.
*
***********************************************************************************

*** LISTING PAGE 1 ***

DUPLEX  EQU >22
ZRAM    EQU >8000           BEGINNING OF RAM.
ZHI     EQU >DFFF           END OF RAM. MAKE SURE BIG ENOUGH FOR DICT AND BUFFERS
ZROM    EQU >2000           BEGINNING OF FORTH ROM (ACTUALLY RAM IN MY TM990 SYSTEM).
*                           APPROX 5.9KB REQUIRED FOR ROM CODE.
DISKH   EQU >F804           DISK HANDLER INTERFACE (NOT PRESENT ON MY TM990 SYSTEM).
SYSBYT  EQU 22
ZCR     EQU >0D
ZPEROD  EQU >2E
ZFF     EQU >0C
ZLF     EQU >0A
ZRUB    EQU >08             ON WINDOWS KEYBOARD: <DELETE> KEY IS > 7F
*                                                <BACKSPACE> KEY IS >08
ZBELL   EQU >07
ZSPACE  EQU >20
ZLNLEN  EQU 80+1            LINE LENGTH. SETS INPUT LINE LENGTH ONLY - DOESN'T
*                           AFFECT OUTPUT FORMATTING.

*** LISTING PAGE 2 ***

ZCRU    EQU 12
ZW      EQU 11
ZR      EQU 10
ZIP     EQU 9
ZSP     EQU 8
ZNEXT   EQU 6
ZTEMP1  EQU 5
ZTEMP2  EQU 4
ZTEMP3  EQU 3

        AORG ZRAM

DSIZE   EQU 4               SIZE OF DICTIONARY (IN KBYTES).
LOWRAM  EQU $
        BSS 1024*DSIZE
        BSS 128
STAX    EQU $
        BSS 160             INPUT BUFFER.
RSTAX   EQU $

USER0   BSS 6
GSZERO  BSS 2
GRZERO  BSS 2
GTIB    BSS 2
GWIDTH  BSS 2
GWARNG  BSS 2
GFENCE  BSS 2
GDP     BSS 2
GVLNK   BSS 2

GBLK    BSS 2
GIN     BSS 2
GOUT    BSS 2
GSCR    BSS 2
GOFSET  BSS 2
GCONT   BSS 2
GCURR   BSS 2
GSTATE  BSS 2
GBASE   BSS 2
GDPL    BSS 2
GFLD    BSS 2
GCSP    BSS 2
GRNUM   BSS 2
GHLD    BSS 2

MAINWS  BSS 32
DBUFF   BSS 12

FORLNK  BSS 2               SMBAKER RAM space to hold vocabulary
FORVOC  BSS 2

NSCR    EQU 2               DISK BUFFERS FOR SCREENS - WAS 16
ZBUFF   BSS 128+4*8*NSCR    ONE 'NSCR' REQUIRES 1,056 BYTES RAM.
ZLO     EQU ZBUFF

*** LISTING PAGE 3 ***

ENDRAM  EQU ZHI

        AORG ZROM

ORIG    B @MAIN1            COLD START.
        B @MAIN2            WARM START.

        DATA 9900,1

XBS     DATA ZRUB
UP      DATA USER0

XUSER0  DATA 0,0,0

XSP     DATA STAX
XR      DATA RSTAX
XTIB    DATA STAX
XWIDTH  DATA 31
XWARNG  DATA 0
XFENCE  DATA VEND
XGDP    DATA LOWRAM
XGVLNK  DATA FORLNK

XNEXT   DATA NEXT
XIPC    DATA COLD+2
XIPW    DATA ABORT
XVCLNK  DATA FORLNK
XVLINK  DATA VLINK
XVMARK  DATA >81A0

MAIN1   LIMI 0
        LWPI MAINWS
        MOV @XIPC,ZIP

        MOV @XVMARK, @FORLNK       SMBAKER: setup vocabulary in RAM
        MOV @XVLINK, @FORVOC

        JMP START

MAIN2   LIMI 0
        LWPI MAINWS
        MOV @XIPW,ZIP

START   MOV @XSP,ZSP
        MOV @XR,ZR
        MOV @XNEXT,ZNEXT
        CLR @DUPLEX

NEXT    MOV *ZIP+,ZW
        MOV *ZW+,ZTEMP1
        B *ZTEMP1

        BYTE >83
        TEXT 'LI'
        BYTE 'T'+>80
        DATA 0
LIT     DATA $+2
        DECT ZSP
        MOV *ZIP+,*ZSP
        B *ZNEXT

        BYTE >87
        TEXT 'EXECUT'
        BYTE 'E'+>80
        DATA LIT-6
EXEC    DATA $+2
        MOV *ZSP+,ZW
        MOV *ZW+,ZTEMP1
        B *ZTEMP1

*** LISTING PAGE 5 ***

        BYTE >86
        TEXT 'BRANCH'
        BYTE >A0
        DATA EXEC-10
BRAN    DATA $+2
BRAN2   A *ZIP,ZIP
        B *ZNEXT

        BYTE >87
        TEXT '0BRANC'
        BYTE 'H'+>80
        DATA BRAN-10
ZBRAN   DATA $+2
        MOV *ZSP,*ZSP+
        JEQ BRAN2
BUMP    INCT ZIP
        B *ZNEXT

        BYTE >86
        TEXT '(LOOP)'
        BYTE >A0
        DATA ZBRAN-10
LOOP    DATA $+2
        INC *ZR
        JMP PLOP1

        BYTE >87
        TEXT '(+LOOP'
        BYTE ')'+>80
        DATA LOOP-10
PLOOP   DATA $+2
        MOV *ZSP+,ZTEMP1
        A ZTEMP1,*ZR
        MOV ZTEMP1,ZTEMP1
        JLT PLOP2
PLOP1   C *ZR,@2(ZR)
        JLT BRAN2

*** LISTING PAGE 6 ***

        JMP PLOP5
PLOP2   C *ZR,@2(ZR)
        JGT BRAN2
PLOP5   AI ZR,4
        JMP BUMP

        BYTE >84
        TEXT '(DO)'
        BYTE >A0
        DATA PLOOP-10
DO      DATA $+2
        AI ZR,-4
        MOV *ZSP+,*ZR
        MOV *ZSP+,@2(ZR)
        B *ZNEXT

        BYTE >81
        BYTE 'I'+>80
        DATA DO-8
I       DATA $+2
        DECT ZSP
        MOV *ZR,*ZSP
        B *ZNEXT

        BYTE >81
        BYTE 'J'+>80
        DATA I-4
J       DATA $+2
        DECT ZSP
        MOV @4(ZR),*ZSP
        B *ZNEXT

        BYTE >85
        TEXT 'DIGI'
        BYTE 'T'+>80
        DATA J-4
DIGIT   DATA $+2
        MOV *ZSP+,ZTEMP1
        MOV *ZSP,ZTEMP2
        AI ZTEMP2,->30
        CI ZTEMP2,10
        JL DIG1
        AI ZTEMP2,-7
        CI ZTEMP2,10

*** LISTING PAGE 7 ***

        JHE DIG1
DIG3    CLR *ZSP
        B *ZNEXT
DIG1    C ZTEMP2,ZTEMP1
        JHE DIG3
        MOV ZTEMP2,*ZSP
        DECT ZSP
        MOV @XTRUE,*ZSP
        B *ZNEXT

        BYTE >86
        TEXT '(FIND)'
        BYTE >A0
        DATA DIGIT-8
PFIND   DATA $+2
        MOV *ZSP,ZTEMP1
        CLR *ZSP
        CLR ZW
PF1     MOV @2(ZSP),ZTEMP2
        MOVB *ZTEMP1,@1(ZSP)
        MOVB *ZTEMP1+,ZW
        MOVB *ZTEMP2+,ZTEMP3
        XOR ZW,ZTEMP3
        ANDI ZTEMP3,>3F00
        SLA ZTEMP3,1
        JNE PF3
PF2     MOVB *ZTEMP1+,ZW
        MOVB *ZTEMP2+,ZTEMP3
        XOR ZW,ZTEMP3
        SLA ZTEMP3,1
        JNE PF25
        JNC PF2

        AI ZTEMP1,4
        MOV ZTEMP1,@2(ZSP)
        DECT ZSP
        MOV @XTRUE,*ZSP
        B *ZNEXT

PF25    JOC PF35
PF3     MOVB *ZTEMP1+,ZW
        JGT PF3
PF35    MOV *ZTEMP1,ZTEMP1
        JNE PF1
        INCT ZSP

*** LISTING PAGE 8 ***

        CLR *ZSP
        B *ZNEXT

        BYTE >87
        TEXT 'ENCLOS'
        BYTE 'E'+>80
        DATA PFIND-10
ENCL    DATA $+2
        MOV *ZSP+,ZTEMP1
        MOV *ZSP,ZTEMP2
        SWPB ZTEMP1
        SETO ZTEMP3
ENC1    INC ZTEMP3
        CB ZTEMP1,*ZTEMP2+
        JEQ ENC1
        DEC ZTEMP2
        AI ZSP,-6
        MOV ZTEMP3,@4(ZSP)
        MOV ZTEMP3,*ZSP
        INC ZTEMP3
        MOV ZTEMP3,@2(ZSP)
        MOVB *ZTEMP2,*ZTEMP2
        JNE ENC4
        B *ZNEXT
ENC4    INC ZTEMP2
ENC2    MOV ZTEMP3,@2(ZSP)
        MOVB *ZTEMP2,*ZTEMP2
        JEQ ENC3
        INC ZTEMP3
        CB ZTEMP1,*ZTEMP2+
        JNE ENC2
ENC3    MOV ZTEMP3,*ZSP
        B *ZNEXT

        BYTE >83
        TEXT 'KE'
        BYTE 'Y'+>80
        DATA ENCL-10
KEY     DATA $+2
        DECT ZSP
        CLR *ZSP
************************* SYSTEM SPECIFIC 'KEY' COMMAND IMPLEMENTATION HERE

        XOP *ZSP,13         TIBUG ROUTINE TO READ ONE CHARACTER FROM TERMINAL.
        
***************************************************************************
        SWPB *ZSP
        B *ZNEXT

        BYTE >84

*** LISTING PAGE 9 ***

        TEXT 'EMIT'
        BYTE >A0
        DATA KEY-6
EMIT    DATA $+2
        SWPB *ZSP
************************* SYSTEM SPECIFIC 'EMIT' COMMAND IMPLEMENTATION HERE

        XOP *ZSP+,12        TIBUG ROUTINE TO WRITE ONE CHARACTER TO TERMINAL.
        
****************************************************************************
        B *ZNEXT

        BYTE >82
        TEXT 'CR'
        BYTE >A0
        DATA EMIT-8
CR      DATA DOCOL
        DATA PTYPE
        BYTE 2,ZCR,ZLF,0
        DATA SEMIS

TTYI    EQU 12              TMS9902 CRU BIT 12 - RECEIVE FRAMING ERROR.
*                           CRU BIT SET HIGH IF A CHARACTER WITH A RECEIVE
*                           FRAMING ERROR IS RECEIVED. SUCH A CHARACTER CAN
*                           BE SENT BY PRESSING <CTRL><BREAK> IN WINDOWS
*                           HYPERTERMINAL. THE ERROR IS CLEARED WHEN ANOTHER
*                           (DIFFERENT) CHARACTER IS SENT.      
        BYTE >89
        TEXT '?TERMINA'
        BYTE 'L'+>80
        DATA CR-6
QTERM   DATA $+2
************************* SYSTEM SPECIFIC '?TERMINAL' COMMAND IMPLEMENTATION HERE

        LI ZCRU,>0080       CRU BASE ADDRESS FOR TMS9902 IN TM990 SYSTEM.
        TB TTYI             STATUS EQ BIT SET IF BREAK CONDITION.
        JNE NOBRK           JUMP IF NO BREAK CONDITION.
        TB TTYI             LOOP UNTIL A KEY IS PRESSED TO CLEAR THE BREAK CONDITION.
        JEQ $-2
        LI ZCRU,1           PUSH 0001 ONTO STACK AS BREAK CONDITION WAS PRESENT.
        JMP Q1
NOBRK   CLR ZCRU            PUSH 0000 ONTO STACK IF BREAK CONDITION NOT PRESENT.
Q1      DECT ZSP
        MOV ZCRU,*ZSP
        B *ZNEXT
*********************************************************************************

        BYTE >85
        TEXT 'CMOV'
        BYTE 'E'+>80
        DATA QTERM-12
CMOVE   DATA $+2
        MOV *ZSP+,ZTEMP1
        MOV *ZSP+,ZTEMP2
        MOV *ZSP+,ZTEMP3

*** LISTING PAGE 10 ***

        MOV ZTEMP1,ZTEMP1
        JEQ CM1
CM2     MOVB *ZTEMP3+,*ZTEMP2+
        DEC ZTEMP1
        JNE CM2
CM1     B *ZNEXT

        BYTE >82
        TEXT 'U*'
        BYTE >A0
        DATA CMOVE-8
MULT    DATA $+2
        MOV *ZSP+,ZTEMP2
        MPY *ZSP,ZTEMP2
        MOV ZTEMP2+1,*ZSP
        DECT ZSP
        MOV ZTEMP2,*ZSP
        B *ZNEXT

        BYTE >82
        TEXT 'U/'
        BYTE >A0
        DATA MULT-6
DIV     DATA $+2
        MOV @2(ZSP),ZTEMP2
        MOV @4(ZSP),ZTEMP2+1
        DIV *ZSP+,ZTEMP2
        MOV ZTEMP2,*ZSP
        MOV ZTEMP2+1,@2(ZSP)
        B *ZNEXT

        BYTE >83
        TEXT 'AN'
        BYTE 'D'+>80
        DATA DIV-6
AND     DATA $+2
        INV *ZSP
        SZC *ZSP+,*ZSP
        B *ZNEXT

        BYTE >82
        TEXT 'OR'
        BYTE >A0
        DATA AND-6
OR      DATA $+2
        SOC *ZSP+,*ZSP
        B *ZNEXT

        BYTE >83
        TEXT 'XO'

*** LISTING PAGE 11 ***

        BYTE 'R'+>80
        DATA OR-6
XOR     DATA $+2
        MOV *ZSP+,ZTEMP1
        XOR *ZSP,ZTEMP1
        MOV ZTEMP1,*ZSP
        B *ZNEXT

        BYTE >83
        TEXT 'SP'
        BYTE '@'+>80
        DATA XOR-6
SPAT    DATA $+2
        DECT ZSP
        MOV ZSP,*ZSP
        INCT *ZSP
        B *ZNEXT

        BYTE >83
        TEXT 'SP'
        BYTE '!'+>80
        DATA SPAT-6
SPSTOR  DATA $+2
        MOV @UP,ZTEMP1
        MOV @GSZERO-USER0(ZTEMP1),ZSP
        B *ZNEXT

        BYTE >83
        TEXT 'RP'
        BYTE '!'+>80        LISTING SAYS BYTE '!'+>A0 BUT THIS PRODUCES WRONG OP-CODE (>C1).
        DATA SPSTOR-6
RPSTOR  DATA $+2
        MOV @UP,ZTEMP1
        MOV @GRZERO-USER0(ZTEMP1),ZR
        B *ZNEXT

        BYTE >82
        TEXT ';S'
        BYTE >A0
        DATA RPSTOR-6
SEMIS   DATA $+2
        MOV *ZR+,ZIP
        B *ZNEXT

        BYTE >85
        TEXT 'LEAV'
        BYTE 'E'+>80

*** LISTING PAGE 12 ***

        DATA SEMIS-6
LEAVE   DATA $+2
        MOV *ZR,@2(ZR)
        B *ZNEXT

        BYTE >82
        TEXT '>R'
        BYTE >A0
        DATA LEAVE-8
TOR     DATA $+2
        DECT ZR
        MOV *ZSP+,*ZR
        B *ZNEXT

        BYTE >82
        TEXT 'R>'
        BYTE >A0
        DATA TOR-6
FROMR   DATA $+2
        DECT ZSP
        MOV *ZR+,*ZSP
        B *ZNEXT

        BYTE >81
        BYTE 'R'+>80
        DATA FROMR-6
R       DATA $+2
        DECT ZSP
        MOV *ZR,*ZSP
        B *ZNEXT

        BYTE >82
        TEXT '0='
        BYTE >A0
        DATA R-4
ZEQU    DATA $+2
        MOV *ZSP,*ZSP
        JEQ PSHTR
        JMP PSHFL

        BYTE >82
        TEXT '0<'
        BYTE >A0
        DATA ZEQU-6
ZLESS   DATA $+2
        MOV *ZSP,*ZSP
        JLT PSHTR
PSHFL   CLR *ZSP
        B *ZNEXT
PSHTR   MOV @XTRUE,*ZSP
        B *ZNEXT

*** LISTING PAGE 13 ***

        BYTE >81
        BYTE '+'+>80
        DATA ZLESS-6
PLUS    DATA $+2
        A *ZSP+,*ZSP
        B *ZNEXT

        BYTE >82
        TEXT 'D+'
        BYTE >A0
        DATA PLUS-4
DPLUS   DATA $+2
        A *ZSP+,@2(ZSP)
        A *ZSP+,@2(ZSP)
        JNC DP1
        INC *ZSP
DP1     B *ZNEXT

        BYTE >85
        TEXT 'MINU'
        BYTE 'S'+>80
        DATA DPLUS-6
MINUS   DATA $+2
        NEG *ZSP
        B *ZNEXT

        BYTE >86
        TEXT 'DMINUS'
        BYTE >A0
        DATA MINUS-8
DMINUS  DATA $+2
        INV @2(ZSP)
        INV *ZSP
        INC @2(ZSP)
        JNC DM1
        INC *ZSP
DM1     B *ZNEXT

        BYTE >84
        TEXT 'OVER'
        BYTE >A0
        DATA DMINUS-10

*** LISTING PAGE 14 ***

OVER    DATA $+2
        DECT ZSP
        MOV @4(ZSP),*ZSP
        B *ZNEXT

        BYTE >84
        TEXT 'DROP'
        BYTE >A0
        DATA OVER-8
DROP    DATA $+2
        INCT ZSP
        B *ZNEXT

        BYTE >84
        TEXT 'SWAP'
        BYTE >A0
        DATA DROP-8
SWAP    DATA $+2
        MOV *ZSP,ZTEMP1
        MOV @2(ZSP),*ZSP
        MOV ZTEMP1,@2(ZSP)
        B *ZNEXT

        BYTE >83
        TEXT 'DU'
        BYTE 'P'+>80
        DATA SWAP-8
DUP     DATA $+2
        DECT ZSP
        MOV @2(ZSP),*ZSP
        B *ZNEXT

        BYTE >82
        TEXT '+!'
        BYTE >A0
        DATA DUP-6
PSTORE  DATA $+2
        MOV *ZSP+,ZTEMP1
        A *ZSP+,*ZTEMP1
        B *ZNEXT

        BYTE >86
        TEXT 'TOGGLE'

*** LISTING PAGE 15 ***

        BYTE >A0
        DATA PSTORE-6
TOGGLE  DATA $+2
        MOV *ZSP+,ZTEMP1
        MOV *ZSP+,ZTEMP2
        MOVB *ZTEMP2,ZTEMP3
        SWPB ZTEMP1
        XOR ZTEMP1,ZTEMP3
        MOVB ZTEMP3,*ZTEMP2
        B *ZNEXT

        BYTE >81
        BYTE '@'+>80
        DATA TOGGLE-10
AT      DATA $+2
        MOV *ZSP,ZTEMP1
        MOV *ZTEMP1,*ZSP
        B *ZNEXT

        BYTE >82
        TEXT 'C@'
        BYTE >A0
        DATA AT-4
CAT     DATA $+2
        MOV *ZSP,ZTEMP1
        MOVB *ZTEMP1,ZTEMP1
        SRL ZTEMP1,8
        MOV ZTEMP1,*ZSP
        B *ZNEXT

        BYTE >81
        BYTE '!'+>80
        DATA CAT-6
STORE   DATA $+2
        MOV *ZSP+,ZTEMP1
        MOV *ZSP+,*ZTEMP1
        B *ZNEXT

        BYTE >82
        TEXT 'C!'
        BYTE >A0
        DATA STORE-4
CSTORE  DATA $+2
        MOV *ZSP+,ZTEMP1
        MOVB @1(ZSP),*ZTEMP1
        INCT ZSP
        B *ZNEXT

        BYTE >81
        BYTE ':'+>80
        DATA CSTORE-6
COLON   DATA DOCOL,QEXEC,STRCSP,CURR

*** LISTING PAGE 16 ***

        DATA AT,CONT,STORE,CREATE,RTBKT,PSCODE
DOCOL   DECT ZR
        MOV ZIP,*ZR
        MOV ZW,ZIP
        B *ZNEXT

        BYTE >C1
        BYTE ';'+>80
        DATA COLON-4
SEMI    DATA DOCOL,QCSP,COMPI,SEMIS,SMUDGE,LBKT,SEMIS

        BYTE >88
        TEXT 'CONSTANT'
        BYTE >A0
        DATA SEMI-4
CON     DATA DOCOL,CREATE,SMUDGE,COMMA,PSCODE
DOCON   DECT ZSP
        MOV *ZW,*ZSP
        B *ZNEXT

        BYTE >88
        TEXT 'VARIABLE'
        BYTE >A0
        DATA CON-12
VAR     DATA DOCOL,CON
        DATA PSCODE

*** LISTING PAGE 17 ***

DOVAR   DECT ZSP
        MOV ZW,*ZSP
        B *ZNEXT

        BYTE >84
        TEXT 'USER'
        BYTE >A0
        DATA VAR-12
USER    DATA DOCOL,CON,PSCODE
DOUSER  DECT ZSP
        MOV *ZW,*ZSP
        A @UP,*ZSP
        B *ZNEXT

        BYTE >87
        TEXT '<BUILD'
        BYTE 'S'+>80
        DATA USER-8
BUILDS  DATA DOCOL,ZERO,CON,SEMIS

        BYTE >85
        TEXT 'DOES'
        BYTE '>'+>80
        DATA BUILDS-10
DOES    DATA DOCOL,FROMR,LATEST,PFA,STORE,PSCODE
DODOES  DECT ZSP
        MOV ZW,*ZSP
        INCT *ZSP
        MOV *ZW,ZW
        JMP DOCOL

        BYTE >81
        BYTE '0'+>80
        DATA DOES-8
ZERO    DATA DOCON

*** LISTING PAGE 18 ***

        DATA 0

        BYTE >81
        BYTE '1'+>80
        DATA ZERO-4
ONE     DATA DOCON
X1W     EQU $
XTRUE   DATA 1

        BYTE >81
        BYTE '2'+>80
        DATA ONE-4
TWO     DATA DOCON,2

        BYTE >81
        BYTE '3'+>80
        DATA TWO-4
THREE   DATA DOCON,3

        BYTE >82
        TEXT 'BL'
        BYTE >A0
        DATA THREE-4
BL      DATA DOCON,ZSPACE

        BYTE >85
        TEXT 'FIRS'
        BYTE 'T'+>80
        DATA BL-6
FIRST   DATA DOCON,ZBUFF

        BYTE >85
        TEXT 'LIMI'
        BYTE 'T'+>80
        DATA FIRST-8
LIMIT   DATA DOCON,ZHI

        BYTE >85
        TEXT 'B/BU'
        BYTE 'F'+>80
        DATA LIMIT-8
BPBUF   DATA DOCON,128

*** LISTING PAGE 19 ***

        BYTE >85
        TEXT 'B/SC'
        BYTE 'R'+>80
        DATA BPBUF-8
BPSCR   DATA DOCON,8

        BYTE >82
        TEXT 'S0'
        BYTE >A0
        DATA BPSCR-8
SZERO   DATA DOUSER,GSZERO-USER0

        BYTE >82
        TEXT 'R0'
        BYTE >A0
        DATA SZERO-6
RZERO   DATA DOUSER,GRZERO-USER0

        BYTE >83
        TEXT 'TI'
        BYTE 'B'+>80
        DATA RZERO-6
TIB     DATA DOUSER,GTIB-USER0

        BYTE >85
        TEXT 'WIDT'
        BYTE 'H'+>80
        DATA TIB-6
WIDTH   DATA DOUSER,GWIDTH-USER0

        BYTE >87
        TEXT 'WARNIN'
        BYTE 'G'+>80
        DATA WIDTH-8
WARNG   DATA DOUSER,GWARNG-USER0

        BYTE >85

*** LISTING PAGE 20 ***

        TEXT 'FENC'
        BYTE 'E'+>80
        DATA WARNG-10
FENCE   DATA DOUSER,GFENCE-USER0

        BYTE >82
        TEXT 'DP'
        BYTE >A0
        DATA FENCE-8
DP      DATA DOUSER,GDP-USER0

        BYTE >88
        TEXT 'VOC-LINK'
        BYTE >A0
        DATA DP-6
VOCLNK  DATA DOUSER,GVLNK-USER0

        BYTE >83
        TEXT 'BL'
        BYTE 'K'+>80
        DATA VOCLNK-12
BLK     DATA DOUSER,GBLK-USER0

        BYTE >82
        TEXT 'IN'
        BYTE >A0
        DATA BLK-6
IN      DATA DOUSER,GIN-USER0

        BYTE >83
        TEXT 'OU'
        BYTE 'T'+>80
        DATA IN-6
OUT     DATA DOUSER,GOUT-USER0

        BYTE >83
        TEXT 'SC'

*** LISTING PAGE 21 ***

        BYTE 'R'+>80
        DATA OUT-6
SCR     DATA DOUSER,GSCR-USER0

        BYTE >86
        TEXT 'OFFSET'
        BYTE >A0
        DATA SCR-6
OFFSET  DATA DOUSER,GOFSET-USER0

        BYTE >87
        TEXT 'CONTEX'
        BYTE 'T'+>80
        DATA OFFSET-10
CONT    DATA DOUSER,GCONT-USER0

        BYTE >87
        TEXT 'CURREN'
        BYTE 'T'+>80
        DATA CONT-10
CURR    DATA DOUSER,GCURR-USER0

        BYTE >85
        TEXT 'STAT'
        BYTE 'E'+>80
        DATA CURR-10
STATE   DATA DOUSER,GSTATE-USER0

        BYTE >84
        TEXT 'BASE'
        BYTE >A0
        DATA STATE-8

*** LISTING PAGE 22 ***

BASE    DATA DOUSER,GBASE-USER0

        BYTE >83
        TEXT 'DP'
        BYTE 'L'+>80
        DATA BASE-8
DPL     DATA DOUSER,GDPL-USER0

        BYTE >83
        TEXT 'FL'
        BYTE 'D'+>80
        DATA DPL-6
FLD     DATA DOUSER,GFLD-USER0

        BYTE >83
        TEXT 'CS'
        BYTE 'P'+>80
        DATA FLD-6
CSP     DATA DOUSER,GCSP-USER0

        BYTE >82
        TEXT 'R#'
        BYTE >A0
        DATA CSP-6
RNUM    DATA DOUSER,GRNUM-USER0

        BYTE >83
        TEXT 'HL'
        BYTE 'D'+>80
        DATA RNUM-6
HLD     DATA DOUSER,GHLD-USER0

        BYTE >82
        TEXT '1+'
        BYTE >A0
        DATA HLD-6
ONEP    DATA $+2
        INC *ZSP
        B *ZNEXT

        BYTE >82
        TEXT '2+'
        BYTE >A0
        DATA ONEP-6
TWOP    DATA $+2

*** LISTING PAGE 23 ***

        INCT *ZSP
        B *ZNEXT

        BYTE >84
        TEXT 'HERE'
        BYTE >A0
        DATA TWOP-6
HERE    DATA DOCOL,DP,AT,SEMIS

        BYTE >85
        TEXT 'ALLO'
        BYTE 'T'+>80
        DATA HERE-8
ALLOT   DATA DOCOL,DP,PSTORE,SEMIS

        BYTE >81
        BYTE ','+>80
        DATA ALLOT-8
COMMA   DATA DOCOL,HERE,STORE,TWO,ALLOT,SEMIS

        BYTE >82
        TEXT 'C,'
        BYTE >A0
        DATA COMMA-4
CCOMMA  DATA DOCOL,HERE,CSTORE,ONE,ALLOT,SEMIS

        BYTE >81
        BYTE '-'+>80
        DATA CCOMMA-6
SUB     DATA $+2
        S *ZSP+,*ZSP
        B *ZNEXT

        BYTE >81

*** LISTING PAGE 24 ***

        BYTE '='+>80
        DATA SUB-4
EQUAL   DATA DOCOL,SUB,ZEQU,SEMIS

        BYTE >81
        BYTE '<'+>80
        DATA EQUAL-4
LESS    DATA DOCOL,SUB,ZLESS,SEMIS

        BYTE >81
        BYTE '>'+>80
        DATA LESS-4
GREAT   DATA DOCOL,SWAP,SUB,ZLESS,SEMIS

        BYTE >83
        TEXT 'RO'
        BYTE 'T'+>80
        DATA GREAT-4
ROT     DATA DOCOL,TOR,SWAP,FROMR,SWAP,SEMIS

        BYTE >85
        TEXT 'SPAC'
        BYTE 'E'+>80
        DATA ROT-6
SPACE   DATA DOCOL,BL,EMIT,SEMIS

        BYTE >84
        TEXT '-DUP'
        BYTE >A0
        DATA SPACE-8
DDUP    DATA DOCOL,DUP,ZBRAN,QDUP1-$,DUP

*** LISTING PAGE 25 ***

QDUP1   DATA SEMIS

        BYTE >88
        TEXT 'TRAVERSE'
        BYTE >A0
        DATA DDUP-8
TRAVRS  DATA DOCOL,SWAP
TRA1    DATA OVER,PLUS,LIT,>7F,OVER
        DATA CAT,LESS,ZBRAN,TRA1-$
        DATA SWAP,DROP,SEMIS

        BYTE >83
        TEXT 'LF'
        BYTE 'A'+>80
        DATA TRAVRS-12
LFA     DATA DOCOL,LIT,4,SUB,SEMIS

        BYTE >83
        TEXT 'CF'
        BYTE 'A'+>80
        DATA LFA-6
CFA     DATA DOCOL,TWO,SUB,SEMIS

        BYTE >83
        TEXT 'NF'
        BYTE 'A'+>80
        DATA CFA-6
NFA     DATA DOCOL,LIT,5,SUB,LIT,-1,TRAVRS,SEMIS

*** LISTING PAGE 26 ***

        BYTE >83
        TEXT 'PF'
        BYTE 'A'+>80
        DATA NFA-6
PFA     DATA DOCOL,ONE,TRAVRS,LIT,5,PLUS,SEMIS

        BYTE >86
        TEXT 'LATEST'
        BYTE >A0
        DATA PFA-6
LATEST  DATA DOCOL,CURR,AT,AT,SEMIS

        BYTE >84
        TEXT '!CSP'
        BYTE >A0
        DATA LATEST-10
STRCSP  DATA DOCOL,SPAT,CSP,STORE,SEMIS

        BYTE >86
        TEXT '?ERROR'
        BYTE >A0
        DATA STRCSP-8
QERROR  DATA DOCOL,SWAP,ZBRAN,QERR1-$,ERROR,SEMIS

*** LISTING PAGE 27 ***

QERR1   DATA DROP,SEMIS

        BYTE >85
        TEXT '?COM'
        BYTE 'P'+>80
        DATA QERROR-10
QCOMP   DATA DOCOL,STATE,AT,ZEQU,LIT,17,QERROR,SEMIS

        BYTE >85
        TEXT '?EXE'
        BYTE 'C'+>80
        DATA QCOMP-8
QEXEC   DATA DOCOL,STATE,AT,LIT,18,QERROR,SEMIS

        BYTE >86
        TEXT '?PAIRS'
        BYTE >A0
        DATA QEXEC-8
QPAIRS  DATA DOCOL,SUB,LIT,19,QERROR,SEMIS

        BYTE >84
        TEXT '?CSP'

*** LISTING PAGE 28 ***

        BYTE >A0
        DATA QPAIRS-10
QCSP    DATA DOCOL,SPAT,CSP,AT,SUB,LIT,20,QERROR,SEMIS

        BYTE >88
        TEXT '?LOADING'
        BYTE >A0
        DATA QCSP-8
QLOAD   DATA DOCOL,BLK,AT,ZEQU,LIT,22,QERROR,SEMIS

        BYTE >87
        TEXT 'COMPIL'
        BYTE 'E'+>80
        DATA QLOAD-12
COMPI   DATA DOCOL,QCOMP,FROMR,DUP,TWOP,TOR,AT,COMMA,SEMIS

        BYTE >C1
        BYTE '['+>80
        DATA COMPI-10
LBKT    DATA DOCOL,ZERO,STATE,STORE,SEMIS

*** LISTING PAGE 29 ***

        BYTE >81
        BYTE ']'+>80
        DATA LBKT-4
RTBKT   DATA DOCOL,LIT,>C0,STATE,STORE,SEMIS

        BYTE >86
        TEXT 'SMUDGE'
        BYTE >A0
        DATA RTBKT-4
SMUDGE  DATA DOCOL,LATEST,LIT,>20,TOGGLE,SEMIS

        BYTE >83
        TEXT 'HE'
        BYTE 'X'+>80
        DATA SMUDGE-10
HEX     DATA DOCOL,LIT,16,BASE,STORE,SEMIS

        BYTE >87
        TEXT 'DECIMA'
        BYTE 'L'+>80
        DATA HEX-6
DEC     DATA DOCOL,LIT,10,BASE,STORE,SEMIS

*** LISTING PAGE 30 ***

        BYTE >87
        TEXT '(;CODE'
        BYTE ')'+>80
        DATA DEC-10
PSCODE  DATA DOCOL,FROMR,LATEST,PFA,CFA,STORE,SEMIS

        BYTE >C5
        TEXT ';COD'
        BYTE 'E'+>80
        DATA PSCODE-10
SEMIC   DATA DOCOL,QCSP,COMPI,PSCODE,LBKT,SMUDGE,ASSMB,SEMIS

        BYTE >85
        TEXT 'COUN'
        BYTE 'T'+>80
        DATA SEMIC-8
COUNT   DATA DOCOL,DUP,ONEP,SWAP,CAT,SEMIS

        BYTE >84
        TEXT 'TYPE'
        BYTE >A0
        DATA COUNT-8
TYPE    DATA DOCOL,DDUP,ZBRAN,TYP2-$,OVER,PLUS,SWAP,DO

*** LISTING PAGE 31 ***

TYP1    DATA I,CAT,EMIT,LOOP,TYP1-$,SEMIS
TYP2    DATA DROP,SEMIS

        BYTE >89
        TEXT '-TRAILIN'
        BYTE 'G'+>80
        DATA TYPE-8
DTRAIL  DATA DOCOL,DUP,ZERO,DO
DTRL1   DATA OVER,OVER,PLUS,ONE,SUB,CAT,BL,SUB
        DATA ZBRAN,DTRL2-$,LEAVE,BRAN,DTRL3-$
DTRL2   DATA ONE,SUB
DTRL3   DATA LOOP,DTRL1-$,SEMIS

        BYTE >84
        TEXT '(.")'
        BYTE >A0
        DATA DTRAIL-12
PTYPE   DATA DOCOL,R
        DATA COUNT,DUP,ONEP,ECELLS,FROMR,PLUS

*** LISTING PAGE 32 ***

        DATA TOR,TYPE,SEMIS

        BYTE >C2
        TEXT '."'
        BYTE >A0
        DATA PTYPE-8
STRING  DATA DOCOL,LIT,'"',STATE,AT,ZBRAN,STR1-$
        DATA COMPI,PTYPE,WORD,HERE,CAT,ONEP
        DATA ECELLS,ALLOT,SEMIS
STR1    DATA WORD,HERE,COUNT,TYPE,SEMIS

        BYTE >86
        TEXT '?STACK'
        BYTE >A0
        DATA STRING-6
QSTACK  DATA DOCOL,SPAT,SZERO,AT,GREAT,ONE,QERROR
        DATA SPAT,HERE,LESS,TWO,QERROR
        DATA SEMIS

*** LISTING PAGE 33 ***

        BYTE >86
        TEXT '=CELLS'
        BYTE >A0
        DATA QSTACK-10
ECELLS  DATA $+2
        INC *ZSP
        SZC @X1W,*ZSP
        B *ZNEXT

        BYTE >86
        TEXT 'EXPECT'
        BYTE >A0
        DATA ECELLS-10
EXPECT  DATA DOCOL,ZERO,DO
EXP1    DATA KEY,DUP,LIT,ZCR,EQUAL,ZBRAN,EXP2-$
        DATA DROP,SPACE,LEAVE,ZERO,BRAN,EXP4-$
EXP2    DATA DUP,LIT,XBS,AT,EQUAL,ZBRAN,EXP5-$
        DATA DROP,I,ZEQU,ZBRAN,EXP6-$
        DATA LIT,ZBELL,EMIT,ZERO,BRAN,EXP4-$

*** LISTING PAGE 34 ***

EXP5    DATA DUP,LIT,>18,EQUAL,ZBRAN,EXP3-$
        DATA DROP,FROMR,ZERO,TOR,SUB
        DATA PTYPE
        BYTE 9
        TEXT ' *DEL*'
        BYTE ZBELL,ZCR,ZLF
        DATA ZERO,BRAN,EXP4-$
EXP6    DATA LIT,8,EMIT,FROMR,ONE,SUB,TOR,ONE,SUB,ZERO
        DATA BRAN,EXP4-$
EXP3    DATA DUP,EMIT,OVER,CSTORE,ONEP,ONE
EXP4    DATA PLOOP,EXP1-$,ZERO
        DATA SWAP,OVER,OVER,CSTORE,ONEP,CSTORE,SEMIS

        BYTE >85
        TEXT 'QUER'

*** LISTING PAGE 35 ***

        BYTE 'Y'+>80
        DATA EXPECT-10
QUERY   DATA DOCOL,TIB,AT,LIT
        DATA ZLNLEN,EXPECT,ZERO,IN,STORE,SEMIS

        BYTE >C1
        BYTE >80
        DATA QUERY-8
NULL    DATA DOCOL,BLK,AT
        DATA ZBRAN,NULL2-$,ONE
        DATA BLK,PSTORE,ZERO,IN,STORE,BLK,AT,BPSCR,MOD
        DATA ZEQU,ZBRAN,NULL4-$,QEXEC
NULL2   DATA FROMR,DROP
NULL4   DATA SEMIS

        BYTE >84
        TEXT 'FILL'
        BYTE >A0
        DATA NULL-4
FILL    DATA DOCOL,SWAP,TOR,OVER,CSTORE,DUP,ONEP
        DATA FROMR,ONE,SUB,CMOVE,SEMIS

*** LISTING PAGE 36 ***

        BYTE >85
        TEXT 'ERAS'
        BYTE 'E'+>80
        DATA FILL-8
ERASE   DATA DOCOL,ZERO,FILL,SEMIS

        BYTE >86
        TEXT 'BLANKS'
        BYTE >A0
        DATA ERASE-8
BLANKS  DATA DOCOL,BL,FILL,SEMIS

        BYTE >84
        TEXT 'HOLD'
        BYTE >A0
        DATA BLANKS-10
HOLD    DATA DOCOL,LIT,-1,HLD,PSTORE,HLD,AT,CSTORE,SEMIS

        BYTE >83
        TEXT 'PA'
        BYTE 'D'+>80
        DATA HOLD-8
PAD     DATA DOCOL,HERE,LIT,68,PLUS,SEMIS

        BYTE >84

*** LISTING PAGE 37 ***

        TEXT 'WORD'
        BYTE >A0
        DATA PAD-6
WORD    DATA DOCOL,BLK,AT
        DATA ZBRAN,WORD1-$,BLK,AT,BLOCK,BRAN,WORD2-$
WORD1   DATA TIB,AT
WORD2   DATA IN,AT,PLUS,SWAP,ENCL,HERE,LIT,34,BLANKS
        DATA IN,PSTORE,OVER,SUB,TOR,R,HERE,CSTORE
        DATA PLUS,HERE,ONEP
        DATA FROMR,CMOVE,SEMIS

        BYTE >88
        TEXT '(NUMBER)'
        BYTE >A0
        DATA WORD-8
PNUMB   DATA DOCOL
PNUM0   DATA ONEP,DUP,TOR,CAT

*** LISTING PAGE 38 ***

        DATA BASE,AT,DIGIT,ZBRAN,PNUM1-$
        DATA SWAP,BASE,AT
        DATA MULT,DROP,ROT,BASE,AT,MULT
        DATA DPLUS,DPL,AT,ONEP,ZBRAN,PNUM2-$
        DATA ONE,DPL,PSTORE
PNUM2   DATA FROMR,BRAN,PNUM0-$
PNUM1   DATA FROMR,SEMIS

        BYTE >86
        TEXT 'NUMBER'
        BYTE >A0
        DATA PNUMB-12
NUMB    DATA DOCOL,ZERO,ZERO,ROT,DUP,ONEP
        DATA CAT,LIT,'-',EQUAL,DUP,TOR,PLUS,LIT,-1
NUM3    DATA DPL,STORE,PNUMB,DUP,CAT

*** LISTING PAGE 39 ***

        DATA BL,SUB,ZBRAN,NUM1-$,DUP,CAT,LIT,ZPEROD
        DATA SUB,ZERO,QERROR,ZERO,BRAN,NUM3-$
NUM1    DATA DROP,FROMR,ZBRAN,NUM2-$,DMINUS
NUM2    DATA SEMIS

        BYTE >85
        TEXT '-FIN'
        BYTE 'D'+>80
        DATA NUMB-10
DFIND   DATA DOCOL,BL,WORD,HERE,CONT,AT,AT,PFIND
        DATA DUP,ZEQU,ZBRAN,PTIC1-$,DROP,HERE,LATEST,PFIND
PTIC1   DATA SEMIS

        BYTE >87
        TEXT '(ABORT'
        BYTE ')'+>80
        DATA DFIND-8
PABORT  DATA DOCOL,ABORT,SEMIS

*** LISTING PAGE 40 ***

        BYTE >85
        TEXT 'ERRO'
        BYTE 'R'+>80
        DATA PABORT-10
ERROR   DATA DOCOL,WARNG,AT,ZLESS,ZBRAN,ERR1-$,PABORT
ERR1    DATA HERE,COUNT,TYPE,PTYPE

        BYTE 3
        TEXT ' ? '

        DATA MESSAG,SPSTOR,IN,AT,BLK,AT,QUIT,SEMIS

        BYTE >83
        TEXT 'ID'
        BYTE '.'+>80
        DATA ERROR-8
IDDOT   DATA DOCOL,PAD,LIT,ZSPACE,LIT,95,FILL
        DATA DUP,PFA,LFA,OVER,SUB,PAD,SWAP,CMOVE
        DATA PAD,COUNT,LIT,>1F,AND,TYPE,SPACE,SEMIS

*** LISTING PAGE 41 ***

        BYTE >86
        TEXT 'CREATE'
        BYTE >A0
        DATA IDDOT-6
CREATE  DATA DOCOL,DFIND,ZBRAN,CRE1-$
        DATA DROP,NFA,IDDOT,LIT,4,MESSAG,SPACE
CRE1    DATA HERE,DUP,CAT,WIDTH,AT,MIN,ONEP,ECELLS,ALLOT
        DATA DUP,LIT,>A0,TOGGLE,HERE,ONE,SUB,LIT,>80,TOGGLE
        DATA LATEST,COMMA,CURR,AT,STORE,HERE,TWOP,COMMA,SEMIS

        BYTE >C9
        TEXT '[COMPILE'

*** LISTING PAGE 42 ***

        BYTE ']'+>80
        DATA CREATE-10
BCOMPI  DATA DOCOL,DFIND,ZEQU,ZERO,QERROR
        DATA DROP,CFA,COMMA,SEMIS

        BYTE >C7
        TEXT 'LITERA'
        BYTE 'L'+>80
        DATA BCOMPI-12
LITER   DATA DOCOL,STATE,AT,ZBRAN,LIT1-$
        DATA COMPI,LIT,COMMA
LIT1    DATA SEMIS

        BYTE >C8
        TEXT 'DLITERAL'
        BYTE >A0
        DATA LITER-10
DLITER  DATA DOCOL,STATE,AT,ZBRAN,DLIT1-$
        DATA SWAP,LITER,LITER
DLIT1   DATA SEMIS

        BYTE >89
        TEXT 'INTERPRE'

*** LISTING PAGE 43 ***

        BYTE 'T'+>80
        DATA DLITER-12
INTER   DATA DOCOL
INT1    DATA DFIND,ZBRAN,INT2-$
        DATA STATE,AT,LESS,ZBRAN,INT4-$,CFA,COMMA,BRAN,INT1-$
INT4    DATA CFA,EXEC,QSTACK,BRAN,INT1-$
INT2    DATA HERE,NUMB,DPL,AT,ONEP,ZBRAN,INT3-$
        DATA DLITER,BRAN,INT5-$
INT3    DATA DROP,LITER
INT5    DATA QSTACK,BRAN,INT1-$

        BYTE >89
        TEXT 'IMMEDIAT'
        BYTE 'E'+>80
        DATA INTER-12
IMMED   DATA DOCOL,LATEST,LIT,>40,TOGGLE,SEMIS

*** LISTING PAGE 44 ***

        BYTE >8A
        TEXT 'VOCABULARY'
        BYTE >A0
        DATA IMMED-12
VOCAB   DATA DOCOL,BUILDS,LIT,>81A0,COMMA
        DATA CURR,AT,CFA,COMMA
        DATA HERE,VOCLNK,AT,COMMA,VOCLNK,STORE,DOES
DOVOC   DATA TWOP,CONT,STORE,SEMIS

        BYTE >C5
        TEXT 'FORT'
        BYTE 'H'+>80
        DATA VOCAB-14
FORTH   DATA DOCOL,LIT,FORVOC,CONT,STORE,SEMIS

*         BYTE >C5
*         TEXT 'FORT'
*         BYTE 'H'+>80
*         DATA VOCAB-14
* FORTH   DATA DODOES,DOVOC
* FORLNK  DATA >81A0,VLINK,0

        BYTE >8B
        TEXT 'DEFINITION'

*** LISTING PAGE 45 ***

        BYTE 'S'+>80
        DATA FORTH-8
DEFIN   DATA DOCOL,CONT,AT,CURR,STORE,SEMIS

        BYTE >C1
        BYTE '('+>80
        DATA DEFIN-14
PAREN   DATA DOCOL,LIT,')',WORD,SEMIS

        BYTE >84
        TEXT 'QUIT'
        BYTE >A0
        DATA PAREN-4
QUIT    DATA DOCOL,SPSTOR
        DATA ZERO,BLK,STORE,LBKT
QUIT1   DATA RPSTOR,CR,QUERY,INTER
        DATA STATE,AT,ZEQU,ZBRAN,QUIT1-$,PTYPE

        BYTE 3
        TEXT 'ok:'

        DATA BRAN,QUIT1-$

        BYTE >85
        TEXT 'ABOR'
        BYTE 'T'+>80
        DATA QUIT-8
ABORT   DATA DOCOL,SPSTOR,DEC,CR,PTYPE

*** LISTING PAGE 46 ***

        BYTE MSIZE
TITLE   BYTE >1B,>5B,>32,>4A  VT100 ESCAPE CODE TO ERASE SCREEN.
        BYTE >1B,>5B,>48      VT100 ESCAPE CODE TO MOVE CURSOR TO TOP LEFT.
        TEXT '9900 fig-FORTH  Rel 1.0'
        EVEN
MSIZE   EQU $-TITLE
        DATA FORTH,DEFIN
*        DATA HERE, HERE, HERE, LIT, >2, ALLOT, LATEST           SMBAKER: FIX VOCAB IN ROM
*        DATA SWAP, STORE, CURR, STORE, CONT, STORE              ...        
        DATA QUIT

        BYTE >84
        TEXT 'COLD'
        BYTE >A0
        DATA ABORT-8
COLD    DATA ORIG
        DATA LIT,XUSER0,LIT,USER0,LIT,SYSBYT,CMOVE
        DATA DR0,EMPBUF,LIT,-1,DPL,STORE
        DATA ABORT

        BYTE >84

*** LISTING PAGE 47 ***

        TEXT 'S->D'
        BYTE >A0
        DATA COLD-8
STOD    DATA $+2
        SETO ZTEMP1
        MOV *ZSP,*ZSP
        JLT ST1
        CLR ZTEMP1
ST1     DECT ZSP
        MOV ZTEMP1,*ZSP
        B *ZNEXT

        BYTE >82
        TEXT '+-'
        BYTE >A0
        DATA STOD-8
PM      DATA DOCOL,ZLESS,ZBRAN,PM1-$,MINUS
PM1     DATA SEMIS

        BYTE >83
        TEXT 'D+'
        BYTE '-'+>80
        DATA PM-6
DPM     DATA DOCOL,ZLESS,ZBRAN,DPM1-$,DMINUS
DPM1    DATA SEMIS

        BYTE >83
        TEXT 'AB'
        BYTE 'S'+>80
        DATA DPM-6
ABS     DATA $+2
        ABS *ZSP
        B *ZNEXT

        BYTE >84
        TEXT 'DABS'
        BYTE >A0
        DATA ABS-6
DABS    DATA DOCOL,DUP,DPM,SEMIS

*** LISTING PAGE 48 ***

        BYTE >83
        TEXT 'MI'
        BYTE 'N'+>80
        DATA DABS-8
MIN     DATA $+2
        C @2(ZSP),*ZSP
        JLT MN1
        MOV *ZSP,@2(ZSP)
MN1     INCT ZSP
        B *ZNEXT

        BYTE >83
        TEXT 'MA'
        BYTE 'X'+>80
        DATA MIN-6
MAX     DATA $+2
        C *ZSP,@2(ZSP)
        JLT MX1
        MOV *ZSP,@2(ZSP)
MX1     INCT ZSP
        B *ZNEXT

        BYTE >82
        TEXT 'M*'
        BYTE >A0
        DATA MAX-6
MSTAR   DATA DOCOL,OVER,OVER,XOR,TOR,ABS,SWAP,ABS
        DATA MULT,FROMR,DPM,SEMIS

        BYTE >82
        TEXT 'M/'
        BYTE >A0
        DATA MSTAR-6
MSLASH  DATA DOCOL,OVER,TOR,TOR,DABS,R,ABS,DIV

*** LISTING PAGE 49 ***

        DATA FROMR,R,XOR,PM,SWAP,FROMR,PM,SWAP,SEMIS

        BYTE >81
        BYTE '*'+>80
        DATA MSLASH-6
TIMES   DATA DOCOL,MULT,DROP,SEMIS

        BYTE >84
        TEXT '/MOD'
        BYTE >A0
        DATA TIMES-4
DMOD    DATA DOCOL,TOR,STOD,FROMR,MSLASH,SEMIS

        BYTE >81
        BYTE '/'+>80
        DATA DMOD-8
DDIV    DATA DOCOL,DMOD,SWAP,DROP,SEMIS

        BYTE >83
        TEXT 'MO'
        BYTE 'D'+>80
        DATA DDIV-4
MOD     DATA DOCOL,DMOD,DROP,SEMIS

        BYTE >85
        TEXT '*/MO'

*** LISTING PAGE 50 ***

        BYTE 'D'+>80
        DATA MOD-6
MDMOD   DATA DOCOL,TOR,MSTAR,FROMR,MSLASH,SEMIS

        BYTE >82
        TEXT '*/'
        BYTE >A0
        DATA MDMOD-8
MD      DATA DOCOL,MDMOD,SWAP,DROP,SEMIS

        BYTE >85
        TEXT 'M/MO'
        BYTE 'D'+>80
        DATA MD-6
MSLMOD  DATA DOCOL,TOR,ZERO,R,DIV,FROMR,SWAP
        DATA TOR,DIV,FROMR,SEMIS

        BYTE >83
        TEXT 'US'
        BYTE 'E'+>80
        DATA MSLMOD-8
USE     DATA DOVAR,ZBUFF

        BYTE >84
        TEXT 'PREV'
        BYTE >A0
        DATA USE-6
PREV    DATA DOVAR,ZBUFF

*** LISTING PAGE 51 ***

        BYTE >84
        TEXT '+BUF'
        BYTE >A0
        DATA PREV-8
PLSBF   DATA DOCOL,BPBUF,LIT,4,PLUS
        DATA PLUS,DUP,LIMIT,EQUAL
        DATA ZBRAN,PLSB1-$,DROP,FIRST
PLSB1   DATA DUP,PREV,AT,SUB,SEMIS

        BYTE >86
        TEXT 'UPDATE'
        BYTE >A0
        DATA PLSBF-8
UPDATE  DATA DOCOL,PREV,AT,AT,LIT,>8000
        DATA OR,PREV,AT,STORE,SEMIS

        BYTE >8D
        TEXT 'EMPTY-BUFFER'

*** LISTING PAGE 52 ***

        BYTE 'S'+>80
        DATA UPDATE-10
EMPBUF  DATA DOCOL,FIRST,LIMIT,OVER,SUB,ERASE,SEMIS

        BYTE >83
        TEXT 'DR'
        BYTE '0'+>80
        DATA EMPBUF-16
DR0     DATA DOCOL,ZERO,OFFSET,STORE,SEMIS

        BYTE >83
        TEXT 'DR'
        BYTE '1'+>80
        DATA DR0-6
DR1     DATA DOCOL,LIT,2000,OFFSET,STORE,SEMIS

        BYTE >86
        TEXT 'BUFFER'
        BYTE >A0
        DATA DR1-6
BUFFER  DATA DOCOL,USE,AT,DUP,TOR
BUF1    DATA PLSBF,ZBRAN,BUF1-$,USE,STORE
        DATA R,AT,ZLESS
        DATA ZBRAN,BUF2-$,R,TWOP,R,AT,LIT,>7FFF,AND,ZERO,RSLW

*** LISTING PAGE 53 ***

BUF2    DATA R,STORE,R,PREV,STORE,FROMR,TWOP,SEMIS

        BYTE >85
        TEXT 'BLOC'
        BYTE 'K'+>80
        DATA BUFFER-10
BLOCK   DATA DOCOL,OFFSET,AT,PLUS,TOR
        DATA PREV,AT,DUP,AT,R,SUB,DUP,PLUS,ZBRAN,BLK1-$
BLK2    DATA PLSBF,ZEQU,ZBRAN,BLK3-$,DROP,R,BUFFER
        DATA DUP,R,ONE,RSLW,TWO,SUB
BLK3    DATA DUP,AT,R,SUB,DUP,PLUS,ZEQU,ZBRAN,BLK2-$

*** LISTING PAGE 54 ***

        DATA DUP,PREV,STORE
BLK1    DATA FROMR,DROP,TWOP,SEMIS

        BYTE >86
        TEXT '(LINE)'
        BYTE >A0
        DATA BLOCK-8
PLINE   DATA DOCOL,TOR,LIT,64,BPBUF,MDMOD,FROMR
        DATA BPSCR,TIMES,PLUS,BLOCK,PLUS,LIT,64,SEMIS

        BYTE >85
        TEXT '.LIN'
        BYTE 'E'+>80
        DATA PLINE-10
DOTLN   DATA DOCOL,PLINE,DTRAIL,TYPE,SEMIS

        BYTE >87
        TEXT 'MESSAG'

*** LISTING PAGE 55 ***

        BYTE 'E'+>80
        DATA DOTLN-8
MESSAG  DATA DOCOL,WARNG,AT,ZBRAN,MSG1-$,DDUP,ZBRAN,MSG2-$
        DATA LIT,4,OFFSET,AT,BPSCR,DIV,SUB,DOTLN,SEMIS
MSG1    DATA PTYPE
        BYTE 7
        TEXT ' Msg # '
        DATA DOT
MSG2    DATA SEMIS

        BYTE >84
        TEXT 'LOAD'
        BYTE >A0
        DATA MESSAG-10
LOAD    DATA DOCOL,BLK,AT,TOR,IN,AT,TOR,ZERO,IN,STORE
        DATA BPSCR,TIMES,BLK,STORE
        DATA INTER,FROMR,IN,STORE,FROMR,BLK,STORE,SEMIS

*** LISTING PAGE 56 ***

        BYTE >C3
        TEXT '--'
        BYTE '>'+>80
        DATA LOAD-8
ARRO    DATA DOCOL,QLOAD,ZERO,IN,STORE,BPSCR,BLK,AT,OVER,MOD
        DATA SUB,BLK,PSTORE,SEMIS

        BYTE >82
        TEXT 'HI'
        BYTE >A0
        DATA ARRO-6
HI      DATA DOCON,ZHI

        BYTE >82
        TEXT 'LO'
        BYTE >A0
        DATA HI-6
LO      DATA DOCON,ZLO

        BYTE >83
        TEXT 'R/'
        BYTE 'W'+>80
        DATA LO-6
RSLW    DATA DOCOL,LIT,DBUFF+12,HLD,STORE,SWAP,ZERO
        DATA OVER,GREAT,OVER,LIT,3999,GREAT,OR,LIT,6

*** LISTING PAGE 57 ***

        DATA QERROR,LIT,ZCR,HOLD,LIT,2000,DMOD,HL,DROP
        DATA LIT,'/',HOLD,BL,HOLD,LIT,26,DMOD,SWAP,ONEP
        DATA HL,HL,DROP,BL,HOLD,HL,HL,DROP,BL,HOLD
        DATA ZBRAN,RSLW1-$,LIT,'I',BRAN,RSLW2-$
RSLW1   DATA LIT,'O'
RSLW2   DATA HOLD,HLD,AT,DISKRW,LIT,8,QERROR,SEMIS

DISKRW  DATA $+2
        MOV *ZSP+,0
        MOV *ZSP,1
        SETO *ZSP
        
*       BLWP @DISKH         COMMENTED OUT - REPLACED BY FOLLOWING COMMAND.     
        
        B @>0080            NO DISK HANDLING SYSTEM ON MY TM990 SYSTEM.
*                           QUIT TO TIBUG.

        DATA DSKERR
        CLR *ZSP
DSKERR  B *ZNEXT

*** LISTING PAGE 58 ***

HL      DATA DOCOL,ZERO,LIT,10,DIV,SWAP
        DATA LIT,'0',PLUS,HOLD,SEMIS

        BYTE >85
        TEXT 'CASE'
        BYTE ':'+>80
        DATA RSLW-6
CASE    DATA DOCOL,BUILDS,SMUDGE,ABS
        DATA ONE,SUB,COMMA,RTBKT,DOES
DOCASE  DATA DUP,AT,ROT,ABS,MIN,DUP
        DATA PLUS,PLUS,TWOP,AT,EXEC,SEMIS

        BYTE >C1
        BYTE >A7                                    *** '''+>80
        DATA CASE-8
TICK    DATA DOCOL,DFIND,ZEQU,ZERO,QERROR,DROP,LITER,SEMIS

        BYTE >86

*** LISTING PAGE 59 ***

        TEXT 'FORGET'
        BYTE >A0
        DATA TICK-4
FORGET  DATA DOCOL,CURR,AT,CONT,AT,SUB,LIT,24,QERROR
        DATA TICK,DUP,FENCE,AT,LESS,LIT,21,QERROR,DUP,NFA
        DATA DP,STORE,LFA,AT,CURR,AT,STORE,SEMIS

        BYTE >84
        TEXT 'BACK'
        BYTE >A0
        DATA FORGET-10
BACK    DATA DOCOL,HERE,SUB,COMMA,SEMIS

        BYTE >C5
        TEXT 'BEGI'
        BYTE 'N'+>80
        DATA BACK-8
BEGIN   DATA DOCOL,QCOMP,HERE,ONE,SEMIS

*** LISTING PAGE 60 ***

        BYTE >C5
        TEXT 'ENDI'
        BYTE 'F'+>80
        DATA BEGIN-8
ENDIF   DATA DOCOL,QCOMP,TWO,QPAIRS,HERE
        DATA OVER,SUB,SWAP,STORE,SEMIS

        BYTE >C4
        TEXT 'THEN'
        BYTE >A0
        DATA ENDIF-8
THEN    DATA DOCOL,ENDIF,SEMIS

        BYTE >C2
        TEXT 'DO'
        BYTE >A0
        DATA THEN-8
IDO     DATA DOCOL,COMPI,DO,HERE,THREE,SEMIS

        BYTE >C4
        TEXT 'LOOP'
        BYTE >A0
        DATA IDO-6
ILOOP   DATA DOCOL,THREE,QPAIRS,COMPI,LOOP,BACK,SEMIS

*** LISTING PAGE 61 ***

        BYTE >C5
        TEXT '+LOO'
        BYTE 'P'+>80
        DATA ILOOP-8
IPLUP   DATA DOCOL,THREE,QPAIRS,COMPI,PLOOP,BACK,SEMIS

        BYTE >C5
        TEXT 'UNTI'
        BYTE 'L'+>80
        DATA IPLUP-8
UNTIL   DATA DOCOL,ONE,QPAIRS,COMPI,ZBRAN,BACK,SEMIS

        BYTE >C3
        TEXT 'EN'
        BYTE 'D'+>80
        DATA UNTIL-8
END     DATA DOCOL,UNTIL,SEMIS

        BYTE >C5
        TEXT 'AGAI'
        BYTE 'N'+>80
        DATA END-6
AGAIN   DATA DOCOL,ONE,QPAIRS,COMPI,BRAN,BACK,SEMIS

        BYTE >C6
        TEXT 'REPEAT'

*** LISTING PAGE 62 ***

        BYTE >A0
        DATA AGAIN-8
REPEAT  DATA DOCOL,TOR,TOR,AGAIN,FROMR
        DATA FROMR,TWO,SUB,ENDIF,SEMIS

        BYTE >C2
        TEXT 'IF'
        BYTE >A0
        DATA REPEAT-10
IF      DATA DOCOL,COMPI,ZBRAN,HERE,ZERO,COMMA,TWO,SEMIS

        BYTE >C5
        TEXT 'WHIL'
        BYTE 'E'+>80
        DATA IF-6
WHILE   DATA DOCOL,IF,TWOP,SEMIS

        BYTE >C4
        TEXT 'ELSE'
        BYTE >A0
        DATA WHILE-8
ELS     DATA DOCOL,TWO,QPAIRS,COMPI,BRAN
        DATA HERE,ZERO,COMMA,SWAP,TWO,ENDIF,TWO,SEMIS

*** LISTING PAGE 63 ***

        BYTE >86
        TEXT 'SPACES'
        BYTE >A0
        DATA ELS-8
SPACS   DATA DOCOL,ZERO,MAX,DDUP,ZBRAN,SPS2-$,ZERO,DO
SPS1    DATA SPACE,LOOP,SPS1-$
SPS2    DATA SEMIS

        BYTE >82
        TEXT '<#'
        BYTE >A0
        DATA SPACS-10
STRTCN  DATA DOCOL,PAD,HLD,STORE,SEMIS

        BYTE >82
        TEXT '#>'
        BYTE >A0
        DATA STRTCN-6
STPCNV  DATA DOCOL,DROP,DROP,HLD,AT,PAD,OVER,SUB,SEMIS

        BYTE >84
        TEXT 'SIGN'

*** LISTING PAGE 64 ***

        BYTE >A0
        DATA STPCNV-6
SIGN    DATA DOCOL,ROT,ZLESS
        DATA ZBRAN,SGN2-$,LIT,'-',HOLD
SGN2    DATA SEMIS

        BYTE >81
        BYTE '#'+>80
        DATA SIGN-8
NUMSGN  DATA DOCOL,PAD,HLD,AT,SUB,DPL,AT,EQUAL
        DATA ZBRAN,NS2-$,LIT,ZPEROD,HOLD
NS2     DATA BASE,AT,MSLMOD,ROT,LIT,9,OVER,LESS
        DATA ZBRAN,NS1-$,LIT,7,PLUS
NS1     DATA LIT,'0',PLUS,HOLD,SEMIS

        BYTE >82
        TEXT '#S'
        BYTE >A0
        DATA NUMSGN-4
NUMS    DATA DOCOL,NUMSGN,OVER,OVER,OR

*** LISTING PAGE 65 ***

        DATA ZEQU,ZBRAN,NUMS+2-$,SEMIS

        BYTE >83
        TEXT 'D.'
        BYTE 'R'+>80
        DATA NUMS-6
DDOTR   DATA DOCOL,TOR,SWAP,OVER,DABS,STRTCN,NUMS,SIGN
        DATA STPCNV,FROMR,OVER,SUB,SPACS,TYPE,SEMIS

        BYTE >82
        TEXT '.R'
        BYTE >A0
        DATA DDOTR-6
DOTR    DATA DOCOL,TOR,STOD,FROMR,DDOTR,SEMIS

        BYTE >82
        TEXT 'D.'
        BYTE >A0
        DATA DOTR-6
DDOT    DATA DOCOL,ZERO,DDOTR,SPACE,SEMIS

        BYTE >81
        BYTE '.'+>80
        DATA DDOT-6
DOT     DATA DOCOL,STOD,DDOT,SEMIS

*** LISTING PAGE 66 ***

        BYTE >81
        BYTE '?'+>80
        DATA DOT-4
QMRK    DATA DOCOL,AT,DOT,SEMIS

        BYTE >82
        TEXT 'U.'
        BYTE >A0
        DATA QMRK-4
UDOT    DATA DOCOL,ZERO,DDOT,SEMIS

        BYTE >84
        TEXT 'LIST'
        BYTE >A0
        DATA UDOT-6
LIST    DATA DOCOL,BASE,AT,SWAP,DEC,CR,DUP,SCR,STORE,PTYPE

        BYTE 6
        TEXT 'SCR # '

        DATA DOT,LIT,16,ZERO,DO
LIST1   DATA CR,I,THREE,DOTR,SPACE,I,SCR,AT,DOTLN,LOOP,LIST1-$

*** LISTING PAGE 67 ***

        DATA CR,BASE,STORE,SEMIS

        BYTE >85
        TEXT 'INDE'
        BYTE 'X'+>80
        DATA LIST-8
INDEX   DATA DOCOL,BASE,AT,ROT,ROT,LIT,ZFF,EMIT
        DATA CR,ONEP,SWAP,DEC,DO
IDX1    DATA CR,I,THREE,DOTR,SPACE,ZERO,I
        DATA DOTLN,LOOP,IDX1-$,BASE,STORE,SEMIS

        BYTE >85
        TEXT 'TRIA'
        BYTE 'D'+>80
        DATA INDEX-8
TRIAD   DATA DOCOL,LIT,ZFF,EMIT,THREE,DDIV,THREE
        DATA TIMES,THREE,OVER,PLUS,SWAP,DO

*** LISTING PAGE 68 ***

TRI1    DATA CR,I,LIST,LOOP,TRI1-$,CR
        DATA LIT,15,MESSAG,CR,SEMIS

VLINK   BYTE >85
        TEXT 'VLIS'         CHANGED COMMAND NAME FROM 'HELP' TO 'VLIST'.
        BYTE 'T'+>80
        DATA TRIAD-8
HELP    DATA DOCOL,CONT,AT,AT
HELP1   DATA DUP,IDDOT,PFA,LFA,AT,SPACE
HELP2   DATA DUP,ZEQU,ZBRAN,HELP1-$,DROP,SEMIS

VEND    EQU $

ASSMB   DATA DOCOL,SEMIS
        DATA -1
ENDROM  DATA ENDRAM
FOREND  EQU $

        END
