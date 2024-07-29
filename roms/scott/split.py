import sys

interleaved = sys.stdin.buffer.read()

even = bytearray()
odd = bytearray()
for i in range(0, int(len(interleaved)/2)):
    even.append(interleaved[i*2])
    odd.append(interleaved[i*2+1])

open(sys.argv[1], "wb" ).write(even)
open(sys.argv[2], "wb" ).write(odd)

