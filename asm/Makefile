all: forth.obj tibug.obj cortexbasic.obj ide.obj

forth.obj: forth.asm
	../asm990/asm990/asm990 -o forth.obj -l forth.lst forth.asm

tibug.obj: tibug.asm
	../asm990/asm990/asm990 -o tibug.obj -l tibug.lst tibug.asm

cortexbasic.obj: cortexbasic.asm
	../asm990/asm990/asm990 -o cortexbasic.obj -l cortexbasic.lst cortexbasic.asm

ide.obj: ide.asm
	../asm990/asm990/asm990 -o ide.obj -l ide.lst ide.asm

clean:
	rm -f *.obj *.lst

