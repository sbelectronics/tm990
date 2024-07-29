import sys

inb = sys.stdin.buffer.read()
outb = bytearray()

def sb(b):
    return (b * 0x0202020202 & 0x010884422010) % 1023

for b in inb:
    outb.append(sb(b))

sys.stdout.buffer.write( outb )
