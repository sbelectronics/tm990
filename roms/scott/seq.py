import sys

interleaved = bytearray()

for i in range(0,32768):
    interleaved.append((i*2) >> 8)
    interleaved.append((i*2) & 0xFF)

sys.stdout.buffer.write( interleaved )
