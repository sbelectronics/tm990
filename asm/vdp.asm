
* TODO XXX
*   Initialize PRAM to 0 ?
*   Call STXT to set text mode?
*   VDPDSR is our entry to write a message?
*     R9 seems to point to the start, and R10 is the end?

* Asm994a Generated Register Equates
*
R0      EQU     0
R1      EQU     1
R2      EQU     2
R3      EQU     3
R4      EQU     4
R5      EQU     5
R6      EQU     6
R7      EQU     7
R8      EQU     8
R9      EQU     9
R10     EQU     10
R11     EQU     11
R12     EQU     12
R13     EQU     13
R14     EQU     14
R15     EQU     15

*Memory mapped I/O definitions.

VRAMW   EQU >EF30        VDP VRAM data write address.
VDPREG  EQU >EF32        VDP VRAM address and register access address.
VRAMR   EQU >EF20        VDP VRAM data read address.
VDPSTTS EQU >EF22        VDP status read address.

*Text/graphics 1 mode storage.

NTBA    EQU >400         Name table.
PGBA    EQU >800         Pattern generator table.

*Allocation addresses.

* XXX SMBAKER moved PRAM to E000
PRAM    EQU >E000        Beginning of storage in permanent RAM. 
*                        All the high storage data needs to come before >EF00
*                        where the TIBUG data/registers start.

*------------------------------------------------------------------------------
*Data storage area - needs to be in RAM, and is located at the top of RAM.
*------------------------------------------------------------------------------

        AORG PRAM

WPVDP   DATA >0000,>0000,>0000,>0000,>0000  (BSS 16*2)  VDP vowrkspace
        DATA >0000,>0000,>0000,>0000,>0000  Do no clear this, as it is workspace for VDPINI
        DATA >0000,>0000,>0000,>0000,>0000
        DATA >0000

BRAMCLR EQU $            Bottom of RAM to start clearing

STRPTR  DATA 0

CCNT    DATA 0           Column counter.
CURFLG  DATA 0           Cursor flag, 0=on, -1=off.

*I/O local storage area.

IOSTOR  EQU $
CCSAVE  BYTE 0           Device 1 - cursor character save.
FBCOL   BYTE 0           Device 1 - foreground/background colour.
NXLOC   BYTE 0           Device 1 - new X coordinate.
NYLOC   BYTE 0           Device 1 - new Y coordinate.
        DATA 0,0         Device 2 - unload pointer, CR count.
        DATA 0,0         Device 3 - unload pointer, CR count.
        DATA 0,0         Device 4 - Centronics printer.
        DATA 0,0         Device 5
        DATA 0,0         Device 6
        DATA 0,0         Device 7
        DATA 0,0         Device 8
        DATA 0,0         Device 9
        DATA 0,0         Device 10
        DATA 0,0         Device 11
        DATA 0,0         Device 12
        DATA 0,0         Device 13
        DATA 0,0         Device 14
        DATA 0,0         Device 15
        DATA 0,0         Device 16

*MID handler workspace.

MIDWP   DATA >0000,>0000,>0000,>0000,>0000  (BSS 16*2) MID handler workspace - use for the 9900 BLWPs used instead of the 9995 MIDs.
        DATA >0000,>0000,>0000,>0000,>0000
        DATA >0000,>0000,>0000,>0000,>0000
        DATA >0000

*Workspaces for VDP routines.

VDPWP1  DATA >0000,>0000,>0000,>0000,>0000  (BSS 16*2)  R0-R15.
        DATA >0000,>0000,>0000,>0000,>0000
        DATA >0000,>0000,>0000,>0000,>0000
        DATA >0000
V1R3L   EQU VDPWP1+7     LSB of R3.
V1R4L   EQU VDPWP1+9     LSB of R4.
V1R5L   EQU VDPWP1+11    LSB of R5.
V1R6L   EQU VDPWP1+13    LSB of R6.
VDPWP0  DATA 0           R0
XLOC    BYTE 0           R1 MSB  This byte and the following byte must be in the same word.
YLOC    BYTE 0           R1 LSB
        DATA 0,0         R2-R3
BITMAP  BYTE 0,0,0,0,0,0,0,0  R4-R7
        DATA 0,0,0,0,0,0,0,0  R8-R15

*******************************************************************************
*** EVERTHING ABOVE THIS POINT IN THE LISTING (THAT IS, LOWER IN MEMORY) IS ***
*** INITIALISED TO ZERO WHEN THE CODE STARTS.                               ***
*******************************************************************************

CLR2HRE EQU $            Need to clear all memory down to BRAM from this point.

WPR1    DATA 0,0,0       R0-R2
        DATA 0           R3
        DATA 0           R4
        DATA 0,0,0       R5-R7
        DATA 0           R8
        DATA 0           R9
        DATA 0,0,0,0,0,0 R10-R15

INITDST EQU $

VMODE   DATA 0           Mode 0=text, -1=graph              SYS(9)

F$SHOW  DATA 0           When non-zero, print control character symbol instead of
*                        performing control character function.
F$ROLL  DATA 0           When non-zero, start printing from top of screen when
*                        bottom reached instead of scrolling screen.

*Section of code from routine to set VDP for text mode.
*The byte at label SFBC is updated with the VDP foreground/background colour,
*so this needs to be in RAM.

STXTR1  BL @LOADER       Load VDP registers.
        BYTE >00,>80+R0  Text mode, external video off.
        BYTE >90,>80+R1  16K, no display, no interrupt, text, size & mag=0.
        BYTE >01,>80+R2  PNTBA=>400. Screen image table.
        BYTE >01,>80+R4  PGTBA=>800. Pattern descriptor table.
SFBC    BYTE >00,>80+R7  Foreground/background colours.
        DATA 0

        B @STXTR2        Jump back to original code location.

*Section of code from routine to set VDP for graphics 2 mode.
*The byte at label BDCOL is updated with the VDP background colour,
*so this needs to be in RAM.

SGRAR1  BL @LOADER       Load VDP registers.
        BYTE >02,>80+R0  Graphics 2 mode, external video off.
        BYTE >80,>80+R1  16K, no display, no interrupt, graphics 2, size & mag=0.
        BYTE >06,>80+R2  PNTBA=>1800. Screen image table.
        BYTE >FF,>80+R3  CTBA=>2000. Colour table.
        BYTE >03,>80+R4  PGTBA=>0000. Pattern descriptor table.
        BYTE >36,>80+R5  SNTBA=>1B00. Sprite name table.
        BYTE >07,>80+R6  SPGBA=>3800. Sprite pattern generator (descriptor) table.
BDCOL   BYTE >00,>80+R7  Backdrop=background colour.
        DATA 0

        B @SGRAR2        Jump back to original code location.

*On the Cortex, after ROM has been copied to RAM and the system initialised by
*the coldstart routine, the coldstart code area is no longer needed and is used
*as a buffer area and overwritten. As the coldstart area is in EPROM, need to
*provide a separate buffer area in RAM. Buffer needs to be a minimum of 920 bytes
*as it is used for the VDP text mode scroll routine.

TMPBUF  DATA 0,0,0,0,0,0,0,0    920 bytes.
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0

        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0

        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0

        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0

        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0

        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0,0,0,0,0
        DATA 0,0,0,0

*Working set of VDP character patterns. These are populated from the character
*patterns stored in EPROM. See comments at the start of the LAST module.

*Control characters.

