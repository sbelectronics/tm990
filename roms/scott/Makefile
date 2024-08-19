# U42 is low byte, U44 is high byte

OBJ2BIN=../../python/obj2bin.py

all: copyin build/multi-high.rom

build/multi.rom: build/monitor.rom build/monitor-orig.rom build/basic.rom build/forth.rom build/cortexbasic.rom build/vdptest.rom
	dd if=build/monitor-orig.rom of=build/multi.rom                                        # Bank 0
	dd if=build/forth.rom of=build/multi.rom oflag=append conv=notrunc                     # Bank 1
	dd if=build/basic.rom of=build/multi.rom oflag=append conv=notrunc                     # Bank 2
	dd if=build/cortexbasic.rom of=build/multi.rom oflag=append conv=notrunc               # Bank 3
	dd if=build/vdptest.rom of=build/multi.rom oflag=append conv=notrunc	               # Bank 4

build/multi-high.rom: build/multi.rom
	cat build/multi.rom | python3 ./split.py build/multi-low.rom build/multi-high.rom
	cp build/multi-high.rom build/00-multi-high.rom
	cp build/multi-low.rom build/00-multi-low.rom

build/seq.bin:
	mkdir -p build
	python3 ./seq.py > build/seq.bin

build/monitor-orig.rom: build/seq.bin
	cp build/seq.bin build/monitor-orig.rom
	python3 ./combine.py build/tibug-u42.bin build/tibug-u44.bin > build/tibug-combined.bin
	dd if=build/tibug-combined.bin of=build/monitor-orig.rom seek=0 bs=1 conv=notrunc

build/monitor.rom: build/seq.bin
	cp build/seq.bin build/monitor.rom
	$(OBJ2BIN) < ../../asm/tibug.obj > build/tibug.bin
	$(OBJ2BIN) -S 1000 < ../../asm/ide.obj > build/ide.bin
	dd if=build/tibug.bin of=build/monitor.rom seek=0 bs=1 conv=notrunc
	dd if=build/ide.bin of=build/monitor.rom seek=4096 bs=1 conv=notrunc

build/basic.rom: build/seq.bin
	cp build/seq.bin build/basic.rom
	$(OBJ2BIN) < build/basic.obj > build/basic.bin
	dd if=build/basic.bin of=build/basic.rom seek=0 bs=1 conv=notrunc

build/forth.rom: build/monitor.rom
	cp build/monitor.rom build/forth.rom
	$(OBJ2BIN) -S 2000 < ../../asm/forth.obj > build/forth.bin
	dd if=build/forth.bin of=build/forth.rom seek=8192 bs=1 conv=notrunc

build/cortexbasic.rom: build/monitor.rom
	cp build/monitor.rom build/cortexbasic.rom
	$(OBJ2BIN) -S 2000 < ../../asm/cortexbasic.obj > build/cortexbasic.bin
	dd if=build/cortexbasic.bin of=build/cortexbasic.rom seek=8192 bs=1 conv=notrunc

build/vdptest.rom: build/monitor.rom
	cp build/monitor.rom build/vdptest.rom
	$(OBJ2BIN) -S 2000 < ../../asm/vdp.obj > build/vdptest.bin
	dd if=build/vdptest.bin of=build/vdptest.rom seek=8192 bs=1 conv=notrunc

copyin:
	mkdir -p build
	cp ../tm990-401-3/tibug*.bin build/
	cp '../basic/TM990_101 EPROM Data 0000 - 3FFF.obj' build/basic.obj

clean:
	rm -f build/*.rom build/*.bin build/*.hex build/*.obj
