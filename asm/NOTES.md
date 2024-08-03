Forth Notes

DEFINITIONS - sets CURRENT to CONTEXT
CURRENT is a variable in RAM that has the current dictionary.
  CURRENT @ - points to vocabulary
  CURRENT @ @ - is latest

We could fix it by:
  * ALLOT 2 bytes
  * put LATEST in these two bytes
  * set CURRENT and CONTEXT to latest (be careful because changing current will change latest)

  * HERE HERE HERE 2 ALLOT LATEST SWAP ! CURRENT ! CONTEXT !

The right way?
  Put two words in RAM
    FORLNK: DATA 81A0
    FORVOC: DATA VLINK
  Rewrite forth word as
    DATA DOCOL,LIT,FORVOC,CONT,STORE,SEMIS 