PCHTB   DATA >0000,>0000,>0000   NUL        >00
        DATA >0000,>0000,>0000   SOH        >01
        DATA >0000,>0000,>0000   STX        >02
        DATA >0000,>0000,>0000   ETX        >03
        DATA >0000,>0000,>0000   EOT        >04
        DATA >0000,>0000,>0000   ENG        >05
        DATA >0000,>0000,>0000   ACK        >06
        DATA >0000,>0000,>0000   BEL        >07
        DATA >0000,>0000,>0000   BS         >08 (CUR. LEFT)
        DATA >0000,>0000,>0000   HT         >09 (CUR. RIGHT)
        DATA >0000,>0000,>0000   LF         >0A (CUR. DOWN)
        DATA >0000,>0000,>0000   VT         >0B (CUR. UP)
        DATA >0000,>0000,>0000   FF         >0C (CLS & HOME)
        DATA >0000,>0000,>0000   CR         >0D (BEG. LINE)
        DATA >0000,>0000,>0000   SO         >0E
        DATA >0000,>0000,>0000   SI         >0F
        DATA >0000,>0000,>0000   DLE        >10
        DATA >0000,>0000,>0000   DC1        >11
        DATA >0000,>0000,>0000   DC2        >12
        DATA >0000,>0000,>0000   DC3        >13
        DATA >0000,>0000,>0000   DC4        >14
        DATA >0000,>0000,>0000   NAK        >15
        DATA >0000,>0000,>0000   SYN        >16
        DATA >0000,>0000,>0000   ETB        >17
        DATA >0000,>0000,>0000   CAN        >18
        DATA >0000,>0000,>0000   EM         >19
        DATA >0000,>0000,>0000   SUB        >1A
        DATA >0000,>0000,>0000   ESC        >1B
        DATA >0000,>0000,>0000   FS         >1C
        DATA >0000,>0000,>0000   GS         >1D
        DATA >0000,>0000,>0000   RS         >1E (HOME)
        DATA >0000,>0000,>0000   US         >1F

