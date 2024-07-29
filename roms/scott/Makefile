build/multi.rom: build/monitor.rom build/basic.rom build/basic2.rom build/basic3.rom build/basic4.rom
	dd if=build/monitor.rom of=build/multi-tmp.rom
	dd if=build/basic.rom of=build/multi-tmp.rom oflag=append conv=notrunc
	dd if=build/basic2.rom of=build/multi-tmp.rom oflag=append conv=notrunc
	dd if=build/basic3.rom of=build/multi-tmp.rom oflag=append conv=notrunc
	dd if=build/basic4.rom of=build/multi-tmp.rom oflag=append conv=notrunc
	python3 ./bitswap.py < build/multi-tmp.rom > build/multi.rom

build/multi-high.rom: build/multi.rom
	cat build/multi.rom | python3 ./split.py build/multi-high.rom build/multi-low.rom

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
	hex2bin.py build/basic1-low.hex build/basic1-low.bin
	hex2bin.py build/basic1-high.hex build/basic1-high.bin
	hex2bin.py build/basic2-low.hex build/basic2-low.bin
	hex2bin.py build/basic2-high.hex build/basic2-high.bin	
	hex2bin.py build/basic3-low.hex build/basic3-low.bin
	hex2bin.py build/basic3-high.hex build/basic3-high.bin
	hex2bin.py build/basic4-low.hex build/basic4-low.bin
	hex2bin.py build/basic4-high.hex build/basic4-high.bin	
	python3 ./combine.py build/basic1-high.bin build/basic1-low.bin > build/basic1-combined.bin
	python3 ./combine.py build/basic2-high.bin build/basic2-low.bin > build/basic2-combined.bin
	python3 ./combine.py build/basic3-high.bin build/basic3-low.bin > build/basic3-combined.bin
	python3 ./combine.py build/basic4-high.bin build/basic4-low.bin > build/basic4-combined.bin
	dd if=build/basic1-combined.bin of=build/basic.rom seek=0 bs=1 conv=notrunc
	dd if=build/basic2-combined.bin of=build/basic.rom seek=4096 bs=1 conv=notrunc
	dd if=build/basic3-combined.bin of=build/basic.rom seek=8192 bs=1 conv=notrunc
	dd if=build/basic4-combined.bin of=build/basic.rom seek=12288 bs=1 conv=notrunc

build/basic2.rom: build/seq.bin
	cp build/seq.bin build/basic2.rom
	python3 ./basload.py
	dd if=build/basload.bin of=build/basic2.rom seek=0 bs=1 conv=notrunc

build/basic3.rom: build/seq.bin
	cp build/seq.bin build/basic3.rom
	python3 ./basload3.py
	dd if=build/basload3.bin of=build/basic3.rom seek=0 bs=1 conv=notrunc

build/basic4.rom: build/seq.bin
	cp build/seq.bin build/basic4.rom
	python3 ./listload.py
	dd if=build/listload.bin of=build/basic4.rom seek=0 bs=1 conv=notrunc

copyin:
	mkdir -p build
	cp ../tm990-401-3/tibug*.bin build/
	cp ../basic/development_basic_u42.2716 build/basic1-high.hex
	cp ../basic/development_basic_u44.2716 build/basic1-low.hex
	cp ../basic/development_basic_u45.2716 build/basic2-high.hex
	cp ../basic/development_basic_u43.2716 build/basic2-low.hex
	cp ../basic/u17.2716 build/basic3-high.hex
	cp ../basic/u15.2716 build/basic3-low.hex
	cp ../basic/u16.2716 build/basic4-high.hex
	cp ../basic/u14.2716 build/basic4-low.hex


clean:
	rm -f build/*.rom build/*.bin build/*.hex
