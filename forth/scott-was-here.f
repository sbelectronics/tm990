( Anthropic Claude-3.5.-Sonnet )

HEX

( Wait for Address Load bit to be set )
: WAIT-ALD ( -- )
  BEGIN EFA4 C@ 1 AND UNTIL ;

( Speak a single phoneme )
: SPEAK-PHONEME ( phoneme -- )
  WAIT-ALD
  EFB4 C! ;

( Unmute the amplifier )
: UNMUTE ( -- )
  1 EFB8 C! ;

( Speak the phrase "scott was here" )
: SCOTT-WAS-HERE ( -- )
  UNMUTE
  37 SPEAK-PHONEME  ( /SS/ )
  2A SPEAK-PHONEME  ( /KK1/ )
  18 SPEAK-PHONEME  ( /AA/ )
  11 SPEAK-PHONEME  ( /TT1/ )
  2E SPEAK-PHONEME  ( /WW/ )
  1E SPEAK-PHONEME  ( /UH/ )
  2B SPEAK-PHONEME  ( /ZZ/ )
  39 SPEAK-PHONEME  ( /HH2/ )
  13 SPEAK-PHONEME  ( /IY/ )
  27 SPEAK-PHONEME  ( /RR2/ )
  00 SPEAK-PHONEME  ( PA1 pause )
;

SCOTT-WAS-HERE