*Printable characters.

        DATA >0000,>0000,>0000   SPACE      >20
        DATA >0000,>0000,>0000   !          >21
        DATA >0000,>0000,>0000   "          >22
        DATA >0000,>0000,>0000   �          >23
        DATA >0000,>0000,>0000   $          >24
        DATA >0000,>0000,>0000   %          >25
        DATA >0000,>0000,>0000   &          >26
        DATA >0000,>0000,>0000   '          >27
        DATA >0000,>0000,>0000   (          >28
        DATA >0000,>0000,>0000   )          >29
        DATA >0000,>0000,>0000   *          >2A
        DATA >0000,>0000,>0000   +          >2B
        DATA >0000,>0000,>0000   COMMA      >2C
        DATA >0000,>0000,>0000   -          >2D
        DATA >0000,>0000,>0000   .          >2E
        DATA >0000,>0000,>0000   /          >2F
        DATA >0000,>0000,>0000   0          >30
        DATA >0000,>0000,>0000   1          >31
        DATA >0000,>0000,>0000   2          >32
        DATA >0000,>0000,>0000   3          >33
        DATA >0000,>0000,>0000   4          >34
        DATA >0000,>0000,>0000   5          >35
        DATA >0000,>0000,>0000   6          >36
        DATA >0000,>0000,>0000   7          >37
        DATA >0000,>0000,>0000   8          >38
        DATA >0000,>0000,>0000   9          >39
        DATA >0000,>0000,>0000   COLON      >3A
        DATA >0000,>0000,>0000   ;          >3B
        DATA >0000,>0000,>0000   <          >3C
        DATA >0000,>0000,>0000   =          >3D
        DATA >0000,>0000,>0000   >0000      >3E
        DATA >0000,>0000,>0000   ?          >3F
        DATA >0000,>0000,>0000   @          >40
        DATA >0000,>0000,>0000   A          >41
        DATA >0000,>0000,>0000   B          >42
        DATA >0000,>0000,>0000   C          >43
        DATA >0000,>0000,>0000   D          >44
        DATA >0000,>0000,>0000   E          >45
        DATA >0000,>0000,>0000   F          >46
        DATA >0000,>0000,>0000   G          >47
        DATA >0000,>0000,>0000   H          >48
        DATA >0000,>0000,>0000   I          >49
        DATA >0000,>0000,>0000   J          >4A
        DATA >0000,>0000,>0000   K          >4B
        DATA >0000,>0000,>0000   L          >4C
        DATA >0000,>0000,>0000   M          >4D
        DATA >0000,>0000,>0000   N          >4E
        DATA >0000,>0000,>0000   O          >4F
        DATA >0000,>0000,>0000   P          >50
        DATA >0000,>0000,>0000   Q          >51
        DATA >0000,>0000,>0000   R          >52
        DATA >0000,>0000,>0000   S          >53
        DATA >0000,>0000,>0000   T          >54
        DATA >0000,>0000,>0000   U          >55
        DATA >0000,>0000,>0000   V          >56
        DATA >0000,>0000,>0000   W          >57
        DATA >0000,>0000,>0000   X          >58
        DATA >0000,>0000,>0000   Y          >59
        DATA >0000,>0000,>0000   Z          >5A
        DATA >0000,>0000,>0000   [          >5B
        DATA >0000,>0000,>0000   \          >5C
        DATA >0000,>0000,>0000   ]          >5D
        DATA >0000,>0000,>0000   ^          >5E
        DATA >0000,>0000,>0000   _          >5F
        DATA >0000,>0000,>0000   `          >60
        DATA >0000,>0000,>0000   a          >61
        DATA >0000,>0000,>0000   b          >62
        DATA >0000,>0000,>0000   c          >63
        DATA >0000,>0000,>0000   d          >64
        DATA >0000,>0000,>0000   e          >65
        DATA >0000,>0000,>0000   f          >66
        DATA >0000,>0000,>0000   g          >67
        DATA >0000,>0000,>0000   h          >68
        DATA >0000,>0000,>0000   i          >69
        DATA >0000,>0000,>0000   j          >6A
        DATA >0000,>0000,>0000   k          >6B
        DATA >0000,>0000,>0000   l          >6C
        DATA >0000,>0000,>0000   m          >6D
        DATA >0000,>0000,>0000   n          >6E
        DATA >0000,>0000,>0000   o          >6F
        DATA >0000,>0000,>0000   p          >70
        DATA >0000,>0000,>0000   q          >71
        DATA >0000,>0000,>0000   r          >72
        DATA >0000,>0000,>0000   s          >73
        DATA >0000,>0000,>0000   t          >74
        DATA >0000,>0000,>0000   u          >75
        DATA >0000,>0000,>0000   v          >76
        DATA >0000,>0000,>0000   w          >77
        DATA >0000,>0000,>0000   x          >78
        DATA >0000,>0000,>0000   y          >79
        DATA >0000,>0000,>0000   z          >7A
        DATA >0000,>0000,>0000   {          >7B
        DATA >0000,>0000,>0000   |          >7C
        DATA >0000,>0000,>0000   }          >7D
        DATA >0000,>0000,>0000   ~          >7E
        DATA >0000,>0000,>0000   DEL        >7F

*911 VDT-type graphics set.

        DATA >0000,>0000,>0000              >80
        DATA >0000,>0000,>0000              >81
        DATA >0000,>0000,>0000              >82
        DATA >0000,>0000,>0000              >83
        DATA >0000,>0000,>0000              >84
        DATA >0000,>0000,>0000              >85
        DATA >0000,>0000,>0000              >86
        DATA >0000,>0000,>0000              >87
        DATA >0000,>0000,>0000  COPYRIGHT   >88
        DATA >0000,>0000,>0000  CHECKED BLK >89
        DATA >0000,>0000,>0000              >8A
        DATA >0000,>0000,>0000              >8B
        DATA >0000,>0000,>0000              >8C
        DATA >0000,>0000,>0000              >8D
        DATA >0000,>0000,>0000              >8E
        DATA >0000,>0000,>0000              >8F
        DATA >0000,>0000,>0000              >90
        DATA >0000,>0000,>0000              >91
        DATA >0000,>0000,>0000              >92
        DATA >0000,>0000,>0000              >93
        DATA >0000,>0000,>0000              >94
        DATA >0000,>0000,>0000              >95
        DATA >0000,>0000,>0000  POUND       >96
        DATA >0000,>0000,>0000              >97
        DATA >0000,>0000,>0000              >98
        DATA >0000,>0000,>0000              >99
        DATA >0000,>0000,>0000              >9A
        DATA >0000,>0000,>0000              >9B
        DATA >0000,>0000,>0000              >9C
        DATA >0000,>0000,>0000              >9D
        DATA >0000,>0000,>0000              >9E
        DATA >0000,>0000,>0000              >9F

*Special character set.

        DATA >0000,>0000,>0000  UP ARROW    >A0
        DATA >0000,>0000,>0000  DOWN ARROW  >A1
        DATA >0000,>0000,>0000  RIGHT ARROW >A2
        DATA >0000,>0000,>0000  LEFT ARROW  >A3
        DATA >0000,>0000,>0000  N.E. ARROW  >A4
        DATA >0000,>0000,>0000  S.W. ARROW  >A5
        DATA >0000,>0000,>0000  S.E. ARROW  >A6
        DATA >0000,>0000,>0000  N.W. ARROW  >A7
        DATA >0000,>0000,>0000  ANCHOR      >A8

*User defined character set.
*Why are these defined as BYTEs rather than DATA?

USERCS  BYTE >00,>00,>00,>00,>00,>00        >A9
        BYTE >00,>00,>00,>00,>00,>00        >AA
        BYTE >00,>00,>00,>00,>00,>00        >AB
        BYTE >00,>00,>00,>00,>00,>00        >AC
        BYTE >00,>00,>00,>00,>00,>00        >AD
        BYTE >00,>00,>00,>00,>00,>00        >AE
        BYTE >00,>00,>00,>00,>00,>00        >AF
        BYTE >00,>00,>00,>00,>00,>00        >B0
        BYTE >00,>00,>00,>00,>00,>00        >B1
        BYTE >00,>00,>00,>00,>00,>00        >B2
        BYTE >00,>00,>00,>00,>00,>00        >B3
        BYTE >00,>00,>00,>00,>00,>00        >B4
        BYTE >00,>00,>00,>00,>00,>00        >B5
        BYTE >00,>00,>00,>00,>00,>00        >B6
        BYTE >00,>00,>00,>00,>00,>00        >B7
        BYTE >00,>00,>00,>00,>00,>00        >B8
        BYTE >00,>00,>00,>00,>00,>00        >B9
        BYTE >00,>00,>00,>00,>00,>00        >BA
        BYTE >00,>00,>00,>00,>00,>00        >BB
        BYTE >00,>00,>00,>00,>00,>00        >BC
        BYTE >00,>00,>00,>00,>00,>00        >BD
        BYTE >00,>00,>00,>00,>00,>00        >BE
        BYTE >00,>00,>00,>00,>00,>00        >BF
        BYTE >00,>00,>00,>00,>00,>00        >C0
        BYTE >00,>00,>00,>00,>00,>00        >C1
        BYTE >00,>00,>00,>00,>00,>00        >C2
        BYTE >00,>00,>00,>00,>00,>00        >C3
        BYTE >00,>00,>00,>00,>00,>00        >C4
        BYTE >00,>00,>00,>00,>00,>00        >C5
        BYTE >00,>00,>00,>00,>00,>00        >C6
        BYTE >00,>00,>00,>00,>00,>00        >C7
        BYTE >00,>00,>00,>00,>00,>00        >C8
        BYTE >00,>00,>00,>00,>00,>00        >C9
        BYTE >00,>00,>00,>00,>00,>00        >CA
        BYTE >00,>00,>00,>00,>00,>00        >CB
        BYTE >00,>00,>00,>00,>00,>00        >CC
        BYTE >00,>00,>00,>00,>00,>00        >CD
        BYTE >00,>00,>00,>00,>00,>00        >CE
        BYTE >00,>00,>00,>00,>00,>00        >CF
        BYTE >00,>00,>00,>00,>00,>00        >D0
        BYTE >00,>00,>00,>00,>00,>00        >D1
        BYTE >00,>00,>00,>00,>00,>00        >D2
        BYTE >00,>00,>00,>00,>00,>00        >D3
        BYTE >00,>00,>00,>00,>00,>00        >D4
        BYTE >00,>00,>00,>00,>00,>00        >D5
        BYTE >00,>00,>00,>00,>00,>00        >D6
        BYTE >00,>00,>00,>00,>00,>00        >D7
        BYTE >00,>00,>00,>00,>00,>00        >D8
        BYTE >00,>00,>00,>00,>00,>00        >D9
        BYTE >00,>00,>00,>00,>00,>00        >DA
        BYTE >00,>00,>00,>00,>00,>00        >DB
        BYTE >00,>00,>00,>00,>00,>00        >DC
        BYTE >00,>00,>00,>00,>00,>00        >DD
        BYTE >00,>00,>00,>00,>00,>00        >DE
        BYTE >00,>00,>00,>00,>00,>00        >DF
        BYTE >00,>00,>00,>00,>00,>00        >E0
        BYTE >00,>00,>00,>00,>00,>00        >E1
        BYTE >00,>00,>00,>00,>00,>00        >E2
        BYTE >00,>00,>00,>00,>00,>00        >E3
        BYTE >00,>00,>00,>00,>00,>00        >E4
        BYTE >00,>00,>00,>00,>00,>00        >E5
        BYTE >00,>00,>00,>00,>00,>00        >E6
        BYTE >00,>00,>00,>00,>00,>00        >E7
        BYTE >00,>00,>00,>00,>00,>00        >E8
        BYTE >00,>00,>00,>00,>00,>00        >E9
        BYTE >00,>00,>00,>00,>00,>00        >EA
        BYTE >00,>00,>00,>00,>00,>00        >EB
        BYTE >00,>00,>00,>00,>00,>00        >EC
        BYTE >00,>00,>00,>00,>00,>00        >ED
        BYTE >00,>00,>00,>00,>00,>00        >EE
        BYTE >00,>00,>00,>00,>00,>00        >EF
        BYTE >00,>00,>00,>00,>00,>00        >F0
        BYTE >00,>00,>00,>00,>00,>00        >F1
        BYTE >00,>00,>00,>00,>00,>00        >F2
        BYTE >00,>00,>00,>00,>00,>00        >F3
        BYTE >00,>00,>00,>00,>00,>00        >F4
        BYTE >00,>00,>00,>00,>00,>00        >F5
        BYTE >00,>00,>00,>00,>00,>00        >F6
        BYTE >00,>00,>00,>00,>00,>00        >F7
        BYTE >00,>00,>00,>00,>00,>00        >F8
        BYTE >00,>00,>00,>00,>00,>00        >F9
        BYTE >00,>00,>00,>00,>00,>00        >FA
        BYTE >00,>00,>00,>00,>00,>00        >FB
        BYTE >00,>00,>00,>00,>00,>00        >FC
        BYTE >00,>00,>00,>00,>00,>00        >FD
        BYTE >00,>00,>00,>00,>00,>00        >FE
        BYTE >00,>00,>00,>00,>00,>00        >FF

        AORG >2000       Load code here, in EPROM. (TIBUG ends around >0BB8.)

        B @START

VDPINIV DATA WPVDP,VDPINIC

VDPDSRV DATA WPVDP,VDPDSRC

VDPSTRV DATA WPVDP,VDPSTRC

*******************************************************************************
*******************************************************************************
*
* MID
*
*******************************************************************************
*******************************************************************************

*Graphics 2 mode storage.

NTBA1   EQU >1800        Name table base address.
CTBA1   EQU >2000        Colour table base address.
PGTBA1  EQU >0000        Pattern generator table base address.
SNTBA1  EQU >1B00        Sprite name table base address.
SPGBA1  EQU >3800        Sprite pattern generator table base address.

*
*VDP utility routines.
*

*Force text mode.

EFTM$   MOV @VMODE,R0    Text mode already?
        JEQ STMXIT       Yes, return to caller.

*Set VDP for text mode.

STXT    MOVB @FBCOL,@SFBC  Set foreground/background colour.

        B @STXTR1        Jump to block of code relocated to RAM as one byte
*                        is updated with the VDP foreground/background colour.

STXTR2  BLWP @LDCS       Load default character set.

        LI R8,NTBA+>4000  Reference PNT. Add >4000 for VDP write operations.
        BL @SENDAD       Send VDP address.

        LI R11,40*24     Set screen size.

CLS     CLR @XLOC        XLOC=0, YLOC=0.
        MOVB @B20,@VRAMW  Write space character.
        DEC R11          Count it.
        JNE CLS          Loop till all done.
        MOVB @B20,@CCSAVE  Set saved character to a ' '.

        CLR @VMODE       Flag VDP in text mode.

        BL @LOADER       Re-enable display.
VDPR1   BYTE >D0,>80+R1  16K, display on, no interrupt, text, size & mag=0.
        DATA 0

STMXIT  RTWP             Return to caller.

*Force graphics 2 mode.

EFGM$   MOV @VMODE,R0    In text mode?
        JNE STMXIT       No, must already be in graphics mode so exit.

*Set VDP for graphics 2 mode.

SGRA    MOVB @FBCOL,@BDCOL  Set background colour.

                                B @SGRAR1        Jump to block of code relocated to RAM as one byte
*                                                is updated with the VDP background colour.

*Clear the sprite pattern generator table (SPG) and sprite name table (SNT).

SGRAR2  CLR R6           Write nulls to VRAM.
        LI R7,VRAMW
        LI R8,SPGBA1+>4000  Reference SPG. Add >4000 for VDP write operations.
        BL @SENDAD       Send VDP address.
        LI R8,256*8      Do 256 8-bit patterns.

KILSPG  MOVB R6,*R7      Null out the pattern.
        MOV R8,R8        Waste some time.
        DEC R8           Count it.
        JNE KILSPG       Loop till all done.

        LI R8,SNTBA1+>4000  Reference SNT. Add >4000 for VDP write operations.
        BL @SENDAD       Send VDP address.
        LI R8,32*8       Kill off all 32 splanes.
        LI R6,>D000      Fill it full of sprite terminators.

KILSNT  MOVB R6,*R7      Clear down SNT.
        MOV R8,R8        Waste some time.
        DEC R8           Count it.
        JNE KILSNT       Loop till all done.

*Set up pattern descriptor table.

GCLEAR  LI R8,NTBA1+>4000  Reference PNT. Add >4000 for VDP write operations.
        BL @SENDAD       Send VDP address.
        SETO R11         Reset count.

SGRA1   INC R11          Next pattern.
        SWPB R11         Position LS byte.
        MOVB R11,@VRAMW  Write it.
        SWPB R11         Restore R11.
        CI R11,3*256     Done all entries?
        JL SGRA1         No, loop around.

*Set up pattern generator table.

        LI R8,PGTBA1+>4000  Reference PGT. Add >4000 for VDP write operations.
        BL @SENDAD       Send VDP address.
        LI R11,3*256*8   Reset count.

SGRA2   CLR @XLOC        Reset XLOC and YLOC.
        MOVB @B00,@VRAMW  Reset entry.
        DEC R11          Done all entries?
        JNE SGRA2        No, loop around.

*Set up pattern colour table.

        LI R8,CTBA1+>4000  Reference CTB. Add >4000 for VDP write operations.
        BL @SENDAD       Send VDP address.
        LI R11,3*256*8   Reset count.

SGRA3   MOVB @FBCOL,@VRAMW  Set entry.
        MOV R8,R8        Waste some time.
        DEC R11          Done all entries?
        JNE SGRA3        No, loop around.

        SETO @VMODE      Set flag to graphics mode.

        MOVB @S$SM,@S$$SM  Reload sprite size and magnification.
        BL @LOADER       Re-enable display.
S$$SM   BYTE >C0,>80+R1
        DATA 0

        RTWP             Return to caller.

*Load the VDP registers from an inline data table.

LOADER  MOVB *R11+,@VDPREG  Write register data.
        C *R11,*R11      Dummy delay for VDP.
        MOVB *R11+,@VDPREG Write register number.
        MOV *R11,*R11    End of data table?
        JNE LOADER       No, loop.
        INCT R11         Yes, skip terminator.
        B *R11           Return.

*Send the address in R8 to the VDP.

SENDAD  SWPB R8          Position LSB.
        MOVB R8,@VDPREG  Send LSB.
        SWPB R8          Position MSB.
        MOVB R8,@VDPREG  Send MSB.
        C *R11,*R11      Dummy delay for VDP.
        B *R11           Return.


*******************************************************************************
*******************************************************************************
*
* VDPDSR
*
*******************************************************************************
*******************************************************************************

*Screen equates.

TLHC    EQU 0            Address of top left hand corner of screen.
BRHC    EQU 959          Address of bottom right hand corner of screen.
SCRSIZ  EQU BRHC-TLHC+1  Screen size.

*
*Graphics mode.
*

GMODE   MOVB @YLOC,R8    Pick up Y location.
        SRL R8,8         Put in LS byte.
        AI R8,>0007      Align with character cell.
        SRL R8,3         Form Y cell number.

        MOVB @XLOC,R7    Pick up X location.
        SRL R7,8         Put in LS byte.
        AI R7,>0007      Align with character cell.
        SRL R7,3         Form X cell number.
        CI R7,31         Off right of screen?
        JLE GM1          No, leave it.
        CLR R7           Yes, reset X cell number.
        INC R8           Increment Y cell number.

GM1     CI R8,23         Off bottom of screen?
        JLE GM2          No, leave it.
        CLR R8           Yes, reset Y cell number.

GM2     SLA R8,5         R8=32*Y cell number.
        A R7,R8          R8=X cell number + (32*Y cell number).
        SLA R8,3         R8=8*(X cell number + (32*Y cell number)).
GM3     AI R8,PGTBA1+>4000  Add in PGT base address and VDP write bit.

*Check for end of text.

GDONE1  BL *R4           Send address to VDP.

GDONE   C R9,R10         Reached end of message?
        JH GREXIT        Yes, exit.
        MOVB *R9+,R0     No, get next character into R0.
        CB R0,@B20       Control character?
        JL GCNTRL        Yes, handle it.

        BLWP @UNPACK     Unpack the bit pattern.
        LI R1,BITMAP     Point to 'BITMAP'.
        LI R0,8          Do 8 bytes.
        MOV R0,R2        Save it.
        A R0,R8          Ready for next character.

CWRITE  MOVB *R1+,@VRAMW  Copy byte to VDP.
        DEC R0           Done?
        JNE CWRITE       No, loop around.

*Now update the colour table.

        AI R8,CTBA1-PGTBA1-8  Reference the colour table.
        BL *R4           Send address to VDP.
UPCTBL  MOVB @FBCOL,@VRAMW  Write the colour information.
        DEC R2           Done?
        JNE UPCTBL       No, loop around.
        AI R8,PGTBA1-CTBA1+8  Yes, restore cursor address.
        BL *R4           Reload VDP address.

CHKBOT  CI R8,32*24*8+PGTBA1+>4000  Off end of table?
        JL GDONE         No, continue.
        AI R8,-32*24*8   Yes, back up a screen.
        JMP GDONE1       And resend address.

*Cursor on/off control.

GFS     CLR @CURFLG      Enable cursor.
        JMP GDONE        And continue.

GGS     SETO @CURFLG     Disable cursor.
        JMP GDONE        And continue.

*Exit from graphics mode.

GREXIT  ANDI R8,>1FF8    Kill pixel and write bits.
        SWPB R8          Position X.
        MOVB R8,@XLOC    Update X.
        SLA R8,11        Position Y.
        MOVB R8,@YLOC    Update Y.
        RTWP             Return to caller.

*
*VDP output routines.
*

VDPSTRC MOV @STRPTR, R9  R9 = start of string
        MOV R9, R10      R10 = end of string
VDPSTRL MOVB *R10, R0    Look for end of String. Get byte at R10.
        JEQ ENDSTR       If zero, we done
        INC R10          Point to next byte
        JMP VDPSTRL      Keep looking
ENDSTR  JMP VDPDSRC      R9=start, R10=end. Print the string.

VDPDSRC LI R4,SENDAD     Reference SENDAD routine.
        MOV @VMODE,R0    What VDP mode?
        JNE GMODE        Graphics mode.
        JMP TMODE        Text mode.

*
*Handle graphic control characters.
*

GCNTRL  BL @JMPR0        Do jump on R0 (uses R1, R2).

GJUMP   BYTE GHT-GJUMP/2,>09  HT - cursor right.
        BYTE GBS-GJUMP/2,>08  BS - cursor left.
        BYTE GLF-GJUMP/2,>0A  LF - cursor down.
        BYTE GVT-GJUMP/2,>0B  VT - cursor up.
        BYTE GFF-GJUMP/2,>0C  FF - clear screen and home.
        BYTE GCR-GJUMP/2,>0D  CR - cursor to beginning of line.
        BYTE GFS-GJUMP/2,>1C  FS - cursor on.
        BYTE GGS-GJUMP/2,>1D  GS - cursor off.
        BYTE GRS-GJUMP/2,>1E  RS - cursor home.
        DATA 0

        JMP GDONE        Loop.

*Cursor right (HT).

GHT     AI R8,8          Next character cell.
GHT1    BL *R4           Send address to VDP.
        JMP CHKBOT       And check it.

*Cursor left (BS).

GBS     AI R8,-8         Back up to previous character cell.
GBS1    BL *R4           Send adress to VDP.
CHKTOP  CI R8,PGTBA1+>4000  Off top of screen?
        JHE GDONE        No, continue.
        AI R8,32*24*8    Yes, add in a screen.
        JMP GDONE1       And resend address to VDP.

*Cursor down (LF).

GLF     AI R8,8*32       Move down a line.
        JMP GHT1         Send address to VDP and check.

*Cursor up (VT).

GVT     AI R8,-8*32      Move up a line.
        JMP GBS1         Send address to VDP and check.

*Clear screen (FF).
*(leaves sprites)

FGMODE  DATA TMPBUF,GCLEAR  Vector into MID code.
GFF     BLWP @FGMODE     Clear graphics screen.
*Fall through to cursor home.

*Cursor home (RS).

GRS     LI R8,PGTBA1+>4000  Reference top of screen.
        JMP GDONE1       Send address to VDP.

*Carriage return (CR).

GCR     ANDI R8,>FF00    Clear the column bits.
        CLR @CCNT        Reset column counter.
        JMP GDONE1       Send address to VDP.

*
*Text mode.
*

FTMODE  DATA TMPBUF,STXT  BLWP vector to STXT routine to set VDP to text mode.

TMODE   MOVB @YLOC,R7    Get Y position.
        SRL R7,8         Position it.
        MPY @D40,R7      R7=0, R8=40*YLOC.
        MOVB @XLOC,R7    Get X position.
        SRL R7,8         Position it.
        A R7,R8          R8 now=linear cursor address.
        CI R8,40*24      Address valid?
        JL REMCUR        Yes, jump.
        BLWP @FTMODE     No, go force text mode.

*Remove cursor.

REMCUR  AI R8,NTBA+>4000  Add in table start and VDP write bit.
        MOV @CURFLG,R0   Cursor enabled?
        JNE RVCA         No, leave screen alone.
        BL *R4           Yes, send address to VDP.
        MOVB @CCSAVE,@VRAMW  Write back character that was under the cursor.
RVCA    BL *R4           Restore VDP cursor address.

*Check for end of message.

DONYET  C R9,R10         Reached end of the message?
        JH PUTCUR        Yes, exit.
        MOVB *R9+,R0     No, get next character.
        MOV @F$SHOW,@F$SHOW  Show all control characters?
        JNE CSHOW        Yes, display control character symbol.
        CB R0,@B20       No, is character a control character?
        JL CNTRL         Yes, handle it.
CSHOW   MOVB R0,@VRAMW   No, write character.
        INC R8           Update cursor position.
OFFBOT  CI R8,NTBA+BRHC+>4000  Cursor off bottom of screen?
        JLE DONYET        No, continue.
        MOV @F$ROLL,@F$ROLL  Yes, scroll disabled?
        JEQ DOROLL       No, do scroll.
        AI R8,-SCRSIZ    Yes, reset R8 to top of screen.
        JMP RVCA         Loop and do next character.

*Scroll routine.

DOROLL  MOV R8,R7        Save cursor position.
        AI R7,-40        Restore cursor position.
        LI R8,NTBA+40    Start reading screen from second line.
        BL *R4           Send address to VDP.

        CLR R1           Get start of buffer.
RDSCR   MOVB @VRAMR,@TMPBUF(R1)  Read character from VDP into buffer.
        INC R1           Increment character count.
        CI R1,920        Done all the characters?
        JL RDSCR         No, loop.

        LI R8,NTBA+>4000  Set VDP for write to top of screen.
        BL *R4           Send address to VDP.

        CLR R1           Get start of buffer.
WRSCR   MOVB @TMPBUF(R1),@VRAMW  Write character from buffer to VDP.
        INC R1           Increment character count.
        CI R1,920        Done all the characters?
        JL WRSCR         No, loop.

        LI R1,40         Now fill bottom line of screen with ' '.
WRSP    MOVB @B20,@VRAMW  Write space character.
        MOVB @B20,@VRAMW  Write space character.
        DECT R1          Done all the characters?
        JNE WRSP         No, loop.

*Now restore the cursor.

        MOV R7,R8        Get saved cursor position.
        BL *R4           Send address to VDP.
        JMP DONYET       And continue output.

OFFTOP  CI R8,NTBA+>4000  Cursor off top of screen?
        JHE DONYET       No, continue.
        AI R8,SCRSIZ     Yes, adjust cursor.
        BL *R4           Send address to VDP.

FD$JMP  JMP DONYET       And continue.

*Put cursor and exit routine.

PUTCUR  AI R8,->4000     Remove write bit from address to put VDP into read mode.
        BL *R4           Send address to VDP.
        CLR R3
        MOVB @VRAMR,R3   Get character under cursor.
        AI R8,>4000      Put VDP back in write mode.
        BL *R4           Send address to VDP.
        MOV @CURFLG,R1   Is cursor enabled?
        JNE PUT$1        No, leave screen.
        MOVB @B7F,@VRAMW  Yes, write cursor character.

*Now work out the X,Y coordinates of the cursor.

PUT$1   AI R8,-CRVAL     -(NTBA+>4000) Strip off table base and VDP write bit.
        CLR R7           Clear ready for division.
        DIV @D40,R7      Split address into X (R8) and Y (R7) coordinates.
        STWP R1          Get workspace pointer.
        MOVB @2*R7+1(R1),@YLOC  Set Y location.
        MOVB @2*R8+1(R1),@XLOC  Set X location.
        MOVB R3,@CCSAVE  Save character under cursor.
        SRL R3,5         R3=8*character value for indexing into character pattern table.
        MOV R3,R8        Set for address.

*Read the pattern for the saved character.

        AI R8,PGBA       R8=address of character pattern.
        BL *R4           Send address to VDP.
        LI R8,BITMAP     Point to bitmap storage area.
        MOV R8,R1        Save address.
        LI R7,8          Do 8 bytes.
        MOV R7,R2        Save it.
RDPAT   MOVB @VRAMR,*R8+  Read byte from VDP.
        DEC R7           Decrement count. All done?
        JNE RDPAT        No, loop.

*Write inverse as character >7F bit pattern.

        LI R8,8*>7F+PGBA+>4000  Reference >7F pattern entry.
        BL *R4           Send address to VDP.
WRPAT   MOVB *R1+,R0     Get pattern.
        INV R0           Invert it.
        MOVB R0,@VRAMW   Send it to the VDP.
        DEC R2           All done?
        JNE WRPAT        No, loop.

        RTWP             Return to caller.

*Cursor on/off control.

FS      CLR @CURFLG      Enable cursor.
        JMP FD$JMP       And continue.

GS      SETO @CURFLG     Disable cursor.
        JMP FD$JMP       And continue.

*Handle text control characters.

CNTRL   BL @JMPR0        Do jump on R0 (uses R1, R2).

CJUMP   BYTE HT-CJUMP/2,>09  HT - cursor right.
        BYTE BS-CJUMP/2,>08  BS - cursor left.
        BYTE LF-CJUMP/2,>0A  LF - cursor down.
        BYTE VT-CJUMP/2,>0B  VT - cursor up.
        BYTE FF-CJUMP/2,>0C  FF - clear screen and home.
        BYTE CR-CJUMP/2,>0D  CR - cursor to beginning of line.
        BYTE FS-CJUMP/2,>1C  FS - cursor on.
        BYTE GS-CJUMP/2,>1D  GS - cursor off.
        BYTE RS-CJUMP/2,>1E  RS - cursor home.
        DATA 0

FDONE   JMP FD$JMP       Ignore illegal control character, do next character.

*Cursor right (HT).

HT      INC R8           Adjust cursor.
UDATED  BL *R4           Send address to VDP.
        B @OFFBOT        Check if cursor is still on screen.

*Cursor left (BS).

BS      DEC R8           Back up cursor.
UDATEU  BL *R4           Send address to VDP.
        JMP OFFTOP       Check if cursor is still on screen.

*Cursor down (LF).

LF      AI R8,40         Down a line.
D40     EQU $-2
        JMP UDATED       Update VDP address and check.

*Cursor up (VT).

VT      AI R8,-40        Up a line.
        JMP UDATEU       Update VDP address and check.

*Clear screen (FF).

FF      LI R8,NTBA+>4000  Reference top of screen.
        BL *R4           Send address for top of screen.
        LI R1,960        Do 960 characters.
CLRSCN  MOV @B20,@VRAMW  Write ' ' to VDP.
        DEC R1           Done all characters?
        JNE CLRSCN       No, loop.
*Fall through to cursor home.

*Cursor home (RS).

RS      LI R8,NTBA+>4000  Reference top of screen.
RS1     BL *R4           Send address for top of screen.
        JMP FDONE

*Carriage return (CR).

CRVAL   EQU NTBA+>4000

CR      AI R8,-CRVAL     Strip off table base and VDP write bit.
        CLR R7           Clear ready for division.
        DIV @D40,R7      Split address into X (R8) and Y (R7) coordinates.
        MPY @D40,R7      Calculate 40*Y.
        AI R8,NTBA+>4000  Add back table base and VDP write bit.
        CLR @CCNT        Reset BASIC's column counter.
        JMP RS1          Update cursor location.

*******************************************************************************
*******************************************************************************
*
* JMP
*
*******************************************************************************
*******************************************************************************

*Entry point for JMPR0.

JMPR0   MOV R11,R2       Get table address.
        CLR R1

JMPR01  MOVB *R11+,R1    Get displacement. Reached end of table?
        JEQ JMPR02       Yes, move on to instruction following table.
        CB R0,*R11+      No, code found?
        JNE JMPR01       No, look at next entry in table.
        SRA R1,7         Yes, position displacement in LSB.
        A R1,R2          Add displacement to start address of table.
        B *R2            Go to routine.

*Byte opcode not found. Return to instruction immediately following the table.

JMPR02  INC R11          Move to line following table.
        B *R11           Return.


*
*Unpack entries from the character generator table in RAM and load them
*into the VDP. LDCS also sets up the PNT.
*
*Call: BLWP @UNPACK
*Call: BLWP @LDCS
*

UNPACK  DATA VDPWP1,$+2  BLWP vector.

        LI R8,BITMAP     Store in 'BITMAP'.
        LI R9,1          Storage increment = 1.
        MOV *R13,R11     Get character number from caller's R0.
        SRL R11,8        Put in LSB.
        MPY @C0006,R11   Calculate inde into table.
        AI R12,PCHTB     Add in table start.
        LI R10,8         Unpack 8 bytes.
        JMP MOD0

LDCS    DATA VDPWP1,$+2  BLWP vector.

*Write pattern names to pattern name table (PNT).

        LI R8,NTBA+>4000  Reference PNT. Add >4000 for VDP write operations.
        BL @SENDAD       Send address to VDP.

        SETO R9          Reset count.
LDCS1   INC R9           Next name.
        SWPB R9          Position LSB.
        MOVB R9,@VRAMW   Write it.
        SWPB R9          Restore R9.
        CI R9,40*24      Name table full?
        JL LDCS1         No, loop.

*Write character set to pattern generator table (PGT).

        LI R8,PGBA+>4000  Reference PGT. Add >4000 for VDP write operations.
        BL @SENDAD       Send address to VDP.

        LI R8,VRAMW      Store character set in pattern table in VRAM.
        CLR R9           Storage increment = 0.
        LI R12,PCHTB     Start at beginning of table.
        LI R10,256*8     Calculate unpacked size.

*Unpack character generator table.

MOD0    LI R7,>0101      Set shift mask.
        SETO R6          Initialise holding register.
MOD1    CLR R5           Initialise data register.
        LI R4,>0001      Initialise adder.
        LI R3,6          Do 6 bits.
C0006   EQU $-2
MOD2    SRC R4,1         Position adder.
        SRC R7,1         Position mask, new byte?
        JNC MOD3         No, skip.
        MOVB *R12+,R6    Yes, get new byte.
MOD3    COC R7,R6        Have we a '1' here?
        JNE MOD4         No, value OK.
        AB R4,R5         Yes, add in adder.
MOD4    DEC R3           Count bit.
        JGT MOD2         Loop till 6 bits done.
        MOVB R5,*R8      Store unpacked byte.
        A R9,R8          Update storage pointer.
        DEC R10          Count byte.
        JGT MOD1         Loop till all bytes done.
        RTWP             Done, return to caller.

* constants from cortex basic

C2000   DATA >2000
B20     EQU C2000
B00     BYTE 0
        BYTE 0           Realign
C7F     DATA >007F
B7F     EQU C7F+1        Cursor character.
S$SM    BYTE >C0,>80+R1  Reload VDP R1.


*------------------------------------------------------------------------------
*Character set for the VDP.
*
*See Cortex firmware documentation for byte packing information.
*
*The initial character patterns are defined in the PCHTBI set at the end
*of this module. At code startup, these patterns are copied to the PCHTB set
*in RAM - it is these that are loaded into the VDP and also these that are
*modified by the CHAR statement. When CHAR is called with no arguments to
*reload the original patterns, the patterns are again copied from the PCHTBI
*set to the PCHTB set.
*------------------------------------------------------------------------------

*The following characters patterns are the initial set.
*See comments at the start of this module.

PCHTBI  DATA >934B,>2449,>2300   NUL        >00
        DATA >6204,>08E8,>E280   SOH        >01
        DATA >6204,>08E8,>4280   STX        >02
        DATA >E20E,>20E8,>E280   ETX        >03
        DATA >E20E,>20E8,>4100   EOT        >04
        DATA >E20D,>2AE8,>A180   ENG        >05
        DATA >624F,>2428,>C280   ACK        >06
        DATA >628C,>28D0,>4180   BEL        >07
        DATA >628D,>A8D0,>2300   BS         >08 (CUR. LEFT)
        DATA >A38A,>0038,>4100   HT         >09 (CUR. RIGHT)
        DATA >820B,>A8F0,>8200   LF         >0A (CUR. DOWN)
        DATA >8942,>0038,>4100   VT         >0B (CUR. UP)
        DATA >E20F,>A8B0,>8200   FF         >0C (CLS & HOME)
        DATA >6208,>1C49,>C480   CR         >0D (BEG. LINE)
        DATA >6205,>0AE8,>A100   SO         >0E
        DATA >6204,>0ED0,>4380   SI         >0F
        DATA >C28A,>3020,>8380   DLE        >10
        DATA >C28A,>3010,>4100   DC1        >11
        DATA >C28B,>3210,>8380   DC2        >12
        DATA >C28B,>3210,>2300   DC3        >13
        DATA >C28A,>3218,>E080   DC4        >14
        DATA >D2C9,>0828,>C280   NAK        >15
        DATA >6204,>0AD0,>4100   SYN        >16
        DATA >E20F,>2AF0,>A300   ETB        >17
        DATA >6206,>1269,>6480   CAN        >18
        DATA >E20E,>20EB,>6A80   EM         >19
        DATA >6207,>0AF0,>A300   SUB        >1A
        DATA >E20E,>26E0,>8180   ESC        >1B
        DATA >E20D,>A890,>2300   FS         >1C
        DATA >6209,>AC91,>A300   GS         >1D
        DATA >E28D,>A810,>2300   RS         >1E (HOME)
        DATA >A28B,>9810,>2300   US         >1F

*Printable characters.

        DATA >0000,>0000,>0000   SPACE      >20
        DATA >2082,>0820,>0200   !          >21
        DATA >5145,>0000,>0000   "          >22
        DATA >514F,>94F9,>4500   ?          >23
        DATA >21EA,>1C2B,>C200   $          >24
        DATA >C321,>0842,>6180   %          >25
        DATA >428A,>10AA,>4680   &          >26
        DATA >1084,>0000,>0000   '          >27
        DATA >2108,>2081,>0200   (          >28
        DATA >2040,>8208,>4200   )          >29
        DATA >22A7,>3E72,>A200   *          >2A
        DATA >0082,>3E20,>8000   +          >2B
        DATA >0000,>0020,>8400   COMMA      >2C
        DATA >0000,>3E00,>0000   -          >2D
        DATA >0000,>0000,>0200   .          >2E
        DATA >0021,>0842,>0000   /          >2F
        DATA >7229,>AACA,>2700   0          >30
        DATA >2182,>0820,>8700   1          >31
        DATA >7220,>8C42,>0F80   2          >32
        DATA >7220,>8C0A,>2700   3          >33
        DATA >10C5,>24F8,>4100   4          >34
        DATA >FA0F,>020A,>2700   5          >35
        DATA >3908,>3C8A,>2700   6          >36
        DATA >F821,>0841,>0400   7          >37
        DATA >7228,>9C8A,>2700   8          >38
        DATA >7228,>9E08,>4E00   9          >39
        DATA >0002,>0020,>0000   COLON      >3A
        DATA >0002,>0020,>8400   ;          >3B
        DATA >1084,>2040,>8100   <          >3C
        DATA >000F,>80F8,>0000   =          >3D
        DATA >4081,>0210,>8400   >          >3E
        DATA >7221,>0820,>0200   ?          >3F
        DATA >722B,>AABA,>0780   @          >40
        DATA >7228,>BE8A,>2880   A          >41
        DATA >F124,>9C49,>2F00   B          >42
        DATA >7228,>2082,>2700   C          >43
        DATA >F124,>9249,>2F00   D          >44
        DATA >FA08,>3C82,>0F80   E          >45
        DATA >FA08,>3C82,>0800   F          >46
        DATA >7A08,>209A,>2780   G          >47
        DATA >8A28,>BE8A,>2880   H          >48
        DATA >7082,>0820,>8700   I          >49
        DATA >0820,>820A,>2700   J          >4A
        DATA >8A4A,>30A2,>4880   K          >4B
        DATA >8208,>2082,>0F80   L          >4C
        DATA >8B6A,>AA8A,>2880   M          >4D
        DATA >8A2C,>AA9A,>2880   N          >4E
        DATA >FA28,>A28A,>2F80   O          >4F
        DATA >F228,>BC82,>0800   P          >50
        DATA >7228,>A2AA,>4680   Q          >51
        DATA >F228,>BCA2,>4880   R          >52
        DATA >7228,>1C0A,>2700   S          >53
        DATA >F882,>0820,>8200   T          >54
        DATA >8A28,>A28A,>2700   U          >55
        DATA >8A28,>9450,>8200   V          >56
        DATA >8A28,>AAAA,>A500   W          >57
        DATA >8A25,>0852,>2880   X          >58
        DATA >8A25,>0820,>8200   Y          >59
        DATA >F821,>0842,>0F80   Z          >5A
        DATA >3882,>0820,>8380   [          >5B
        DATA >0204,>0810,>2000   \          >5C
        DATA >7041,>0410,>4700   ]          >5D
        DATA >2148,>8000,>0000   ^          >5E
        DATA >0000,>0000,>0F80   _          >5F
        DATA >4081,>0000,>0000   `          >60
        DATA >0007,>22FA,>2880   a          >61
        DATA >000F,>1271,>2F00   b          >62
        DATA >0007,>A082,>0780   c          >63
        DATA >000F,>1249,>2F00   d          >64
        DATA >000F,>20E2,>0F00   e          >65
        DATA >000F,>20E2,>0800   f          >66
        DATA >0007,>A0BA,>2700   g          >67
        DATA >0008,>A2FA,>2880   h          >68
        DATA >0007,>0820,>8700   i          >69
        DATA >0007,>0822,>8E00   j          >6A
        DATA >0009,>28C2,>8900   k          >6B
        DATA >0008,>2082,>0F80   l          >6C
        DATA >0008,>B6AA,>2880   m          >6D
        DATA >0008,>B2AA,>6880   n          >6E
        DATA >000F,>A28A,>2F80   o          >6F
        DATA >000F,>22F2,>0800   p          >70
        DATA >000F,>A2AA,>4E80   q          >71
        DATA >000F,>22F2,>8900   r          >72
        DATA >0007,>A070,>2F00   s          >73
        DATA >000F,>8820,>8200   t          >74
        DATA >0004,>9249,>2300   u          >75
        DATA >0008,>A292,>8400   v          >76
        DATA >0008,>A2AB,>6880   w          >77
        DATA >0008,>9421,>4880   x          >78
        DATA >0008,>9420,>8200   y          >79
        DATA >000F,>8421,>0F80   z          >7A
        DATA >3104,>2041,>0300   {          >7B
        DATA >2082,>0020,>8200   |          >7C
        DATA >6041,>0210,>4600   }          >7D
        DATA >42A1,>0000,>0000   ~          >7E
        DATA >8DDB,>F7DF,>FDFF   DEL        >7F

