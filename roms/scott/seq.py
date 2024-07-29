import sys

interleaved = bytearray()

for i in range(0,32768):
    low = (i*2) & 0xFF
    high = (i*2) >> 8
    interleaved.append(low)
    interleaved.append(high)

sys.stdout.buffer.write( interleaved )
