all: forth.obj tibug.obj

forth.obj: forth.asm
	../asm990/asm990/asm990 -o forth.obj -l forth.lst forth.asm

tibug.obj: tibug.asm
	../asm990/asm990/asm990 -o tibug.obj -l tibug.lst tibug.asm

clean:
	rm -f forth.obj tibug.obj *.lst