*911 VDT-type graphics set.

        DATA >0000,>0000,>001C              >80
        DATA >0000,>0000,>071C              >81
        DATA >0000,>0001,>C71C              >82
        DATA >0000,>0071,>C71C              >83
        DATA >0000,>1C71,>C71C              >84
        DATA >0007,>1C71,>C71C              >85
        DATA >01C7,>1C71,>C71C              >86
        DATA >71C7,>1C71,>C71C              >87
        DATA >7A1B,>69B6,>1780  COPYRIGHT   >88
        DATA >A95A,>95A9,>5A95  CHECKED BLK >89
        DATA >0007,>DF7D,>C71C              >8A
        DATA >71CF,>3CF1,>C71C              >8B
        DATA >000F,>FFFD,>C71C              >8C
        DATA >71C7,>DF7C,>0000              >8D
        DATA >0C61,>0821,>0C20              >8E
        DATA >03F0,>0003,>F000              >8F
        DATA >0008,>2080,>0000              >90
        DATA >000C,>30C0,>0000              >91
        DATA >000E,>38E0,>0000              >92
        DATA >000F,>3CF0,>0000              >93
        DATA >000F,>BEF8,>0000              >94
        DATA >000F,>FFFC,>0000              >95
        DATA >3124,>1C41,>0B80  POUND       >96
        DATA >0007,>1C70,>0000              >97
        DATA >71CF,>FFFD,>C71C              >98
        DATA >FFFF,>FFFF,>FFFF              >99
        DATA >000F,>3CF1,>C71C              >9A
        DATA >71C7,>DF7D,>C71C              >9B
        DATA >71CF,>FFFC,>0000              >9C
        DATA >71CF,>3CF0,>0000              >9D
        DATA >8304,>0820,>4183              >9E
        DATA >8A28,>A28A,>28A2              >9F

