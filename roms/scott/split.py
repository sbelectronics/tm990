import sys

interleaved = sys.stdin.buffer.read()

low = bytearray()
high = bytearray()
for i in range(0, int(len(interleaved)/2)):
    low.append(interleaved[i*2])
    high.append(interleaved[i*2+1])

open(sys.argv[1], "wb" ).write(low)
open(sys.argv[2], "wb" ).write(high)

