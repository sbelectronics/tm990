# U42 is low byte, U44 is high byte

OBJ2BIN=../../python/obj2bin.py

all: copyin build/multi-high.rom

build/multi.rom: build/monitor.rom build/basic.rom
	dd if=build/monitor.rom of=build/multi-tmp.rom
	dd if=build/basic.rom of=build/multi-tmp.rom oflag=append conv=notrunc
	#cp build/multi-tmp.rom build/multi.rom
	python3 ./bitswap.py < build/multi-tmp.rom > build/multi.rom

build/multi-high.rom: build/multi.rom
	cat build/multi.rom | python3 ./split.py build/multi-low.rom build/multi-high.rom
	cp build/multi-high.rom build/00-multi-high.rom
	cp build/multi-low.rom build/00-multi-low.rom

build/seq.bin:
	mkdir -p build
	python3 ./seq.py > build/seq.bin

build/monitor.rom: build/seq.bin
	cp build/seq.bin build/monitor.rom
	#head -c 65536 /dev/zero | sed 's/\x00/\x33/g' > build/monitor.rom
	python3 ./combine.py build/tibug-u42.bin build/tibug-u44.bin > build/tibug-combined.bin
	dd if=build/tibug-combined.bin of=build/monitor.rom seek=0 bs=1 conv=notrunc

build/basic.rom: build/seq.bin
	cp build/seq.bin build/basic.rom
	$(OBJ2BIN) < build/basic.obj > build/basic.bin
	dd if=build/basic.bin of=build/basic.rom seek=0 bs=1 conv=notrunc

copyin:
	mkdir -p build
	cp ../tm990-401-3/tibug*.bin build/
	cp '../basic/TM990_101 EPROM Data 0000 - 3FFF.obj' build/basic.obj

clean:
	rm -f build/*.rom build/*.bin build/*.hex