*Special character set.

        DATA >21CA,>8820,>8200  UP ARROW    >A0
        DATA >2082,>08A9,>C200  DOWN ARROW  >A1
        DATA >0081,>3E10,>8000  RIGHT ARROW >A2
        DATA >0084,>3E40,>8000  LEFT ARROW  >A3
        DATA >00E1,>8A42,>0000  N.E. ARROW  >A4
        DATA >0021,>28C3,>8000  S.W. ARROW  >A5
        DATA >0204,>0A18,>E000  S.E. ARROW  >A6
        DATA >038C,>2810,>2000  N.W. ARROW  >A7
        DATA >21C2,>2AA9,>C000  ANCHOR      >A8

* Stuff to initialize

INITSRC EQU $
        DATA 0           VMODE
        DATA 0           F$SHOW
        DATA 0           F$ROW

        BL @LOADER       Load VDP registers.
        BYTE >00,>80+R0  Text mode, external video off.
        BYTE >90,>80+R1  16K, no display, no interrupt, text, size & mag=0.
        BYTE >01,>80+R2  PNTBA=>400. Screen image table.
        BYTE >01,>80+R4  PGTBA=>800. Pattern descriptor table.
        BYTE >00,>80+R7  Foreground/background colours.
        DATA 0

        B @STXTR2        Jump back to original code location.


        BL @LOADER       Load VDP registers.
        BYTE >02,>80+R0  Graphics 2 mode, external video off.
        BYTE >80,>80+R1  16K, no display, no interrupt, graphics 2, size & mag=0.
        BYTE >06,>80+R2  PNTBA=>1800. Screen image table.
        BYTE >FF,>80+R3  CTBA=>2000. Colour table.
        BYTE >03,>80+R4  PGTBA=>0000. Pattern descriptor table.
        BYTE >36,>80+R5  SNTBA=>1B00. Sprite name table.
        BYTE >07,>80+R6  SPGBA=>3800. Sprite pattern generator (descriptor) table.
        BYTE >00,>80+R7  Backdrop=background colour.
        DATA 0

        B @SGRAR2        Jump back to original code location.

* End of stuff copied to RAM

VDPINIC EQU $
*                        Copy INITSRC to INITDST to setup initial RAM
        LI R1,INITSRC    Address of data/code in EPROM.
        LI R2,INITDST    Address of where data/code is to go in RAM.
CPYDATA MOV *R1+,*R2+    Copy data/code.
        CI  R2,TMPBUF    Done? (Address of word immediately after block of data/code in RAM.)
        JL  CPYDATA

*                        Clear out the RAM that is supposed to be zero
        LI R2,CLR2HRE    Address of current workspace at end of PRAM.
CLRDATA DECT R2          Work down through PRAM towards the interpreter code.
        CLR *R2          Clear RAM.
        CI R2,BRAMCLR    Reached the end of the interpreter?
        JH CLRDATA       No, loop.

*                        Copy patterns from ROM to RAM
        LI R1,PCHTBI     Address of initial set of patterns.
        LI R2,PCHTB      Address of working set of patterns.

CPYPTRN MOV *R1+,*R2+    Copy patterns.
        CI R2,USERCS     Done?
        JL CPYPTRN       No, loop.

        B @STXT          This will RTWP at the end

START   LWPI WPR1        Load workspace pointer. 
        BLWP @VDPINIV
        MOV @MSGPTR, @STRPTR
        BLWP @VDPSTRV
        DATA >2FC0       Breakpoint??

MSGPTR  DATA MSG
MSG     TEXT 'SCOTT WAS HERE'
        BYTE CR,LF
        TEXT 'SECOND LINE'
        BYTE 0

        END